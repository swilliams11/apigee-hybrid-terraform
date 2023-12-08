import subprocess
import time
import requests


APIGEE_HOST = "https://apigee.googleapis.com"
IN_PROGRESS = "IN_PROGRESS"
SLEEP_TIME = 10 #seconds
MAX_SLEEP = SLEEP_TIME * 2
HTTP_SUCCESS_STATUS_CODE = requests.codes.ok

def get_token():
   token = subprocess.run(['gcloud', 'auth', 'print-access-token'], stdout=subprocess.PIPE)
   return token.stdout


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