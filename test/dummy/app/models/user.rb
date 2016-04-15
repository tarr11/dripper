class User < ActiveRecord::Base
  scope :has_username, -> { where.not(username: nil) }
  scope :week_old, -> { where("users.created_at <= ?", DateTime.now - 1.weeks) }
end
