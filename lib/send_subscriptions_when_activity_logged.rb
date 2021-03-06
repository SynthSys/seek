ActivityLog.class_eval do
  after_create :send_notification

  def send_notification
    if Seek::Config.email_enabled && activity_loggable.try(:subscribable?) && activity_loggable.subscribers_are_notified_of?(action)
      SendImmediateEmailsJob.new(id).queue_job
    end
  end
end