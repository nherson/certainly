class CertificatesController < ApplicationController
  def show
    certificate_not_found and return unless cert
    resp = { subject: @cert.subject,
             not_before: @cert.not_before.to_s,
             not_after: @cert.not_after.to_s }
    render :json => resp
  end

  def pem
    certificate_not_found and return unless cert
    unknown_format and return unless valid_format
    render plain: @data, content_type: @content_type
  end

  private

  def valid_format
    format = params[:format] || "pem"
    case format.downcase
    when "pem"
      @data = @cert.pem
      @content_type = "application/x-pem-file"
    when "der"
      @data = @cert.der
      @content_type = "application/x-x509-ca-cert"
    end
  end

  def unknown_format
    render json: {:error => "unknown format specified: #{params[:format]}"}, status: 400
  end

  def cert
    begin
      @cert ||= Certificate.find(params[:id])
    rescue
      nil
    end
  end

  def certificate_not_found
    render :json => {:error => "certificate not found"}, :status => 404
  end
end
