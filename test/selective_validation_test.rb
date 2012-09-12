require_relative "../lib/selective_validation"
require "active_model"
require "shoulda-context"

class SelectiveValidationTest < ActiveSupport::TestCase
  class TestModel
    include ActiveModel::MassAssignmentSecurity
    include ActiveModel::Validations
    include SelectiveValidation::Base

    allows_selective_validation
    validates :attr, presence: true
    validates :attr_with_if_proc, presence: true, if: Proc.new { |model| model.do_attr_with_if }
    validates :attr_with_if_symbol, presence: true, if: :do_attr_with_if
    validates :attr_with_if_string, presence: true, if: "do_attr_with_if"
    validates :attr_with_unless_proc, presence: true, unless: Proc.new { |model| model.skip_attr_with_unless }
    validates :attr_with_unless_symbol, presence: true, unless: :skip_attr_with_unless
    validates :attr_with_unless_string, presence: true, unless: "skip_attr_with_unless"
    validates_inclusion_of :attr_with_inclusion, :in => [1,2,3]
    attr_accessor :attr,
                  :attr_with_if_proc,
                  :attr_with_if_symbol,
                  :attr_with_if_string,
                  :do_attr_with_if,
                  :attr_with_unless_proc,
                  :attr_with_unless_symbol,
                  :attr_with_unless_string,
                  :skip_attr_with_unless,
                  :attr_with_inclusion,
                  :do_attr_with_inclusion
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
        [:attr_with_if_proc, :attr_with_if_symbol, :attr_with_if_string].each do |attr|
          @model.send(:"#{attr}=", nil)
          @model.do_attr_with_if = true
          @model.attrs_to_validate = []
          assert @model.invalid?
          assert_present @model.errors[attr]

          @model.attrs_to_validate = [attr]
          assert @model.invalid?
          assert_present @model.errors[attr]

          @model.send(:"#{attr}=", "not nil")
          assert @model.valid?
        end
      end

      should "not validate when :if condition is false" do
        [:attr_with_if_proc, :attr_with_if_symbol, :attr_with_if_string].each do |attr|
          @model.send(:"#{attr}=", nil)
          @model.do_attr_with_if = false
          @model.attrs_to_validate = []
          @model.valid?
          assert_blank @model.errors[attr]

          @model.attrs_to_validate = [attr]
          assert @model.valid?
        end
      end
    end

    context "when :attrs_to_validate does not include the attribute" do
      should "not validate" do
        [:attr_with_if_proc, :attr_with_if_symbol, :attr_with_if_string].each do |attr|
          @model.send(:"#{attr}=", nil)
          @model.attrs_to_validate = [:another_attr]
          assert @model.valid?
        end
      end
    end
  end

  context "attribute with :unless validation" do
    context "when :attrs_to_validate is empty or includes the attribute" do
      should "validate when :unless condition is false" do
        [:attr_with_unless_proc, :attr_with_unless_symbol, :attr_with_unless_string].each do |attr|
          @model.send(:"#{attr}=", nil)
          @model.skip_attr_with_unless = false
          @model.attrs_to_validate = []
          assert @model.invalid?
          assert_present @model.errors[attr]

          @model.attrs_to_validate = [attr]
          assert @model.invalid?
          assert_present @model.errors[attr]

          @model.send(:"#{attr}=", "not nil")
          assert @model.valid?
        end
      end

      should "not validate when :unless condition is true" do
        [:attr_with_unless_proc, :attr_with_unless_symbol, :attr_with_unless_string].each do |attr|
          @model.send(:"#{attr}=", nil)
          @model.skip_attr_with_unless = true
          @model.attrs_to_validate = []
          @model.valid?
          assert_blank @model.errors[:attr_with_unless]

          @model.attrs_to_validate = [:attr_with_unless]
          assert @model.valid?
        end
      end
    end

    context "when :attrs_to_validate does not include the attribute" do
      should "not validate" do
        [:attr_with_unless_proc, :attr_with_unless_symbol, :attr_with_unless_string].each do |attr|
          @model.send(:"#{attr}=", nil)
          @model.skip_attr_with_unless = false
          @model.attrs_to_validate = [:another_attr]
          assert @model.valid?
        end
      end
    end
  end

  context "validates_inclusion_of" do
    should "skip validation when :attrs_to_validate includes the attribute or is empty" do
      @model.attr_with_inclusion = nil
      @model.attrs_to_validate = []
      assert @model.invalid?
      assert_present @model.errors[:attr_with_inclusion]

      @model.attrs_to_validate = [:attr_with_inclusion]
      assert @model.invalid?
      assert_present @model.errors[:attr_with_inclusion]

      @model.attr_with_inclusion = 1
      assert @model.valid?

      @model.attrs_to_validate = nil
    end
  end
end