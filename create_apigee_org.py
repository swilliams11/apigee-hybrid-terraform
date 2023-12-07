import argparse
import json
import os
import subprocess
import requests
import sys

def get_token():
   token = subprocess.run(['gcloud', 'auth', 'print-access-token'], stdout=subprocess.PIPE)
   return token.stdout

def create_apigee_org(org_name, analytics_region, runtime_type):
    token = get_token().decode("utf-8").replace("\n","")
    url = f"https://apigee.googleapis.com/v1/organizations?parent=projects/{org_name}"
    headers = {'Content-Type': 'application/json',
               'Authorization': f'Bearer {token}'}
    data = {"name":org_name, "runtimeType":runtime_type, "analyticsRegion":analytics_region}
    print(json.dumps(data))
    response = requests.post(url, headers=headers, data=json.dumps(data))

    if response.status_code == requests.codes.created:
      check_status()

    elif str(response.status_code) == '409':
      check_status()

    else:
      print("Bad response from Apigee API while registering new account.")
      print("HTTP: " + str(response.status_code))
      sys.exit(3)


def check_status():
    """
    TODO
    """
    pass


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

    # Initialize parameters
    acctnum = None
    type = None

    create_apigee_org(args.org_name, args.analytics_region, runtime_type)


if __name__ == '__main__':
    sys.exit(main())