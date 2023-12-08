import argparse
import json
import os
import subprocess
import requests
import sys
import time

APIGEE_HOST = "https://apigee.googleapis.com"
SLEEP_TIME = 10 #seconds
MAX_SLEEP = SLEEP_TIME * 2
HTTP_SUCCESS_STATUS_CODE = requests.codes.ok
IN_PROGRESS = "IN_PROGRESS"

def get_token():
   token = subprocess.run(['gcloud', 'auth', 'print-access-token'], stdout=subprocess.PIPE)
   return token.stdout


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


def wait_for_complete(post_response):
  """
  Wait for the Apigee Create Org to complete successfully before continuing.
  """
  sleep_time = SLEEP_TIME
  operation_state = post_response["metadata"]["state"]
  if operation_state == IN_PROGRESS:
    operation_name = post_response["name"]
    while operation_state == IN_PROGRESS and sleep_time < MAX_SLEEP:
      time.sleep(SLEEP_TIME)
      sleep_time += SLEEP_TIME
      get_response = requests.get(f"{APIGEE_HOST}/v1/{operation_name}")
      operation_state = get_response.json()["metadata"]["state"]


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