-- Week 1, Activity 18: Extending our Arithmetic Expressions
-- We'll extend our arithmetic expression processor to include
-- other operations.

local lpeg = require "lpeg"

espaco = lpeg.S(" \n\t")^0
vazio = -lpeg.P(1)
numero = (lpeg.R("09")^1 / tonumber) * espaco
operador = lpeg.C(lpeg.S("+-")) * espaco

soma = espaco * numero * (operador * numero)^0 * vazio

print(soma:match("12 - 43 + 45 - 90"))

function fold(lst)
   local acc = lst[1]
   for i = 2, #lst, 2 do
      if lst[i] == "+" then
         acc = acc + lst[i + 1]
      else
         acc = acc - lst[i + 1]
      end
   end
   return acc
end

local soma = espaco * lpeg.Ct(numero * (operador * numero)^0) / fold * vazio
local teste = "32 - 32 + 14 - 1"
print(teste)
print(soma:match(teste))
