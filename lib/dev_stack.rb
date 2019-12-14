require 'dev_stack/environment'
require 'dev_stack/service'
require 'dev_stack/stack'

module DevStack
  VERSION = '2.0.0'

  class << self
    def root
      File.expand_path('..', __dir__)
    end

    def link!
      Dir.chdir(root) do
        Dir['bin/*'].each do |bin|
          source = File.expand_path(bin)
          target = "/usr/local/bin/#{File.basename(bin)}"
          unless File.exist?(target)
            warn "Linking #{source} -> #{target}"
            FileUtils.ln_s source, target 
          end
        end
      end
    end

    def update!
      Dir.chdir(root) do
        `git pull origin`
        link!
      end
      display_version
    end

    def display_version
      Dir.chdir(root) do
        cmds = ['git fetch origin >/dev/null 2>&1', 'git rev-parse HEAD', 'git rev-parse origin/master'].join(' && ')
        (local_rev, remote_rev) = `#{cmds}`.strip.split
        warn "devstack version #{VERSION}, build #{local_rev[0..7]}\n" + `docker-compose version`
        return if local_rev == remote_rev
        remote_version = `git show origin/master:VERSION`.strip
        warn "\nVersion #{remote_version}, build #{remote_rev[0..7]} available."
        warn 'Run `devstack update` to upgrade'
      end
    end
  end
end
