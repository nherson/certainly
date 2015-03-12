class CertificateSerializer
  def self.load(pem)
    OpenSSL::X509::Certificate.new(pem) unless pem.nil?
  end

  def self.dump(cert)
    cert.to_pem
  end
end

class PrivateKeySerializer
  def self.load(pem)
    OpenSSL::PKey::RSA.new(pem) unless pem.nil?
  end

  def self.dump(privkey)
    privkey.to_pem
  end
end

class SubjectSerializer
  def self.load(str)
    OpenSSL::X509::Name.parse(str)
  end
  def self.dump(name)
    name.to_s
  end
end
