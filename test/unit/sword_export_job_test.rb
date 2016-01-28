require 'test_helper'

class SwordExportJobTest < ActiveSupport::TestCase

  fixtures :all

  def setup
    Delayed::Job.delete_all
  end

  def teardown
    Delayed::Job.delete_all
  end

  #test "create data share pack" do
  #  puts 'hello world'
  #  @pack = Factory(:data_share_pack)
  #end

  test "sword export job is added to the queue when it's creted" do
    snapshot = create_snapshot
    pack = data_share_packs(:first_data_share)
    pack.snapshot = snapshot

    assert_difference("Delayed::Job.count", 1) do
      SwordExportJob.new(pack).queue_job
    end

    handlers = Delayed::Job.all.collect(&:handler).join(',')
    assert_includes(handlers, 'SwordExportJob')
  end


  test "perform" do
    snapshot = create_snapshot
    pack = data_share_packs(:first_data_share)
    pack.snapshot = snapshot

    job = SwordExportJob.new(pack)
    job.perform

    #TODO assert that the data export has happened somehow.
  end

  private

  def create_snapshot
    @user = Factory(:user)
    @investigation = Factory(:investigation, :description => 'not blank', :policy => Factory(:publicly_viewable_policy), :contributor => @user.person)
    @snapshot = @investigation.create_snapshot
  end
end