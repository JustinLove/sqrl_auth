require 'spec_helper'
require 'sqrl/response_generator'

describe SQRL::ResponseGenerator do
  def nut; 'x'*22; end
  subject {SQRL::ResponseGenerator.new(nut, {}, {})}

  it {expect(subject.response_body).to match('server=')}
  it {expect(subject.server_string).to match('ver=1')}
  it {expect(subject.to_hash).to be_a(Hash)}
  it {expect(subject.server_data).to be_a(Hash)}
  it {expect(subject.server_data[:ver]).to eq('1')}
  it {expect(subject.server_data[:nut]).to eq(nut)}
  it {expect(subject.server_data[:tif]).to be_a(String)}

  def with(flags)
    SQRL::ResponseGenerator.new(nut, flags, {}).tif
  end

  describe 'tif' do
    it {expect(with({})).to eq(0)}
    it {expect(with(:id_match => true)).to eq(0x01)}
    it {expect(with(:id_match => true, :previous_id_match => true)).to eq(0x03)}
    it {expect(with(:ip_match => true, :sqrl_disabled => true)).to eq(0x0c)}
    it {expect(with(:logged_in => true, :creation_allowed => true)).to eq(0x30)}
    it {expect(with(:command_failed => true, :sqrl_failure => true)).to eq(0xc0)}
  end

  describe 'additional fields' do
    subject {SQRL::ResponseGenerator.new(nut, {}, {
        :qry => 'query',
        :sfn => 'name',
        :other => 'other',
      })}
    it {expect(subject.server_data[:qry]).to eq('query')}
    it {expect(subject.server_data[:other]).to eq('other')}
  end
end
