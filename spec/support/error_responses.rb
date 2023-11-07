# https://eliotsykes.com/2017/03/08/realistic-error-responses/
module ErrorResponses
  def respond_without_detailed_exceptions
    env_config = Rails.application.env_config
    original_show_exceptions = env_config["action_dispatch.show_exceptions"]
    original_show_detailed_exceptions = env_config["action_dispatch.show_detailed_exceptions"]
    # original_error_handling = env_config["x.error_handling_enabled"]
    env_config["action_dispatch.show_exceptions"] = true
    env_config["action_dispatch.show_detailed_exceptions"] = false
    # env_config["x.error_handling_enabled"] = true
    yield
  ensure
    env_config["action_dispatch.show_exceptions"] = original_show_exceptions
    env_config["action_dispatch.show_detailed_exceptions"] = original_show_detailed_exceptions
    # env_config["x.error_handling_enabled"] = original_error_handling
  end
end
