require 'test/unit'
require 'test_helper'
require 'sword2ruby'

class SwordConnectorTest < ActiveSupport::TestCase


  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @connector = Synthsys::Sword::SwordConnector.new

  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_configured
    assert @connector.configured?
  end

  def test_readconfiguration

    config = @connector.read_configuration
    assert_not_nil config
    assert_equal 'dspacedemo+submit@gmail.com',config.username
    assert_equal 'dspace',config.password
    assert_equal 'http://demo.dspace.org/swordv2/servicedocument',config.uri
  end

  def test_connect
    assert_not_nil @connector.connect
  end

  def test_swordClientOverwrite
    assert Atom::Service.zielu
  end
end