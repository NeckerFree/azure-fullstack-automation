output "app_service_url" {
  value       = azurerm_linux_web_app.main.default_hostname
  description = "The default URL of the App Service"
  sensitive   = false
}

output "app_service_name" {
  value       = azurerm_linux_web_app.main.name
  description = "The name of the App Service"
}
