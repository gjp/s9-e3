chip FullAdder do
  in :a, :b, :cin
  out :s, :cout

  xab   = XOR(:a, :b)
  :s    = XOR(xab, :cin)
  :cout = OR(AND(xab, :cin),
             AND(:a, :b))
end
