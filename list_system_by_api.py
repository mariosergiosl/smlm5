#!/usr/bin/env python3
"""
FILE: list_system_by_api.py

DESCRIPTION:
    Connects to SUSE Manager XML-RPC API and lists all registered systems in table format.

    Fields:
    - System name
    - System ID
    - Release
    - IP address

REQUIREMENTS:
    - Python 3.x
    - xmlrpc.client (standard library)
    - Access to SUSE Manager XML-RPC API

AUTHOR: Mario Luz
VERSION: 2.0
CREATION DATE: 08/12/2024
REVISION: 08/08/2025

USAGE:
    python3 list_system_by_api.py

NOTES:
    - Edit USER, PASS, and API_URL variables as needed.
    - The script disables SSL verification for demonstration purposes.
"""

import sys
import ssl
import re
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
    context = ssl._create_unverified_context()
    return xmlrpc.client.ServerProxy(API_URL, context=context)

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

def extract_ip_from_description(description):
    """
    Attempts to extract an IP address from the system description field.
    Args:
        description (str): System description.
    Returns:
        str or None: Extracted IP address or None if not found.
    """    
    if not description:
        return None
    match = re.search(r'\b(?:\d{1,3}\.){3}\d{1,3}\b', description)
    return match.group(0) if match else None

def get_ip(client, session_key, system_id, details):
    """
    Retrieves the system's IP address.
    Tries to extract from description, otherwise queries network devices.
    Args:
        client (ServerProxy): The API client.
        session_key (str): Session key.
        system_id (int): System ID.
        details (dict): System details.
    Returns:
        str: IP address or "N/A".
    """    
    ip = extract_ip_from_description(details.get("description", ""))
    if ip:
        return ip
    try:
        devices = client.system.getNetworkDevices(session_key, system_id)
        for device in devices:
            ip = device.get("ip")
            if ip and ip != "127.0.0.1":
                return ip
    except Exception:
        pass
    return "N/A"

def list_systems(client, session_key):
    """
    Lists all registered systems and prints their information in a table.
    Args:
        client (ServerProxy): The API client.
        session_key (str): Session key.
    """    
    try:
        systems = client.system.listSystems(session_key)

        print("\n{:<20} {:<12} {:<8} {:<15}".format(
            "Nome", "ID", "Release", "IP Address"))
        print("{:<20} {:<12} {:<8} {:<15}".format(
            "-"*20, "-"*12, "-"*8, "-"*15))

        for system in systems:
            name = system.get("name", "N/A")
            system_id = system.get("id", "N/A")
            details = client.system.getDetails(session_key, system_id)

            release = details.get("release", "N/A")
            ip_address = get_ip(client, session_key, system_id, details)

            print("{:<20} {:<12} {:<8} {:<15}".format(
                name, system_id, release, ip_address))

    except Exception as e:
        print(f"ERROR: Failed to list systems - {e}")
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
    - Connects to API
    - Authenticates and retrieves session key
    - Lists systems
    - Logs out
    """    
    client = connect_to_api()
    session_key = login(client)
    list_systems(client, session_key)
    logout(client, session_key)

if __name__ == "__main__":
    main()
