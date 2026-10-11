import std/[os, sets, strutils, tables]

import serializeinteractions

type
    Rule = object
        negated: bool
        dirOnly: bool
        segments: seq[string]

var
    rulesCached: seq[Rule]
    trackedCached: HashSet[string]
    cacheReady = false

proc strip_dot_slash(path: string): string=
    if path == "." or path == "./":
        return ""
    if path.startsWith("./"):
        return path[2 .. ^1]
    return path

proc has_builtin(path: string): bool=
    for part in path.split("/"):
        if part == ".git" or part == ".Forrest":
            return true
    return false

proc trim_rule(line: string): string=
    var i = line.len - 1
    while i >= 0 and line[i] in {' ', '\t', '\r'}:
        var slashes = 0
        var j = i - 1
        while j >= 0 and line[j] == '\\':
            inc slashes
            dec j
        if (slashes mod 2) == 1:
            break
        dec i
    if i < 0:
        return ""
    return line[0 .. i]

proc has_unescaped_slash(body: string): bool=
    var i = 0
    while i < body.len:
        if body[i] == '\\' and i + 1 < body.len:
            i += 2
            continue
        if body[i] == '/':
            return true
        inc i
    return false

proc split_pattern(body: string): seq[string]=
    result = @[]
    var current = ""
    var i = 0
    while i < body.len:
        if body[i] == '\\' and i + 1 < body.len:
            current.add('\\')
            current.add(body[i + 1])
            i += 2
            continue
        if body[i] == '/':
            result.add(current)
            current = ""
            inc i
            continue
        current.add(body[i])
        inc i
    result.add(current)

proc parse_rule(raw: string): tuple[ok: bool, rule: Rule]=
    let line = trim_rule(raw)
    if line.len == 0 or line[0] == '#':
        return (false, Rule())
    var body = line
    var negated = false
    if body[0] == '!':
        negated = true
        body = if body.len == 1: "" else: body[1 .. ^1]
    if body.len == 0:
        return (false, Rule())
    var dirOnly = false
    if body[^1] == '/':
        var slashes = 0
        var j = body.len - 2
        while j >= 0 and body[j] == '\\':
            inc slashes
            dec j
        if (slashes mod 2) == 0:
            dirOnly = true
            body = if body.len == 1: "" else: body[0 .. ^2]
    if body.len == 0:
        return (false, Rule())
    var anchored = false
    if body[0] == '/':
        anchored = true
        body = if body.len == 1: "" else: body[1 .. ^1]
    elif has_unescaped_slash(body):
        anchored = true
    if body.len == 0:
        return (false, Rule())
    var segments = split_pattern(body)
    if not anchored:
        segments = @["**"] & segments
    return (true, Rule(negated: negated, dirOnly: dirOnly, segments: segments))

proc load_rules(): seq[Rule]=
    result = @[]
    if not fileExists("./.clearing"):
        return
    for raw in readFile("./.clearing").splitLines():
        let parsed = parse_rule(raw)
        if parsed.ok:
            result.add(parsed.rule)

proc ensure_cache()=
    if cacheReady:
        return
    trackedCached = initHashSet[string]()
    for key in return_forrest_as_table().keys():
        trackedCached.incl(key)
        trackedCached.incl(strip_dot_slash(key))
    rulesCached = load_rules()
    cacheReady = true

proc class_matches(pat: string, start: int, ch: char): tuple[parsed: bool, matched: bool, next: int]=
    var i = start + 1
    if i >= pat.len:
        return (false, false, start)
    var negated = false
    if pat[i] == '!' or pat[i] == '^':
        negated = true
        inc i
    var matched = false
    var saw = false
    while i < pat.len and pat[i] != ']':
        var lo = pat[i]
        if lo == '\\' and i + 1 < pat.len:
            lo = pat[i + 1]
            i += 2
        else:
            inc i
        if i < pat.len and pat[i] == '-' and i + 1 < pat.len and pat[i + 1] != ']':
            var hi = pat[i + 1]
            if hi == '\\' and i + 2 < pat.len:
                hi = pat[i + 2]
                i += 3
            else:
                i += 2
            if ch >= lo and ch <= hi:
                matched = true
            saw = true
        else:
            if ch == lo:
                matched = true
            saw = true
    if i >= pat.len or pat[i] != ']' or not saw:
        return (false, false, start)
    if negated:
        matched = not matched
    return (true, matched, i + 1)

proc match_one(pat, text: string, pi, ti: int): bool=
    if pi == pat.len:
        return ti == text.len
    if pat[pi] == '\\':
        if pi + 1 >= pat.len:
            return false
        if ti < text.len and text[ti] == pat[pi + 1]:
            return match_one(pat, text, pi + 2, ti + 1)
        return false
    if pat[pi] == '*':
        if match_one(pat, text, pi + 1, ti):
            return true
        if ti < text.len and match_one(pat, text, pi, ti + 1):
            return true
        return false
    if ti == text.len:
        return false
    if pat[pi] == '?':
        return match_one(pat, text, pi + 1, ti + 1)
    if pat[pi] == '[':
        let cls = class_matches(pat, pi, text[ti])
        if not cls.parsed:
            if text[ti] == '[':
                return match_one(pat, text, pi + 1, ti + 1)
            return false
        if not cls.matched:
            return false
        return match_one(pat, text, cls.next, ti + 1)
    if text[ti] == pat[pi]:
        return match_one(pat, text, pi + 1, ti + 1)
    return false

proc match_segments(pats, segs: seq[string], pi, si: int): bool=
    if pi == pats.len:
        return si == segs.len
    if pats[pi] == "**":
        if match_segments(pats, segs, pi + 1, si):
            return true
        if si < segs.len and match_segments(pats, segs, pi, si + 1):
            return true
        return false
    if si == segs.len:
        return false
    if not match_one(pats[pi], segs[si], 0, 0):
        return false
    return match_segments(pats, segs, pi + 1, si + 1)

proc rules_ignore(segs: seq[string], isDir: bool): bool=
    var ignored = false
    for rule in rulesCached:
        if rule.dirOnly and not isDir:
            continue
        if match_segments(rule.segments, segs, 0, 0):
            ignored = not rule.negated
    return ignored

proc is_clearing_ignored*(path: string, isDir: bool): bool=
    if has_builtin(path):
        return true
    ensure_cache()
    let stripped = strip_dot_slash(path)
    if trackedCached.contains(path) or trackedCached.contains(stripped):
        return false
    if stripped.len == 0:
        return false
    let segs = stripped.split("/")
    if segs.len > 1:
        for i in 0 ..< segs.len - 1:
            if rules_ignore(segs[0 .. i], true):
                return true
    return rules_ignore(segs, isDir)
