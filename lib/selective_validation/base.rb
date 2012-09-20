module SelectiveValidation
  module Base
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def allows_selective_validation
        attr_accessor :attrs_to_validate
        extend ValidatesWith
      end
    end
  end
end
