-- Week 2, Activity 12:
-- a) Change the definition of numeral so that it can match floating-point
--    numbers like 0.1 and 13.25. It is up to you whether the syntax would also
--    accept things like 0. or .5 (You probably won't need to change anything in
--    the captures for this feature as all operations we used naturally handle
--    floats)
--
-- b) Add scientific notation ("E notation") to the previous definition, so that
--    we can write numbers like 0.5E-3 and 123e12 (Again, you probably won't
--    need to change anything in the captures)

local lpeg = require "lpeg"
local pt = require "pt"
local loc = lpeg.locale()

--------------------------------------------------------------------------------
-- FRONTEND: PARSER
-- Our frontend is a parser that gets a source code as input and produces an
-- intermediate representation of the program in an AST
--------------------------------------------------------------------------------
-- Initial patterns:
local spc = loc.space^0
local vazio = -lpeg.P(1)
local sinal = lpeg.S("+")^-1
local menosUnario = lpeg.P("-") * spc
local numsci = (lpeg.S("Ee") * sinal * loc.digit^1)^-1 * spc
local dot = lpeg.P(".")^-1
local numeral = ((sinal * loc.digit^1 * dot * loc.digit^0) +
                 (dot * loc.digit^1)) * numsci * spc
local hexdig = lpeg.R("AF", "af", "09")
local hexpre = lpeg.P("0") * lpeg.S("Xx")
local hextot = sinal * hexpre * hexdig^1 * spc
local opAS = lpeg.C(lpeg.S("+-")) * spc
local opMD = lpeg.C(lpeg.S("*/%")) * spc
local opE = lpeg.C(lpeg.P("^")) * spc
local lt = lpeg.C(lpeg.P("<")) * spc
local lte = lpeg.C(lpeg.P("<=")) * spc
local gt = lpeg.C(lpeg.P(">")) * spc
local gte = lpeg.C(lpeg.P(">=")) * spc
local eq = lpeg.C(lpeg.P("==")) * spc
local neq = lpeg.C(lpeg.P("!=")) * spc
local opRel = (lte + gte + lt + gt + eq + neq) * spc
local OP = lpeg.P("(") * spc
local CP = lpeg.P(")") * spc


-- Function that get's a number and return a node of AST
function node(numero)
   return {
      tag = "numero",
      val = numero
   }
end


-- What is a number? Note that an AST node is returned
local decnum = (numeral / tonumber) / node * spc
local hexnum = (hextot / tonumber) / node * spc
local numero = spc * (hexnum + decnum) * spc


-- Function to fold a list and convert the list to an AST:
-- input: list: {n1, "+", n2, "+", n3, ...}
-- output: AST: {...{ op = "+", e1 = {op = "+", e1 = n1, e2 = n2}, e2 = n3}...}

-- foldBinEsq = operators with left-associativity
local function foldBinEsq(list)
   local tree = list[1]
   for i = 2, #list, 2 do
      tree = { tag = "binop", e1 = tree, op = list[i], e2 = list[i + 1] }
   end
   return tree
end

-- foldBinDir = operator with right-associativity
local function foldBinDir(list)
   local tree = list[#list]
   for i = #list - 1, 2, -2 do
      tree = { tag = "binop", e1 = list[i - 1], op = list[i], e2 = tree }
   end
   return tree
end

-- Unary minus
local function fold_menos_unario(numero)
   return { tag = "menos_unario" , op = numero }
end


-- Our grammar for mathematic expression:
local factor = lpeg.V"factor"
local pot = lpeg.V"pot"
local term = lpeg.V"term"
local exp = lpeg.V"exp"
local rel = lpeg.V"rel"
local unary_minus = lpeg.V"unary_minus"

grammar = lpeg.P{"rel",
   factor = spc * numero + OP * exp * CP,
   pot = lpeg.Ct(spc * factor * (opE * factor)^0) / foldBinDir,
   unary_minus = (menosUnario * unary_minus / fold_menos_unario) + pot,
   term = lpeg.Ct(spc * unary_minus * (opMD * unary_minus)^0) / foldBinEsq,
   exp = lpeg.Ct(spc * term * (opAS * term)^0) / foldBinEsq,
   rel = lpeg.Ct(spc * exp * (opRel * exp)^0) / foldBinEsq
}
grammar = spc * grammar * vazio


-- The parser per si:
local function parse(input)
   return grammar:match(input)
end


--------------------------------------------------------------------------------
-- BACKEND: CODE GENERATOR
-- Our backend is a code generator that get's an AST and generate the final
-- output of the compiler
--------------------------------------------------------------------------------
-- Function to add opcodes:
local function addCode(state, op)
   local code = state.code
   code[#code + 1] = op
end

-- Operators:
local ops = {["+"] = "add", ["-"] = "sub",
             ["*"] = "mul", ["/"] = "div", ["%"] = "rem",
             ["^"] = "exp",
             ["<="] = "lte", [">="] = "gte", ["=="] = "eq", ["!="] = "ne",
             [">"] = "gt", ["<"] = "lt"}


-- Function to specify the operations by type (tag) of node:
local function codeExp(state, ast)
   if ast.tag == "numero" then
      addCode(state, "push")
      addCode(state, ast.val)
   elseif ast.tag == "binop" then
      codeExp(state, ast.e1)
      codeExp(state, ast.e2)
      addCode(state, ops[ast.op])
   elseif ast.tag == "menos_unario" then
      codeExp(state, ast.op)
      addCode(state, "inverter")
   else
      error("invalid tree")
   end
end


-- The compiler per si:
local function compile(ast)
   local state = { code = {} }
   codeExp(state, ast)
   return state.code
end


--------------------------------------------------------------------------------
-- INTERPRETER
-- Receives the intermediate code produced by the compiler and empty stack and,
-- when finished, leaves the result of the expression on the top of the stack.
--------------------------------------------------------------------------------
-- The interpreter:
local function run(code, stack)
   local pc = 1                   -- program counter
   local top = 0                  -- top of stack
   while pc <= #code do
      if code[pc] == "push" then
         pc = pc + 1
         top = top + 1
         stack[top] = code[pc]
      elseif code[pc] == "add" then
         stack[top - 1] = stack[top - 1] + stack[top]
         top = top - 1
      elseif code[pc] == "sub" then
         stack[top - 1] = stack[top - 1] - stack[top]
         top = top - 1
      elseif code[pc] == "mul" then
         stack[top - 1] = stack[top - 1] * stack[top]
         top = top - 1
      elseif code[pc] == "div" then
         stack[top - 1] = stack[top - 1] / stack[top]
         top = top - 1
      elseif code[pc] == "rem" then
         stack[top - 1] = stack[top - 1] % stack[top]
         top = top - 1
      elseif code[pc] == "exp" then
         stack[top - 1] = stack[top - 1] ^ stack[top]
         top = top - 1
      elseif code[pc] == "gte" then
         stack[top - 1] = (stack[top - 1] >= stack[top]) and 1 or 0
         top = top - 1
      elseif code[pc] == "lte" then
         stack[top - 1] = (stack[top - 1] <= stack[top]) and 1 or 0
         top = top - 1
      elseif code[pc] == "gt" then
         stack[top - 1] = (stack[top - 1] > stack[top]) and 1 or 0
         top = top - 1
      elseif code[pc] == "lt" then
         stack[top - 1] = (stack[top - 1] < stack[top]) and 1 or 0
         top = top - 1
      elseif code[pc] == "eq" then
         stack[top - 1] = (stack[top - 1] == stack[top]) and 1 or 0
         top = top - 1
      elseif code[pc] == "ne" then
         stack[top - 1] = (stack[top - 1] ~= stack[top]) and 1 or 0
         top = top - 1
      elseif code[pc] == "inverter" then
         stack[top] = -stack[top]
      else
         error("unknown instruction")
      end
      pc = pc + 1
   end
end


-- Tests:
-- Get's the source code (only a number for now):
local input = io.read("a")

-- The frontend (parser) generates as AST:
local ast = parse(input)
print(pt.pt(ast))

-- The backend (code generator) compiles AST to intermediate code:
local code = compile(ast)
print(pt.pt(code))

-- We run the interpreter passing as arguments the
-- intermediate code and the stack:
local stack = {}
run(code, stack)
print(stack[1])
