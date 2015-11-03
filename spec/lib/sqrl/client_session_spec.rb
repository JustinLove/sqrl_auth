require 'spec_helper'
require 'sqrl/client_session'
require 'sqrl/key/identity_master'

describe SQRL::ClientSession do
  let(:url) {'sqrl://example.com/sqrl?nut=awnuts'}
  let(:imk) {SQRL::Key::IdentityMaster.new('x'.b*32)}
  subject {SQRL::ClientSession.new(url, imk)}

  it {expect(subject.post_path).to eq('https://example.com/sqrl?nut=awnuts')}
  it {expect(subject.site_key).to be_a(SQRL::Key::Site)}

  describe 'qry' do
    it {
      subject.update_post_path('/sqrl?nut=qry')
      expect(subject.post_path).to eq('https://example.com/sqrl?nut=qry')
    }
  end
end
