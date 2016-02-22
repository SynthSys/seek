require 'test_helper'

class DspaceUploaderConnectorTest < ActiveSupport::TestCase

  fixtures :all

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @connector = Synthsys::Dspace::DspaceUploaderConnector.new
    @dataSharePack = data_share_packs(:first_data_share)
    @dataSharePack.snapshot = create_snapshot
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_deposit

    content_blob = create_tmp_blob
    @dataSharePack.snapshot.content_blob = content_blob

    #resp = @connector.deposit(@dataSharePack)
    #assert resp == true
    #fail "Should failed if run"
  end

  def test_data_share_to_deposit

    dataSharePack = @dataSharePack

    deposit = @connector.prepare_deposit dataSharePack
    assert_not_nil deposit

    assert_equal dataSharePack.collection, deposit[:collection]
    assert_equal dataSharePack.title, deposit[:title]
    assert_equal dataSharePack.description, deposit[:description]
    assert_equal dataSharePack.funder, deposit[:funder]
    assert_equal dataSharePack.depositor, deposit[:depositor]
    assert_equal dataSharePack.publisher, deposit[:publisher]
    assert_equal dataSharePack.creators, deposit[:creators]
    assert_equal dataSharePack.keywords, deposit[:keywords]
    assert_equal dataSharePack.subject, deposit[:subject]
    assert_equal dataSharePack.toc, deposit[:toc]
    assert_equal dataSharePack.license, deposit[:licence]
    assert_equal 'Dataset', deposit[:type]

    assert_not_nil deposit[:filePath]
    assert File.file? deposit[:filePath]
    assert_equal 'application/zip', deposit[:fileType]
    assert deposit[:fileName].end_with?('ro.zip')

    #TODO deal with dates, and link to original series
    #assert_equal deposit[:source], dataSharePack.
    #assert_equal deposit[:createdAtStr], dataSharePack.created
    #assert_equal deposit[:updatedAtStr], dataSharePack.modified

    #puts '============='
    #puts deposit.to_json
    #puts '============='
  end

  def test_prepareDataPackage

    content_blob = create_tmp_blob
    @dataSharePack.snapshot.content_blob = content_blob
    path = @connector.prepareDataPackage(@dataSharePack)
    assert File.file?(path)

    assert_raise Exception do
      File.delete(path)
      assert !File.file?(path)
      path = @connector.prepareDataPackage(@dataSharePack)
    end


    assert_raise Exception do
      @dataSharePack.snapshot.content_blob = nil
      path = @connector.prepareDataPackage(@dataSharePack)
    end

  end

  def test_makeDepositFileName

    name = @connector.makeDepositFileName(@dataSharePack);
    assert_not_nil name
    #puts name
    assert_equal "Investigation.#{@dataSharePack.snapshot.parent_id}.ro.zip", name


  end

  def test_configured
    assert @connector.configured?
  end

  def test_readconfiguration

    config = @connector.read_configuration
    assert_not_nil config
    assert_equal 'http://localhost:8550/deposit',config.uri
  end

  private

  def create_snapshot
    @user = Factory(:user)
    @investigation = Factory(:investigation, :description => 'not blank', :policy => Factory(:publicly_viewable_policy), :contributor => @user.person)
    @snapshot = @investigation.create_snapshot
  end

  def create_tmp_blob

    io_object = Tempfile.new('dspace_content_blop')
    io_object.write("DSpace export content of the fille XXX")

    blob=ContentBlob.new(:tmp_io_object=>io_object,:original_filename=>"xxx.ro.zip")
    assert_difference("ContentBlob.count") do
      blob.save!
    end

    blob.reload
    assert_not_nil blob.filepath
    return blob
  end
end