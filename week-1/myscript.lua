local lpeg = require "lpeg"

-- Equipara uma palavra seguida por end-of-string
p = lpeg.R"az"^1 * -1

print(p:match("hello"))
print(lpeg.match(p, "hello"))
print(p:match("1 hello"))
