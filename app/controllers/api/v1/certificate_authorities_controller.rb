class Api::V1::CertificateAuthoritiesController < ApplicationController

  # Creates a new CA and saves it to the DB
  def create
    @ca = CertificateAuthority.new(certificate_authority_params)
    ca_data = @ca.generate_ca_data!
    if @ca.save
      render :nothing => true, :status => :created
    else
      render :json => {"errors" => @ca.errors.to_hash}, :status => 400
    end
  end

  def info
    ca_not_found and return unless ca
    render :json => {:name => @ca.name, :ca_cert => @ca.ca_cert.to_pem}
  end

  # Just responds with the the CA's certificate data (no JSON nonsense)
  def ca_cert
    ca_not_found and return unless ca
    if params[:format] == 'der'
      data = @ca.ca_cert.to_der
      content = 'application/x-x509-ca-cert'
    elsif params[:format] == 'pem' or not params[:format]
      data = @ca.ca_cert.to_pem
      content = 'application/x-pem-file'
    else
      render :json => {"errors" => ["#{params[:format]} is an invalid certificate encoding"]}, :status => 400
      return
    end
    render :plain => data, :content_type => content
  end

  def destroy
    ca_not_found and return unless ca
    @ca.destroy
  end

  private

  def ca
    begin
      @ca ||= CertificateAuthority.find(params[:id])
    rescue
      nil
    end
  end

  def ca_not_found
    render :json => {"errors" => ["CA not found"]}, :status => 400
  end

  def certificate_authority_params
    params.require(:certificate_authority).permit(:name, :subject)
  end

end
