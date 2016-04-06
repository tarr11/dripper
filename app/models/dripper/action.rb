module Dripper
  class Action < ActiveRecord::Base
    validates :action, presence: true
    validates :mailer, presence: true
  end
end
