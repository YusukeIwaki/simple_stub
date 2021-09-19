# frozen_string_literal: true

require 'minitest/autorun'
require 'simple_stub'

class TestForInstanceMethodExample < Minitest::Test
  class Dog
    def hello
      'Hello!'
    end
  end

  def test_example_dog
    dog1 = Dog.new
    stub_dog_hello = SimpleStub.for_instance_method(Dog, :hello) { 'Bow' }
    stub_dog_hello.apply!
    assert_equal 'Bow', dog1.hello
    assert_equal 'Bow', Dog.new.hello
    stub_dog_hello.reset!
    assert_equal 'Hello!', dog1.hello
    assert_equal 'Hello!', Dog.new.hello
  end
end

class TestDuplicatedStubInstanceMethod < Minitest::Test
  class Dog
    def hello
      'Hello!'
    end
  end

  def stub_dog_hello1
    SimpleStub.for_instance_method(Dog, :hello) { 'Hello1' }
  end

  def stub_dog_hello2
    SimpleStub.for_instance_method(Dog, :hello) { 'Hello2' }
  end

  def teardown
    stub_dog_hello1.reset
    stub_dog_hello2.reset
  end

  def test_dup_apply
    stub_dog_hello1.apply
    stub_dog_hello2.apply
    assert_equal 'Hello1', Dog.new.hello
  end

  def test_dup_apply!
    stub_dog_hello1.apply!
    assert_raises(SimpleStub::AlreadyAppliedError) do
      stub_dog_hello2.apply!
    end
  end

  def test_reset_only
    assert_equal 'Hello!', Dog.new.hello
    stub_dog_hello1.reset
    assert_equal 'Hello!', Dog.new.hello
  end

  def test_dup_reset!
    stub_dog_hello2.apply!
    stub_dog_hello1.reset!
    assert_raises(SimpleStub::NotAppliedError) do
      stub_dog_hello2.reset!
    end
  end
end

class TestForInstanceMethodOfSubclassOrModule < Minitest::Test
  module Hello2
    def hello2
      'hello-2'
    end
  end

  class Hello
    include Hello2

    def hello1
      'hello-1'
    end
  end

  class SubHello < Hello
    def hello1
      "SUB - #{super}"
    end

    def hello3
      "hello - #{hello2}"
    end
  end

  def stub_hello_hello1
    SimpleStub.for_instance_method(Hello, :hello1) do
      ">> #{super()} <<"
    end
  end

  def stub_hello_hello2
    SimpleStub.for_instance_method(Hello, :hello2) do
      "->> #{super()} <<-"
    end
  end

  def stub_subhello_hello2
    SimpleStub.for_instance_method(SubHello, :hello2) do
      "->> #{super()} <<-"
    end
  end

  def stub_subhello_hello1
    SimpleStub.for_instance_method(SubHello, :hello1) do
      ">>> #{super()} <<<"
    end
  end

  def teardown
    stub_hello_hello1.reset
    stub_hello_hello2.reset
    stub_subhello_hello2.reset
    stub_subhello_hello1.reset
  end

  def test_stubbing_instance_method
    hello = Hello.new
    stub_hello_hello1.apply!
    assert_equal '>> hello-1 <<', hello.hello1
    assert_equal '>> hello-1 <<', Hello.new.hello1
    assert_equal 'SUB - >> hello-1 <<', SubHello.new.hello1
    stub_hello_hello1.reset!
    assert_equal 'hello-1', hello.hello1
    assert_equal 'hello-1', Hello.new.hello1
    assert_equal 'SUB - hello-1', SubHello.new.hello1
  end

  def test_stubbing_instance_method_defined_in_module
    hello = Hello.new
    stub_hello_hello2.apply!
    assert_equal '->> hello-2 <<-', hello.hello2
    assert_equal '->> hello-2 <<-', Hello.new.hello2
    assert_equal '->> hello-2 <<-', SubHello.new.hello2
    assert_equal 'hello - ->> hello-2 <<-', SubHello.new.hello3
    stub_hello_hello2.reset!
    assert_equal 'hello-2', hello.hello2
    assert_equal 'hello-2', Hello.new.hello2
    assert_equal 'hello-2', SubHello.new.hello2
    assert_equal 'hello - hello-2', SubHello.new.hello3
  end

  def test_stubbing_instance_method_defined_in_module_of_superclass
    subhello = SubHello.new
    stub_subhello_hello2.apply!
    assert_equal '->> hello-2 <<-', subhello.hello2
    assert_equal 'hello-2', Hello.new.hello2
    assert_equal '->> hello-2 <<-', SubHello.new.hello2
    assert_equal 'hello - ->> hello-2 <<-', SubHello.new.hello3
    stub_subhello_hello2.reset!
    assert_equal 'hello-2', subhello.hello2
    assert_equal 'hello-2', Hello.new.hello2
    assert_equal 'hello-2', SubHello.new.hello2
    assert_equal 'hello - hello-2', SubHello.new.hello3
  end

  def test_stubbing_me_and_super
    stub_subhello_hello1.apply!
    assert_equal '>>> SUB - hello-1 <<<', SubHello.new.hello1
    assert_equal 'hello-1', Hello.new.hello1
    stub_hello_hello1.apply!
    assert_equal '>>> SUB - >> hello-1 << <<<', SubHello.new.hello1
    assert_equal '>> hello-1 <<', Hello.new.hello1
  end

  def test_apply_twice
    stub_hello_hello1.apply!
    stub_hello_hello1.apply
    stub_hello_hello1.apply
    assert_equal '>> hello-1 <<', Hello.new.hello1
  end
end
