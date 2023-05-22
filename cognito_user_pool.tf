
# user pool
resource "aws_cognito_user_pool" "default" {
  name = "${var.projectPrefix}-user-pool"

  username_attributes      = ["email", "phone_number"]
  auto_verified_attributes = ["email"]

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
    recovery_mechanism {
      name     = "verified_phone_number"
      priority = 2
    }
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "name"
    required                 = true
    string_attribute_constraints {
      max_length = "2048"
      min_length = "1"
    }
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_message        = file("templates/verification_message_template.html")
  }
}

# erp_client clients
resource "aws_cognito_user_pool_client" "erp_client" {
  name                         = "erp_client"
  generate_secret              = true
  explicit_auth_flows          = ["ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_ADMIN_USER_PASSWORD_AUTH"]
  user_pool_id                 = aws_cognito_user_pool.default.id
  supported_identity_providers = ["COGNITO"]
  allowed_oauth_scopes         = aws_cognito_resource_server.default.scope_identifiers
  allowed_oauth_flows          = ["client_credentials"]

  depends_on = [
    aws_cognito_resource_server.default
  ]
}

# vehicle admin client 
resource "aws_cognito_user_pool_client" "vehicle_admin" {
  name                         = "vehicle_admin"
  user_pool_id                 = aws_cognito_user_pool.default.id
  explicit_auth_flows          = ["ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"]
  allowed_oauth_scopes         = ["email", "openid", "profile", "aws.cognito.signin.user.admin"]
  allowed_oauth_flows          = ["code"]
  supported_identity_providers = ["COGNITO", "Google", "Facebook", "SignInWithApple"]
  callback_urls                = var.client_callback_urls
  logout_urls                  = var.client_logout_urls

  depends_on = [
    aws_cognito_identity_provider.google,
    aws_cognito_identity_provider.facebook,
    aws_cognito_identity_provider.apple
  ]
}

# domain
resource "aws_cognito_user_pool_domain" "default" {
  domain       = "development-vehicle"
  user_pool_id = aws_cognito_user_pool.default.id
}

# resource server
resource "aws_cognito_resource_server" "default" {
  identifier = var.resource_server_identifier
  name       = "vehicle_api"

  user_pool_id = aws_cognito_user_pool.default.id

  scope {
    scope_name        = "sensor.read"
    scope_description = "Read Vehicle Sensor"
  }
}

# ui customization
resource "aws_cognito_user_pool_ui_customization" "default" {
  css        = file("custom.css")
  image_file = filebase64("logo.jpg")

  # Refer to the aws_cognito_user_pool_domain resource's
  # user_pool_id attribute to ensure it is in an 'Active' state
  user_pool_id = aws_cognito_user_pool_domain.default.user_pool_id
}

# Google
resource "aws_cognito_identity_provider" "google" {
  user_pool_id  = aws_cognito_user_pool.default.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    authorize_scopes = "email openid profile"
    client_id        = var.google.client_id
    client_secret    = var.google.client_secret
  }

  attribute_mapping = {
    email          = "email"
    username       = "sub"
    name           = "name"
    email_verified = "email_verified"
  }
}

# Facebook
resource "aws_cognito_identity_provider" "facebook" {
  user_pool_id  = aws_cognito_user_pool.default.id
  provider_name = "Facebook"
  provider_type = "Facebook"

  provider_details = {
    authorize_scopes = "public_profile,email"
    client_id        = var.facebook.app_id
    client_secret    = var.facebook.app_secret
  }

  attribute_mapping = {
    name     = "name"
    email    = "email"
    username = "id"
  }
}

# SignInWithApple
resource "aws_cognito_identity_provider" "apple" {
  user_pool_id  = aws_cognito_user_pool.default.id
  provider_name = "SignInWithApple"
  provider_type = "SignInWithApple"

  provider_details = {
    client_id        = var.apple.client_id
    team_id          = var.apple.team_id
    key_id           = var.apple.key_id
    private_key      = file("AuthKey_43PD862NV5.p8")
    authorize_scopes = "email name"
  }

  attribute_mapping = {
    email_verified = "email_verified"
    name           = "firstName"
    email          = "email"
    username       = "sub"
  }
}
