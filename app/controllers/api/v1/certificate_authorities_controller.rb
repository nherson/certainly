# Receives actions pertaining to the CertificateAuthority model
class Api::V1::CertificateAuthoritiesController < ApplicationController

  before_action :load_ca, only: [:pem, :der, :info, :destroy]

  # Creates a new CA and saves it to the DB
  def create
    @ca = CertificateAuthority.new(certificate_authority_params)
    begin
      @ca.subject = OpenSSL::X509::Name.parse(params[:certificate_authority][:subject])
    rescue
      render json: {errors: ["invalid subject format"]}, status: 400
    end
    @ca.generate_ca_data!
    if @ca.save
      render nothing: true, status: :created
    else
      render json: {errors: @ca.errors.to_hash.values.flatten}, status: 400
    end
  end

  # Should return as much easily digestible info as possible
  def info
    render json: {name: @ca.name, 
                  subject: @ca.subject.to_s,
                  ca_cert: @ca.ca_cert.to_pem}
  end

  def pem
    render body: @ca.to_pem, content_type: pem_mime
  end

  def der
    render body: @ca.to_der, content_type: der_mime
  end

  def destroy
    @ca.destroy
  end

  private

  def load_ca
    begin
      @ca ||= CertificateAuthority.find(params[:id])
      true
    rescue
      render json: {errors: ["CA not found"]}, :status => 400
      false
    end
  end

  def certificate_authority_params
    params.require(:certificate_authority).permit(:name)
  end
end
