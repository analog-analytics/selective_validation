module SelectiveValidation
  module Base
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def allows_selective_validation
        attr_accessible :attrs_to_validate
        attr_accessor :attrs_to_validate
        extend Validates
      end
    end
  end
end