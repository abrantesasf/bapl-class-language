-- Week 1, Activity 15:
-- Modify the previous exercise so that it only succeeds if it matches the
-- whole subject.

local lpeg = require "lpeg"

-- Lexical Elements:
vazio = -lpeg.P(1)
espaco = lpeg.S(" \n\t")^0
numero = lpeg.P("-")^-1 * lpeg.R("09")^1 * espaco
adisub = lpeg.S("+-") * espaco
muldiv = lpeg.S("*/") * espaco
parini = lpeg.P("(") * espaco
parfim = lpeg.P(")") * espaco

-- Pattern:
p = lpeg.C(numero) * (lpeg.Cp() * adisub * lpeg.C(numero))^0 * vazio

-- Some tests:
-- These must be OK:
print(p:match("12+13+25"))
print(p:match("12 + 13 + 25"))
print(p:match("12+13+25       + 34  +               12345"))
print(p:match("100 + 200 + 100 + 400"))
-- These must FAIL:
print(p:match("+"))
print(p:match(" 12+13+25"))
print(p:match("12+13+25 "))
print(p:match(" 12 + 13 + 25 "))
