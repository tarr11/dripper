require "dripper/engine"

module Dripper
  @registry = []

  def self.registry
    @registry
  end

  def self.config(opts={}, &block)
    DripperProxy.new(opts, &block)
    @registry.each do |r|
      r.register
    end
  end

  def self.execute
    @registry.each do |d|
      d.execute
    end
  end

end

class DripperProxy
  attr_accessor :model
  attr_accessor :mailer
  attr_accessor :action
  attr_accessor :scope
  attr_accessor :parent
  attr_accessor :children

  def initialize(opts={}, &block)
    # if there's a parent, initialize all values to the parent values first
    # then override with children
    [:model, :mailer, :action, :scope].each do |method|
      parent = opts[:parent]
      if parent
        instance_variable_set "@#{method}", parent.send(method)
      end
    end
    opts.each { |k,v| instance_variable_set("@#{k}", v) }
    @children = []
    instance_eval(&block) if block
    # only include complete ones in the registry
    if self.action && self.mailer && self.model
      Dripper.registry << self
    end
  end

  def dripper(opts={}, &block)
    proxy = DripperProxy.new opts.merge(parent: self), &block
    @children << proxy
  end

  def register
    Dripper::Action.where(action: self.action.to_s, mailer: self.mailer.to_s).first_or_create
  end

  def execute
    dripper_action = Dripper::Action.find_by(action: self.action.to_s, mailer: self.mailer.to_s)

    all_recs = self.model.to_s.classify.constantize.send(:all)

      # only send if we haven't already
    already_sent = Dripper::Message
      .where(drippable_type: self.model.to_s.classify.to_s, dripper_action_id: dripper_action.id)
      .select(:drippable_id)

    scoped_recs =  all_recs
      .merge(self.scope)
      .where.not(id: already_sent)
      .where("#{self.model.to_s.classify.constantize.table_name}.created_at >= ?", dripper_action.created_at.change(usec: 0))


    scoped_recs.each do |obj|

      # instantiate the mailer and run the code
      mailer_obj = self.mailer.to_s.classify.constantize
      mail_obj = mailer_obj.send self.action, obj
      mail_obj.deliver_now

      # insert a row
      Dripper::Message.create!(dripper_action_id: dripper_action.id, drippable: obj)
    end


  end
end
