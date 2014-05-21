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

libmetis = %w[libmetis.so libmetis.a]

libdirs.each do |dir|
  libmetis.each do |name|
    path = File.join(dir,name)
    if File.exist?(path)
      $libmetis = path
      break
    end
  end
  break if $libmetis
end

incdirs.each do |dir|
  path = File.join(dir,'metis.h')
  if File.exist?(path)
    puts "reading #{path}"
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

conf_file = File.join("..","lib","rbmetis","config.rb")
print "creating #{conf_file}\n"
open(conf_file, "w") do |f|
  f.puts <<EOL
module RbMetis
  IDXTYPEWIDTH=#{$idxtypewidth}
  REALTYPEWIDTH=#{$realtypewidth}
  LIBMETIS='#{$libmetis}'
end
EOL
end

create_makefile("rbmetis")
