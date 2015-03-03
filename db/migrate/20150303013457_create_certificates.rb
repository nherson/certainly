class CreateCertificates < ActiveRecord::Migration
  def change
    create_table :certificates do |t|
      t.text :cert
      t.integer :serial
      t.belongs_to :certificate_authority

      t.timestamps
    end
    add_index :certificates, [:certificate_authority_id, :serial], unique: true
  end
end
