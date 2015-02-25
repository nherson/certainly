class AddNextSerialToCertificateAuthority < ActiveRecord::Migration
  def change
    add_column :certificate_authorities, :next_serial, :integer
  end
end
