class Threshold
  class << self
    def data
      @data ||= load_data
    end

    def load_data
      data = {}
      index = YAML.safe_load_file(Rails.root.join(data_folder_path, "values.yml"), permitted_classes: [Date])
      index.each do |date, filename|
        hash = YAML.safe_load_file(Rails.root.join(filename), permitted_classes: [Date]).deep_symbolize_keys
        data[date.beginning_of_day] = hash if threshold_loadable?(hash)
      end
      data
    end

    def value_for(item, at:)
      key = data.keys.select { |time| time <= at }.max || data.keys.min
      threshold = data[key]
      threshold[item.to_sym]
    end

    def data_folder_path=(new_path)
      @data_folder_path = new_path
      @data = nil
    end

    def data_folder_path
      @data_folder_path ||= Rails.root.join("config/thresholds")
    end

    def threshold_loadable?(hash)
      return true unless hash.key?(:test_only)

      Rails.configuration.x.use_test_threshold_data == "true"
    end
  end
end
