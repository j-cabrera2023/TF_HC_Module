# Data source to retrieve the specified Azure Function App
data "azurerm_function_app" "function_app" {
  name                = var.function_app_name
  resource_group_name = var.resource_group_name
}

# Application Insights Web Test for the health check endpoint
resource "azurerm_application_insights_web_test" "health_check_test" {
  name                    = "${var.function_app_name}-HealthCheckTest"
  location                = var.location
  resource_group_name     = var.resource_group_name
  application_insights_id = var.application_insights_id
  kind                    = "ping"
  frequency               = 300
  timeout                 = 30
  geo_locations       = ["us-va-ash-azr", "us-ca-sjc-azr", "us-fl-mia-edge"]

  configuration = <<XML
<WebTest Name="WebTest1" Id="ABD48585-0831-40CB-9069-682EA6BB3583" Enabled="True" CssProjectStructure="" CssIteration="" Timeout="0" WorkItemIds="" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010" Description="" CredentialUserName="" CredentialPassword="" PreAuthenticate="True" Proxy="default" StopOnError="False" RecordedResultFile="" ResultsLocale="">
  <Items>
    <Request Method="GET" Guid="a5f10126-e4cd-570d-961c-cea43999a200" Version="1.1" Url="http://microsoft.com" ThinkTime="0" Timeout="300" ParseDependentRequests="True" FollowRedirects="True" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="200" ExpectedResponseUrl="" ReportingName="" IgnoreHttpStatusCode="False" />
  </Items>
</WebTest>
XML


}

# Metric alert for failed health checks, in a disabled state
resource "azurerm_monitor_metric_alert" "health_check_alert" {
  name                = "${var.function_app_name}-HealthCheckAlert"
  resource_group_name = var.resource_group_name
  scopes              = [var.application_insights_id]
  description         = "Alert on health check failures for /api/HEALTHCHECK endpoint"
  severity            = var.alert_severity
  frequency           = "PT5M"                 # Frequency of evaluation
  window_size         = "PT15M"                # Time window for checking metric
  enabled             = false                  # Disabled state as requested

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http5xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.alert_threshold
  }

  dynamic "action" {
    for_each = var.action_group_ids
    content {
      action_group_id = action.value
    }
  }
}

#adding this line for Github testing