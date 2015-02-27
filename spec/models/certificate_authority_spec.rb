require 'rails_helper'

RSpec.describe CertificateAuthority, type: :model do
  describe "CA validity" do
    before :each do
      @ca = FactoryGirl.build(:certificate_authority)
    end
    it "is valid if given name and subject and ca data generated" do
      @ca.generate_ca_data!
      expect(@ca.valid?).to be true
    end
    
    it "is invalid if .new() is called but key data is not generated" do
      expect{@ca.save!}.to raise_error
    end
  end

  describe "private/public keypair" do
    before :each do
      @ca = FactoryGirl.create(:certificate_authority)
    end
    it "should become invalid if CA certificate is modified" do
      @ca.ca_cert = OpenSSL::X509::Certificate.new
      expect{ @ca.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
    it "should become invalid if private key is modified" do
      @ca.private_key = OpenSSL::PKey::RSA.new(2048)
      expect{ @ca.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
    it "should become invalid if subject doesn't match CA cert subject" do
      @ca.subject = "/CN=Totally Awesome Common Name"
      expect{ @ca.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
