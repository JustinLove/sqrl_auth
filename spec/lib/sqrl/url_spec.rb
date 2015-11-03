require 'spec_helper'
require 'sqrl/url'

describe SQRL::URL do
  describe 'server' do
    describe 'sqrl' do
      subject {SQRL::URL.sqrl('example.com/sqrl', {:nut => 'awnuts'})}
      it {expect(subject.to_s).to eq('sqrl://example.com/sqrl?nut=awnuts')}
      it {expect(subject.post_path).to eq('https://example.com/sqrl?nut=awnuts')}
    end

    describe 'qrl' do
      subject {SQRL::URL.qrl('example.com/sqrl', {:nut => 'awnuts'})}
      it {expect(subject.to_s).to eq('qrl://example.com/sqrl?nut=awnuts')}
      it {expect(subject.post_path).to eq('http://example.com/sqrl?nut=awnuts')}
    end

    describe 'sfn' do
      subject {SQRL::URL.sqrl('example.com/sqrl', {:nut => 'awnuts', :sfn => 'hi'})}
      it {expect(subject.to_s).to eq('sqrl://example.com/sqrl?nut=awnuts&sfn=aGk')}
    end

    describe 'bar' do
      subject {SQRL::URL.sqrl('example.com/foo|sqrl', {:nut => 'awnuts'})}
      it {expect(subject.to_s).to eq('sqrl://example.com/foo|sqrl?nut=awnuts')}
      it {expect(subject.post_path).to eq('https://example.com/foo/sqrl?nut=awnuts')}
    end

    describe 'x' do
      subject {SQRL::URL.sqrl('example.com/foo/sqrl', {:nut => 'awnuts', :x => '/foo'})}
      it {expect(subject.to_s).to eq('sqrl://example.com/foo/sqrl?nut=awnuts&x=4')}
      it {expect(subject.post_path).to eq('https://example.com/foo/sqrl?nut=awnuts&x=4')}
    end
  end

  describe 'client' do
    describe 'sqrl' do
      subject {SQRL::URL.parse('sqrl://example.com/sqrl?nut=awnuts')}
      it {expect(subject.signing_host).to eq('example.com')}
      it {expect(subject.nut).to eq('awnuts')}
    end

    describe 'qrl' do
      subject {SQRL::URL.parse('qrl://example.com/sqrl?nut=awnuts')}
      it {expect(subject.signing_host).to eq('example.com')}
      it {expect(subject.nut).to eq('awnuts')}
    end

    describe 'sfn' do
      subject {SQRL::URL.parse('sqrl://example.com/sqrl?nut=awnuts&sfn=aGk')}
      it {expect(subject.signing_host).to eq('example.com')}
      it {expect(subject.nut).to eq('awnuts')}
      it {expect(subject.sfn).to eq('hi')}
    end

    describe 'bar' do
      subject {SQRL::URL.parse('sqrl://example.com/foo|sqrl?nut=awnuts')}
      it {expect(subject.signing_host).to eq('example.com/foo')}
      it {expect(subject.nut).to eq('awnuts')}
    end

    describe 'x' do
      subject {SQRL::URL.parse('sqrl://example.com/foo/sqrl?nut=awnuts&x=4')}
      it {expect(subject.signing_host).to eq('example.com/foo')}
      it {expect(subject.nut).to eq('awnuts')}
    end
  end
end
