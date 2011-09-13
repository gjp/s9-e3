require 'json'
require 'tsort'
require_relative 'gates'
require_relative 'options'

class Solver
  include TSort
  include Gates
  include Options

  GATES = Gates::BASIC
 
  attr_reader :circuits, :wires, :ordered_keys

  def initialize
    @options = {}
    @circuits = {}
    @wires = {}
    @state = {}
    @input_ports = []
    @output_ports = []

    get_options

    @entry_circuit = @options[:circuit]
    raise RuntimeError, "No top level circuit specified" unless @entry_circuit

    @inputs = @options[:inputs]

    parse_circuit_definitions
    locate_io_ports
    build(@entry_circuit)
    order_keys

    dump_initial_state if @options[:verbose]
  end

  def parse_circuit_definitions
    ARGV.each do |filename|
      circuit = JSON.parse(File.open(filename).read)
      name = circuit['name']
      parts = circuit['parts']

      raise RuntimeError,
        "Circuit #{name} does not contain a parts hash" unless parts.is_a?(Hash)

      @circuits[name] = parts.freeze

      puts "Loaded circuit #{circuit['name']}"
    end
  end

  # This code started as a copy from Steve Morris and is still being integrated
  
  def build(name, prefix = '')
    @circuits[name].each_pair do |input, outputs|
      outputs = [outputs] unless outputs.is_a?(Array)

      outputs.each do |output|
        ns_output = prefix + output
        ns_input  = prefix + input
        @wires[ns_output] = ns_input

        next unless input.include?('#') # Next if no referenced circuit

        circuit = referenced_circuit(ns_input)

        if GATES.key?(circuit)
          # Add wires for a logic gate output and inputs
          @wires[ns_input] = [ns_input.chop + 'A']
          @wires[ns_input] << ns_input.chop + 'B' unless circuit == 'NOT'
        else
          raise RuntimeError,
            "Circuit #{circuit} referenced but not loaded" unless @circuits[circuit]

          # Add the referenced circuit with the full prefix
          build(circuit, namespace(ns_input))
        end
      end
    end
  end

  def solve
    # Look ma, no explicit recursion!
    # This solver relies on the builder to flatten nested inputs, and tsort
    # to provide the keys to the wire hash in the right order.
  
    @ordered_keys.each do |lexp|
      rexp = @wires[lexp]

      if rexp
        if rexp.is_a?(Array) # This is a gate. Reduce it.
          @state[lexp] = reduce_gate( referenced_circuit(lexp), gather_state(rexp) )

        else # This is a wire. Copy state.
          @state[lexp] = @state[rexp]
        end

      else # This is an input port.
        @state[lexp] = @inputs[lexp]
      end
    end
  end

  def gather_state(wires)
    wires.map{|id| @state[id] }
  end

  def reduce_gate(type, input)
    gate = GATES[type]
    raise RuntimeError, "Unknown gate type #{type}" unless gate
    gate.call(*input)
  end

  def compute_truth_table
    @truth_table = []
    bits = @input_ports.size

    (0...(2**bits)).each do |row|
      input_states = int_to_truths(row, bits)
      @input_ports.zip( input_states ).each do |i|
        @inputs[i.first] = i.last
      end

      solve
      @truth_table << input_states + @output_ports.map{|port| @state[port]}
    end
  end

  def truth_table
    compute_truth_table unless @truth_table

    puts "\n " + (@input_ports + @output_ports).join('  ')
    @truth_table.each do |row|
      p row.map{|x| x ? 1 : 0}
    end
  end

  def outputs
    o = @output_ports.map {|name| "#{name}: #{@state[name]}"}
    puts "\noutput: #{o}"
  end

private

 def locate_io_ports
    @circuits[@entry_circuit].each do |input, output|
      @input_ports << input unless input.include?('#')
      @output_ports << output unless output.class == Array || output.include?('#')
    end
  end

  #FIXME: These string manipulations are kind of ugly
  def referenced_circuit(name)
    name.split('.')[-2].split('#')[0]
  end

  def namespace(name)
    name.split('.')[0..-2].join('.') + '.'
  end

  def int_to_truths(i, bits)
    # Convert an integer to a true/false bit array. Based on a hack from JEG2
    Array.new(bits) { |bit| i[bit] == 1 ? true : false }.reverse!
  end

  def order_keys
    @ordered_keys = tsort
  end

  def tsort_each_node(&block)
    @wires.each_key(&block)
  end

  def tsort_each_child(node, &block)
    return nil unless inputs = @wires[node]
    inputs = [inputs] unless inputs.is_a?(Array)
    inputs.each(&block)
  end

  def dump_initial_state
    puts "\nInputs:"
    p @input_ports

    puts "\nOutputs:"
    p @output_ports
 
    puts "\nOrdered keys:"
    @ordered_keys.each {|id| puts "#{id} <- #{@wires[id]}" }

    puts
  end
end

s = Solver.new
s.solve
s.outputs
s.truth_table
