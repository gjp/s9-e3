chip My_XOR do
  in :a, :b
  out :out

  :out = OR(
           AND(:b, NOT(:a)),
           AND(:a, NOT(:b))
         )
end
