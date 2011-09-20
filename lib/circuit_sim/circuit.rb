module CircuitSim
  class Circuit
    attr_accessor :wires, :input_ports, :output_ports, :ordered_keys, :state

    def initialize
      @wires = {}
      @state = {}
      @input_ports = []
      @output_ports = []
      @ordered_keys = []
      @truth_table = []
    end

   def output_for(inputs)
      solve_for(inputs)

      outputs = @output_ports.map do |name|
        "#{name}: #{@state[name]}"
      end.join(' ')

      puts "\noutput: #{outputs}"
    end

    def truth_table
      compute_truth_table

      port_names = (@input_ports + @output_ports).map do |port|
        port[0..2].ljust(3)
      end

      puts "\n" + port_names.join(' ')

      @truth_table.each do |row|
        puts ' ' + row.map{|s| s ? 1 : 0}.join('   ')
      end
    end

    def dump
      puts "\nInputs:"
      p @input_ports

      puts "\nOutputs:"
      p @output_ports

      puts "\nOrdered keys:"
      @ordered_keys.each { |id| p "#{id} <- #{@wires[id]}" }
      puts
    end
 
    private

    def solve_for(inputs)
      # This solver relies on the builder to flatten nested inputs
      # and tsort to provide the keys to the wire hash in the right order.
      @ordered_keys.each do |lexp|
        rexp = @wires[lexp]

        if rexp
          if rexp.is_a?(Array) # This is a gate.
            @state[lexp.name] = gate_output( lexp.part, gather_state(rexp) )
          else # This is a wire.
            @state[lexp.name] = @state[rexp]
          end

        else # This is an input port.
          @state[lexp.name] = inputs[lexp]
        end
      end
    end

    def gather_state(wires)
      wires.map{ |id| @state[id] }
    end

    def gate_output(type, input)
      gate = GATES[type]
      raise CircuitError, "Unknown gate type #{type}" unless gate

      gate.call(*input)
    end

    def compute_truth_table
      inputs = {}
      bits = @input_ports.size

      ( 0...(2**bits) ).each do |row|
        input_states = int_to_truths(row, bits)

        @input_ports.zip( input_states ).each do |i|
          inputs[i.first] = i.last
        end

        solve_for(inputs)

        output_states = @output_ports.map{ |port| @state[port] }
        @truth_table << input_states + output_states
      end
    end

    def int_to_truths(i, bits)
      i.to_s(2).rjust(bits, '0').chars.map { |e| e == '1' }
    end
  end
end
