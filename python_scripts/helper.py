import subprocess
import time
import requests
import os
import logging as log
import sys

APIGEE_WAIT_TIME_IN_SECS = 'APIGEE_WAIT_TIME_IN_SECS'
INCREMENT_WAIT_TIME_BY = 'INCREMENT_WAIT_TIME_BY'
SLEEP_TIME_DEFAULT = 60 #seconds
INCR_BY_DEFAULT = 15
APIGEE_HOST = "https://apigee.googleapis.com"
IN_PROGRESS = "IN_PROGRESS"
sleep_time = os.environ.get(APIGEE_WAIT_TIME_IN_SECS, None)
SLEEP_TIME = SLEEP_TIME_DEFAULT if sleep_time is None else int(sleep_time)  #in seconds
incr_by = os.environ.get(INCREMENT_WAIT_TIME_BY, None)
MAX_SLEEP = SLEEP_TIME * INCR_BY_DEFAULT if incr_by is None else SLEEP_TIME * int(incr_by)
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
    log.info(f"Apigee operation is {operation_state} ... {operation_name}")
    while operation_state == IN_PROGRESS and sleep_time < MAX_SLEEP:
      log.info(f"Waiting for operation to complete...")
      time.sleep(SLEEP_TIME)
      sleep_time += SLEEP_TIME
      get_response = requests.get(f"{APIGEE_HOST}/v1/{operation_name}")
      if get_response.status_code != 200:
        operation_state = get_response.json()["metadata"]["state"]
        log.info(f"Operation state is {operation_state}")
      else:
        log.error(f"Cannot get operation state for {operation_name}")
        sys.exit(3)
      break