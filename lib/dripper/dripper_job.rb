class DripperJob < ActiveJob::Base
  queue_as :default

  def perform(obj)
    # find any drippers for this class and try to execute them
    Dripper.registry.select{|r| r.model == obj.class.table_name.underscore.to_sym}.each do |r|
      r.execute obj
    end
  end
 
end
