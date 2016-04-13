class Hash
  # Recursively converts camelCase/dash-case keys to snake_case
  def to_snake_keys(value = self)
    case value
    when Array
      value.map { |v| to_snake_keys(v) }
    when ActionController::Parameters
      ActionController::Parameters.new(snake_hash(value))
    when Hash
      Hash[value.map { |k, v| [snakeify_key(k), to_snake_keys(v)] }]
    else
      value
    end
  end

  # Recursively converts snake_case/dash-case keys to camelCase
  def to_camel_keys(value = self)
    case value
    when Array
      value.map { |v| to_camel_keys(v) }
    when Hash
      Hash[value.map { |k, v| [camelize_key(k), to_camel_keys(v)] }]
    else
      value
    end
  end

  # Recursively converts snake_case/camelCase keys to dash-case
  def to_dash_keys(value = self)
    case value
    when Array
      value.map { |v| to_dash_keys(v) }
    when Hash
      Hash[value.map { |k, v| [dasherize_key(k), to_dash_keys(v)] }]
    else
      value
    end
  end

  private

  def snakeify_key(key)
    case key
    when Symbol
      snakeify(key.to_s).to_sym
    when String
      snakeify(key)
    else
      key
    end
  end

  def snakeify(string)
    string.gsub(/::/, '/')
      .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      .gsub(/([a-z\d])([A-Z])/, '\1_\2')
      .tr('-', '_')
      .downcase
  end

  def camelize_key(key)
    case key
    when Symbol
      camelize(key.to_s).to_sym
    when String
      camelize(key)
    else
      key
    end
  end

  def camelize(string)
    string.gsub(/([_-])(.)/) { $2.upcase }
  end

  def dasherize_key(key)
    case key
    when Symbol
      dasherize(key.to_s).to_sym
    when String
      dasherize(key)
    else
      key
    end
  end

  def dasherize(string)
    string.gsub(/::/, '/')
      .gsub(/([A-Z]+)([A-Z][a-z])/, '\1-\2')
      .gsub(/([a-z\d])([A-Z])/, '\1-\2')
      .tr('_', '-')
      .downcase
  end

end
