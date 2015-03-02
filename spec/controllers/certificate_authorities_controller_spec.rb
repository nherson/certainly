require 'rails_helper'
require 'json'

RSpec.describe CertificateAuthoritiesController, type: :controller do

  describe "#create" do
    it "responds with success when given name and subject" do
      post :create, :certificate_authority => {:name => "My CA", :subject => "/CN=My Sweet CA"}
      expect(response).to be_success
      expect(response.response_code).to eq(201)
    end
    it "responds with an error when no name" do
      post :create, :certificate_authority => {:subject => "/CN=My Sweet CA"}
      expect(response).not_to be_success
      expect(response.response_code).to eq(400)
    end
  end

  describe "#info" do
    it "responds with public information about the CA" do
      @ca = FactoryGirl.create(:certificate_authority)
      get :info, :id => @ca.id
      info = JSON.parse(response.body)
      expect(info["name"]).to eq(@ca.name)
      expect(info["ca_cert"]).to eq(@ca.ca_cert.to_pem)
    end
  end

  describe "#data" do
    before :each do
      @ca = FactoryGirl.create(:certificate_authority)
    end
    it "responds with PEM by default" do
      get :ca_cert, :id => @ca.id
      expect(response.body).to eq(@ca.ca_cert.to_pem)
    end
    it "responds with PEM when specified" do
      get :ca_cert, :id => @ca.id, :format => 'pem'
      expect(response.body).to eq(@ca.ca_cert.to_pem)
    end
    it "responds with DER when specified" do
      get :ca_cert, :id => @ca.id, :format => 'der'
      expect(response.body).to eq(@ca.ca_cert.to_der)
    end
    it "responds with an error when asked for an unknown format" do
      get :ca_cert, :id => @ca.id, :format => "nonsense"
      expect(response.response_code).to eq(400)
      resp = JSON.parse(response.body)
      expect(resp["errors"]).to eq(["nonsense is an invalid certificate encoding"])
    end
  end

  describe "#destroy" do
    it "destroys an existing CA" do
      @ca = FactoryGirl.create(:certificate_authority)
      delete :destroy, :id => @ca.id
      expect(response).to be_success
      expect { CertificateAuthority.find(@ca.id) }.to raise_error
    end
    it "errors if deleting a CA that doesn't exist" do
      delete :destroy, :id => 12345
      expect(response).not_to be_success
      expect(response.response_code).to eq(400)
      resp = JSON.parse(response.body)
      expect(resp["errors"]).to eq(["CA not found"])
    end
  end
end
