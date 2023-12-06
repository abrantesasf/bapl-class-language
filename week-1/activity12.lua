-- Week 1, Activity 12
-- Captures

local lpeg = require "lpeg"



-- Simple capture:
p = lpeg.P("a")^0 * lpeg.C(lpeg.P(1))
print(p:match("aaaaaaabcd"))                 --> b

p = lpeg.P("a")^0 * lpeg.C(3)
print(p:match("aaaaaaabcd"))                 --> bcd

p = lpeg.P("a")^0 * lpeg.C(1) * 2 * lpeg.C(2)
print(p:match("aaX  bcd"))                   --> X	bc

-- Here the capture is being executed several times:
p = lpeg.C("a")^0
print(p:match("aaaa"))                       --> a  a  a  a

-- Here the capture is executed only 1 time:
p = lpeg.C(lpeg.P("a")^0)
print(p:match("aaaa"))                       --> aaaa

-- Here the capture is executed at most n times:
-- (several captures, not just only one)
p = lpeg.C("a")^-2
print(p:match("aaaa"))                       --> a  a

-- If there is no match, capture return the
-- index that capture stop:
p = lpeg.C("a")^-1
print(p:match("b"))                          --> 1

p = lpeg.C(lpeg.P("a")^-1)
print(p:match("a"))                          --> a
print(p:match("b"))                          --> " " (empty string)

-- Capture the current position
p = lpeg.P("a")^0 * lpeg.Cp() * "b"
print(p:match("aaab"))                       --> 4
