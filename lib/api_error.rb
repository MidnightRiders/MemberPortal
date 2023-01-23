# frozen_string_literal: true

class ApiError < StandardError
  attr_reader :status, :message

  def initialize(status, message)
    @status = status
    @message = message
  end
end
