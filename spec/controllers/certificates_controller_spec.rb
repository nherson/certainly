require 'rails_helper'

RSpec.describe CertificatesController, type: :controller do

  describe "#show" do
    context 'the certificate exists' do
      before :each do
        @cert = double("Certificate")
        allow(@cert).to receive(:subject) { [["CN", "Freddy Five Fingers"], ["ST", "CA"]] }
        allow(@cert).to receive(:not_before) { Time.now }
        allow(@cert).to receive(:not_after) { Time.now + 1000 }
        allow(Certificate).to receive(:find) { @cert }
      end
      it 'returns JSON information about the certificate' do
        get :show, ca_id: 1, id: 1 
        h = JSON.parse(response.body)
        expect(h["subject"]).to eq(@cert.subject)
        expect(h["not_before"]).to eq(@cert.not_before.to_s)
        expect(h["not_after"]).to eq(@cert.not_after.to_s)
      end
      it 'responds with 200 status' do
        get :show, ca_id: 1, id: 1 
        expect(response.response_code).to eq(200)
      end
    end
    context 'the certificate does not exist' do
      it "returns JSON with an 'error' key" do
        get :show, ca_id: 777, id: 666
        h = JSON.parse(response.body)
        expect(h["error"]).to eq("certificate not found")
      end
      it "responds with 404 status" do
        get :show, ca_id: 777, id: 666
        expect(response.response_code).to eq(404)
      end
    end
  end

  describe '#pem' do
    context 'the certificate exists' do
      before :each do
        @cert = FactoryGirl.create(:certificate)
      end
      context 'the requestor does not specify a format (default to PEM)' do
        before :each do
          get :pem, ca_id: @cert.certificate_authority_id, id: @cert.id
        end
        it 'returns PEM format' do
          expect(response.body).to eq(@cert.pem)
        end
        it 'responds with 200 status' do
          expect(response.response_code).to eq(200)
        end
      end
      context 'the requestor specifies PEM format' do
        before :each do
          get :pem, ca_id: @cert.certificate_authority_id, id: @cert.id, format: 'pem'
        end
        it 'returns PEM format' do
          expect(response.body).to eq(@cert.pem)
        end
        it 'responds with 200 status' do
          expect(response.response_code).to eq(200)
        end
      end
      context 'the requestor specifies DER format' do
        before :each do
          get :pem, ca_id: @cert.certificate_authority_id, id: @cert.id, format: 'DER' #uppercase to make sure the controller downcases
        end
        it 'returns DER format' do
          expect(response.body).to eq(@cert.der)
        end
        it 'responds with 200 status' do
          expect(response.response_code).to eq(200)
        end
      end
      context 'the requestor specifies an unknown format' do
        before :each do
          get :pem, ca_id: @cert.certificate_authority_id, id: @cert.id, format: 'weird format'
        end
        it 'returns an error' do
          expect(JSON.parse(response.body)["error"]).to eq("unknown format specified: weird format")
        end
        it 'responds with 400 status' do
          expect(response.response_code).to eq(400)
        end
      end
    end
    context 'the certificate does not exist' do
      it 'returns an error message' do
        get :pem, ca_id: 777, id: 666
        h = JSON.parse(response.body)
        expect(h["error"]).to eq("certificate not found")
      end
      it 'responds with 404 status' do
        get :pem, ca_id: 777, id: 666
        expect(response.response_code).to eq(404)
      end
    end
  end

  describe '#create', pending: true do
    
  end
end
