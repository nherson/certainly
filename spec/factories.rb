FactoryGirl.define do
  factory :certificate_authority do
    name "Test CA"
    subject "/CN=Certainly Test CA/OU=certainly/O=nherson/L=Berkeley/ST=CA/C=US"
    before(:create) { |ca| ca.generate_ca_data! }
  end
end

