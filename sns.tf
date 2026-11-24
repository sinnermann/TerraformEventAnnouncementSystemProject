resource "aws_sns_topic" "event_announcements" {
  name         = "${var.project_name}-announcements"
  display_name = "Garage Events"
}
