module Dripper
  class Message < ActiveRecord::Base
    belongs_to :drippable, polymorphic: true
  end
end
