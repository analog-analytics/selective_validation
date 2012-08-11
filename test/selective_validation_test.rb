require_relative "../lib/selective_validation"
require "shoulda-context"

class SelectiveValidationTest < ActiveSupport::TestCase
  class TestModel
    include ActiveModel::MassAssignmentSecurity
    include ActiveModel::Validations
    include SelectiveValidation::Base

    allows_selective_validation
    validates :attr, presence: true
    validates :attr_with_if, presence: true, if: Proc.new { |model| model.do_attr_with_if }
    validates :attr_with_unless, presence: true, unless: Proc.new { |model| model.skip_attr_with_unless }
    attr_accessor :attr,
                  :attr_with_if,
                  :do_attr_with_if,
                  :attr_with_unless,
                  :skip_attr_with_unless
  end

  def setup
    @model = TestModel.new
    one = "two"
  end

  context "attribute without conditional validation" do
    should "validate when :attrs_to_validate is empty or includes the attribute" do
      @model.attr = nil
      @model.attrs_to_validate = []
      assert @model.invalid?
      assert_present @model.errors[:attr]

      @model.attrs_to_validate = [:attr]
      assert @model.invalid?
      assert_present @model.errors[:attr]

      @model.attr = "not nil"
      assert @model.valid?
    end

    should "not validate when :attrs_to_validate does not include the attribute" do
      @model.attr = nil
      @model.attrs_to_validate = [:another_attr]
      assert @model.valid?
    end
  end

  context "attribute with :if validation" do
    context "when :attrs_to_validate is empty or includes the attribute" do
      should "validate when :if condition is true" do
        @model.attr_with_if = nil
        @model.do_attr_with_if = true
        @model.attrs_to_validate = []
        assert @model.invalid?
        assert_present @model.errors[:attr_with_if]

        @model.attrs_to_validate = [:attr_with_if]
        assert @model.invalid?
        assert_present @model.errors[:attr_with_if]

        @model.attr_with_if = "not nil"
        assert @model.valid?
      end

      should "not validate when :if condition is false" do
        @model.attr_with_if = nil
        @model.do_attr_with_if = false
        @model.attrs_to_validate = []
        @model.valid?
        assert_blank @model.errors[:attr_with_if]

        @model.attrs_to_validate = [:attr_with_if]
        assert @model.valid?
      end
    end

    context "when :attrs_to_validate does not include the attribute" do
      should "not validate" do
        @model.attr_with_if = nil
        @model.attrs_to_validate = [:another_attr]
        assert @model.valid?
      end
    end
  end

  context "attribute with :unless validation" do
    context "when :attrs_to_validate is empty or includes the attribute" do
      should "validate when :unless condition is false" do
        @model.attr_with_unless = nil
        @model.skip_attr_with_unless = false
        @model.attrs_to_validate = []
        assert @model.invalid?
        assert_present @model.errors[:attr_with_unless]

        @model.attrs_to_validate = [:attr_with_unless]
        assert @model.invalid?
        assert_present @model.errors[:attr_with_unless]

        @model.attr_with_unless = "not nil"
        assert @model.valid?
      end

      should "not validate when :unless condition is true" do
        @model.attr_with_unless = nil
        @model.skip_attr_with_unless = true
        @model.attrs_to_validate = []
        @model.valid?
        assert_blank @model.errors[:attr_with_unless]

        @model.attrs_to_validate = [:attr_with_unless]
        assert @model.valid?
      end
    end

    context "when :attrs_to_validate does not include the attribute" do
      should "not validate" do
        @model.attr_with_unless = nil
        @model.skip_attr_with_unless = false
        @model.attrs_to_validate = [:another_attr]
        assert @model.valid?
      end
    end
  end
end