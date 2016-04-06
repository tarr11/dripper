class AddActionToMessage < ActiveRecord::Migration
  def change
    add_reference :dripper_messages, :dripper_action, index: true, foreign_key: true
  end
end
