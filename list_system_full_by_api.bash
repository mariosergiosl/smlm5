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
#   - curl
#   - xmlstarlet
#
# AUTHOR: Mario Luz
# VERSION: 2.3
# REVISION: 08/08/2025

API_URL="https://suma5.lab/rpc/api"
USER="admin"
PASS="admin"

# Authenticate
LOGIN_XML="<?xml version='1.0'?>
<methodCall>
  <methodName>auth.login</methodName>
  <params>
    <param><value><string>${USER}</string></value></param>
    <param><value><string>${PASS}</string></value></param>
  </params>
</methodCall>"

SESSION_KEY=$(curl -s -k -H "Content-Type: text/xml" -d "$LOGIN_XML" "$API_URL" | \
  xmlstarlet sel -t -v "//string")

[ -z "$SESSION_KEY" ] && { echo "ERROR: Failed to authenticate."; exit 1; }

# List systems
LIST_XML="<?xml version='1.0'?>
<methodCall>
  <methodName>system.listSystems</methodName>
  <params>
    <param><value><string>${SESSION_KEY}</string></value></param>
  </params>
</methodCall>"

RESPONSE=$(curl -s -k -H "Content-Type: text/xml" -d "$LIST_XML" "$API_URL")

SYSTEM_IDS=($(echo "$RESPONSE" | xmlstarlet sel -t -m "//array/data/value/struct" -v "member[name='id']/value/i4" -n))
SYSTEM_NAMES=($(echo "$RESPONSE" | xmlstarlet sel -t -m "//array/data/value/struct" -v "member[name='name']/value/string" -n))

printf "\n%-20s %-15s %-20s\n" "System Name" "System ID" "IP Address"
printf "%-20s %-15s %-20s\n" "------------" "---------" "----------"

for ((i=0; i<${#SYSTEM_IDS[@]}; i++)); do
  ID="${SYSTEM_IDS[$i]}"
  NAME="${SYSTEM_NAMES[$i]}"
  IP="N/A"

  # Get network devices
  NET_XML="<?xml version='1.0'?>
<methodCall>
  <methodName>system.getNetworkDevices</methodName>
  <params>
    <param><value><string>${SESSION_KEY}</string></value></param>
    <param><value><int>${ID}</int></value></param>
  </params>
</methodCall>"

  NET=$(curl -s -k -H "Content-Type: text/xml" -d "$NET_XML" "$API_URL")
  IP=$(echo "$NET" | xmlstarlet sel -t -m "//array/data/value/struct" \
    -v "member[name='ip']/value/string" -n | grep -vE '^(127\.|$)' | head -n 1)
  [ -z "$IP" ] && IP="N/A"

  printf "%-20s %-15s %-20s\n" "$NAME" "$ID" "$IP"
done

# Logout
LOGOUT_XML="<?xml version='1.0'?>
<methodCall>
  <methodName>auth.logout</methodName>
  <params>
    <param><value><string>${SESSION_KEY}</string></value></param>
  </params>
</methodCall>"

curl -s -k -H "Content-Type: text/xml" -d "$LOGOUT_XML" "$API_URL" > /dev/null

echo -e "\nSession closed successfully."
