require 'phonelib'

parse_and_format = lambda do
  phone = Phonelib.parse('+1 202 555 0123')
  [phone.valid?, phone.e164, phone.national, phone.international]
end
parse_and_format.call

counts = Array.new(5) do
  GC.disable
  before = GC.stat(:total_allocated_objects)
  parse_and_format.call
  allocated = GC.stat(:total_allocated_objects) - before
  GC.enable
  allocated
end
puts "#{RUBY_VERSION} #{ARGV.first}: #{counts.min} objects"
