module CircuitSimulator
  class Application
    def self.run(argv)
      options = get_options(argv)

      s = Solver.new(options)
      s.solve
      puts s.outputs

      s.truth_table if options[:truth]
    end

    def self.get_options(argv)
      options = {}

      options[:filenames] = OptionParser.new do |parser|
        parser.banner = "Usage: #{$PROGRAM_NAME} [options] FILE [...]"

        parser.on("-c", "--circuit CIRCUIT", "Name of top-level circuit") do |c|
          options[:circuit] = c
        end

        parser.on("-i", "--inputs \"A:1, B:0, [...]\"", "Specify inputs") do |i|
          list = i.split(/[, ]+/)
          options[:inputs] = {}

          list.each do |i|
            k,v = i.split(':')
            options[:inputs][k] = (v.to_i == 1 ? true : false)
          end
        end

        parser.on("-t", "--truth", "Compute truth table") do |t|
          options[:truth] = t
        end

        parser.on("-v", "--verbose", "Run verbosely") do |v|
          options[:verbose] = v
        end
      end.parse(argv)

      options
    end

  end
end
