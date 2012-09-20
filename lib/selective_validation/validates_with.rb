module SelectiveValidation
  module ValidatesWith
    def validates_with(*args, &block)
      options = args.extract_options!
      original_if = options.delete(:if)
      attributes = Array(options[:attributes].dup).map(&:to_sym)
      options[:if] = Proc.new { |model|
        SelectiveValidation::ValidatesWith.do_selective_validation?(model, attributes) &&
            SelectiveValidation::ValidatesWith.do_original_validation?(model, original_if)
      }
      super(*args, options, &block)
    end

    module_function

    def do_selective_validation?(model, attributes)
      attrs_to_validate = model.attrs_to_validate.map(&:to_sym)
      model.attrs_to_validate.blank? || (attributes & attrs_to_validate).present?
    end

    def do_original_validation?(model, original_if)
      case original_if
        when Proc
          original_if.call(model)
        when Symbol
          model.send(original_if)
        when String
          model.instance_eval(original_if)
        when NilClass
          true
        else
          raise ArgumentError, "Unexpected type: #{original_if.class.name}"
      end
    end
  end
end
