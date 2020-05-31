require 'test_helper'
require 'mocha'
require 'mocha/mini_test'

module Dripper
  class ConcernTest < ActiveSupport::TestCase

    def setup
      Dripper.config model: :newsletters do
        dripper mailer: :user_mailer do
          dripper action: :newsletter
        end
      end

    end


    def teardown
      Dripper.registry.clear
    end

    test "Concern Test" do

      msg = mock()
      msg.stubs(:deliver_now)
      msg.stubs(:deliver_later)

      UserMailer.stubs(:newsletter)
        .with(instance_of(Newsletter))
        .returns(msg)
        .at_least(1)

      u = User.create(email: "foo@bar.com")
      Newsletter.create(user: u, title: "test")
      Dripper.execute
    end

  end
end
