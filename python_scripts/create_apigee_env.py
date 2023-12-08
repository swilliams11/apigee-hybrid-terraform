import argparse
import json
import requests
import sys
import time
from helper import APIGEE_HOST, HTTP_SUCCESS_STATUS_CODE, get_token, wait_for_complete



def create_apigee_env_request(org_name, env_name, env_group_name, host_names: str):
    """
    Creates the Apigee org request and sends it to the Apigee management API.
    Wait for a successful response or raise an exception if the Apigee
    Management API returns an error. 
    """

    # fetch the authorization token for the current user
    token = get_token().decode("utf-8").replace("\n","")

    # Create an Apigee environment group
    url = f"{APIGEE_HOST}/v1/organizations/{org_name}/envgroups"
    headers = {'Content-Type': 'application/json',
               'Authorization': f'Bearer {token}'}
    hostnames_list = host_names.split(",")
    data = {"name":env_group_name, "hostnames": hostnames_list}
    response = requests.post(url, headers=headers, data=json.dumps(data))
    check_response_status(response)

    # Create an Apigee environment
    url = f"{APIGEE_HOST}/v1/organizations/{org_name}/environments"
    headers = {'Content-Type': 'application/json',
               'Authorization': f'Bearer {token}'}
    data = {"name":env_name, }
    response = requests.post(url, headers=headers, data=json.dumps(data))
    check_response_status(response)

    # Attach the Apigee environment to the group
    url = f"{APIGEE_HOST}/v1/organizations/{org_name}/envgroups/{env_group_name}/attachments"
    headers = {'Content-Type': 'application/json',
               'Authorization': f'Bearer {token}'}
    data = {"environment":env_name}
    response = requests.post(url, headers=headers, data=json.dumps(data))
    check_response_status(response)

    
def check_response_status(response):
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
                    prog='ApigeeHybridEnv',
                    description='Create Apigee Hybrid Enviornment and Environment Group')
    
    parser.add_argument('-o', '--org_name', required=True, help="Apigee Organization Name, which should be the same as the Google Cloud Project ID")
    parser.add_argument('-e', '--env_name', required=True, help="Apigee Environment Name")
    parser.add_argument('-g', '--env_group_name', required=True, help="Apigee Environment Group Name")
    parser.add_argument('-n', '--host_names', required=True, help="Apigee Environment Group Host Names")

    args = parser.parse_args()

    create_apigee_env_request(args.org_name, args.env_name, args.env_group_name, args.host_names)


if __name__ == '__main__':
    sys.exit(main())