class ExceptionsController < ActionController::Base
  def show
    # Taken from https://github.com/richpeck/exception_handler
    exception = request.env['action_dispatch.exception']
    @message = exception&.message || Rack::Utils::HTTP_STATUS_CODES[status]
    # => Status code (404, 500 etc)
    @status = exception ? ActionDispatch::ExceptionWrapper.new(request.env, exception).try(:status_code) : request.env["PATH_INFO"][1..-1].to_i
    # => Server Response ("Not Found" etc)
    @response = ActionDispatch::ExceptionWrapper.rescue_responses[exception.class.name]

    render template: 'exceptions/show', status: @status, formats: %i[html]
  end
end
