require 'rails_helper'

RSpec.describe Certificate, type: :model do
  describe "validity" do
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
end
