require 'test_helper'
require 'mocha'
require 'mocha/mini_test'

module Dripper
  class RunTwiceTest < ActiveSupport::TestCase

    def setup
      Dripper.config model: :users do
        dripper mailer: :user_mailer do
          dripper action: :welcome
          dripper action: :newsletter, scope: -> {has_username}
        end
      end

      # create the mailer
      User.create!(email: "foo@bar.com", username: "foo")
      User.create!(email: "foo2@bar.com")
      User.create!(email: "foo3@bar.com")
      # run it once
      Dripper.execute
    end


    def teardown
      Dripper.registry.clear
    end

    test "2nd Run" do

      # make sure it never runs again for the same users
      msg = mock()
      msg.stubs(:deliver_now)

      # expect that welcome was called 2x, newsletter called once
      UserMailer.stubs(:welcome)
        .with(instance_of(User))
        .returns(msg)
        .never

      UserMailer.stubs(:newsletter)
        .with(instance_of(User))
        .returns(msg)
        .never

      Dripper.execute

    end

  end
end
