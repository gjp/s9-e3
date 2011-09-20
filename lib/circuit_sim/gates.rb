module CircuitSim
  GATES = {
    "AND"  => lambda {|a,b| a & b },
    "OR"   => lambda {|a,b| a | b },
    "XOR"  => lambda {|a,b| a ^ b },
    "NOT"  => lambda {|a| !a },
    "NAND" => lambda {|a,b| !(a & b) },
    "NOR"  => lambda {|a,b| !(a | b) },
    "XNOR" => lambda {|a,b| !(a ^ b) }
  }
end
