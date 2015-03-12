FactoryGirl.define do  
  factory :certificate do
    certificate_authority
    serial 13
    cert OpenSSL::X509::Certificate.new
    # include most basic cert information
    after(:build) do |c|
      c.cert.subject = OpenSSL::X509::Name.new([["CN", "bomb.com"], ["ST", "CA"]])
      c.cert.public_key = OpenSSL::PKey::RSA.new(1024).public_key
      c.cert.not_before = Time.now
      c.cert.not_after = Time.now + 365 * 24 * 60 *60
      c.cert.serial = c.serial
      c.cert.version = 2
    end
    # sign before saving to db
    before(:create) do |c|
      c.certificate_authority.sign!(c)
    end
  end

  factory :certificate_authority do
    name "Test CA"
    subject OpenSSL::X509::Name.parse("/CN=Certainly Test CA/OU=certainly/O=nherson/L=Berkeley/ST=CA/C=US")
    next_serial 1
    before(:create) { |ca| ca.generate_ca_data! }
  end
end

