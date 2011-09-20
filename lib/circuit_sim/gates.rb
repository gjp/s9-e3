module CircuitSim
  class Gate

    def initialize(&callback)
      @action = callback
    end

    def execute(*a)
      @action.call(*a)
    end

    def binary?
      @action.arity == 2
    end

    def unary?
      @action.arity == 1
    end

  end

  GATES = {
    "AND"  => Gate.new { |a,b| a & b },
    "OR"   => Gate.new { |a,b| a | b },
    "XOR"  => Gate.new { |a,b| a ^ b },
    "NOT"  => Gate.new { |a| !a },
    "NAND" => Gate.new { |a,b| !(a & b) },
    "NOR"  => Gate.new { |a,b| !(a | b) },
    "XNOR" => Gate.new { |a,b| !(a ^ b) }
  }

end
