#!/bin/bash
#
# FILE: list_system_full_by_api.bash
#
# DESCRIPTION:
#   Connects to SUSE Manager XML-RPC API and lists systems with:
#     - Name
#     - ID
#     - Real IP address (from network devices)
#
# REQUIREMENTS:
#   - curl: For making HTTP requests to the API.
#   - xmlstarlet: For parsing XML responses.
#
# AUTHOR: Mario Luz - mario.luz@suse.com
# VERSION: 2.3
# CREATION DATE: 08/12/2024
# REVISION: 08/08/2025
#
# USAGE:
#   ./list_system_full_by_api.bash
#
# NOTES:
#   - Edit USER, PASS, and API_URL variables as needed.
#   - Ensure xmlstarlet and curl are installed on your system.
#

# --- Configuration Section ---
# SUSE Manager API endpoint
API_URL="https://suma5.lab/rpc/api"
# API username
USER="admin"
# API password
PASS="admin"

# --- Authentication Section ---
# Build XML for login request
LOGIN_XML="<?xml version='1.0'?>
<methodCall>
  <methodName>auth.login</methodName>
  <params>
    <param><value><string>${USER}</string></value></param>
    <param><value><string>${PASS}</string></value></param>
  </params>
</methodCall>"

# Send login request and extract session key
SESSION_KEY=$(curl -s -k -H "Content-Type: text/xml" -d "$LOGIN_XML" "$API_URL" | \
  xmlstarlet sel -t -v "//string")

# Check if authentication was successful
[ -z "$SESSION_KEY" ] && { echo "ERROR: Failed to authenticate."; exit 1; }

# --- List Systems Section ---
# Build XML for listing systems
LIST_XML="<?xml version='1.0'?>
<methodCall>
  <methodName>system.listSystems</methodName>
  <params>
    <param><value><string>${SESSION_KEY}</string></value></param>
  </params>
</methodCall>"

# Send request to list systems and store response
RESPONSE=$(curl -s -k -H "Content-Type: text/xml" -d "$LIST_XML" "$API_URL")

# Parse system IDs and names from the response
SYSTEM_IDS=($(echo "$RESPONSE" | xmlstarlet sel -t -m "//array/data/value/struct" -v "member[name='id']/value/i4" -n))
SYSTEM_NAMES=($(echo "$RESPONSE" | xmlstarlet sel -t -m "//array/data/value/struct" -v "member[name='name']/value/string" -n))

# Print table header
printf "\n%-20s %-15s %-20s\n" "System Name" "System ID" "IP Address"
printf "%-20s %-15s %-20s\n" "------------" "---------" "----------"

# --- Per-System Network Device Query Section ---
for ((i=0; i<${#SYSTEM_IDS[@]}; i++)); do
  ID="${SYSTEM_IDS[$i]}"
  NAME="${SYSTEM_NAMES[$i]}"
  IP="N/A"

  # Get network devices
  # Build XML for getting network devices of the system
  NET_XML="<?xml version='1.0'?>
<methodCall>
  <methodName>system.getNetworkDevices</methodName>
  <params>
    <param><value><string>${SESSION_KEY}</string></value></param>
    <param><value><int>${ID}</int></value></param>
  </params>
</methodCall>"
  
  # Send request and parse the first non-loopback IP address
  NET=$(curl -s -k -H "Content-Type: text/xml" -d "$NET_XML" "$API_URL")
  IP=$(echo "$NET" | xmlstarlet sel -t -m "//array/data/value/struct" \
    -v "member[name='ip']/value/string" -n | grep -vE '^(127\.|$)' | head -n 1)
  [ -z "$IP" ] && IP="N/A"

  # Print system information
  printf "%-20s %-15s %-20s\n" "$NAME" "$ID" "$IP"
done

# --- Logout Section ---
# Build XML for logout request
LOGOUT_XML="<?xml version='1.0'?>
<methodCall>
  <methodName>auth.logout</methodName>
  <params>
    <param><value><string>${SESSION_KEY}</string></value></param>
  </params>
</methodCall>"

# Send logout request to close the session
curl -s -k -H "Content-Type: text/xml" -d "$LOGOUT_XML" "$API_URL" > /dev/null

echo -e "\nSession closed successfully."
