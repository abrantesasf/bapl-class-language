-- Week 1, Activity 19:
-- Add a remainder (%) and exponential (^)

local lpeg = require "lpeg"
local pt = require "pt"

-- Lexical Elements:
vazio = -lpeg.P(1)
espaco = lpeg.S(" \n\t")^0
sinal = lpeg.S("+-")^-1
numero = ((sinal * lpeg.R("09")^1) / tonumber) * espaco
opAdd = lpeg.C(lpeg.S("+-")) * espaco
opMul = lpeg.C(lpeg.S("*/%")) * espaco
opExp = lpeg.C(lpeg.P("^")) * espaco

-- Fold function for exponentials
function foldexp(lst)
  local acc = lst[#lst]
  for i = #lst - 1, 2, -2 do
    acc = lst[i - 1] ^ acc
  end
  return acc
end

-- Fold function for multiplicative and additive operators
function fold(lst)
  local acc = lst[1]
  for i = 2, #lst, 2 do
    if lst[i] == "+" then
      acc = acc + lst[i + 1]
    elseif lst[i] == "-" then
      acc = acc - lst[i + 1]
    elseif lst[i] == "*" then
      acc = acc * lst[i + 1]
    elseif lst[i] == "/" then
      acc = acc / lst[i + 1]
    elseif lst[i] == "%" then
      acc = acc % lst[i + 1]
    elseif lst[i] == "^" then
      acc = acc ^ lst[i + 1]
    else
      error("unknown operator")
    end
  end
  return acc
end

-- Pattern:
local pot = espaco * lpeg.Ct(numero * (opExp * numero)^0) / foldexp
local term = espaco * lpeg.Ct(pot * (opMul * pot)^0) / fold
local sum = espaco * lpeg.Ct(term * (opAdd * term)^0) / fold * vazio

-- Some tests: These must be OK:
local teste = "-10 + 2 ^ 2 ^ 3 + 4 + 50"
local tabela = espaco * lpeg.Ct(numero * ((opMul + opAdd + opExp) * numero)^0) * vazio
print(teste)
print(pt.pt(tabela:match(teste)))
print(sum:match(teste))
