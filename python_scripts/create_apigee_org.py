import argparse
import json
import requests
import sys
import os
from helper import APIGEE_HOST, HTTP_SUCCESS_STATUS_CODE, APIGEE_WAIT_TIME_IN_SECS, INCREMENT_WAIT_TIME_BY, get_token, wait_for_complete
import logging as log

def create_apigee_org_request(org_name, analytics_region, runtime_type):
    """
    Creates the Apigee org request and sends it to the Apigee management API.
    Wait for a successful response or raise an exception if the Apigee
    Management API returns an error. 
    """
    token = get_token().decode("utf-8").replace("\n","")
    log.info("Getting the gcloud auth token.")
    url = f"{APIGEE_HOST}/v1/organizations?parent=projects/{org_name}"
    headers = {'Content-Type': 'application/json',
               'Authorization': f'Bearer {token}'}
    data = {"name":org_name, "runtimeType":runtime_type, "analyticsRegion":analytics_region}
    response = requests.post(url, headers=headers, data=json.dumps(data))
    log.info("Sent the request to create the Apigee Org.")

    if response.status_code == HTTP_SUCCESS_STATUS_CODE:
      wait_for_complete(response.json())
    elif response.status_code == 409:
       log.info("Apigee organization already exists, so exiting.")
       sys.exit(0)
    else:
      log.error("Bad response from Apigee API while creating a new Apigee Organization account.")
      log.error(f"HTTP: {response.status_code} - {response.text}")
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
    parser.add_argument('-t', '--wait_time', help="Time to wait for command to complete in seconds")
    parser.add_argument('-i', '--increment_by', help="Total number of times to increment the wait time, so if you t = 60 seconds, i = 10, then it will wait for a total time of 10minutes")

    args = parser.parse_args()

    if args.wait_time is not None and args.increment_by is not None:
      os.environ[APIGEE_WAIT_TIME_IN_SECS] = args.wait_time
      os.environ[INCREMENT_WAIT_TIME_BY] = args.increment_by
    else:
      os.environ.pop(APIGEE_WAIT_TIME_IN_SECS)
      os.environ.pop(INCREMENT_WAIT_TIME_BY)

    runtime_type = "HYBRID" if args.runtime_type == None else args.runtime_type

    create_apigee_org_request(args.org_name, args.analytics_region, runtime_type)


if __name__ == '__main__':
    sys.exit(main())