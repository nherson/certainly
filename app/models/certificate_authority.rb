require 'openssl_serializer'
class CertificateAuthority < ActiveRecord::Base

  validates :name, :presence => true
  validates :private_key, :presence => true
  validates :ca_cert, :presence => true
  validates :subject, :presence => true
  validate :key_matches_cert

  serialize :ca_cert, CertificateSerializer
  serialize :private_key, PrivateKeySerializer

  has_many :certificates

  # generate a key, self.ca_cert, etc
  def generate_ca_data!(subject)
    private_key = OpenSSL::PKey::RSA.new(2048)
    public_key = private_key.public_key

    ca_cert = OpenSSL::X509::Certificate.new
    ca_cert.subject = ca_cert.issuer = OpenSSL::X509::Name.parse(subject)
    ca_cert.not_before = Time.now
    ca_cert.not_after = Time.now + 365 * 24 * 60 * 60 * 10 #TODO change from hardcoded 10 years
    ca_cert.public_key = public_key
    ca_cert.serial = 0x0
    ca_cert.version = 2

    ef = OpenSSL::X509::ExtensionFactory.new
    ef.subject_certificate = ca_cert
    ef.issuer_certificate = ca_cert
    # TODO Make this changeable
    ca_cert.extensions = [
        ef.create_extension("basicConstraints","CA:TRUE", true),
        ef.create_extension("subjectKeyIdentifier", "hash"),
    ]
    ca_cert.add_extension ef.create_extension("authorityKeyIdentifier", "keyid:always,issuer:always")

    ca_cert.sign private_key, OpenSSL::Digest::SHA1.new

    return {:private_key => private_key, :ca_cert => ca_cert}
  end

  def key_matches_cert
    privkey = OpenSSL::PKey::RSA.new(self.private_key)
    cert = OpenSSL::X509::Certificate.new(self.ca_cert)
    errors.add(:private_key, "Private key and CA certificate do not match") unless cert.check_private_key(privkey)
  end
end
