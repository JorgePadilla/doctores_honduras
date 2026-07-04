require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  test "unread scope only returns unread notifications" do
    assert_includes Notification.unread, notifications(:one)
    assert_not_includes Notification.unread, notifications(:two)
  end

  test "mark_as_read! sets read and read_at" do
    n = notifications(:one)
    n.mark_as_read!
    assert n.reload.read?
    assert_not_nil n.read_at
  end

  test "notify creates a notification for the user" do
    assert_difference -> { users(:one).notifications.count }, 1 do
      Notification.notify(user: users(:one), type: "test", title: "Hola", message: "hola")
    end
  end

  test "notify is a no-op when the user is nil" do
    assert_no_difference -> { Notification.count } do
      Notification.notify(user: nil, type: "test", message: "hola")
    end
  end
end
