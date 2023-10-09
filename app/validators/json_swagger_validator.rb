class JsonSwaggerValidator
  def initialize(version, payload)
    @payload = payload
    @schema = SwaggerLoader.load_request_schema version
  end

  def valid?
    JSON::Validator.validate(@schema, @payload)
  end

  def errors
    JSON::Validator.fully_validate(@schema, @payload)
  end
end
