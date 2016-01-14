require 'test_helper'

class DsPackTest < ActiveSupport::TestCase

  fixtures :all

  # test "the truth" do
  #   assert true
  # end

  def setup
    assay = assays(:metabolomics_assay)
    @pack = DsPack.new(title: "Test DataSharePack", description: "DataSet generated in experiment AT0089.\\nIncluded raw and processed data files",assay: assay)
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

  test "assay id should be present" do
    @pack.assay_id = nil
    assert !@pack.valid?
  end

  test "assay should be present" do
    @pack.assay = nil
    assert !@pack.valid?
  end

end
