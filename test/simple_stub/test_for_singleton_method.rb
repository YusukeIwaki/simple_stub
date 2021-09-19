require 'minitest/autorun'
require 'simple_stub'

class TestForSingletonMethodExample < Minitest::Test
  def test_example_time_now
    fixed_time = Time.now
    stub_time_now = SimpleStub.for_singleton_method(Time, :now) { fixed_time }
    stub_time_now.apply!
    sleep 1
    assert_equal fixed_time, Time.now
    stub_time_now.reset!
  end

  class Dog
    def hello
      'Hello!'
    end
  end

  def test_example_dog
    dog1 = Dog.new
    stub_dog1 = SimpleStub.for_singleton_method(dog1, :hello) { 'Bow' }
    stub_dog1.apply!
    assert_equal 'Bow', dog1.hello
    assert_equal 'Hello!', Dog.new.hello
  end
end

class TestForSingletonMethodAndInstanceMethod < Minitest::Test
  class Dog
    def hello
      'hello'
    end
  end

  def setup
    @dog1 = Dog.new
  end

  def stub_dog_hello
    SimpleStub.for_instance_method(Dog, :hello) { 'Bow' }
  end

  def stub_dog1_hello
    SimpleStub.for_singleton_method(@dog1, :hello) { ">> #{super()} <<" }
  end

  def teardown
    stub_dog1_hello.reset
    stub_dog_hello.reset
  end

  def test_stub_singleton_method_before_instance_method
    stub_dog1_hello.apply!
    stub_dog_hello.apply!
    assert_equal '>> Bow <<', @dog1.hello
  end

  def test_stub_singleton_method_after_instance_method
    stub_dog_hello.apply!
    stub_dog1_hello.apply!
    assert_equal '>> Bow <<', @dog1.hello
  end
end
