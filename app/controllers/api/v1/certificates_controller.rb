# Controller for actions relating to the Certificate model
class Api::V1::CertificatesController < ApiController
  before_action :load_cert, only: [:info, :pem, :der]

  # Should return as much info about the cert as possible
  def info
    resp = { subject: @cert.subject,
             not_before: @cert.not_before.to_s,
             not_after: @cert.not_after.to_s }
    render json: resp
  end

  def pem
    render body: @cert.to_pem, content_type: pem_mime
  end

  def der
    render body: @cert.to_der, content_type: der_mime
  end

  private

  def load_cert
    begin
      @cert ||= Certificate.find(params[:id])
      true
    rescue
      render json: {errors: ["certificate not found"]}, status: 404
      false
    end
  end

end
