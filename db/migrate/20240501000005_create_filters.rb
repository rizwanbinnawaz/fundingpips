class CreateFilters < ActiveRecord::Migration[7.0]
  def change
    create_table :filters do |t|
      t.string :name, null: false
      t.references :user, null: false, foreign_key: true
      t.string :filterable_type, null: false
      t.bigint :filterable_id, null: false
      t.jsonb :params, null: false, default: '{}'
      t.timestamps
    end

    add_index :filters, [:filterable_type, :filterable_id]
  end
end