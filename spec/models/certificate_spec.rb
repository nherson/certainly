require 'rails_helper'

RSpec.describe Certificate, type: :model do
  describe "validity" do
    before :each do
      @cert = FactoryGirl.build(:certificate)
    end
    it "is valid when signed by parent CA" do
      @cert.certificate_authority.sign(@cert)
      expect(@cert.valid?).to eq(true)
    end
    it "is invalid when not signed by parent CA" do
      @other_ca = FactoryGirl.create(:certificate_authority)
      @other_ca.sign(@cert)
      expect(@cert.valid?).to eq(false)
    end
    it "is invalid when not signed at all" do
      expect(@cert.valid?).to eq(false)
    end
  end
end
