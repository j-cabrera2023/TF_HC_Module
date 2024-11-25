# variables.tf

variable "function_app_name" {
  description = "The name of the Azure Function App"
  type        = string
}

variable "resource_group_name" {
  description = "The resource group where the function app and Application Insights are located"
  type        = string
}

variable "application_insights_id" {
  description = "The ID of the Application Insights resource used for monitoring"
  type        = string
}

variable "location" {
  description = "Location of the resources (e.g., eastus)"
  type        = string
  default     = "East US"
}

variable "alert_severity" {
  description = "Severity level of the alert"
  type        = number
  default     = 3
}

variable "alert_threshold" {
  description = "Threshold for the alert to trigger"
  type        = number
  default     = 1
}

variable "action_group_ids" {
  description = "List of action group IDs for alert notifications"
  type        = list(string)
  default     = []
}
