module Chips
  BASIC = 
  {
    "AND"  => Proc.new {|a,b| a & b},
    "OR"   => Proc.new {|a,b| a | b},
    "XOR"  => Proc.new {|a,b| a ^ b},
    "NOT"  => Proc.new {|a,b| a == 0 ? 1 : 1},
    "SINK" => Proc.new {|a| a }
  }
end
