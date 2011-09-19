module CircuitSim
  class Pin
    attr_reader :name, :path, :part, :port
    attr_accessor :state

    def initialize(name)
      @name = name
      names = name.split('.')

      @part_id = names[-2]
      @port = names[-1]

      if @part_id
        @part = @part_id.split('#')[0] 
        @path = names[0..-2].join('.') + '.'
      else
        @part = @path = nil
      end

      @state = nil
    end

    def is_circuit?
      !!@part && !is_gate?
    end

    def is_gate?
      GATES.include?(@part)
    end

    def is_io_port?
      !@name.include?('#')
    end

    def to_s
      @name
    end

    def eql?(o)
      to_s == o.to_s
    end

    def hash
      @name.hash
    end
  end
end
