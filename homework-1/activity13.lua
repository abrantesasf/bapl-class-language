-- Week 1, Activity 13:
-- Modify the previous exercise so that it returns all numerals in the subject
-- intercalated with the positions of the intercalated plus operators, like
-- this:
--       print(patt:match("12+13+25"))
--       --> 12 3 13 6 25

local lpeg = require "lpeg"

-- After some googling I found this useful reference:
-- LPeg: Parsing Grammars for Lua (https://www.inf.puc-rio.br/~roberto/lpeg)

-- Lexical Elements:
espaco = lpeg.S(" \n\t")^0
numero = lpeg.P("-")^-1 * lpeg.R("09")^1 * espaco
adisub = lpeg.S("+-") * espaco
muldiv = lpeg.S("*/") * espaco
parini = lpeg.P("(") * espaco
parfim = lpeg.P(")") * espaco

-- Pattern:
p = espaco * lpeg.C(numero) * (lpeg.Cp() * (adisub + muldiv) * lpeg.C(numero))^0

-- Some tests:
-- These must be OK:
print(p:match("12+13+25"))
print(p:match("12+13+25 XXX"))
print(p:match("12 + 13 +25"))
print(p:match("12 + 13 +25      XXXXX"))
print(p:match("12 - 13 -25"))
print(p:match("12 + 13 - -25"))
print(p:match("12+13+25       + 34  +               12345"))
print(p:match("100 + 200 + 100 + 400"))
-- These must FAIL:
print(p:match("+"))
