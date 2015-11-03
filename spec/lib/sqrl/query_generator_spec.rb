require 'spec_helper'
require 'sqrl/query_generator'
require 'sqrl/client_session'
require 'sqrl/key/identity_master'
require 'sqrl/key/identity_unlock'
require 'sqrl/key/server_unlock'
require 'sqrl/key/unlock_request_signing'

describe SQRL::QueryGenerator do
  let(:url) {'sqrl://example.com/sqrl?nut=awnuts'}
  let(:imk) {SQRL::Key::IdentityMaster.new('x'.b*32)}
  let(:iuk) {SQRL::Key::IdentityUnlock.new('x'.b*32)}
  let(:suk) {SQRL::Key::ServerUnlock.new('x'.b*32)}
  let(:ursk) {SQRL::Key::UnlockRequestSigning.new(suk, iuk)}
  let(:session) {SQRL::ClientSession.new(url, imk)}
  subject {SQRL::QueryGenerator.new(session, url)}

  it {expect(subject.post_path).to eq('https://example.com/sqrl?nut=awnuts')}
  it {expect(subject.server_string).to eq('c3FybDovL2V4YW1wbGUuY29tL3Nxcmw_bnV0PWF3bnV0cw')}
  it {expect(subject.client_string).to match("ver=1\r\nidk=")}
  it {expect(subject.to_hash).to be_a(Hash)}
  it {expect(subject.to_hash[:server]).to eq('c3FybDovL2V4YW1wbGUuY29tL3Nxcmw_bnV0PWF3bnV0cw')}
  it {expect(subject.to_hash[:client]).to match(/\A[\-\w_]+\Z/)}
  it {expect(subject.to_hash[:ids]).to match(/\A[\-\w_]+\Z/)}
  it {expect(subject.to_hash.keys).to eq([:client, :server, :ids])}
  it {expect(subject.post_body).to be_a(String)}
  it {expect(subject.commands).to be_empty}
  it {expect(subject.client_data.include?(:cmd)).to be false}

  describe "query command" do
    subject {SQRL::QueryGenerator.new(session, url).query!}
    it {expect(subject.commands).to include('query')}
    it {expect(subject.client_data[:cmd]).to eq('query')}
  end

  describe "setlock" do
    subject {SQRL::QueryGenerator.new(session, url).setlock({:vuk => 'vuk', :suk => 'suk'})}
    it {expect(subject.client_data[:vuk]).to be_a(String)}
    it {expect(subject.client_data[:suk]).to be_a(String)}
  end

  describe "second loop" do
    let(:server_string) {SQRL::Base64.encode('response')}
    subject {SQRL::QueryGenerator.new(session, server_string)}
    it {expect(subject.to_hash[:server]).to eq(server_string)}
  end
end
