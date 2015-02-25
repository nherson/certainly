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
end
