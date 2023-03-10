class APIResponse
  include ActiveModel::Serialization

  attr_accessor :success, :objects, :errors

  def self.success(objects)
    response = new
    response.success = true
    response.objects = objects
    response.errors = []
    response
  end

  def self.error(messages)
    response = new
    response.success = false
    response.objects = nil
    response.errors = messages
    response
  end

  def success?
    raise "APIResponse object is in incomplete state" if @success.nil?

    @success
  end
end
