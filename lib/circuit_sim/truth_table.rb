module CircuitSim
  class TruthTable

    def initialize(circuit)
      @circuit = circuit
      @table = []
    end

    def to_s
      format_table
    end

    def format_table
      compute_truth_table

      port_names = @circuit.all_ports.map do |port|
        port[0..2].ljust(3)
      end

      out = "\n" + port_names.join(' ')+ "\n"

      @table.each do |row|
        out << ' ' + row.map{|s| s ? 1 : 0}.join('   ') + "\n"
      end

      out
    end

    def compute_truth_table
      inputs = {}
      bits = @circuit.input_ports.size

      ( 0...(2**bits) ).each do |row|
        input_states = int_to_truths(row, bits)

        @circuit.input_ports.zip( input_states ).each do |i|
          inputs[i.first] = i.last
        end

        @circuit.solve_for(inputs)

        output_states = @circuit.output_ports.map do |port|
          @circuit.state[port]
        end

        @table << input_states + output_states
      end
    end

    def int_to_truths(i, bits)
      i.to_s(2).rjust(bits, '0').chars.map { |e| e == '1' }
    end
 
  end
end
