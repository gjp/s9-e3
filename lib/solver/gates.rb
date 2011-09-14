module CircuitSimulator
  module Gates
    BASIC = 
      {
      "AND"  => Proc.new {|a,b| a & b },
      "OR"   => Proc.new {|a,b| a | b },
      "XOR"  => Proc.new {|a,b| a ^ b },
      "NOT"  => Proc.new {|a,b| !a },
      "NAND" => Proc.new {|a,b| !(a & b) },
      "NOR"  => Proc.new {|a,b| !(a | b) },
      "XNOR" => Proc.new {|a,b| !(a ^ b) }
    }
  end
end
