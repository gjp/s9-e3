require "treetop"
Treetop.load "logic"

parser = LogicParser.new
parser.consume_all_input = false

in_list = ' in :a, :b '
out_list = ' out :a, :b '
gate = 'AND(:a, :b)'

simple_assignment =  ' :out = NOT(:a)'

complex_assignment = <<EOF
  :out = Or(
         And(:b, Not(:a)),
         And(:a, Not(:b))
        )
EOF

chip = <<EOF
chip My_XOR do
  in :a, :b
  out :out

  :out = Or(
         And(:b, Not(:a)),
         And(:a, Not(:b))
        )
end
EOF

out = parser.parse(chip)

if out
  p out
else
  p parser.failure_reason
end
