require 'rails_helper'

RSpec.describe Certificate, type: :model do
  describe "signature validity" do
    before :each do
      @cert = FactoryGirl.build(:certificate)
    end
    it "is valid when signed by parent CA" do
      @cert.cert.sign(@cert.certificate_authority.private_key, OpenSSL::Digest::SHA1.new)
      expect(@cert.valid?).to eq(true)
    end
    it "is invalid when not signed by parent CA" do
      @other_ca = FactoryGirl.create(:certificate_authority)
      @cert.cert.sign(@other_ca.private_key, OpenSSL::Digest::SHA1.new)
      expect(@cert.valid?).to eq(false)
    end
    it "is invalid when not signed at all" do
      expect(@cert.valid?).to eq(false)
    end
  end

  describe 'time validity' do
    before :each do
      t = Time.new(1000)
      allow(Time).to receive(:now) { t }
      @cert = FactoryGirl.create(:certificate)
    end
    it 'returns the proper not_before time' do
      expect(@cert.not_before).to eq(Time.now)
    end
    it 'returns the proper not_after time' do
      expect(@cert.not_after).to eq(Time.now + 365*24*60*60)
    end
  end

  describe 'subject' do
    it 'returns the subject' do
      @cert = FactoryGirl.create(:certificate)
      expect(@cert.subject).to eq(@cert.cert.subject)
    end
  end

  describe 'pem conversion' do
    it 'returns a long pem string matching the underlying certificate' do
      @cert = FactoryGirl.create(:certificate)
      expect(@cert.to_pem).to eq(@cert.cert.to_pem)
    end
  end

  describe 'der conversion' do
    it 'returns a der encoding matching the underlying certifcate' do
      @cert = FactoryGirl.create(:certificate)
      expect(@cert.to_der).to eq(@cert.cert.to_der)
    end
  end
end
