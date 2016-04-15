require 'test_helper'
require 'mocha'
require 'mocha/mini_test'

module Dripper
  class MessageTest < ActiveSupport::TestCase

    def setup
      # create the mailer
      User.create(email: "foo@bar.com", username: "foo")
      User.create(email: "foo2@bar.com")
      User.create(email: "foo3@bar.com")

      Dripper.config model: :users do
        dripper mailer: :user_mailer do
          dripper action: :welcome
          dripper action: :newsletter, wait: 1.minutes, scope: -> {has_username} do
            dripper action: :newsletter_2, wait: 1.minutes, scope: -> {week_old}
          end
        end
      end

    end


    def teardown
      Dripper.registry.clear
    end

    test "Config" do
      assert Dripper.registry.count == 3
    end

    test "Integration" do
      msg = mock()
      msg.stubs(:deliver_now)
      msg.stubs(:deliver_later)

      # expect that welcome was called 2x, newsletter called once
      UserMailer.stubs(:welcome)
        .with(instance_of(User))
        .returns(msg)
        .at_least(3)
        .at_most(3)

      UserMailer.stubs(:newsletter)
        .with(instance_of(User))
        .returns(msg)
        .once

      Dripper.execute

    end


  end
end
