require "dripper/engine"
require "dripper/drippable"
require "dripper/dripper_job"

module Dripper
  # this file is called dripper_mail because the gem needs to be named the same as the default file
  @registry = []
  mattr_accessor :job_queue

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
  attr_accessor :wait
  attr_accessor :wait_until

  def initialize(opts={}, &block)
    @scopes = []
    # if there's a parent, initialize all values to the parent values first
    # then override with children
    [:model, :mailer, :action, :wait, :wait_until].each do |method|
      parent = opts[:parent]
      if parent
        instance_variable_set "@#{method}", parent.send(method)
      end
    end

    #overwrite any defined options
    opts.each { |k,v| instance_variable_set("@#{k}", v) }
    if opts[:scope]
      @scopes << opts[:scope] 
    end

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
    # don't register until migrations have completed
    if ActiveRecord::Base.connection.data_source_exists? 'dripper_actions'
      Dripper::Action.where(action: self.action.to_s, mailer: self.mailer.to_s).first_or_create
    end
  end

  def scoped_recs(item = nil)

    dripper_action = Dripper::Action.find_by(action: self.action.to_s, mailer: self.mailer.to_s)

    all_recs = self.model.to_s.classify.constantize.send(:all)

      # only send if we haven't already
    already_sent = Dripper::Message
      .where(drippable_type: self.model.to_s.classify.to_s, dripper_action_id: dripper_action.id)
      .select(:drippable_id)

    final_scope = all_recs
      .where.not(id: already_sent)
      .where("#{self.model.to_s.classify.constantize.table_name}.created_at >= ?", dripper_action.created_at.change(usec: 0))

    # merge all the scopes
    @scopes.each do |s|
      final_scope = final_scope.merge s
    end

    if item
      final_scope = final_scope.where(id: item.id)
    end

    return final_scope

  end

  def execute(item = nil)

    dripper_action = Dripper::Action.find_by(action: self.action.to_s, mailer: self.mailer.to_s)
    scoped_recs(item).each do |obj|

      # instantiate the mailer and run the code
      mailer_obj = self.mailer.to_s.classify.constantize
      mail_obj = mailer_obj.send self.action, obj
      if mail_obj
        if self.wait
          if self.wait.respond_to? :call
            wait_date = self.wait.call
          else
            wait_date = self.wait
          end
          mail_obj.deliver_later(wait: wait_date)
        elsif self.wait_until
          if self.wait_until.respond_to? :call
            wait_date = self.wait_until.call
          else
            wait_date = self.wait_until
          end
          mail_obj.deliver_later(wait_until: wait_date)
        else
          mail_obj.deliver_now
        end

        # insert a row
        Dripper::Message.create!(dripper_action_id: dripper_action.id, drippable: obj)
      end

    end


  end
end
