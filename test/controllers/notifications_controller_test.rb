require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  test "index requires authentication" do
    get notifications_url
    assert_redirected_to new_session_path
  end

  test "signed-in user can view their notifications" do
    sign_in_as users(:one)
    get notifications_url
    assert_response :success
  end

  test "mark_as_read marks the notification and redirects" do
    sign_in_as users(:one)
    patch mark_as_read_notification_url(notifications(:one))
    assert notifications(:one).reload.read?
    assert_redirected_to notifications_path
  end

  test "mark_all_as_read clears the user's unread notifications" do
    sign_in_as users(:one)
    patch mark_all_as_read_notifications_url
    assert_equal 0, users(:one).notifications.unread.count
  end
end
