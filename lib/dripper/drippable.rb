# yaffle/lib/yaffle/acts_as_yaffle.rb
module Dripper
  module Drippable
    extend ActiveSupport::Concern

    included do
      after_create :execute_drippers

      def execute_drippers
        # find any drippers for this class and try to execute them
        Dripper.registry.select{|r| r.model == self.class.table_name.underscore.to_sym}.each do |r|
          r.execute self
        end
      end
    end

  end
end

