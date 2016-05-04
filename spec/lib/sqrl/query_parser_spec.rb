require 'spec_helper'
require 'sqrlid'
require 'sqrl/query_parser'
require 'sqrl/client_session'
require 'sqrl/query_generator'
require 'sqrl/key/unlock_request_signing'
require 'sqrl/key/random_lock'
require 'sqrl/key/identity_unlock'

describe SQRL::QueryParser do
  URL = 'sqrl://example.com/sqrl?nut=awnuts'
  def self.testcase(ursk)
    session = SQRL::ClientSession.new(URL, ['x'.b*32])
    SQRL::QueryGenerator.new(session, URL).query!.unlock(ursk).opt('sqrlonly', 'hardlock')
  end

=begin
  iuk = SQRL::Key::IdentityUnlock.new
  ilk = iuk.identity_lock_key
  rlk = SQRL::Key::RandomLock.new
  vuk = SQRL::Key::VerifyUnlock.generate(ilk, rlk)
  suk = rlk.server_unlock_key
  ursk = SQRL::Key::UnlockRequestSigning.new(suk, iuk)
  p SQRL::Base64.encode(vuk)
  p testcase(ursk).to_hash
  p testcase(ursk).post_body
=end

  let(:vuk) {SQRL::Key::VerifyUnlock.new(SQRL::Base64.decode("mkNweHKcBXbJxABLkAIn2qSa4kXOndhckaA9-2vWQj4"))}
  let(:raw_request) {
    {:client=>"dmVyPTENCmNtZD1xdWVyeQ0Kb3B0PXNxcmxvbmx5fmhhcmRsb2NrDQppZGs9dmRhbzZGT092TTlMSWk3clBQY0ZIUjhtLW9nZ1N3TFNRb1A1Q1R1UnNRTQ", :server=>"c3FybDovL2V4YW1wbGUuY29tL3Nxcmw_bnV0PWF3bnV0cw", :ids=>"bcIBqwgHHH82qN8eaB70ZW3eqI8njs2LWmKSqRT6vPgapAE2B0fQSXRi69mIIPgXqUHXGViBbmHblQMb6ssgAg", :urs=>"4FXl1FMT0yzAM2CHLfRoLmmDACngMF6MxmrDe1FWtOKC5Ne8g8LzaA6J_Wj6FnP99ku3U1eXqMXa8wbP-UrrDQ"}
  }
  let(:request) {
    Hash[raw_request.map {|k,v| [k.to_s,v]}]
  }
  let(:body) {
    "client=dmVyPTENCmNtZD1xdWVyeQ0Kb3B0PXNxcmxvbmx5fmhhcmRsb2NrDQppZGs9dmRhbzZGT092TTlMSWk3clBQY0ZIUjhtLW9nZ1N3TFNRb1A1Q1R1UnNRTQ&server=c3FybDovL2V4YW1wbGUuY29tL3Nxcmw_bnV0PWF3bnV0cw&ids=bcIBqwgHHH82qN8eaB70ZW3eqI8njs2LWmKSqRT6vPgapAE2B0fQSXRi69mIIPgXqUHXGViBbmHblQMb6ssgAg&urs=4FXl1FMT0yzAM2CHLfRoLmmDACngMF6MxmrDe1FWtOKC5Ne8g8LzaA6J_Wj6FnP99ku3U1eXqMXa8wbP-UrrDQ"
  }

  it {expect(SQRL::QueryParser.new({})).not_to be_valid}

  describe 'hash request' do
    subject {SQRL::QueryParser.new(request)}
    it {expect(subject.server_string).to eq(URL)}
    it {expect(subject.client_string).to match('ver=1\r\ncmd=query\r\nopt=')}
    it {expect(subject.client_data).to be_a(Hash)}
    it {expect(subject.client_data['ver']).to eq('1')}
    it {expect(subject.client_data['cmd']).to eq('query')}
    it {expect(subject.client_data['opt']).to eq('sqrlonly~hardlock')}
    it {expect(subject.commands).to eq(['query'])}
    it {expect(subject.opt?('sqrlonly')).to be true}
    it {expect(subject.idk.length).to eq(32)}
    it {expect(subject.ids.length).to eq(64)}
    it {expect(subject).to be_valid}
    it {expect(subject.unlocked?(vuk)).to be true}
  end

  describe 'string request' do
    subject {SQRL::QueryParser.new(body)}
    it {expect(subject.server_string).to eq(URL)}
    it {expect(subject.client_string).to match('ver=1\r\ncmd=query\r\nopt=')}
  end

  describe 'sqrlid query' do
    let(:body) {SQRLid::First}
    subject {SQRL::QueryParser.new(body)}
    it {expect(subject.client_data['ver']).to eq('1')}
    it {expect(subject.client_data['cmd']).to eq('query')}
  end

  describe 'sqrlid ident' do
    let(:body) {SQRLid::Second}
    subject {SQRL::QueryParser.new(body)}
    #it {expect(subject).to be_valid}
    it {expect(subject.client_data['ver']).to eq('1')}
    it {expect(subject.client_data['cmd']).to eq('query')} # ??
  end
end
