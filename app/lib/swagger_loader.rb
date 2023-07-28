class SwaggerLoader
  class << self
    def load_request_schema(version)
      load_schema(version, ["post", "requestBody", "content", "application/json", "schema"])
    end

    def load_response_schema(version)
      load_schema(version, ["post", "responses", "200", "content", "application/json", "schema"])
    end

  private

    def load_schema(version, path)
      swagger_yaml = YAML.load_file(Rails.root.join("swagger/v#{version}/swagger.yaml"))
      endpoint_yaml = swagger_yaml.dig("paths", "/v#{version}/assessments")
      components = swagger_yaml.fetch("components")
      endpoint_yaml.dig(*path).merge(components:)
    end
  end
end
