subject = "birth date: 12/03/1980"
pattern = "(%d%d)/(%d%d)/(%d%d%d%d)"
d, m, y = string.match(subject, pattern)
print(d, m, y)

local lpeg = require "lpeg"
local p = lpeg.P("hello")

print(lpeg.match(p, "hello world"))
print(lpeg.match(p, "hy world"))

