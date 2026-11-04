require 'phonelib'

describe 'allocations' do
  def allocated_objects
    GC.disable
    before = GC.stat(:total_allocated_objects)
    yield
    GC.stat(:total_allocated_objects) - before
  ensure
    GC.enable
  end

  it 'parses and formats numbers without rebuilding their patterns' do
    numbers = [
      ['+1 202 555 0123', nil],
      ['202 555 0123', 'US'],
      ['+33 6 12 34 56 78', nil],
      ['06 12 34 56 78', 'FR'],
      ['+44 20 7183 8750', nil]
    ]
    parse_and_format = lambda do
      numbers.each do |number, country|
        phone = Phonelib.parse(number, country)
        [phone.valid?, phone.e164, phone.national, phone.international]
      end
    end
    parse_and_format.call

    # 474 objects on Ruby 3.3 and 377 on Ruby 4.0, against 854 and 712
    # when regexp sources and format strings are rebuilt on every parse
    expect(allocated_objects(&parse_and_format)).to be < 650
  end
end
