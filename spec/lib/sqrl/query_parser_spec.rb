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
    SQRL::QueryGenerator.new(session, URL).query!.unlock(ursk)
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

  let(:vuk) {SQRL::Key::VerifyUnlock.new(SQRL::Base64.decode("j5rWzCNlvSlAf3G6jocfJfYTkIyejjvzB-Cliftfs-s"))}
  let(:raw_request) {
    {:client=>"dmVyPTENCmNtZD1xdWVyeQ0KaWRrPXZkYW82Rk9Pdk05TElpN3JQUGNGSFI4bS1vZ2dTd0xTUW9QNUNUdVJzUU0", :server=>"c3FybDovL2V4YW1wbGUuY29tL3Nxcmw_bnV0PWF3bnV0cw", :ids=>"6EpGjA2Tl3qs7pc7nyes2-CGApMraouxpfaVoRVBK4yQr0KMYxUZ3xhKMVpyRoi2NUHZJdgCJGCp5SezJ3ZfBg", :urs=>"33_pkq3l8FGsS-lcl1OjEMcHKs3BkLqhV3E9A4sOycWf-J5PwbIxZMBISQkSj51D8z0HxHZ5tXnb5RdORdIrCA"}
  }
  let(:request) {
    Hash[raw_request.map {|k,v| [k.to_s,v]}]
  }
  let(:body) {
    "client=dmVyPTENCmNtZD1xdWVyeQ0KaWRrPXZkYW82Rk9Pdk05TElpN3JQUGNGSFI4bS1vZ2dTd0xTUW9QNUNUdVJzUU0&server=c3FybDovL2V4YW1wbGUuY29tL3Nxcmw_bnV0PWF3bnV0cw&ids=6EpGjA2Tl3qs7pc7nyes2-CGApMraouxpfaVoRVBK4yQr0KMYxUZ3xhKMVpyRoi2NUHZJdgCJGCp5SezJ3ZfBg&urs=33_pkq3l8FGsS-lcl1OjEMcHKs3BkLqhV3E9A4sOycWf-J5PwbIxZMBISQkSj51D8z0HxHZ5tXnb5RdORdIrCA"
  }

  it {expect(SQRL::QueryParser.new({})).not_to be_valid}

  describe 'hash request' do
    subject {SQRL::QueryParser.new(request)}
    it {expect(subject.server_string).to eq(URL)}
    it {expect(subject.client_string).to match('ver=1\r\ncmd=query\r\nidk=')}
    it {expect(subject.client_data).to be_a(Hash)}
    it {expect(subject.client_data['ver']).to eq('1')}
    it {expect(subject.client_data['cmd']).to eq('query')}
    it {expect(subject.commands).to eq(['query'])}
    it {expect(subject.idk.length).to eq(32)}
    it {expect(subject.ids.length).to eq(64)}
    it {expect(subject).to be_valid}
    it {expect(subject.unlocked?(vuk)).to be true}
  end

  describe 'string request' do
    subject {SQRL::QueryParser.new(body)}
    it {expect(subject.server_string).to eq(URL)}
    it {expect(subject.client_string).to match('ver=1\r\ncmd=query\r\nidk=')}
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
