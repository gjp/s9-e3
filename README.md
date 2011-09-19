# Academic Exercise: Digital Logic Simulator

_written by Gregory Parkhurst for Mendicant University core skills session #9_

## What does this thing do?

circuitsim reads a set of digital logic definition files in JSON format and computes either the output for a given input or a truth table.

## How do I run it?

Example run commands and output:

```
> ruby bin/circuitsim.rb --circuit TwoBitAdder --input "Cin:0 A1:1 A2:0 B1:1 B2:0" lib/circuits/*.json
Loaded circuit FullAdder
Loaded circuit MUX21
Loaded circuit TwoBitAdder

output: ["S1: false", "S2: true", "Cout: false"]

> ruby bin/circuitsim.rb --truth --circuit FullAdder lib/circuits/*.json
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
```

## Issues

- Input format should be documented
- The circuit graph uses separate but similar data structures. These should be merged into a single structure with a new class as nodes

## Future Expansion

- A front-end for building the logic definition files
- A back-end for displaying a completed circuit and the state of each trace
