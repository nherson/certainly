# Includes methods useful for rendering responses
# from API calls across different controllers
module RenderHelper
  def pem_mime
    'application/x-pem-file'
  end

  def der_mime
    'application/x-x509-ca-cert'
  end
end
