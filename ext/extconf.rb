require "mkmf"

# configure options:
#  --with-metis-dir=path
#  --with-metis-include=path
#  --with-metis-lib=path

dir_config("metis")

libdirs = $LIBPATH.dup
libdirs |= %w[/usr/lib64 /usr/lib /usr/local/lib]
incdirs = $CPPFLAGS.scan(/(?<=^-I|\s-I)\S+/)
incdirs |= %w[/usr/include /usr/local/include]

print "searching libmetis.so ..."
libdirs.each do |dir|
  path = File.join(dir,"libmetis.so")
  if File.exist?(path)
    $libmetis = path
    break
  end
end
if $libmetis
  puts "found"
else
  puts "not found"
  exit
end

print "searching metis.h ..."
incdirs.each do |dir|
  path = File.join(dir,'metis.h')
  if File.exist?(path)
    $metis_h = path
    open(path,'r').each do |line|
      case line
      when /^\s*#define\s+IDXTYPEWIDTH\s+(\d+)/
        $idxtypewidth = $1.to_i
      when /^\s*#define\s+REALTYPEWIDTH\s+(\d+)/
        $realtypewidth = $1.to_i
      end
    end
    break
  end
end
if $metis_h
  puts "found"
else
  puts "not found"
  exit
end

config = <<EOL
  IDXTYPEWIDTH=#{$idxtypewidth}
  REALTYPEWIDTH=#{$realtypewidth}
  LIBMETIS='#{$libmetis}'
EOL
puts "config options:"
puts config

conf_file = File.join("..","lib","rbmetis","config.rb")
print "writing #{conf_file}\n"
open(conf_file, "w") do |f|
  f.puts "module RbMetis\n"+config+"end"
end

create_makefile("rbmetis")
