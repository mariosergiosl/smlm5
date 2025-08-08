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

AUTHOR: Mario Luz
VERSION: 2.0
REVISION: 08/08/2025
"""

import sys
import ssl
import re
import xmlrpc.client

API_URL = "https://suma5.lab/rpc/api"
USER = "admin"
PASS = "admin"

def connect_to_api():
    context = ssl._create_unverified_context()
    return xmlrpc.client.ServerProxy(API_URL, context=context)

def login(client):
    try:
        return client.auth.login(USER, PASS)
    except Exception as e:
        print(f"ERROR: Login failed - {e}")
        sys.exit(1)

def extract_ip_from_description(description):
    if not description:
        return None
    match = re.search(r'\b(?:\d{1,3}\.){3}\d{1,3}\b', description)
    return match.group(0) if match else None

def get_ip(client, session_key, system_id, details):
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
    try:
        client.auth.logout(session_key)
        print("\nSession closed successfully.")
    except Exception as e:
        print(f"WARNING: Logout failed - {e}")

def main():
    client = connect_to_api()
    session_key = login(client)
    list_systems(client, session_key)
    logout(client, session_key)

if __name__ == "__main__":
    main()
