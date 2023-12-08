from unittest import mock
import unittest
import create_apigee_org
import sys


class TestCreateApigeeOrg(unittest.TestCase):
    
    def test_main_missing_command_line_args(self):
        # Test that the function raises an error if the user does not enter the required command line arguments
        with self.assertRaises(SystemExit):
            create_apigee_org.main()
    

    @mock.patch('requests.post')
    @mock.patch('sys.argv', ['main', '-o', 'org_name', '-a', 'us-central1'])
    def test_main_then_create_apigee_org_failed(self, mock_post):
        # Given user enters the correct command line args
        # And the Create Apigee Org API request returns a 403, resulting in a SystemExit
        # Then the main function should throw a SystemExit
        
        # mock the Create Apigee Org API Response as 403
        mock_response = mock.Mock()
        mock_response.status_code = 403
        mock_response.json = lambda: {'data': 'Mocked response data'}
        mock_post.return_value = mock_response

        with self.assertRaises(SystemExit):
            create_apigee_org.main()    


    @mock.patch('requests.post')
    def test_create_apigee_org_failed(self, mock_post):
        # Tests that System Exit is called when Apigee returns a 403 response code

        # mock the Create Apigee Org API Response as 403
        mock_response = mock.Mock()
        mock_response.status_code = 403
        mock_response.json = lambda: {'data': 'Mocked response data'}
        mock_post.return_value = mock_response

        with self.assertRaises(SystemExit):
            create_apigee_org.create_apigee_org_request("org", 'us-central1', 'HYBRID')
            assert SystemExit.code == 3



    @mock.patch('requests.post')
    @mock.patch('create_apigee_org.wait_for_complete')
    def test_create_apigee_org_succeeded(self, mock_post, mock_wait_for_complete):
        # Tests the create_apigee_org() function directly correctly waits for a success response.

        # mock the Create Apigee Org API Response as 200 - state inprogress
        mock_response_inprogress = mock.Mock()
        mock_response_inprogress.status_code = 200
        mock_response_inprogress.json = lambda: {
        "name": "organizations/org_name/operations/LONG_RUNNING_OPERATION_ID",
        "metadata": {
            "@type": "type.googleapis.com/google.cloud.apigee.v1.OperationMetadata",
            "operationType": "INSERT",
            "targetResourceName": "organizations/org_name",
            "state": "IN_PROGRESS"
        }
        }
        mock_post.return_value = mock_response_inprogress
        mock_wait_for_complete.return_value = ""

        create_apigee_org.create_apigee_org_request("org", 'us-central1', 'HYBRID')
         # Verify the first response
        self.assertEqual(mock_response_inprogress.status_code, 200)
        self.assertEqual(mock_response_inprogress.json()['metadata']['state'], 'IN_PROGRESS')
        self.assertEqual(mock_post.call_count, 1)


    @mock.patch('requests.get')
    def test_wait_for_complete_succeeded(self, mock_get):
        # Tests the wait_for_compelete() function directly correctly waits for a success response.

        data = {
        "name": "organizations/org_name/operations/LONG_RUNNING_OPERATION_ID",
        "metadata": {
            "@type": "type.googleapis.com/google.cloud.apigee.v1.OperationMetadata",
            "operationType": "INSERT",
            "targetResourceName": "organizations/org_name",
            "state": "IN_PROGRESS"
        }
        }

         # mock the Create Apigee Org API Response as 200 as state finished
        mock_response_complete = mock.Mock()
        mock_response_complete.status_code = 200
        mock_response_complete.json = lambda: {
        "name": "organizations/ORG_NAME/operations/LONG_RUNNING_OPERATION_ID",
        "metadata": {
            "@type": "type.googleapis.com/google.cloud.apigee.v1.OperationMetadata",
            "operationType": "INSERT",
            "targetResourceName": "organizations/ORG_NAME",
            "state": "FINISHED"
        }
        }
        mock_get.return_value = mock_response_complete

        create_apigee_org.wait_for_complete(data)
         # Verify the response
        self.assertEqual(mock_response_complete.json()['metadata']['state'], 'FINISHED')
        self.assertEqual(mock_get.call_count, 1)
