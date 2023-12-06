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
numero = espaco * lpeg.P("-")^-1 * lpeg.R("09")^1 * espaco
adisub = espaco * lpeg.S("+-") * espaco
muldiv = espaco * lpeg.S("*/") * espaco
parini = espaco * lpeg.P("(") * espaco
parfim = espaco * lpeg.P(")") * espaco

-- Pattern:
p = lpeg.C(numero) * (lpeg.Cp() * adisub * lpeg.C(numero))^0

-- Tests:
-- These must be OK:
print(p:match("12+13+25"))
print(p:match("12 + 13 + 25"))
print(p:match("12+13+25       + 34  +               12345"))
print(p:match("100 + 200 + 100 + 400"))
-- These must FAIL:
print(p:match("+"))
