class JsonSwaggerValidator
  def initialize(version, payload)
    @payload = payload
    swagger_yaml = YAML.load_file(Rails.root.join("swagger/v#{version}/swagger.yaml"))
    endpoint_yaml = swagger_yaml.dig("paths", "/v#{version}/assessments")
    components = swagger_yaml.fetch("components")
    @schema = endpoint_yaml.dig("post", "requestBody", "content", "application/json", "schema").merge(components:)
  end

  def valid?
    JSON::Validator.validate(@schema, @payload)
  end

  def errors
    JSON::Validator.fully_validate(@schema, @payload)
  end
end
