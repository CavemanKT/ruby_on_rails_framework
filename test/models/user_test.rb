require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "user should have default role of user" do
    user = User.create!(
      email_address: "test@example.com",
      password: "password123"
    )
    assert user.user?
    assert_not user.admin?
    assert_equal "user", user.role
  end

  test "user can be assigned admin role" do
    admin = User.create!(
      email_address: "admin@example.com",
      password: "password123",
      role: :admin
    )
    assert admin.admin?
    assert_not admin.user?
    assert_equal "admin", admin.role
  end

  test "role can be changed" do
    user = User.create!(
      email_address: "test2@example.com",
      password: "password123"
    )
    assert user.user?
    
    user.update!(role: :admin)
    assert user.admin?
  end

  test "user profile fields are optional" do
    user = User.create!(
      email_address: "minimal@example.com",
      password: "password123"
    )
    assert_nil user.first_name
    assert_nil user.last_name
    assert_nil user.tel
  end

  test "user has default notification preferences" do
    user = User.create!(
      email_address: "test3@example.com",
      password: "password123"
    )
    assert user.allow_sms_messages
    assert user.allow_email_messages
  end

  test "full_name returns complete name when all fields present" do
    user = User.create!(
      email_address: "john@example.com",
      password: "password123",
      first_name: "John",
      middle_initial: "M",
      last_name: "Doe"
    )
    assert_equal "John M Doe", user.full_name
  end

  test "full_name returns partial name when some fields missing" do
    user = User.create!(
      email_address: "john@example.com",
      password: "password123",
      first_name: "John",
      last_name: "Doe"
    )
    assert_equal "John Doe", user.full_name
  end

  test "full_name returns email prefix when no name fields" do
    user = User.create!(
      email_address: "john@example.com",
      password: "password123"
    )
    assert_equal "john", user.full_name
  end

  test "middle_initial validation limits to one character" do
    user = User.new(
      email_address: "test@example.com",
      password: "password123",
      middle_initial: "AB"
    )
    assert_not user.valid?
    assert_includes user.errors[:middle_initial], "is too long (maximum is 1 character)"
  end

  test "tel validation accepts valid phone formats" do
    valid_numbers = ["+1-555-0100", "(555) 123-4567", "555.123.4567", "+1 555 123 4567"]
    valid_numbers.each do |number|
      user = User.new(
        email_address: "test@example.com",
        password: "password123",
        tel: number
      )
      assert user.valid?, "#{number} should be valid but got errors: #{user.errors.full_messages}"
    end
  end

  test "tel validation rejects invalid formats" do
    user = User.new(
      email_address: "test@example.com",
      password: "password123",
      tel: "abc-def-ghij"
    )
    assert_not user.valid?
    assert_includes user.errors[:tel], "must be a valid phone number"
  end

  test "sms_enabled? returns true when both conditions met" do
    user = User.create!(
      email_address: "test@example.com",
      password: "password123",
      tel: "+1-555-0100",
      allow_sms_messages: true
    )
    assert user.sms_enabled?
  end

  test "sms_enabled? returns false when tel is missing" do
    user = User.create!(
      email_address: "test@example.com",
      password: "password123",
      allow_sms_messages: true
    )
    assert_not user.sms_enabled?
  end

  test "sms_enabled? returns false when allow_sms_messages is false" do
    user = User.create!(
      email_address: "test@example.com",
      password: "password123",
      tel: "+1-555-0100",
      allow_sms_messages: false
    )
    assert_not user.sms_enabled?
  end

  test "email_enabled? returns true when conditions met" do
    user = User.create!(
      email_address: "test@example.com",
      password: "password123",
      allow_email_messages: true
    )
    assert user.email_enabled?
  end
end
