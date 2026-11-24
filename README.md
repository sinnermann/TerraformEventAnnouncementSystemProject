# Serverless Event Announcement System (AWS + Terraform)

This project is an automated, serverless web application built on AWS using Terraform. Visitors can subscribe to email updates, and admins can publish new car events—automatically updating the website and sending email alerts to subscribers.

## How It Works

1. **Amazon S3:** Hosts the static website (`index.html`) and stores the list of events in `events.json`.
2. **Amazon API Gateway:** Connects the website buttons to the backend Lambda functions (`/subscribe` and `/create-event`).
3. **AWS Lambda (Python 3.13):**
   - `subscribe.py` adds the user's email to Amazon SNS.
   - `create_event.py` saves the new event to `events.json` in S3 and triggers an email alert.
4. **Amazon SNS:** Sends confirmation emails and event announcements to subscribers.

## Project Files

- `frontend/` — Website HTML, CSS, JavaScript, images, and `events.json`
- `lambda/` — Python scripts for subscribing and publishing events
- `*.tf` — Terraform files that automatically build all AWS resources

## How to Run The Project

1. Create a file named `terraform.tfvars` and add your unique S3 bucket name:
   ```hcl
   bucket_name = "your-unique-bucket-name"
   ```
2. Run Terraform in your terminal:
   ```bash
   terraform init
   terraform apply -auto-approve
   ```
3. Open the `website_url` printed in the terminal.

## How to Delete Everything (Clean Up)

```bash
terraform destroy -auto-approve
```
