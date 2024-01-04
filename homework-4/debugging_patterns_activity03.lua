-- Week 4, Activity 03
-- Debugging pattern matching
--
-- Student: Abrantes Araújo Silva Filho


local lpeg = require "lpeg"


-- Supose we have this wrong pattern (c is after C in ASCII):
p = lpeg.P("a") * lpeg.P("b") * lpeg.R("cC")
print(p:match("abc"))                                  --> nil
print(p:match("abC"))                                  --> nil

-- Let's create a function that returns a match-time capture that
-- prints a message and return true (so it allways succeed):
local function I (msg)
   return lpeg.P(function () print(msg); return true end)
end

-- Now we can use this function to "trace" the pattern and see
-- where the error is:
p = I"A" * lpeg.P("a") * I"B" * lpeg.P("b") * I"C" * lpeg.R("cC") * I"D"
print(p:match("abc"))                                  --> A
                                                       --> B
                                                       --> C
                                                       --> nil

-- So we can see that the errer is between the C and D, and we can
-- isolate and debug the pattern that is wrong.
