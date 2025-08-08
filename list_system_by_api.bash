#!/bin/bash
#
# FILE: list_system_by_api.bash
#
# USAGE: ./list_system_by_api.bash
#
# DESCRIPTION:
#   This script connects to a SUSE Manager XML-RPC API endpoint,
#   authenticates using provided credentials, and lists all registered
#   systems with their name and ID.
#
# OPTIONS:
#   None
#
# REQUIREMENTS:
#   - curl
#   - xmlstarlet
#
# AUTHOR: Mario Luz
# CONTACT: mario.luz@suse.com
# COMPANY: SUSE
#
# VERSION: 1.1
# CREATED: 14/12/2024
# REVISION: 14/12/2024
#

# --- Global constants ---
API_URL="https://suma5.lab/rpc/api"     # SUSE Manager API endpoint
USER="admin"                            # API username
PASS="admin"                            # API password

# --- Check if xmlstarlet is installed ---
if ! command -v xmlstarlet >/dev/null 2>&1; then
  echo "ERROR: 'xmlstarlet' is not installed."
  echo "To install it, run the following command:"
  echo "  sudo zypper install xmlstarlet"
  exit 1
fi

# --- Authenticate and retrieve session key ---
LOGIN_XML="<?xml version='1.0'?>
<methodCall>
  <methodName>auth.login</methodName>
  <params>
    <param><value><string>${USER}</string></value></param>
    <param><value><string>${PASS}</string></value></param>
  </params>
</methodCall>"

# --- Send login request ---
SESSION_KEY=$(curl -s -k -H "Content-Type: text/xml" -d "$LOGIN_XML" "$API_URL" | \
  xmlstarlet sel -t -v "//string")     # Extract session key from response

# --- Check if session key was retrieved ---
if [ -z "$SESSION_KEY" ]; then
  echo "ERROR: Failed to retrieve session key. Check credentials or API URL."
  exit 1
fi

# --- Prepare system listing request ---
LIST_XML="<?xml version='1.0'?>
<methodCall>
  <methodName>system.listSystems</methodName>
  <params>
    <param><value><string>${SESSION_KEY}</string></value></param>
  </params>
</methodCall>"

# --- Send system listing request ---
RESPONSE=$(curl -s -k -H "Content-Type: text/xml" -d "$LIST_XML" "$API_URL")

# --- Parse and display system information ---
echo "Registered systems:"
echo "-------------------"

echo "$RESPONSE" | xmlstarlet sel -t -m "//struct" \
  -v "member[name='name']/value/string" -o " | " \
  -v "member[name='id']/value/int" -n     # Display system name and ID

# --- Logout from session ---
LOGOUT_XML="<?xml version='1.0'?>
<methodCall>
  <methodName>auth.logout</methodName>
  <params>
    <param><value><string>${SESSION_KEY}</string></value></param>
  </params>
</methodCall>"

curl -s -k -H "Content-Type: text/xml" -d "$LOGOUT_XML" "$API_URL" > /dev/null

# --- Summary report ---
echo "-------------------"
echo "Session closed successfully."
