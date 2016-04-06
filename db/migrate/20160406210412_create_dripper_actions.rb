class CreateDripperActions < ActiveRecord::Migration
  def change
    create_table :dripper_actions do |t|
      t.string :mailer, null: false
      t.string :action, null: false

      t.timestamps null: false
    end
  end
end
