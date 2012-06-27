require File.expand_path '../../../lib/libv8', __FILE__

module Libv8
  module Build

    module_function
    def build(params)
      compiler = params[:compiler]
      make = params[:make]
      target_arch = params[:target_arch]
      target_os = params[:target_arch]

      if target_arch == "win32"
        puts `scons os=win32 toolchain=crossmingw arch=#{target_arch}`
      else
        puts `env CXX=#{File.basename compiler} LINK=#{File.basename compiler} #{File.basename make} #{target_arch}.release GYPFLAGS="-Dhost_arch=#{target_arch}"`
      end

      if $?.exitstatus != 0
        return $?.exitstatus
      end

      begin
        Libv8.libv8_objects
      rescue => e
        puts e.message
        return 1
      end

      0
    end
  end
end
