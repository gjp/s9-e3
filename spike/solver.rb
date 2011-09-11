require 'json'
require 'tsort'
require './chips'

class Solver
  include TSort
  include Chips

  attr_reader :nodes, :ordered_keys

  def initialize
    parse_input
    order_keys
    @chips = Chips::BASIC
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

  def gather_states(node_ids)
    node_ids.map{|id| @nodes[id]['state'] }
  end

  def solve
    @ordered_keys.each do |key|
      node = @nodes[key]
      node['state'] ||= chip(node['type'], gather_states(node['input']))
    end
  end

  def chip(type, input)
    puts "type: #{type} states: #{input}"
    c = @chips[type]
    raise Exception, "Chip: unknown type #{type}" unless c
    c.call(*input)
  end
end

s = Solver.new
p s.ordered_keys
s.solve
puts JSON.pretty_generate(s.nodes)
