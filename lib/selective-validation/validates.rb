module SelectiveValidation
  module Validates
    def validates(*attributes)
      options = attributes.extract_options!
      passed_if = options.delete(:if)
      options[:if] = Proc.new { |model|
        do_selective_validation = model.attrs_to_validate.blank? || (attributes & model.attrs_to_validate).present?
        do_passed_validation = !passed_if || passed_if.call(model)
        do_selective_validation && do_passed_validation
      }
      super(*attributes, options)
    end
  end
end