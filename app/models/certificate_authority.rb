require 'openssl_serializer'
class CertificateAuthority < ActiveRecord::Base

  validates :name, :presence => true
  validates :private_key, :presence => true
  validates :ca_cert, :presence => true
  validates :subject, :presence => true
  validates :next_serial, :presence => true
  validate :key_matches_cert
  # 'and_issuer' so long as external signers not supported
  validate :subject_matches_cert_and_issuer

  serialize :ca_cert, CertificateSerializer
  serialize :private_key, PrivateKeySerializer
  serialize :subject, SubjectSerializer

  has_many :certificates

  # generate a key, self.ca_cert, etc
  def generate_ca_data!
    self.private_key = OpenSSL::PKey::RSA.new(2048)
    public_key = private_key.public_key

    self.ca_cert = OpenSSL::X509::Certificate.new
    self.ca_cert.subject = self.ca_cert.issuer = self.subject # self-signed
    self.ca_cert.not_before = Time.now
    self.ca_cert.not_after = Time.now + 365 * 24 * 60 * 60 * 10 #TODO change from hardcoded 10 years
    self.ca_cert.public_key = public_key
    self.ca_cert.serial = 0x0
    self.next_serial = 0x1
    self.ca_cert.version = 2

    ef = OpenSSL::X509::ExtensionFactory.new
    ef.subject_certificate = ca_cert
    ef.issuer_certificate = ca_cert
    # TODO Make this changeable
    self.ca_cert.extensions = [
        ef.create_extension("basicConstraints","CA:TRUE", true),
        ef.create_extension("subjectKeyIdentifier", "hash"),
    ]
    self.ca_cert.add_extension ef.create_extension("authorityKeyIdentifier", "keyid:always,issuer:always")

    self.ca_cert.sign private_key, OpenSSL::Digest::SHA1.new
  end

  # Given a CSR, hands back a certificate signed by this CA
  # also bumps the serial number on this CA
  def sign!(cert)
    openssl_cert = cert.cert # because model -> OpenSSL object
    openssl_cert.serial = self.next_serial
    cert.serial = self.next_serial
    openssl_cert.issuer = ca_cert.subject
    openssl_cert.sign private_key, OpenSSL::Digest::SHA1.new
    self.next_serial = self.next_serial + 1
    self.save
    nil
  end

  # Merges CA profile and CSR requested fields onto a new, unsigned Certificate object
  def prepare_certificate(csr)
    cert = OpenSSL::X509::Certificate.new
    cert.subject = csr.subject
    cert.public_key = csr.public_key
    cert
  end

  # Helper methods that let you avoid statements like @ca.ca_cert.to_pem
  def to_pem
    ca_cert.to_pem
  end

  def to_der
    ca_cert.to_der
  end

  def not_before
    ca_cert.not_before
  end

  def not_after
    ca_cert.not_after
  end

  # VALIDATIONS

  def key_matches_cert
    begin
      errors.add(:private_key, "Private key and CA certificate do not match") unless ca_cert.check_private_key(private_key)
    rescue
      errors.add(:private_key, "Private key or CA certificate corrupt or missing")
    end
  end

  def subject_matches_cert_and_issuer
    begin
      errors.add(:subject, "Subject does not match CA certificate subject") unless ca_cert.subject == subject
    rescue
    end
  end
end
