module Dripper
  class Message < ActiveRecord::Base
    validates :drippable, presence: true
    belongs_to :drippable, polymorphic: true

    belongs_to :action
  end
end
