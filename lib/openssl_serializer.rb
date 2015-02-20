class CertificateSerializer
  def self.load(pem)
    OpenSSL::X509::Certificate.new(pem)
  end

  def self.dump(cert)
    cert.to_pem
  end
end

class PrivateKeySerializer
  def self.load(pem)
    OpenSSL::PKey::RSA.new(pem)
  end

  def self.dump(privkey)
    privkey.to_pem
  end
end
