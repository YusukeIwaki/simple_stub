# frozen_string_literal: true

require 'simple_stub/version'
require 'simple_stub/already_applied_error'
require 'simple_stub/for_instance_method'
require 'simple_stub/not_applied_error'

module SimpleStub
  # Stubs instance method.
  # This affect to any instance of the target class.
  #
  #   class Dog
  #     def hello
  #       'Hello!'
  #     end
  #   end
  #
  #   dog1 = Dog.new
  #   stub_dog_hello = SimpleStub.for_singleton_method(Dog, :hello) { 'Bow' }
  #   stub_dog_hello.apply!
  #   dog1.hello # => 'Bow'
  #   Dog.new.hello # => 'Bow'
  #   stub_dog_hello.reset!
  #   dog1.hello # => 'Hello!'
  #   Dog.new.hello # => 'Hello!'
  #
  # @param klass [Class]
  # @param method_name [Symbol]
  def for_instance_method(klass, method_name, &impl)
    ForInstanceMethod.new(klass, method_name, &impl)
  end

  # Create a definition for stubbing singleton method.
  # This can be used to stub class method like:
  #
  #   fixed_time = Time.now
  #   stub_time_now = SimpleStub.for_singleton_method(Time, :now) { fixed_time }
  #   stub_time_now.apply!
  #   # Time.now returns fixed_time here.
  #   stub_time_now.reset!
  #
  # And also can be used for stubbing method of an object instance.
  #
  #   class Dog
  #     def hello
  #       'Hello!'
  #     end
  #   end
  #
  #   dog1 = Dog.new
  #   stub_dog1 = SimpleStub.for_singleton_method(dog1, :hello) { 'Bow' }
  #   stub_dog1.apply!
  #   dog1.hello # => 'Bow'
  #   Dog.new.hello # => 'Hello!'
  #
  # @param receiver [Class|Object]
  # @param method_name [Symbol]
  def for_singleton_method(receiver, method_name, &impl)
    ForInstanceMethod.new(receiver.singleton_class, method_name, &impl)
  end

  module_function :for_instance_method, :for_singleton_method
end
