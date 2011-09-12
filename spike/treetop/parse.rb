require "treetop"
Treetop.load "logic"

parser = LogicParser.new
parser.consume_all_input = false

infile = File.read(ARGV[0])
out = parser.parse(infile)

if out
  p out
else
  p parser.failure_reason
end
