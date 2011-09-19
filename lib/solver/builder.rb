module CircuitSimulator
  class Builder
    include TSort

    attr_reader :circuit

    def self.build(params)
      new(params)
    end

    def initialize(params)
      @params = params
      @definitions = {}
      @circuit = Circuit.new
      @entry_circuit = @params[:circuit]

      parse_circuit_definitions
      locate_io_ports
      build_circuit(@entry_circuit)
      order_keys
    end

    def parse_circuit_definitions
      @params[:filenames].each do |filename|
        circuit_definition = JSON.parse(File.open(filename).read)

        name  = circuit_definition['name']
        parts = circuit_definition['parts']

        unless parts.is_a?(Hash)
          raise CircuitError, "Circuit #{name} does not contain a parts hash"
        end

        @definitions[name] = parts.freeze

        puts "Loaded circuit definition #{name}"
      end

      unless @definitions[@entry_circuit]
        raise CircuitError, "Top level circuit #{@entry_circuit} was not found" 
      end
    end

    # I adopted Steve Morris' input format (converted to JSON)
    # so the processing method is extremely similar

    def build_circuit(name, ns = '')
      @definitions[name].each_pair do |input, outputs|
        outputs = *outputs
        ns_input  = ns + input

        outputs.each do |output|
          ns_output = ns + output
          @circuit.wires[ns_output] = ns_input

          next unless input.include?('#') 

          circuit = referenced_circuit(ns_input)
          build_referenced_circuit(circuit, ns_input)
        end
      end
    end

    def build_referenced_circuit(circuit, input)
      if GATES.include?(circuit)
        # Basic gates will follow the naming convention of A and B for input ports
        # We do not care which is which; these gates are symmetrical

        @circuit.wires[input] = [input.chop + 'A']
        @circuit.wires[input] << input.chop + 'B' if GATES[circuit].arity == 2

      elsif @definitions[circuit]
        # Recurse to the referenced circuit, using this circuit's name as a namespace
        build_circuit(circuit, namespace(input))

      else
        raise CircuitError,
          "Circuit #{circuit} referenced but not loaded" unless @circuits[circuit]
      end
    end

  private

    def locate_io_ports
      unless @definitions[@entry_circuit]
        raise CircuitError, "Circuit #{@entry_circuit} referenced but not loaded"
      end

      @definitions[@entry_circuit].each do |input, output|
        @circuit.input_ports << input unless input.include?('#')
        @circuit.output_ports << output unless output.class == Array || output.include?('#')
      end
    end

    def referenced_circuit(name)
      # Return only the circuit or gate name
      # "FullAdder#1.XOR#1.Q" -> "XOR"
      name.split('.')[-2].split('#')[0]
    end

    def namespace(name)
      # Return everything but the final port name
      # "FullAdder#1.A" -> "FullAdder#1."
      name.split('.')[0..-2].join('.') + '.'
    end

    def order_keys
      @circuit.ordered_keys = tsort
    end

    def tsort_each_node(&block)
      @circuit.wires.each_key(&block)
    end

    def tsort_each_child(node, &block)
      return nil unless inputs = @circuit.wires[node]
      inputs = [inputs] unless inputs.is_a?(Array)
      inputs.each(&block)
    end
  end
end
