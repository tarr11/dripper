module Dripper
  module Drippable
    extend ActiveSupport::Concern

    included do
      after_create :execute_drippers
      after_update :execute_drippers
      after_touch :execute_drippers

      def execute_drippers
        DripperJob.perform_later self
      end
    end

  end
end

