module CircuitSimulator
  class Circuit
    attr_accessor :wires, :input_ports, :output_ports, :ordered_keys, :state

    def initialize
      @wires = {}
      @input_ports = []
      @output_ports = []
      @ordered_keys = []
      @state = {}
    end

    def dump
      puts "\nInputs:"
      p @input_ports

      puts "\nOutputs:"
      p @output_ports

      puts "\nOrdered keys:"
      @ordered_keys.each {|id| puts "#{id} <- #{@wires[id]}" }

      puts
    end

    def solve_for(inputs)
      compute_output_for(inputs)

      outputs = @output_ports.map do |name|
        "#{name}: #{@state[name]}"
      end.join(' ')

      puts "\noutput: #{outputs}"
    end

    def truth_table
      compute_truth_table

      puts "\n " + (@input_ports + @output_ports).join('  ')
      @truth_table.each do |row|
        p row.map{|x| x ? 1 : 0}
      end
    end

    def compute_output_for(inputs)
      # This solver relies on the builder to flatten nested inputs, and tsort
      # to provide the keys to the wire hash in the right order.

      @ordered_keys.each do |lexp|
        rexp = @wires[lexp]

        if rexp
          if rexp.is_a?(Array) # This is a gate. Reduce it.
            @state[lexp] = gate_output( referenced_circuit(lexp), gather_state(rexp) )

          else # This is a wire. Copy state.
            @state[lexp] = @state[rexp]
          end

        else # This is an input port.
          @state[lexp] = inputs[lexp]
        end
      end
    end

    def referenced_circuit(name)
      # Return only the circuit or gate name
      # "FullAdder#1.XOR#1.Q" -> "XOR"
      name.split('.')[-2].split('#')[0]
    end

    def gather_state(wires)
      wires.map{|id| @state[id] }
    end

    def gate_output(type, input)
      gate = GATES[type]
      raise CircuitError, "Unknown gate type #{type}" unless gate

      gate.call(*input)
    end

    def compute_truth_table
      @truth_table = []
      inputs = {}
      bits = @input_ports.size

      (0...(2**bits)).each do |row|
        input_states = int_to_truths(row, bits)

        @input_ports.zip( input_states ).each do |i|
          inputs[i.first] = i.last
        end

        compute_output_for(inputs)

        @truth_table << input_states + @output_ports.map{|port| @state[port]}
      end
    end

    def int_to_truths(i, bits)
      # Convert an integer to a true/false bit array. Based on code from JEG2
      Array.new(bits) { |bit| i[bit] == 1 ? true : false }.reverse!
    end
  end
end
