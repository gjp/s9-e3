module CircuitSim
  class Circuit

    attr_accessor :wires, :input_ports, :output_ports, :ordered_keys, :state
    attr_accessor :truth_table

    def initialize
      @wires = {}
      @state = {}
      @ordered_keys = []
      @truth_table = TruthTable.new(self)
    end

    def add_input_port(port)
      @input_ports ||= []
      @input_ports << port
    end

    def add_output_ports(port)
      @output_ports ||= []
      @output_ports << port
    end

    def add_wire(inputs, output)
      @wires[output] = inputs
    end

    def add_gate(inputs, output)
      @wires[output] ||= []
      @wires[output] << inputs
    end

    def all_ports
      @input_ports + @output_ports
    end

    def solve_for(inputs)
      # This solver relies on the builder to flatten nested inputs
      # and tsort to provide the keys to the wire hash in the right order.
      @ordered_keys.each do |lexp|
        rexp = @wires[lexp]

        if rexp
          if rexp.is_a?(Array) # This is a gate.
            @state[lexp.name] = execute_gate( lexp.part, gather_state(rexp) )

          else # This is a wire.
            @state[lexp.name] = @state[rexp]
          end

        else # This is an input port.
          @state[lexp.name] = inputs[lexp]
        end
      end
    end

    def output_for(inputs)
      solve_for(inputs)

      outputs = @output_ports.map do |name|
        "#{name}: #{@state[name]}"
      end.join(' ')

      "\noutput: #{outputs}"
    end

    def dump
      out  = "\nInputs:"
      out << input_ports.to_s + "\n"

      out << "\nOutputs:"
      out << output_ports.to_s + "\n"

      out << "\nOrdered keys:"
      out << @ordered_keys.map { |id| "#{id} <- #{@wires[id]}\n" }.join
    end

    private

    def gather_state(wires)
      wires.map{ |id| @state[id] }
    end

    def execute_gate(type, input)
      gate = GATES[type]
      raise CircuitError, "Unknown gate type #{type}" unless gate

      gate.execute(*input)
    end

  end
end
