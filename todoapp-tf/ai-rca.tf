# AI RCA application image reference
# The image is built and pushed after ACR is provisioned.
output "ai_rca_image" {
  value = "agenticdevopsacr.azurecr.io/ai-rca:latest"
}
