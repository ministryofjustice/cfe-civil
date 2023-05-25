class ApplicationController < ActionController::API
  around_action :log_request, if: :log_request?

  class ErrorSerializer < ApiErrorHandler::Serializers::BaseSerializer
    def serialize(_serializer_options)
      { success: false, errors: ["#{@error.class}: #{@error.message}"] }
    end

    def render_format
      :json
    end
  end

  handle_api_errors(serializer: ErrorSerializer, error_reporter: :sentry)

  # ActiveSupport::Notifications.subscribe "process_action.action_controller" do |*args|
  #   event = ActiveSupport::Notifications::Event.new(*args)
  #   if event.payload.fetch(:controller) == V6::AssessmentsController.to_s
  #     RequestLog.create!(
  #       request: event.payload.fetch(:params).except("controller", "action"),
  #       http_status: event.payload.fetch(:status),
  #       response: JSON.parse(event.payload.fetch(:response).body),
  #       duration: event.duration,
  #     )
  #   end
  # end

  def render_unprocessable(message)
    messages = Array.wrap(message)
    sentry_message = messages.join(", ")
    Sentry.capture_message(sentry_message)
    render json: { success: false, errors: messages }, status: :unprocessable_entity
  end

  def render_success
    render json: { success: true, errors: [] }
  end

  def log_request
    start_time = Time.zone.now
    yield
    RequestLog.create!(
      request: request.params.except(:controller, :action),
      http_status: response.status,
      response: JSON.parse(response.body),
      duration: Time.zone.now - start_time,
    )
  end

private

  def log_request?
    /^\/v6\/assessment/.match?(request.path)
  end

  def validate_swagger_schema(schema_name, parameters)
    json_validator = JsonSwaggerValidator.new(schema_name, parameters)
    unless json_validator.valid?
      render_unprocessable(json_validator.errors)
    end
  end
end
