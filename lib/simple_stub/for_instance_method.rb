# frozen_string_literal: true

require 'digest'

module SimpleStub
  # Stub for instance methods, without any alias_method.
  # This class internally prepends a module into the target class.
  # #apply adds a method into the prepended module.
  # #reset removes a method from the prepended module.
  #
  # This class must be stateless for the usecase that
  # the caller of #apply and the caller of #reset can be different.
  # Both
  #
  #   @stub_user_name = SimpleStub::ForInstanceMethod(User, :name) { 'YusukeIwaki' }
  #   @stub_user_name.apply!
  #   # Any username is YusukeIwaki here
  #   @stub_user_name.reset!
  #
  # and
  #
  #   stub_user_name = SimpleStub::ForInstanceMethod(User, :name) { 'YusukeIwaki' }
  #   stub_user_name.apply!
  #   # Any username is YusukeIwaki here
  #   stub_user_name = SimpleStub::ForInstanceMethod(User, :name) { 'YusukeIwaki' }
  #   stub_user_name.reset!
  #
  # should work.
  #
  class ForInstanceMethod
    def initialize(klass, method_name, &impl)
      raise ArgumentError, "klass must be a Class. #{klass.class} specified." unless klass.is_a?(Class)
      raise ArgumentError, 'method name must be a Symbol.' unless method_name.is_a?(Symbol)

      @klass = klass
      @method_name = method_name
      @impl = impl
    end

    # Safer version of #apply!
    # Nothing happens even if already stubbed.
    def apply
      return if stub_defined?

      apply_stub
    end

    # Apply the stub. If the stub is already applied, raises error.
    def apply!
      raise AlreadyAppliedError, "The stub for #{@klass}##{@method_name} is already applied" if stub_defined?

      apply_stub
    end

    def reset
      return unless stub_defined?

      reset_stub
    end

    def reset!
      raise NotAppliedError, "The stub for #{@klass}##{@method_name} is already applied" unless stub_defined?

      reset_stub
    end

    private

    def apply_stub
      # define_method is private on Ruby <= 2.4
      impl_module.send(:define_method, @method_name, &@impl)
    end

    def reset_stub
      # remove_method is private on Ruby <= 2.4
      impl_module.send(:remove_method, @method_name)
    end

    def impl_module
      impl_module_or_nil || create_and_apply_impl_module
    end

    def impl_module_or_nil
      ForInstanceMethod.const_get(impl_module_name) if ForInstanceMethod.const_defined?(impl_module_name)
    end

    def create_and_apply_impl_module
      Module.new.tap do |mod|
        # Name the module here
        ForInstanceMethod.const_set(impl_module_name, mod)

        @klass.prepend(mod)
      end
    end

    def klass_digest
      @klass_digest ||= Digest::SHA256.hexdigest(@klass.to_s)
    end

    def impl_module_name
      @impl_module_name ||= "StubImpl#{klass_digest}"
    end

    def stub_defined?
      # Avoid creating module just in asking if stub exists.
      impl_module_or_nil&.method_defined?(@method_name)
    end
  end
end
