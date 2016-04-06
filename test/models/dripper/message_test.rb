require 'test_helper'

module Dripper
  class MessageTest < ActiveSupport::TestCase
    require 'dripper'
    test "simple case" do
      d = Dripper.config model: :users do
        dripper mailer: :welcome_mailer, action: :welcome do
          dripper mailer: :welcome_mailer, action: :welcome2
        end
        dripper mailer: :foo_mailer, action: :welcome
      end
      byebug
    end
  end
end
