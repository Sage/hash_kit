module HashKit
  class Helper

    #This method is called to make a hash allow indifferent access (it will accept both strings & symbols for a valid key).
    def indifferent!(hash)
      unless hash.is_a?(Hash)
        return
      end

      #set the default proc to allow the key to be either string or symbol if a matching key is found.
      hash.default_proc = proc do |h, k|
        if h.key?(k.to_s)
          h[k.to_s]
        elsif h.key?(k.to_sym)
          h[k.to_sym]
        else
          nil
        end
      end

      #recursively process any child hashes
      hash.each do |key,value|
        if hash[key] != nil
          if hash[key].is_a?(Hash)
            indifferent!(hash[key])
          elsif hash[key].is_a?(Array)
            indifferent_array!(hash[key])
          end
        end
      end

      hash
    end

    def indifferent_array!(array)
      unless array.is_a?(Array)
        return
      end

      array.each do |i|
        if i.is_a?(Hash)
          indifferent!(i)
        elsif i.is_a?(Array)
          indifferent_array!(i)
        end
      end
    end

    #This method is called to convert all the keys of a hash into symbols to allow consistent usage of hashes within your Ruby application.
    def symbolize(hash)
      {}.tap do |h|
        hash.each { |key, value| h[key.to_sym] = map_value_symbol(value) }
      end
    end

    #This method is called to convert all the keys of a hash into strings to allow consistent usage of hashes within your Ruby application.
    def stringify(hash)
      {}.tap do |h|
        hash.each { |key, value| h[key.to_s] = map_value_string(value) }
      end
    end

    # Convert an object to a hash representation of its instance variables.
    # @return [Hash] if the object is not nil, otherwise nil is returned.
    def to_hash(obj)
      return nil unless obj
      return obj if obj.is_a?(Hash)

      hash = {}
      obj.instance_variables.each do |key|
        hash[key[1..-1].to_sym] = deeply_to_hash(obj.instance_variable_get(key))
      end
      hash
    end

    def from_hash(hash, klass, transforms =  [])
      obj = klass.new
      return obj if hash.nil? || hash.empty?
      raise ArgumentError, "#{hash.inspect} is not a hash" unless hash.is_a?(Hash)

      hash.each do |k,v|
        if !obj.respond_to?(k)
          next
        end
        transform = transforms.detect { |t| t.key.to_sym == k.to_sym }
        if transform != nil
          if v.is_a?(Hash)
            child = from_hash(v, transform.klass, transforms)
            obj.instance_variable_set("@#{k}", child)
          elsif v.is_a?(Array)
            items = v.map do |i|
              from_hash(i, transform.klass, transforms)
            end
            obj.instance_variable_set("@#{k}", items)
          end
        else
          obj.instance_variable_set("@#{k}", v)
        end
      end
      return obj
    end

    private

    # nodoc
    def convert_hash_values(hash)
      new_hash = {}
      hash.each do |key, val|
        new_hash[key] = deeply_to_hash(val)
      end
      new_hash
    end

    # nodoc
    def convert_array_values(array)
      new_array = []
      array.each_index do |index|
        new_array[index] = deeply_to_hash(array[index])
      end
      new_array
    end

    def standard_type?(obj)
      [
        String, Numeric, Float, Date, DateTime, Time, Integer, TrueClass, FalseClass, NilClass, Symbol
      ].detect do |klass|
        obj.is_a?(klass)
      end
    end

    # nodoc
    def deeply_to_hash(val)
      if val.is_a?(Hash)
        return convert_hash_values(val)
      elsif val.is_a?(Array)
        return convert_array_values(val)
      elsif standard_type?(val)
        val
      else
        return to_hash(val)
      end
    end

    def map_value_symbol(thing)
      case thing
        when Hash
          symbolize(thing)
        when Array
          thing.map { |v| map_value_symbol(v) }
        else
          thing
      end
    end

    def map_value_string(thing)
      case thing
        when Hash
          stringify(thing)
        when Array
          thing.map { |v| map_value_string(v) }
        else
          thing
      end
    end
  end
end
