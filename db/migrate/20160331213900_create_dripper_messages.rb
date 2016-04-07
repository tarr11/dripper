class CreateDripperMessages < ActiveRecord::Migration
  def change
    create_table :dripper_messages do |t|
      t.references :drippable, polymorphic: true, index: true, null: false

      t.timestamps null: false
    end
    create_table :dripper_actions do |t|
      t.string :mailer, null: false
      t.string :action, null: false

      t.timestamps null: false
    end

    add_reference :dripper_messages, :dripper_action, index: true, foreign_key: true
  end
end
