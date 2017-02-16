class ErrorNotifier
  class << self
    def notify(error, severity: :error, output: nil)
      Rails.logger.public_send(severity, "#{error.class}: #{error.message}")
      Rails.logger.info error.backtrace.to_yaml
      error.message
    end
  end
end
