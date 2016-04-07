class Newsletter < ActiveRecord::Base
  include Dripper::Drippable
  belongs_to :user
end
