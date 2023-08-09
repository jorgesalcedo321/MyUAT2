/****************************************************************************************
* Class: CreateWorkspace_Ctrl_Test
* Created By: Ajinkya Hingne
----------------------------------------------------------------------------------------
* Description: Test class for CreateWorkspace_Ctrl class.
----------------------------------------------------------------------------------------
* Version History:
* VERSION     DEVELOPER NAME       DATE            DETAIL FEATURES
https://vera.my.salesforce.com/
  1.0         Ajinkya Hingne       04/11/2019      Initial Development
***************************************************************************************/
@isTest
public with sharing class CreateWorkspace_Ctrl_Test {
    @isTest static void createWorkspaceForProjectTest() {
        CreateWorkspace_Ctrl.Response response = new CreateWorkspace_Ctrl.Response();
        List<ampi__Project__c> projectRecords = Project_TestHelper.insertProjectRecords(
            Project_TestFactory.createProjectRecords(1)
        );
        Credential_TestHelper.insertCredentialRecords(
            Credential_TestFactory.createCredentialRecords(1, 'Sharepoint')
        );

        System.Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        response = CreateWorkspace_Ctrl.createWorkspaceForProject(projectRecords[0].Id);
        System.Test.stopTest();

        System.assertEquals(
            System.Label.CREATE_WORKSPACE_REQUEST_SUCCESS_MESSAGE,
            response.message,
            'Success message mismatched'
        );
    }

    @isTest static void testWithNoCredentials() {
        CreateWorkspace_Ctrl.Response response = new CreateWorkspace_Ctrl.Response();
        List<ampi__Project__c> projectRecords = Project_TestHelper.insertProjectRecords(
            Project_TestFactory.createProjectRecords(1)
        );
        Credential_TestHelper.insertCredentialRecords(
            Credential_TestFactory.createCredentialRecords(1, 'Dummy Sharepoint')
        );

        System.Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        response = CreateWorkspace_Ctrl.createWorkspaceForProject(projectRecords[0].Id);
        System.Test.stopTest();

        System.assertEquals(
            System.Label.CREATE_WORKSPACE_REQUEST_ERROR_MESSAGE,
            response.message,
            'Error message mismatched'
        );
    }
}