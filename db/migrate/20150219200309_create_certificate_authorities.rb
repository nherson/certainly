class CreateCertificateAuthorities < ActiveRecord::Migration
  def change
    create_table :certificate_authorities do |t|
      t.string :name
      t.text :private_key
      t.text :ca_cert
      t.string :subject

      t.timestamps
    end
  end
end
