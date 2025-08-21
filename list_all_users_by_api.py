#!/usr/bin/env python3
"""
FILE: list_all_users_by_api.py

DESCRIPTION:
    Connects to the SUSE Manager XML-RPC API to list all users
    and display their information in a table.

    Fields displayed:
    - Username
    - Full Name
    - Email
    - Account Status

REQUIREMENTS:
    - Python 3.x
    - xmlrpc.client (standard library)
    - Access to the SUSE Manager XML-RPC API

AUTHOR: Mario Luz
VERSION: 1.0
CREATION DATE: 2025-08-21

USAGE:
    python3 list_all_users_by_api.py

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
        context = ssl._create_unverified_context()
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

def list_all_users(client, session_key):
    """
    Lists all users and displays their information in a table.
    Args:
        client (ServerProxy): The API client.
        session_key (str): Session key.
    """
    try:
        users = client.user.listUsers(session_key)

        if not users:
            print("\nNo users are registered.")
            return

        print("\nList of Users:")
        print("{:<20} {:<25} {:<35} {:<15}".format(
            "Username", "Full Name", "Email", "Status"))
        print("{:<20} {:<25} {:<35} {:<15}".format(
            "-"*20, "-"*25, "-"*35, "-"*15))

        for user in users:
            username = user.get("login", "N/A")
            full_name = f"{user.get('first_name', '')} {user.get('last_name', '')}".strip()
            email = user.get("email", "N/A")
            status = "Active" if user.get("enabled", False) else "Disabled"
            
            print("{:<20} {:<25} {:<35} {:<15}".format(
                username, full_name, email, status))

    except Exception as e:
        print(f"ERROR: Failed to list users - {e}")
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
    - Lists all users
    - Logs out
    """
    client = connect_to_api()
    session_key = login(client)
    list_all_users(client, session_key)
    logout(client, session_key)

if __name__ == "__main__":
    main()