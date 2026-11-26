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

## 🛠️ Troubleshooting & Engineering Lessons Learned

During development and deployment of this Terraform stack, we encountered and resolved three practical cloud engineering issues:

### 1. Copy-Paste Link Corruption in AWS Service Principals

- **Issue:** Copying Terraform HCL blocks containing AWS service principal hostnames across rich-text editors automatically converted the hostnames into clickable hyperlinks, causing `terraform validate` syntax errors.
- **Fix:** Constructed AWS service principal identifiers dynamically using Terraform's `join(".", ["lambda", "amazonaws", "com"])` function so the HCL code remains immune to editor link auto-formatting.

### 2. Frontend `publishNewEvent()` Variable Reference & Endpoint Injection

- **Issue:** Submitting a new event initially failed because `index.html` referenced a mismatched JavaScript variable name for the API Gateway endpoint and required manual URL updates after deployment.
- **Fix:** Standardized the frontend configuration around `const API_BASE_URL = "${api_base_url}";` and used Terraform's `templatefile()` function inside `s3_frontend.tf` to inject the live API Gateway Invoke URL automatically during `terraform apply`.

### 3. S3 Bucket Teardown Failure When `events.json` Was Updated at Runtime

- **Issue:** Running `terraform destroy` failed with `BucketNotEmpty` after testing the live website because `create_event.py` modified and wrote new versions of `events.json` inside S3 outside of Terraform's state tracking.
- **Fix:** Enabled `force_destroy = true` on `aws_s3_bucket.website` in `s3_frontend.tf` so Terraform cleanly empties all runtime objects before deleting the bucket in a single command.

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
