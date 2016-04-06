require "dripper/engine"

module Dripper
  @registry = []

  def self.registry
    @registry
  end

  def self.config(opts={}, &block)
    DripperProxy.new(opts, &block)
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
  end

  def dripper(opts={}, &block)
    proxy = DripperProxy.new opts.merge(parent: self), &block
    @children << proxy
  end


  def execute(association)

    association = get_association(self.model, self.scope)

    association.each do |obj|
      # instantiate the mailer and run the code
      mailer_obj = self.mailer
      mail_obj = mailer.send self.action, obj
      mail_obj.deliver_now
    end

  end
end
