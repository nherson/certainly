require 'rails_helper'

RSpec.describe Api::V1::CertificatesController, type: :controller do

  describe "#info" do
    context 'the certificate exists' do
      before :each do
        @cert = double("Certificate")
        allow(@cert).to receive(:subject) { [["CN", "Freddy Five Fingers"], ["ST", "CA"]] }
        allow(@cert).to receive(:not_before) { Time.now }
        allow(@cert).to receive(:not_after) { Time.now + 1000 }
        allow(Certificate).to receive(:find) { @cert }
      end
      it 'returns JSON information about the certificate' do
        get :info, ca_id: 1, id: 1 
        h = JSON.parse(response.body)
        expect(h["subject"]).to eq(@cert.subject)
        expect(h["not_before"]).to eq(@cert.not_before.to_s)
        expect(h["not_after"]).to eq(@cert.not_after.to_s)
      end
      it 'responds with 200 status' do
        get :info, ca_id: 1, id: 1 
        expect(response.response_code).to eq(200)
      end
    end
    context 'the certificate does not exist' do
      it "returns JSON with an 'error' key" do
        get :info, ca_id: 777, id: 666
        h = JSON.parse(response.body)
        expect(h["errors"]).to eq(["certificate not found"])
      end
      it "responds with 404 status" do
        get :info, ca_id: 777, id: 666
        expect(response.response_code).to eq(404)
      end
    end
  end

  describe '#pem' do
    before :each do
      @cert = FactoryGirl.create(:certificate)
    end
    it "returns the PEM of the certificate" do
      get :pem, ca_id: @cert.certificate_authority_id, id: @cert.id
      expect(response.body).to eq(@cert.to_pem)
    end
    it "returns with a 200 status code" do
      get :pem, ca_id: @cert.certificate_authority_id, id: @cert.id
      expect(response.response_code).to eq(200)
    end
    it "contains the proper MIME type" do
      get :pem, ca_id: @cert.certificate_authority_id, id: @cert.id
      expect(response.content_type).to eq('application/x-pem-file')
    end
    it "returns a json formatted error when the certificate does not exist" do
      get :pem, ca_id: 777, id: 666
      expect(response.response_code).to eq(404)
      expect(JSON.parse(response.body)["errors"]).to eq(["certificate not found"])
    end
  end

  describe '#der' do
    before :each do
      @cert = FactoryGirl.create(:certificate)
    end
    it "returns the DER of the certificate" do
      get :der, ca_id: @cert.certificate_authority_id, id: @cert.id
      expect(response.body).to eq(@cert.to_der)
    end
    it "returns with a 200 status code" do
      get :der, ca_id: @cert.certificate_authority_id, id: @cert.id
      expect(response.response_code).to eq(200)
    end
    it "contains the proper MIME type" do
      get :der, ca_id: @cert.certificate_authority_id, id: @cert.id
      expect(response.content_type).to eq('application/x-x509-ca-cert')
    end
    it "returns a json formatted error when the certificate does not exist" do
      get :der, ca_id: 777, id: 666
      expect(response.response_code).to eq(404)
      expect(JSON.parse(response.body)["errors"]).to eq(["certificate not found"])
    end
  end
    
  describe '#create', pending: true do
  end
   
end
