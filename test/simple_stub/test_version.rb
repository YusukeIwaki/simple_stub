# frozen_string_literal: true

require 'minitest/autorun'

class TestVersion < Minitest::Test
  def test_version_present
    assert defined?(SimpleStub::VERSION)
    assert Gem::Version.new(SimpleStub::VERSION) >= Gem::Version.new('0.0.1')
  end
end
