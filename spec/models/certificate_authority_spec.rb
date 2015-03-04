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

  describe "#sign!" do
    before :each do
      @ca = FactoryGirl.create(:certificate_authority)
      @cert = FactoryGirl.build(:certificate)
    end
    it "should return nil (modifies underlying cert)" do
      expect(@ca.sign!(@cert)).to eq(nil)
    end
    it "should bump CA's next serial" do
      serial = @ca.next_serial
      @ca.sign! @cert
      expect(@cert.serial).to eq(serial)
      expect(@ca.next_serial).to eq(serial+1)
    end
    it "should cause the signed cert's issuer to be this CA" do
      @ca.sign! @cert
      expect(@cert.cert.issuer.to_s).to eq(@ca.subject)
    end
  end
end
