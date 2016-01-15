require 'test_helper'

class DataSharePackTest < ActiveSupport::TestCase
  fixtures :all

  # test "the truth" do
  #   assert true
  # end

  def setup
    snapshot = create_snapshot
    @pack = DataSharePack.new(title: "Test DataSharePack", description: "DataSet generated in experiment AT0089.\\nIncluded raw and processed data files",snapshot_id: snapshot.id)
  end

  test "should be valid" do
    assert @pack.valid?
  end

  test "title should be present" do
    @pack.title = "     "
    assert !@pack.valid?
  end

  test "title length [10,140]" do
    @pack.title = "a"*141
    assert !@pack.valid?
    @pack.title = "a"*9
    assert !@pack.valid?
    @pack.title = "a"*11
    assert @pack.valid?
  end


  test "description should be present" do
    @pack.description = "     "
    assert !@pack.valid?
  end

  test "snapshot id should be present" do
    @pack.snapshot_id = nil
    assert !@pack.valid?
  end

  test "snapshot should be present" do
    @pack.snapshot = nil
    assert !@pack.valid?
  end

  test "parent same snapshot parent" do
    assert_not_nil @pack.snapshot
    assert_not_nil @pack.snapshot.parent

    assert_equal @pack.snapshot.parent, @pack.parent
  end

  test "parent nil for nil snapshot" do
    @pack.snapshot = nil
    assert_nil @pack.parent
  end


  private

  def create_snapshot
    @user = Factory(:user)
    @investigation = Factory(:investigation, :description => 'not blank', :policy => Factory(:publicly_viewable_policy), :contributor => @user.person)
    @snapshot = @investigation.create_snapshot
  end


end
