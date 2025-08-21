#!/usr/bin/env python3
"""
FILE: get_user_details_by_api.py

DESCRIPTION:
    Connects to the SUSE Manager XML-RPC API to fetch and display
    the details of a specific user.

    Fields displayed:
    - Username
    - Full Name
    - Email
    - Administrator Roles
    - Account Status

REQUIREMENTS:
    - Python 3.x
    - xmlrpc.client (standard library)
    - Access to the SUSE Manager XML-RPC API

AUTHOR: Mario Luz
VERSION: 1.0
CREATION DATE: 2025-08-21

USAGE:
    python3 get_user_details_by_api.py <username>

NOTES:
    - Edit the USER, PASS, and API_URL variables as needed.
    - The script disables SSL verification for demonstration purposes.
"""

import sys
import ssl
import xmlrpc.client

# --- Configuration Section ---
# SUSE Manager API endpoint
API_URL = "https://suma5.lab/rpc/api"
# API username
USER = "admin"
# API password
PASS = "admin"

def connect_to_api():
    """
    Establishes a connection to the SUSE Manager XML-RPC API.
    Disables SSL verification for self-signed certificates.
    Returns:
        xmlrpc.client.ServerProxy: API client object.
    """
    try:
        context = ssl._create_unverified_verified_context()
        return xmlrpc.client.ServerProxy(API_URL, context=context)
    except Exception as e:
        print(f"ERROR: Failed to connect to API - {e}")
        sys.exit(1)

def login(client):
    """
    Authenticates with the SUSE Manager API and retrieves a session key.
    Args:
        client (ServerProxy): The API client.
    Returns:
        str: Session key.
    """
    try:
        return client.auth.login(USER, PASS)
    except Exception as e:
        print(f"ERROR: Login failed - {e}")
        sys.exit(1)

def get_user_details(client, session_key, username_to_query):
    """
    Fetches and displays the details for a specific user.
    Args:
        client (ServerProxy): The API client.
        session_key (str): Session key.
        username_to_query (str): The username to query.
    """
    try:
        user_details = client.user.getDetails(session_key, username_to_query)

        if not user_details:
            print(f"\nERROR: User '{username_to_query}' not found.")
            sys.exit(1)

        print("\nUser Details:")
        print("-" * 30)
        print(f"{'Username:':<20} {user_details.get('login', 'N/A')}")
        print(f"{'Full Name:':<20} {user_details.get('first_name', 'N/A')} {user_details.get('last_name', 'N/A')}")
        print(f"{'Email:':<20} {user_details.get('email', 'N/A')}")
        print(f"{'Account Status:':<20} {'Active' if user_details.get('enabled') else 'Disabled'}")

        roles = [role.get('label') for role in user_details.get('roles', [])]
        print(f"{'Roles:':<20} {', '.join(roles) if roles else 'None'}")

    except Exception as e:
        print(f"ERROR: Failed to get user details - {e}")
        sys.exit(1)

def logout(client, session_key):
    """
    Logs out from the SUSE Manager API session.
    Args:
        client (ServerProxy): The API client.
        session_key (str): Session key.
    """
    try:
        client.auth.logout(session_key)
        print("\nSession closed successfully.")
    except Exception as e:
        print(f"WARNING: Logout failed - {e}")

def main():
    """
    Main execution flow:
    - Connects to the API
    - Authenticates and retrieves a session key
    - Fetches and displays user details
    - Logs out
    """
    if len(sys.argv) != 2:
        print("Usage: python3 get_user_details_by_api.py <username>")
        sys.exit(1)

    username_to_query = sys.argv[1]

    client = connect_to_api()
    session_key = login(client)
    get_user_details(client, session_key, username_to_query)
    logout(client, session_key)

if __name__ == "__main__":
    main()