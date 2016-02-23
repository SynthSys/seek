require 'test_helper'

class DspaceUploaderConnectorTest < ActiveSupport::TestCase

  fixtures :all

  class MockPoster

    def initialize
      @posted = 0
      @content = nil
    end

    def post(url,content)
      @posted+=1
      @content = content;
      return true
    end

    def posted
      return @posted
    end

    def content
      return @content
    end
  end

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @poster = MockPoster.new

    @dir = Dir.mktmpdir('~DEPOSITS')
    @url = 'http://localhost.fake/deposit'

    @config = Synthsys::Dspace::DspaceUploaderConnector::Config.new
    @config.uri = @url
    @config.deposits_dir = @dir

    @connector = Synthsys::Dspace::DspaceUploaderConnector.new(@poster,@config)
    @dataSharePack = data_share_packs(:first_data_share)
    @dataSharePack.snapshot = create_snapshot
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    FileUtils.remove_dir(@dir)
  end

  def test_INSTANCE

    instance = Synthsys::Dspace::DspaceUploaderConnector.INSTANCE
    assert_not_nil instance

    instance2 = Synthsys::Dspace::DspaceUploaderConnector.INSTANCE
    assert instance.equal?(instance2)
  end

  def test_deposit

    content_blob = create_tmp_blob
    @dataSharePack.snapshot.content_blob = content_blob

    assert_difference ->{ @poster.posted },1 do
      resp = @connector.deposit(@dataSharePack)
      assert resp
    end

  end


=begin
  def test_do_deposition

    poster = Synthsys::Dspace::Poster.new
    deposit = 'A kuku matutu'
    uri = 'http://localhost:8550/testservice'

    stub_request(:post, uri).
        with(:body => deposit)

    assert @connector.do_deposition(poster,uri,deposit)

    body = 'Wrong class'
    msg = "Deposit failed:\n #{body}"

    assert_raise_with_message(Synthsys::Dspace::DspaceUploaderConnector::DepositError,msg) do
      stub_request(:post, uri).
          with(:body => deposit).
          to_return(:body => body, :status => [400, 'Bad Request'])

      @connector.do_deposition(poster,uri,deposit)
    end
  end
=end

  def test_data_share_to_deposit

    dataSharePack = @dataSharePack
    depositFile = Tempfile.new("a.file")

    deposit = @connector.prepare_deposit(dataSharePack,depositFile)
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
    assert_equal File.basename(depositFile),deposit[:filePath]

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

    Dir.mktmpdir do |dir|


      content_blob = create_tmp_blob
      blobPath = content_blob.filepath
      @dataSharePack.snapshot.content_blob = content_blob
      path = @connector.prepareDataPackage(@dataSharePack,dir)
      assert File.file?(path)
      assert_equal File.size(blobPath), File.size?(path)
      assert path.kind_of? Tempfile

      assert_raise Exception do
        File.delete(blobPath)
        assert !File.file?(blobPath)
        path = @connector.prepareDataPackage(@dataSharePack,dir)
      end


      assert_raise Exception do
        @dataSharePack.snapshot.content_blob = nil
        path = @connector.prepareDataPackage(@dataSharePack,dir)
      end


    end
  end

  def test_make_deposit_copy
    Dir.mktmpdir do |dir|

      tmpPath = File.join(dir,'a.file.tmp')
      File.write(tmpPath, 'Some test data XXX')

      cpyFile = @connector.makeDepositCopy(tmpPath,dir)
      assert_not_nil cpyFile
      assert File.file? cpyFile.path

      inDir = File.join(dir,File.basename(cpyFile))
      assert File.file? inDir

      assert_equal File.size?(tmpPath), cpyFile.size

    end
  end


  def test_makeDepositFileName

    name = @connector.makeDepositFileName(@dataSharePack);
    assert_not_nil name
    #puts name
    assert_equal "Investigation.#{@dataSharePack.snapshot.parent_id}.ro.zip", name


  end

  def test_updateconfig

    nconfig = Synthsys::Dspace::DspaceUploaderConnector::Config.new

    Dir.mktmpdir('~DEPOSITS2') do |tmp|
      nconfig.uri = @url+'/23'
      nconfig.deposits_dir = tmp;

      @connector.config= nconfig
      assert_equal nconfig.uri,@connector.url
    end

    assert_raise(RuntimeError) {@connector.config= nconfig}

  end

  def test_configured
    assert @connector.configured?
  end

  def test_readconfiguration

    config = @connector.read_configuration
    assert_not_nil config
    assert_equal 'http://localhost.ignore.me:8550/deposit',config.uri
    assert_equal 'FAKE/DEPOSITS',config.deposits_dir
  end

  def test_verifies_configuration
    #I could not access the Config class on configuration so doing it like that
    #config1 = Struct.new(:uri,:deposits_dir)
    #config = config1.new
    config = Synthsys::Dspace::DspaceUploaderConnector::Config.new

    Dir.mktmpdir do |dir|
      config.deposits_dir = dir
      @connector.verify_config config
    end
    assert_raise(RuntimeError) {@connector.verify_config config}
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