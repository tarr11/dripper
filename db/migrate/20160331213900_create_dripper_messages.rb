class CreateDripperMessages < ActiveRecord::Migration
  def change
    create_table :dripper_messages do |t|
      t.references :drippable, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
