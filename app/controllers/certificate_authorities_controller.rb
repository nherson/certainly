class CertificateAuthoritiesController < ApplicationController

  # Creates a new CA and saves it to the DB
  def create
    @ca = CertificateAuthority.new(certificate_authority_params)
    ca_data = @ca.generate_ca_data!(params[:certificate_authority][:subject])
    @ca.private_key = ca_data[:private_key]
    @ca.ca_cert = ca_data[:ca_cert]
    if @ca.save
      # happy path
      # return the ca_cert itself with a 200
    else
      # sad path
      # return some JSON saying it was an error and why
    end
  end

  # returns the CA cert
  def show
    @ca = CertificateAuthority.find(params[:id])
    render :json => {:name => @ca.name, :ca_cert => @ca.ca_cert.to_pem}
  end

  def destroy
    CertificateAuthority.find(params[:id]).destroy
  end

  private

  def certificate_authority_params
    params.require(:certificate_authority).permit(:name, :subject)
  end

end
