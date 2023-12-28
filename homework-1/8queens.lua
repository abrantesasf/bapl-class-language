-- Programming with Lua, Chapter 2

N = 8

-- Verifica se a posição (n, c) é livre de ataques
function isplaceok(a, n, c)
   for i = 1, n - 1 do             -- para cada rainha já colocada
      if (a[i] == c) or            -- mesma coluna?
         (a[i] - i == c - n) or    -- mesma diagonal
         (a[i] + i == c + n) then  -- mesma diagonal
         return false              -- a posição pode ser atacada!
      end
   end
   return true                     -- a posição é segura
end

-- Imprime o tabuleiro
function printsolution(a)
   for i = 1, N do                               -- para cada linha
      for j = 1, N do                            -- e para cada coluna
         io.write(a[i] == j and "X" or "-", " ") -- escreva X ou -
      end
      io.write("\n")
   end
   io.write("\n")
end

-- Adiciona ao tabuleiro "a" todas as rainhas de 'n' até 'N'
function addqueen(a, n)
   if n > N then                     -- todas as rainhas foram colocadas?
      printsolution(a)
   else                              -- tenta colocar n-ésima rainha
      for c = 1, N do
         if isplaceok(a, n, c) then
            a[n] = c                 -- coloca n-ésima rainha na coluna "c"
            addqueen(a, n + 1)
         end
      end
   end
end

-- Executa o programa
addqueen({}, 1)
