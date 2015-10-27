require 'spec_helper'
require 'sqrl/query_parser'
require 'sqrl/client_session'
require 'sqrl/query_generator'
require 'sqrl/key/unlock_request_signing'
require 'sqrl/key/random_lock'
require 'sqrl/key/identity_unlock'

describe SQRL::QueryParser do
  URL = 'sqrl://example.com/sqrl?nut=awnuts'
  def self.testcase(ursk)
    session = SQRL::ClientSession.new(URL, 'x'.b*32)
    SQRL::QueryGenerator.new(session, URL)
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

  let(:vuk) {SQRL::Key::VerifyUnlock.new(SQRL::Base64.decode("psdVVFCBMt-kbsP-4rQft4Gx-kb21lcS0oITSd-rn7U"))}
  let(:raw_request) {
    {:client=>"dmVyPTENCmNtZD1sb2dpbg0KaWRrPXZkYW82Rk9Pdk05TElpN3JQUGNGSFI4bS1vZ2dTd0xTUW9QNUNUdVJzUU0", :server=>"c3FybDovL2V4YW1wbGUuY29tL3Nxcmw_bnV0PWF3bnV0cw", :ids=>"QKKRM7ygMKilHrYLOp9X4ZndAYZ3nZaQVI8l-qVSIj7XUebqnG_GZ2jOTuZMOlNOVz36RyBCrC7wdvSJl6phAQ", :urs=>"gppH_2ESX4w-nkhawUpSKXCBvqOg6SACaUlizCEDB6umfr1OhQ7Jt2TLNFeqh80mTxceGFi19UGoJ1_eYuIdDw"}
  }
  let(:request) {
    Hash[raw_request.map {|k,v| [k.to_s,v]}]
  }
  let(:body) {
    "client=dmVyPTENCmNtZD1sb2dpbg0KaWRrPXZkYW82Rk9Pdk05TElpN3JQUGNGSFI4bS1vZ2dTd0xTUW9QNUNUdVJzUU0&server=c3FybDovL2V4YW1wbGUuY29tL3Nxcmw_bnV0PWF3bnV0cw&ids=QKKRM7ygMKilHrYLOp9X4ZndAYZ3nZaQVI8l-qVSIj7XUebqnG_GZ2jOTuZMOlNOVz36RyBCrC7wdvSJl6phAQ&urs=gppH_2ESX4w-nkhawUpSKXCBvqOg6SACaUlizCEDB6umfr1OhQ7Jt2TLNFeqh80mTxceGFi19UGoJ1_eYuIdDw"
  }

  it {expect(SQRL::QueryParser.new({})).not_to be_valid}

  describe 'hash request' do
    subject {SQRL::QueryParser.new(request)}
    it {expect(subject.server_string).to eq(URL)}
    #it {expect(subject.client_string).to match('ver=1\r\ncmd=login\r\nidk=')}
    it {expect(subject.client_data).to be_a(Hash)}
    it {expect(subject.client_data['ver']).to eq('1')}
    #it {expect(subject.client_data['cmd']).to eq('login')}
    #it {expect(subject.commands).to eq(['login'])}
    it {expect(subject.idk.length).to eq(32)}
    it {expect(subject.ids.length).to eq(64)}
    it {expect(subject).to be_valid}
    it {expect(subject.unlocked?(vuk)).to be true}
  end

  describe 'string request' do
    subject {SQRL::QueryParser.new(body)}
    it {expect(subject.server_string).to eq(URL)}
    #it {expect(subject.client_string).to match('ver=1\r\ncmd=login\r\nidk=')}
  end
end
