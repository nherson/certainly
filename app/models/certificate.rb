require 'openssl_serializer'
class Certificate < ActiveRecord::Base
  belongs_to :certificate_authority

  validates :serial, presence: true
  validates :cert, presence: true
  validate :signed
  validate :serial_matches_cert

  serialize :cert, CertificateSerializer

  def signed
    if not cert.verify(certificate_authority.ca_cert.public_key)
      errors.add(:cert, "Certificate is not signed by indicated parent CA")
    end
  end

  def serial_matches_cert
    if not serial == cert.serial
      errors.add(:cert, "Serial in Certificate model does not match certificate data")
    end
  end

  def not_before
    return cert.not_before
  end

  def not_after
    return cert.not_after
  end

  def subject
    return cert.subject
  end

  def pem
    return cert.to_pem
  end

  def der
    return cert.to_der
  end

end
