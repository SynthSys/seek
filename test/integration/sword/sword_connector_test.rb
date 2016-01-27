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
    service = @connector.connect
    assert_not_nil service
    puts "service.workspaces.count: #{service.workspaces.count}"
    puts "service.collections.count: #{service.collections.count}"

    puts service.collections.class
    service.collections.each do |c|
      puts "#{c.class} #{c.title}"
      puts "#{c.accepts}"
    end

    assert_equal 1, service.workspaces.count
    assert_equal 3, service.collections.count

  end

  def test_findCollection

    connection = @connector.connect
    name = "CATALOGING"
    col = @connector.findCollection(name,connection)
    assert_not_nil col
    assert_equal name,col.title.to_s

    name = "ZUPA"
    assert_raise(Synthsys::Sword::SwordConnector::NotFound) {@connector.findCollection(name,connection)}

  end


=begin
  def test_upload
    connection = @connector.connect
    colName = "CATALOGING"
    colName = "Collection of Sample Items"
    file_path = "/localdisk/seek/upload.txt"
    title = "Test sword deposition"

    deposit_receipt = @connector.upload(file_path,title,colName,connection)

    assert_not_nil deposit_receipt
    puts deposit_receipt.class
    puts "deposit_receipt.has_entry: #{deposit_receipt.has_entry}"
    puts "deposit_receipt.entry.to_s: #{deposit_receipt.entry.to_s}"
    puts "deposit_receipt.entry.alternate_uri: #{deposit_receipt.entry.alternate_uri}"
  end
=end

  def test_swordClientOverwrite
    assert Atom::Service.zielu
    assert Atom::Collection.zielu
  end

  private


end