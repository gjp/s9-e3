require_relative 'lib/solver'
require_relative 'lib/options'

include Options

@options = {}
get_options

s = Solver.new(@options)
s.solve
puts s.outputs

s.truth_table if @options[:truth]
