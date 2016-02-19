class SwordExportJob < SeekJob
  attr_reader :item_id

  def initialize(item)
    @item_id = item.id
  end

  # executes the job - save a file in tmp and then export to sword.
  def perform_job(item)
    # TODO actually call export to sword here
    # print all the details of what we'd be sending to sword.
    Rails.logger.info "Here we should be sending item of class #{item.class} #{item.id} to sword."
    Rails.logger.info "Title: #{item.title}"
    Rails.logger.info "Description: #{item.description}"
  end

  def gather_items
    [DataSharePack.find_by_id(item_id)].compact
  end

  def item
    DataSharePack.find_by_id(item_id)
  end

  # Overwriting SeekJob method.
  def report_exception(exception, item, message = nil, data = {})
    message ||= "Error in SwordExportJob when executing job for #{item.class.name} #{@item_id}"
    data[:message] = message
    data[:item] = item.inspect
    if Seek::Config.exception_notification_enabled
      ExceptionNotifier.notify_exception(exception, data: data)
    end
    Rails.logger.error(message)
    Rails.logger.error("Exception: #{exception}")
    Rails.logger.error("This error came from item #{item.inspect}")
    exception.backtrace.each do |s|
      Rails.logger.error(s)
    end
  end
end
