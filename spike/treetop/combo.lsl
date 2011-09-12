chip My_XOR do
  in :a, :b
  out :out

  :out = OR(
           AND(:b, NOT(:a)),
           AND(:a, NOT(:b))
         )
end

chip FullAdder do
  in :a, :b, :cin
  out :s, :cout

  xab   = XOR(:a, :b)
  :s    = XOR(xab, :cin)
  :cout = OR(AND(xab, :cin),
             AND(:a, :b))
end

chip TwoBitAdder do
  in  :cin, :a0, :b0, :a1, :b1
  out :s0, :s1, :cout

  :s0, a0out = FullAdder(:a0, :b0 :cin)
  :s1, :cout = FullAdder(:a1, :b1, a0out)
end
