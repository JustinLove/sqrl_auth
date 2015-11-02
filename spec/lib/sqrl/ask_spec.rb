require 'spec_helper'
require 'sqrl/ask'

describe SQRL::Ask do
  it {expect(SQRL::Ask.new('hi').message).to eq('hi')}
  it {expect(SQRL::Ask.new("\n").to_s).not_to match("\n")}
  it {expect(SQRL::Ask.parse("Cg").message).to eq("\n")}
  it {expect(SQRL::Ask.parse("Cg~aGk").message).to eq("\n")}
end
