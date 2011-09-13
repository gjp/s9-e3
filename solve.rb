$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "/lib"))
$: << '.'

require 'solver'
require 'options'

include Options

@options = {}
get_options

s = Solver.new(@options)
s.solve
puts s.outputs

s.truth_table if @options[:truth]
