module CircuitSimulator
  def get_options
    OptionParser.new do |opts|
      opts.banner = "Usage: #{$PROGRAM_NAME} [options] FILE [...]"

      opts.on("-c", "--circuit CIRCUIT", "Name of top-level circuit") do |c|
        @options[:circuit] = c
      end

      opts.on("-i", "--inputs \"A:1, B:0, [...]\"", "Specify inputs") do |i|
        list = i.split(/[, ]+/)
        @options[:inputs] = {}

        list.each do |i|
          k,v = i.split(':')
          @options[:inputs][k] = (v.to_i == 1 ? true : false)
        end
      end

      opts.on("-t", "--truth", "Compute truth table") do |t|
        @options[:truth] = t
      end

      opts.on("-v", "--verbose", "Run verbosely") do |v|
        @options[:verbose] = v
      end

    end.parse!
  end
end
