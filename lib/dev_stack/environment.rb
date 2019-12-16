module DevStack
  class Environment
    def initialize(config)
      @config = { 'destroy_volumes' => false, 'port_offset' => 0 }.merge(config)
      @config['suffix'] ||= @config['name']
    end

    def get_binding
      binding
    end

    def offset_port(_service, base)
      base + port_offset
    end

    def file_path(*args)
      @base_dir ||= Pathname.new(Dir.mktmpdir(['devstack_',"_#{suffix}"])).realpath
      @base_dir.join(*args)
    end

    def volume(service, base)
      [service.name, base, suffix].join('_')
    end

    def respond_to_missing?(sym, *args)
      @config.key?(sym.to_s)
    end

    def method_missing(sym, *args)
      respond_to_missing?(sym) ? @config[sym.to_s] : super
    end
  end
end