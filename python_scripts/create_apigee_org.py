import argparse
import json
import os
import subprocess
import requests
import sys
import time
from helper import APIGEE_HOST, HTTP_SUCCESS_STATUS_CODE, get_token, wait_for_complete


def create_apigee_org_request(org_name, analytics_region, runtime_type):
    """
    Creates the Apigee org request and sends it to the Apigee management API.
    Wait for a successful response or raise an exception if the Apigee
    Management API returns an error. 
    """
    token = get_token().decode("utf-8").replace("\n","")
    url = f"{APIGEE_HOST}/v1/organizations?parent=projects/{org_name}"
    headers = {'Content-Type': 'application/json',
               'Authorization': f'Bearer {token}'}
    data = {"name":org_name, "runtimeType":runtime_type, "analyticsRegion":analytics_region}
    response = requests.post(url, headers=headers, data=json.dumps(data))

    if response.status_code == HTTP_SUCCESS_STATUS_CODE:
      wait_for_complete(response.json())
    else:
      print("Bad response from Apigee API while creating a new Apigee Organization account.")
      print(f"HTTP: {response.status_code} - {response.text}")
      sys.exit(3)


def main():
    '''
    Main function: work with command line options and send an HTTPS request to the Apigee API.
    '''
    parser = argparse.ArgumentParser(
                    prog='ApigeeHybridOrg',
                    description='Create Apigee Hybrid Organization')
    
    parser.add_argument('-o', '--org_name', required=True, help="Apigee Organization Name, which should be the same as the Google Cloud Project ID")
    parser.add_argument('-a', '--analytics_region', required=True, help="Apigee Analytics Google Cloud region")
    parser.add_argument('-r', '--runtime_type', help="Apigee Organization Runtime Type")

    args = parser.parse_args()
    runtime_type = "HYBRID" if args.runtime_type == None else args.runtime_type

    create_apigee_org_request(args.org_name, args.analytics_region, runtime_type)


if __name__ == '__main__':
    sys.exit(main())