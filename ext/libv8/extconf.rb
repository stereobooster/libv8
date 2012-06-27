require 'mkmf'
create_makefile('libv8')

require File.expand_path '../arch.rb', __FILE__
require File.expand_path '../make.rb', __FILE__
require File.expand_path '../compiler.rb', __FILE__
require File.expand_path '../build.rb', __FILE__

Dir.chdir(File.expand_path '../../../vendor/v8', __FILE__) do
  res = Libv8::Build.biuild(
    :target_arch => Libv8::Arch.libv8_arch, 
    :compiler => Libv8::Compiler.compiler, 
    :make => Libv8::Make.make
  )
end

exit res
