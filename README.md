# Academic Exercise: Digital Logic Simulator

_written by Gregory Parkhurst for Mendicant University core skills session #9_

version 0.1.0

This code is in pretty dire need of refactoring. Thus far I've focused on solidifying
basic features and adding a bit of error handling.

Example run commands and output:

`
> ruby solve.rb --circuit TwoBitAdder --input "Cin:0 A1:1 A2:0 B1:1 B2:0" circuits/*.json
Loaded circuit FullAdder
Loaded circuit MUX21
Loaded circuit TwoBitAdder

output: ["S1: false", "S2: true", "Cout: false"]

> ruby solve.rb --truth --circuit FullAdder circuits/*.json
Loaded circuit FullAdder
Loaded circuit MUX21
Loaded circuit TwoBitAdder

output: ["S: false", "Cout: false"]


 A  B  Cin  S  Cout
[0, 0, 0, 0, 0]
[0, 0, 1, 1, 0]
[0, 1, 0, 1, 0]
[0, 1, 1, 0, 1]
[1, 0, 0, 1, 0]
[1, 0, 1, 0, 1]
[1, 1, 0, 0, 1]
[1, 1, 1, 1, 1]
`
