class Hash
  def camelize_keys
    each.with_object({}) do |(key, value), obj|
      original_key = key
      key = key.to_s.split('_').map.with_index { |part, i|
        i == 0 ? part : part[0].upcase + part[1...part.length]
      }.join
      key = key.to_sym if original_key.is_a? Symbol
      obj[key] = camelize_value(value)
      obj
    end
  end

  private

  def camelize_array(array)
    array.map { |val|
      camelize_value(val)
    }
  end

  def camelize_value(value)
    if value.is_a? Hash
      value.camelize_keys
    elsif value.is_a? Array
      camelize_array(value)
    else
      value
    end
  end
end
