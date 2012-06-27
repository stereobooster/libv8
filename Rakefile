require 'bundler/setup'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

V8_Version = Libv8::VERSION.gsub(/\.\d$/,'')
V8_Source = File.expand_path '../vendor/v8', __FILE__

require File.expand_path '../ext/libv8/make.rb', __FILE__
include Libv8::Make

desc "setup the vendored v8 source to correspond to the libv8 gem version and prepare deps"
task :checkout do
  sh "git submodule update --init"
  Dir.chdir(V8_Source) do
    sh "git fetch"
    sh "git checkout #{V8_Version} -f"
    sh "#{make} dependencies"
  end

  # Fix gyp trying to build platform-linux on FreeBSD 9 and FreeBSD 10.
  # Based on: https://chromiumcodereview.appspot.com/10079030/patch/1/2
  sh "patch -N -p0 -d vendor/v8 < patches/add-freebsd9-and-freebsd10-to-gyp-GetFlavor.patch"
  # Fix scons to work with MinGW
  sh "patch -N -p0 -d vendor/v8 < patches/scons_mingw.patch"
end

desc "compile v8 via the ruby extension mechanism"
task :compile do
  sh "ruby ext/libv8/extconf.rb"
end

desc "manually invoke the GYP compile. Useful for seeing debug output"
task :manual_compile do
  require File.expand_path '../ext/libv8/arch.rb', __FILE__
  include Libv8::Arch
  Dir.chdir(V8_Source) do
    sh %Q{#{make} -j2 #{libv8_arch}.release GYPFLAGS="-Dhost_arch=#{libv8_arch}"}
  end
end


desc "build all binary gems"
task :binary do
end

require File.expand_path '../ext/libv8/arch.rb', __FILE__
require File.expand_path '../ext/libv8/compiler.rb', __FILE__
require File.expand_path '../ext/libv8/build.rb', __FILE__

require 'rubygems'
GEMSPEC = Gem::Specification.load('libv8.gemspec')

# what about MacOS ?
# 'x86-mswin32-60'
platfroms = ['x86-mingw32', 'i686-linux']

if Gem::Platform.new(RUBY_PLATFORM).cpu != "x86"
  platfroms += ['x64-linux']
end

platfroms.each do |platform|
  desc "build #{platform}"
  task "binary:#{platform}" do
    gemspec = GEMSPEC.dup 
    gemspec.platform = Gem::Platform.new(platform)
    # binary_gem_name = File.basename gemspec.cache_file

    target_os = if platform =~ /mingw|mswin/
      "win32"  
    end

    target_arch = if gemspec.platform.cpu == "x86"
      "ia32"
    else
      "x64"
    end

    compiler = if platform =~ /mingw/
      # mingw
      Libv8::Compiler.mingw_gcc_executable
    else
      # gcc
      Libv8::Compiler.compiler
    end

    res = Libv8::Build.build(
      :target_arch => target_arch,
      :target_os => target_os,
      :compiler => compiler,
      :make => Libv8::Make.make)
    abort if res != 0

    # We don't need most things for the binary
    gemspec.files = ['lib/libv8.rb', 'ext/libv8/arch.rb', 'lib/libv8/version.rb']
    # V8
    gemspec.files += Dir['vendor/v8/include/*']
    gemspec.files += Dir['vendor/v8/out/**/*.a']
    FileUtils.mkdir_p 'pkg'
    FileUtils.mv(Gem::Builder.new(gemspec).build, 'pkg')
  end
  Rake::Task[:binary].prerequisites << "binary:#{platform}"
end

desc "clean up artifacts of the build"
task :clean do
  sh "rm -rf pkg"
  sh "git clean -df"
  sh "cd #{V8_Source} && git clean -dxf"
end

task :default => [:checkout, :compile, :spec]
task :build => [:clean, :checkout]
