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
