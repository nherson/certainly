class CertificateAuthoritiesController < ApplicationController
  before_filter :fetch_certificate_authority, :only => [:info, :show, :destroy]

  # Creates a new CA and saves it to the DB
  def create
    @ca = CertificateAuthority.new(certificate_authority_params)
    ca_data = @ca.generate_ca_data!
    if @ca.save
      render :nothing => true
    else
      render :json => {"errors" => @ca.errors.to_hash}
    end
  end

  def info
    render :json => {:name => @ca.name, :ca_cert => @ca.ca_cert.to_pem}
  end

  def data
    if params[:format] == "der"
      render @ca.ca_cert.to_der, :content_type => "application/x-x509-ca-cert"
    else
      render @ca.ca_cert.to_pem, :content_type => "application/x-pem-file"
    end
  end

  def destroy
    @ca.destroy
  end

  private

  def fetch_certificate_authority(id)
    begin
      @ca = CertificateAuthority.find(id)
    rescue
      render :json => {"error" => "CA not found"} and return
    end
  end

  def certificate_authority_params
    params.require(:certificate_authority).permit(:name, :subject)
  end

end
