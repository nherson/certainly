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
      expect(@cert.cert.issuer).to eq(@ca.subject)
    end
  end

  describe "certificate helper methods" do
    before :each do
      @ca = FactoryGirl.create(:certificate_authority)
    end
    describe "#to_pem" do
      it "should return the certificate as a PEM string" do
        expect(@ca.to_pem).to eq(@ca.ca_cert.to_pem)
      end
    end
    describe "#to_der" do
      it "should return the certificate with DER encoding" do
        expect(@ca.to_der).to eq(@ca.ca_cert.to_der)
      end
    end
    describe "#not_before" do
      it "should return the start date of the CA's validity" do
        expect(@ca.not_before).to eq(@ca.ca_cert.not_before)
      end
    end
    describe "#not_after" do
      it "should return the end date of the CA's validity" do
        expect(@ca.not_after).to eq(@ca.ca_cert.not_after)
      end
    end
    describe "#subject" do
      it "should return the subject of the CA" do
        expect(@ca.subject).to eq(@ca.ca_cert.subject)
      end
    end
  end

end
