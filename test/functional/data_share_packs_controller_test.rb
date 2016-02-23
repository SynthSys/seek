require 'test_helper'

class DataSharePacksControllerTest < ActionController::TestCase

  fixtures :all

  include AuthenticatedTestHelper

  setup do
    login_as(:datafile_owner)
    @data_share_pack = data_share_packs(:first_data_share)
    @data_share_pack.snapshot = create_snapshot
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:data_share_packs)
  end

  test "should get new based on existing snapshot" do
    investigation = investigations(:metabolomics_investigation)
    snapshot = investigation.create_snapshot
    get :new, :snapshot_id=>snapshot.id
    assert_response :success

    assert_equal investigation, assigns(:data_share_pack).parent
    assert_equal investigation.title, assigns(:data_share_pack).title
    assert_equal investigation.description, assigns(:data_share_pack).description

  end

  test "should show error when new called without assay" do
    get :new
    assert_response :missing

    get :new, :assay_id=>"Wrong"
    assert_response :missing
  end

  test "should create data_share_pack" do

    #Stubing DSpace Upload URL, as currently, the deposittion is hard linked to data share pack creation
    #bypassing the jobs subsystem

    url = Synthsys::Dspace::DspaceUploaderConnector.INSTANCE.url
    stub = stub_request(:post, url)

    Dir.mktmpdir('~DEPOSITS2') do |tmp|
      nconfig = Synthsys::Dspace::DspaceUploaderConnector::Config.new
      nconfig.uri = url
      nconfig.deposits_dir = tmp;

      Synthsys::Dspace::DspaceUploaderConnector.INSTANCE.config= nconfig

        assert_difference('DataSharePack.count') do
          #post :create, data_share_pack: { description: @data_share_pack.description, msg: @data_share_pack.msg, status: @data_share_pack.status, title: @data_share_pack.title, assay_id: @data_share_pack.assay.id }
          post :create, data_share_pack: {
              description: @data_share_pack.description,
              title: @data_share_pack.title,
              snapshot_id: @data_share_pack.snapshot.id,
              funder: @data_share_pack.funder,
              collection: @data_share_pack.collection,
              publisher: @data_share_pack.publisher,
              settype: @data_share_pack.settype,
              license: @data_share_pack.license,
              creators: @data_share_pack.creators,
              keywords: @data_share_pack.keywords,
              subject: @data_share_pack.subject,
              toc: @data_share_pack.toc
          }
        end
    end

    remove_request_stub(stub)
    assert_redirected_to data_share_pack_path(assigns(:data_share_pack))
  end

  test "should show data_share_pack" do
    get :show, id: @data_share_pack
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @data_share_pack
    assert_response :success
  end

=begin
  test "should update data_share_pack" do
    put :update, id: @data_share_pack, data_share_pack: { description: "N #{@data_share_pack.description}", title: "N: "+@data_share_pack.title }

    assert_redirected_to data_share_pack_path(assigns(:data_share_pack))
  end
=end

  test "should destroy data_share_pack" do
    assert_difference('DataSharePack.count', -1) do
      delete :destroy, id: @data_share_pack
    end

    assert_redirected_to data_share_packs_path
  end


  private

  def create_snapshot
    @user = Factory(:user)
    @investigation = Factory(:investigation, :description => 'not blank', :policy => Factory(:publicly_viewable_policy), :contributor => @user.person)
    @snapshot = @investigation.create_snapshot
  end

end
