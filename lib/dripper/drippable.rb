# yaffle/lib/yaffle/acts_as_yaffle.rb
module Dripper
  module Drippable
    extend ActiveSupport::Concern

    included do
      after_create :execute_drippers

      def execute_drippers
        DripperJob.perform_later self
      end
    end

  end
end

