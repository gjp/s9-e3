require 'json'
require 'tsort'
require './gates'

class Solver
  include TSort
  include Gates

  attr_reader :nodes, :ordered_keys, :truth_table

  def initialize
    @chips = Gates::BASIC
    parse_input
    order_keys
  end

  def parse_input
    @circuit = JSON.parse(File.open(ARGV[0]).read)
    @nodes = {}

    # Convert parsed JSON to a simple hash indexed by integer IDs
    @circuit.each do |node|
      n = node.first
      id = n.first.to_i
      @nodes[id] = n.last
    end
  end

  def solve
    @ordered_keys.each do |key|
      node = @nodes[key]
      next unless node['input']
      #puts "node #{key}"
      node['output'] = chip(node['type'], gather_states(node['input']))
    end
  end

  def chip(type, input)
    #puts " type: #{type} states: #{input}"
    c = @chips[type]
    raise Exception, "Chip: unknown type #{type}" unless c
    c.call(*input)
  end

  def compute_truth_table
    @truth_table = []
    bits = input_ids.size

    (0...(2**bits)).each do |row|
      input_states = int_to_truths(row, bits)
      input_ids.zip( input_states ).each do |i|
        @nodes[i.first]['output'] = i.last
      end

      solve
      @truth_table << input_states + output_states
    end
  end

private

  def input_ids
    @in_ids ||= nodes_by_type('IN')
  end

  def output_ids
    @out_ids ||= nodes_by_type('OUT')
  end

  def nodes_by_type(type)
    @ordered_keys.select{ |id| @nodes[id]['type'] == type }
  end

  def output_states
    output_ids.map{ |id| @nodes[id]['output'] }
  end

  def int_to_truths(i, bits)
    # Convert an integer to a true/false bit array
    # Based on a hack from JEG2
    Array.new(bits) { |bit| i[bit] == 1 ? true : false }.reverse!
  end

  def gather_states(node_ids)
    #puts " gather nodes #{node_ids}"
    node_ids.map{|id| @nodes[id]['output'] }
  end

  def order_keys
    @ordered_keys = tsort
  end

  def tsort_each_node(&block)
    @nodes.each_key(&block)
  end

  def tsort_each_child(node, &block)
    return nil unless input = @nodes[node]['input']
    input.each(&block)
  end
end

s = Solver.new
s.solve
puts JSON.pretty_generate(s.nodes)
s.compute_truth_table
p s.truth_table
