class User < ActiveRecord::Base
  scope :has_username, -> { where.not(username: nil) }
end
