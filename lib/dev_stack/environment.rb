module DevStack
  class Environment
    attr_reader :name, :port_offset, :suffix

    def initialize(name:, port_offset:, suffix: nil)
      @name = name
      @port_offset = port_offset
      @suffix = suffix || @name
    end

    def get_binding
      binding
    end

    def offset_port(_service, base)
      base + @port_offset
    end

    def file_path(*args)
      @base_dir ||= Pathname.new(Dir.mktmpdir)
      @base_dir.join(*args)
    end

    def volume(service, base)
      [service.name, base, suffix].join('_')
    end
  end
end