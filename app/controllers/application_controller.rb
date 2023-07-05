class ApplicationController < ActionController::API
  class ErrorSerializer < ApiErrorHandler::Serializers::BaseSerializer
    def serialize(_serializer_options)
      { success: false, errors: ["#{@error.class}: #{@error.message}"] }
    end

    def render_format
      :json
    end
  end

  handle_api_errors(serializer: ErrorSerializer, error_reporter: :sentry)

  ActiveSupport::Notifications.subscribe "process_action.action_controller" do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    if event.payload.fetch(:controller).in? %w[V6::AssessmentsController V7::AssessmentsController]
      RequestLogger.log_request event.duration, event.payload
    end
  end

  def render_unprocessable(message)
    messages = Array.wrap(message)
    sentry_message = messages.join(", ")
    Sentry.capture_message(sentry_message)
    render json: { success: false, errors: messages }, status: :unprocessable_entity
  end

  def render_success
    render json: { success: true, errors: [] }
  end

private

  def validate_swagger_schema(schema_name, parameters)
    json_validator = JsonSwaggerValidator.new(schema_name, parameters)
    unless json_validator.valid?
      render_unprocessable(json_validator.errors)
    end
  end
end
