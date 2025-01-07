variable "security_group_name_web" {
  description = "The name of the security group"
  type        = string
  default     = "test-sg-web"
}

variable "security_group_name_alb" {
  description = "The name of the security group"
  type        = string
  default     = "test-sg-alb"
}

variable "fully_qualified_domain_name" {
  description = "The fully qualified domain name for the certificate"
  type        = string
  default     = "*.zeta4.shop"
}

variable "domain_name" {
  description = "The domain name for the Route 53 zone ID"
  type        = string
  default     = "zeta4.shop"
}

variable "subject_alternative_names" {
  description = "Additional domain names for the certificate"
  type        = list(string)
  default     = []
}
