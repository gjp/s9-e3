require 'json'
a= JSON.parse(File.open(ARGV[0]).read)
puts JSON.pretty_generate(a)
