module CircuitSimulator
  class CircuitError < RuntimeError; end

  class Application
    def self.run(argv)
      params = get_params(argv)

      raise CircuitError,
        "No circuit definitions given" unless params[:filenames].size > 0

      raise CircuitError,
        "No top level circuit specified" unless params[:circuit]

      circuit = Builder.build(params).circuit
      circuit.dump if params[:verbose]

      circuit.solve_for(params[:inputs]) if params[:inputs]
      circuit.truth_table if params[:truth]

    rescue CircuitError => e
      puts "\nCircuitError: #{e.message}"
    end

    def self.get_params(argv)
      params = {}

      params[:filenames] = OptionParser.new do |parser|
        parser.banner = "Usage: #{$PROGRAM_NAME} [params] FILE [...]"

        parser.on("-c", "--circuit CIRCUIT", "Name of top-level circuit") do |c|
          params[:circuit] = c
        end

        parser.on("-i", "--inputs \"A:1, B:0, [...]\"", "Specify inputs") do |i|
          list = i.split(/[, ]+/)
          params[:inputs] = {}

          list.each do |i|
            k,v = i.split(':')
            params[:inputs][k] = (v.to_i == 1 ? true : false)
          end
        end

        parser.on("-t", "--truth", "Compute truth table") do |t|
          params[:truth] = t
        end

        parser.on("-v", "--verbose", "Run verbosely") do |v|
          params[:verbose] = v
        end
      end.parse(argv)

      params
    end

  end
end
