# Issues

Must support m inputs, n outputs for each chip
- Either input or output lists must refer not only to the chip, but the port
- Requires a 2-layer naming scheme or assumed order
- Remove IDs from output array and replace with output states?

Must support nested chips
- How to include the file and import into the @chips hash
- How to prevent ID conflict without using UUID? Might need after all

Textual front-end
- All grammars investigated thus far are horribad

Non-trivial test data
- We don't have any
- Writing JSON by hand is not fun
