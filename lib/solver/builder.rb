module CircuitSim
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
      build_circuit(@entry_circuit)

      locate_io_ports
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
 
    def build_circuit(name, path = '')
      @definitions[name].each_pair do |input, outputs|
        ns_input = Pin.new(path + input)
        outputs = *outputs

        outputs.each do |output|
          output = Pin.new(path + output)
          @circuit.wires[output] = ns_input
          build_subcircuit(ns_input) if input.include?('#')
        end
      end
    end

    def build_subcircuit(output)
      if GATES.include?(output.part)
        # Subcircuit gates are assigned the traditional A and B port names
        @circuit.wires[output] = [ Pin.new(output.path + 'A') ]

        if GATES[output.part].arity == 2
          @circuit.wires[output] << Pin.new(output.path + 'B')
        end

      elsif @definitions[output.part]
        build_circuit(output.part, output.path)

      else
        raise CircuitError, "Circuit #{output.name} referenced but not loaded"
      end
    end

  private

    def locate_io_ports
      @definitions[@entry_circuit].each do |input, output|
        @circuit.input_ports << input unless input.include?('#')
        @circuit.output_ports << output unless output.class == Array || output.include?('#')
      end
    end

    def order_keys
      @circuit.ordered_keys = tsort
    end

    def tsort_each_node(&block)
      @circuit.wires.each_key(&block)
    end

    def tsort_each_child(node, &block)
      return nil unless inputs = @circuit.wires[node]
      inputs = *inputs
      inputs.each(&block)
    end
  end
end
