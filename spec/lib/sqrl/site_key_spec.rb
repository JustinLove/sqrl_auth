require 'spec_helper'
require 'sqrl/site_key'

describe SQRL::SiteKey do
  let(:imk) {'x'*32}
  let(:url) {'https://example.com/sqrl?nut=awnuts'}
  subject {SQRL::SiteKey.new(imk, url)}

  it {expect(subject.public_key).to be_a(String)}
  it {expect(subject.signature(url)).to be_a(String)}
end