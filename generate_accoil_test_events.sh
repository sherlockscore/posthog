#!/bin/bash

# PostHog test events for Accoil integration
# Usage: ./generate_accoil_test_events.sh <API_KEY>
# Example: ./generate_accoil_test_events.sh phc_XuzX6OX0DZI3i98youG8EvDBr12JJoTLKXMbtMxUKds

# Check if API key was provided
if [ $# -eq 0 ]; then
    echo "Error: API key is required"
    echo "Usage: $0 <API_KEY>"
    echo "Example: $0 phc_XuzX6OX0DZI3i98youG8EvDBr12JJoTLKXMbtMxUKds"
    exit 1
fi

API_KEY="$1"
POSTHOG_URL="http://localhost:8010/capture/"

# Generate unique IDs for each run
TIMESTAMP=$(date +%s)
USER_ID="test-user-${TIMESTAMP}"

echo "Generating test events for user: ${USER_ID}"

# 1. $identify event - Identify a user
echo "Sending $identify event..."
curl -X POST ${POSTHOG_URL} \
  -H 'Content-Type: application/json' \
  -d '{
    "api_key": "'${API_KEY}'",
    "event": "$identify",
    "distinct_id": "'${USER_ID}'",
    "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")'",
    "properties": {
      "$set": {
        "email": "testuser-'${TIMESTAMP}'@example.com",
        "name": "Test User '${TIMESTAMP}'",
        "role": "admin",
        "account_status": "active",
        "company": "Test Company '${TIMESTAMP}'",
        "created_at": "2024-01-15T10:30:00Z"
      }
    }
  }'
echo ""

# 2. $set event - Update user properties
echo "Sending $set event..."
curl -X POST ${POSTHOG_URL} \
  -H 'Content-Type: application/json' \
  -d '{
    "api_key": "'${API_KEY}'",
    "event": "$set",
    "distinct_id": "'${USER_ID}'",
    "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")'",
    "properties": {
      "$set": {
        "last_login": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'",
        "plan": "premium"
      }
    }
  }'
echo ""

# 3. $pageview event - Track a page view
echo "Sending $pageview event..."
curl -X POST ${POSTHOG_URL} \
  -H 'Content-Type: application/json' \
  -d '{
    "api_key": "'${API_KEY}'",
    "event": "$pageview",
    "distinct_id": "'${USER_ID}'",
    "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")'",
    "properties": {
      "$current_url": "https://example.com/products/widget-'${TIMESTAMP}'",
      "$pathname": "/products/widget-'${TIMESTAMP}'",
      "$host": "example.com",
      "title": "Widget '${TIMESTAMP}' - Product Page"
    }
  }'
echo ""

# 4. $screen event - Track a screen view (mobile)
echo "Sending $screen event..."
curl -X POST ${POSTHOG_URL} \
  -H 'Content-Type: application/json' \
  -d '{
    "api_key": "'${API_KEY}'",
    "event": "$screen",
    "distinct_id": "'${USER_ID}'",
    "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")'",
    "properties": {
      "$screen_name": "ProductDetailScreen-'${TIMESTAMP}'",
      "product_id": "widget-'${TIMESTAMP}'",
      "category": "Electronics"
    }
  }'
echo ""

# 5. $groupidentify event - Identify a group/company
echo "Sending $groupidentify event..."
curl -X POST ${POSTHOG_URL} \
  -H 'Content-Type: application/json' \
  -d '{
    "api_key": "'${API_KEY}'",
    "event": "$groupidentify",
    "distinct_id": "'${USER_ID}'",
    "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")'",
    "properties": {
      "$group_type": "company",
      "$group_key": "company-'${TIMESTAMP}'",
      "$group_set": {
        "name": "Acme Corporation '${TIMESTAMP}'",
        "plan": "enterprise",
        "industry": "Technology",
        "mrr": '$(( RANDOM % 100000 + 1000 ))',
        "created_at": "2023-01-15T10:30:00Z",
        "status": "active",
        "employee_count": '$(( RANDOM % 1000 + 10 ))'
      }
    }
  }'
echo ""

# 6. Custom track event - Product Viewed
echo "Sending custom 'Product Viewed' track event..."
curl -X POST ${POSTHOG_URL} \
  -H 'Content-Type: application/json' \
  -d '{
    "api_key": "'${API_KEY}'",
    "event": "Product Viewed",
    "distinct_id": "'${USER_ID}'",
    "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")'",
    "properties": {
      "product_id": "widget-'${TIMESTAMP}'",
      "product_name": "Super Widget '${TIMESTAMP}'",
      "price": '$(( RANDOM % 500 + 10 ))',
      "currency": "USD",
      "category": "Electronics"
    }
  }'
echo ""

# 7. Custom track event - Checkout Started
echo "Sending custom 'Checkout Started' track event..."
curl -X POST ${POSTHOG_URL} \
  -H 'Content-Type: application/json' \
  -d '{
    "api_key": "'${API_KEY}'",
    "event": "Checkout Started",
    "distinct_id": "'${USER_ID}'",
    "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")'",
    "properties": {
      "cart_value": '$(( RANDOM % 1000 + 50 ))',
      "items_count": '$(( RANDOM % 10 + 1 ))',
      "currency": "USD",
      "payment_method": "credit_card"
    }
  }'
echo ""

# 8. Custom track event - Subscription Upgraded
echo "Sending custom 'Subscription Upgraded' track event..."
curl -X POST ${POSTHOG_URL} \
  -H 'Content-Type: application/json' \
  -d '{
    "api_key": "'${API_KEY}'",
    "event": "Subscription Upgraded",
    "distinct_id": "'${USER_ID}'",
    "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")'",
    "properties": {
      "old_plan": "basic",
      "new_plan": "premium",
      "mrr_change": '$(( RANDOM % 200 + 50 ))',
      "upgrade_reason": "need_more_features"
    }
  }'
echo ""

echo "✅ All test events sent successfully!"
echo "User ID: ${USER_ID}"
echo "You can now load these events in the PostHog UI"