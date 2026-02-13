#!/bin/bash

# Configuration file
CONFIG_FILE="ketal_config.yml"
OUTPUT_FILE="app.yml"

# Helper function to extract values from YAML manually (simple grep/cut)
# Usage: get_config_value "key"
get_config_value() {
    local key=$1
    grep "$key:" "$CONFIG_FILE" | head -n 1 | cut -d '"' -f 2
}

# Extract Branding
APP_NAME=$(get_config_value "app_name")
DISPLAY_NAME=$(get_config_value "display_name")
BUNDLE_ID_BASE=$(get_config_value "bundle_id_base")
APP_GROUP=$(get_config_value "app_group")
TEAM_ID=$(get_config_value "team_id")

# Extract Domains
DOMAIN_BASE=$(get_config_value "base")
# Only extract exact matches or use specific logic if keys are duplicated
# For simplicity in this bespoke script, we assume unique keys or order.
# ketal_config.yml has indented keys. grep might match multiple.
# Let's use a more robust parsing for domains.

# Refined extraction:
# Get the block content? Or just specific lines?
# Since we control ketal_config.yml, we can look for specific unique strings or context.
# But "base" appears in domain: base: "ketals.online".

# Let's match indentation.
DOMAIN_BASE=$(grep "  base: " "$CONFIG_FILE" | cut -d '"' -f 2)
DOMAIN_MATRIX=$(grep "  matrix: " "$CONFIG_FILE" | cut -d '"' -f 2)
DOMAIN_AUTH=$(grep "  auth: " "$CONFIG_FILE" | cut -d '"' -f 2)

# Extract OIDC
OIDC_REDIRECT_URI=$(grep "  redirect_uri: " "$CONFIG_FILE" | cut -d '"' -f 2)
OIDC_CLIENT_NAME=$(grep "  client_name: " "$CONFIG_FILE" | cut -d '"' -f 2)

# PUSH
PUSH_FALLBACK_RAW=$(grep "  fallback_gateway_url: " "$CONFIG_FILE" | cut -d '"' -f 2)
# Substitute ${domain.base} with actual value
PUSH_FALLBACK=${PUSH_FALLBACK_RAW//\$\{domain.base\}/$DOMAIN_BASE}

echo "Generating $OUTPUT_FILE from $CONFIG_FILE..."

cat > "$OUTPUT_FILE" <<EOF
settings:
  # Branding
  APP_DISPLAY_NAME: $DISPLAY_NAME
  PRODUCTION_APP_NAME: $APP_NAME
  APP_GROUP_IDENTIFIER: $APP_GROUP
  BASE_BUNDLE_IDENTIFIER: $BUNDLE_ID_BASE
  ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME: "colors/accent-color"
  DEVELOPMENT_TEAM: $TEAM_ID

  # Custom Configuration (Injected via apply_ketal_config.sh)
  KETAL_DOMAIN_BASE: $DOMAIN_BASE
  KETAL_DOMAIN_MATRIX: $DOMAIN_MATRIX
  KETAL_DOMAIN_AUTH: $DOMAIN_AUTH
  
  KETAL_OIDC_REDIRECT_URI: $OIDC_REDIRECT_URI
  KETAL_OIDC_CLIENT_NAME: $OIDC_CLIENT_NAME
  
  # Push
  KETAL_PUSH_FALLBACK_URL: $PUSH_FALLBACK
EOF

echo "Done. $OUTPUT_FILE updated."
echo "APP_DISPLAY_NAME: $DISPLAY_NAME"
echo "BASE_BUNDLE_IDENTIFIER: $BUNDLE_ID_BASE"
