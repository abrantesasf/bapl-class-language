-- Week 1, Activity 17:
-- Add an optional sign (+) or (-) to numerals.

local lpeg = require "lpeg"

-- Lexical Elements:
vazio = -lpeg.P(1)
espaco = lpeg.S(" \n\t")^0
sinal = lpeg.S("+-")
numero = lpeg.P(sinal)^-1 * lpeg.R("09")^1 * espaco
adisub = lpeg.S("+-") * espaco
muldiv = lpeg.S("*/") * espaco
parini = lpeg.P("(") * espaco
parfim = lpeg.P(")") * espaco

-- Pattern:
p = espaco * lpeg.C(numero) * (adisub * lpeg.C(numero))^0 * vazio

-- Some tests:
-- These must be OK:
print(p:match("12+13+25"))
print(p:match("12 + 13 + 25"))
print(p:match("12+13+25       + 34  +               12345"))
print(p:match("100 + 200 + 100 + 400"))
-- These with sign must be OK:
print(p:match("+12"))
print(p:match("-12"))
print(p:match("-12 + -13 + -25"))
print(p:match("  -12  +  +13   +  -25  "))
-- These must FAIL:
print(p:match("+"))
print(p:match(" 12+13+25abc"))
print(p:match("12+13+25abc"))
print(p:match(" 12 + 13abc + 25 "))
print(p:match("12 + - 13 + 35"))
print(p:match("12 + +-13 + 35"))
