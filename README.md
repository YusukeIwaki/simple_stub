[![Gem Version](https://badge.fury.io/rb/simple_stub.svg)](https://badge.fury.io/rb/simple_stub)

# SimpleStub

Defining simple scoped stub with apply/reset interface

```ruby
fixed_time = Time.now
stub_time_now = SimpleStub.for_singleton_method(Time, :now) { fixed_time }

stub_time_now.apply!
# Time.now is fixed here
stub_time_now.reset!
```

## Installation

```ruby
gem 'simple_stub'
```

then `bundle install`.

## Usage

For stubbing a singleton method (or class method), use `SimpleStub.for_singleton_method`.

```ruby
fixed_time = Time.now
stub_time_now = SimpleStub.for_singleton_method(Time, :now) { fixed_time }

stub_time_now.apply!
# Time.now is fixed here
stub_time_now.reset!
```

For stubbing an instance method (which affects to all of the instances), use `SimpleStub.for_instance_method`.

```ruby
class Dog
  def hello
    'Hello!'
  end
end

stub_dog_hello = SimpleStub.for_instance_method(Dog, :hello) { 'Bow' }
dog1 = Dog.new
stub_dog1_hello = SimpleStub.for_singleton_method(dog1, :hello) { ">> #{super()} <<" }

stub_dog_hello.apply!
Dog.new.hello # => 'Bow'
dog1.hello # => 'Bow'
stub_dog1_hello.apply!
dog1.hello # => '>> Bow <<'
```

Since SimpleStub doesn't store any state in the instance, we can use it separatedly.

```ruby
class SomethingSetup
  def call
    # All username becomes John Doe
    SimpleStub.for_instance_method(User, :name) { 'John Doe' }.apply
  end
end

class SomethingTeardown
  def call
    SimpleStub.for_instance_method(User, :name).reset
  end
end
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SimpleStub project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/simple_stub/blob/master/CODE_OF_CONDUCT.md).
