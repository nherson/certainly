require 'rails_helper'
require 'json'

RSpec.describe Api::V1::CertificateAuthoritiesController, type: :controller do

  describe "#create" do
    it "responds with success when given name and subject" do
      post :create, certificate_authority: {name: "My CA", subject: "/CN=My Sweet CA"}
      expect(response).to be_success
      expect(response.response_code).to eq(201)
    end
    it "responds with an error when no name" do
      post :create, certificate_authority: {subject: "/CN=My Sweet CA"}
      expect(response).not_to be_success
      expect(response.response_code).to eq(400)
    end
  end

  describe "#info" do
    it "responds with public information about the CA" do
      @ca = FactoryGirl.create(:certificate_authority)
      get :info, id: @ca.id
      info = JSON.parse(response.body)
      expect(info["name"]).to eq(@ca.name)
      expect(info["ca_cert"]).to eq(@ca.ca_cert.to_pem)
    end
  end

  describe "#pem" do
    before :each do
      @ca = FactoryGirl.create(:certificate_authority)
    end
    it "responds with PEM" do
      get :pem, id: @ca.id
      expect(response.body).to eq(@ca.to_pem)
    end
    it "has the proper MIME type for pem files" do
      get :pem, id: @ca.id
      expect(response.content_type).to eq('application/x-pem-file')
    end
    it "responds with an error when the CA doesn't exist" do
      get :pem, id: 45
      expect(JSON.parse(response.body)["errors"][0]).to eq("CA not found")
      expect(response.response_code).to eq(400)
    end
  end

  describe "#der" do
    before :each do
      @ca = FactoryGirl.create(:certificate_authority)
    end
    it "responds with DER" do
      get :der, id: @ca.id
      expect(response.body).to eq(@ca.to_der)
    end
    it "has the proper MIME type for DER files" do
      get :der, id: @ca.id
      expect(response.content_type).to eq('application/x-x509-ca-cert')
    end
    it "responds with an error when the CA doesn't exist" do
      get :der, id: 45
      expect(JSON.parse(response.body)["errors"][0]).to eq("CA not found")
      expect(response.response_code).to eq(400)
    end
  end

  describe "#destroy" do
    it "destroys an existing CA" do
      @ca = FactoryGirl.create(:certificate_authority)
      delete :destroy, id: @ca.id
      expect(response).to be_success
      expect { CertificateAuthority.find(@ca.id) }.to raise_error
    end
    it "errors if deleting a CA that doesn't exist" do
      delete :destroy, id: 12345
      expect(response).not_to be_success
      expect(response.response_code).to eq(400)
      resp = JSON.parse(response.body)
      expect(resp["errors"]).to eq(["CA not found"])
    end
  end
end
