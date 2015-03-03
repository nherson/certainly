require 'openssl_serializer'
class Certificate < ActiveRecord::Base
  belongs_to :certificate_authority

  validates :serial, presence: true
  validates :cert, presence: true
  validate :signed
  validate :serial_matches_cert

  serialize :pem, CertificateSerializer

  def signed

  end

  def serial_matches_cert

  end

end
