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

class TestWithTimeNow < Minitest::Test
  class MyTime < Time ; end

  def stub_time_now
    SimpleStub.for_singleton_method(Time, :now) { 111111 }
  end

  def stub_mytime_now
    SimpleStub.for_singleton_method(MyTime, :now) { 222222 }
  end

  def stub_time_hoge
    SimpleStub.for_singleton_method(Time, :hoge) { 333333 }
  end

  def test_stub_defined_class
    original_method = Time.method(:now)
    stub_time_now.apply!
    assert Time.now == 111111
    assert MyTime.now == 111111
    stub_time_now.reset!
    assert Time.now != 111111
    assert_equal original_method, Time.method(:now)
  end

  def test_stub_defined_in_super_class
    stub_mytime_now.apply!
    assert Time.now != 111111
    assert MyTime.now == 222222
    stub_mytime_now.reset!
    assert MyTime.now != 222222
  end

  def test_stub_undefined_class
    stub_time_hoge.apply!
    assert Time.hoge == 333333
    stub_time_hoge.reset!
    assert !Time.respond_to?(:hoge)
  end

  def teardown
    stub_time_now.reset
    stub_mytime_now.reset
    stub_time_hoge.reset
  end
end

class TestWithDogInstance < Minitest::Test
  class Base
    def hello
      'base'
    end

    def name
      '--name--'
    end
  end

  class Dog < Base
    def hello
      'dog'
    end

    def greet
      hello
    end
  end

  def setup
    @dog = Dog.new
  end

  def stub_hello
    SimpleStub.for_singleton_method(@dog, :hello) { 111111 }
  end

  def stub_name
    SimpleStub.for_singleton_method(@dog, :name) { 222222 }
  end

  def stub_greet
    SimpleStub.for_singleton_method(@dog, :greet) { 333333 }
  end

  def stub_hoge
    SimpleStub.for_singleton_method(@dog, :hoge) { 444444 }
  end

  def teardown
    stub_hello.reset
    stub_name.reset
    stub_greet.reset
    stub_hoge.reset
  end

  def test_stub_defined_method
    stub_hello.apply!
    assert @dog.hello == 111111
    assert @dog.greet == 111111
    assert Dog.new.hello == 'dog'
    stub_hello.reset!
    assert @dog.hello == 'dog'
  end

  def test_stub_defined_method2
    stub_greet.apply!
    assert @dog.hello == 'dog'
    assert @dog.greet == 333333
    assert Dog.new.greet == 'dog'
    stub_greet.reset!
    assert @dog.greet == 'dog'
  end

  def test_stub_defined_method_in_superclass
    stub_name.apply!
    assert @dog.name == 222222
    assert Dog.new.name == '--name--'
    stub_name.reset!
    assert @dog.name == '--name--'
  end
end
