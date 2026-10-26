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

  it 'parses and formats a number without rebuilding its patterns' do
    parse_and_format = lambda do
      phone = Phonelib.parse('+1 202 555 0123')
      [phone.valid?, phone.e164, phone.national, phone.international]
    end
    parse_and_format.call

    # 574 objects on Ruby 3.3 and 484 on Ruby 4.0, against 1,243 to 2,319
    # when regexp sources and format strings are rebuilt on every parse
    expect(allocated_objects(&parse_and_format)).to be < 850
  end
end
