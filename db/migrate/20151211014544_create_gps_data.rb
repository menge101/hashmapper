class CreateGpsData < ActiveRecord::Migration
  def change
    create_table :gps_data do |t|
      t.integer :count
      t.json :data
    end
  end
end
