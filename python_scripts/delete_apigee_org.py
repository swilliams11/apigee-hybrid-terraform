import argparse
import requests
import sys
from helper import APIGEE_HOST, HTTP_SUCCESS_STATUS_CODE, get_token, wait_for_complete
import logging as log

def delete_apigee_org_request(org_name):
    """
    Deletes the Apigee org request and sends it to the Apigee management API.
    Wait for a successful response or raise an exception if the Apigee
    Management API returns an error. 
    """
    token = get_token().decode("utf-8").replace("\n","")
    url = f"{APIGEE_HOST}/v1/organizations/{org_name}"
    headers = {'Authorization': f'Bearer {token}'}
    
    response = requests.delete(url, headers=headers)
    log.info(f"Sent request to delete Apigee organization {org_name}")
    if response.status_code == HTTP_SUCCESS_STATUS_CODE:
      log.info(f"Delete Apigee organization request was successful... now waiting for operation to complete...")
      wait_for_complete(response.json())
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

    args = parser.parse_args()

    delete_apigee_org_request(args.org_name)


if __name__ == '__main__':
    sys.exit(main())