/****************************************************************************************
* Class: ProjectManager
* Created By: Ajinkya Hingne
----------------------------------------------------------------------------------------
* Description: REST API class for ampi__Project__c related operations
----------------------------------------------------------------------------------------
* Version History:
* VERSION     DEVELOPER NAME       DATE            DETAIL FEATURES
https://vera.my.salesforce.com/a041O00000e6qhH
  1.0         Ajinkya Hingne       24/10/2019      Initial Development
***************************************************************************************/
@isTest
public with sharing class ProjectManager_Test {

    /**
     * Method to test success condition
     */
    @isTest static void testSyncProject() {
        List<ampi__Project__c> projectRecords = Project_TestHelper.insertProjectRecords(
            Project_TestFactory.createProjectRecords(1)
        );
        RestContext.response = new RestResponse();

        System.Test.startTest();
        ProjectManager.syncProject('/' + projectRecords[0].Id, 'www.workspace.com');
        System.Test.stopTest();

        List<ampi__Project__c> processedProject = Project_TestHelper.getProjectRecords();

        System.assertEquals(
            'www.workspace.com',
            processedProject[0].SharePoint_Team_Site_URL__c,
            'Project should be updated successfully'
        );
    }

    /**
     * Method to test codition with null parameter passed in callout
     */
    @isTest static void testSyncProjectWithNullParam() {
        List<ampi__Project__c> projectRecords = Project_TestHelper.insertProjectRecords(
            Project_TestFactory.createProjectRecords(1)
        );
        RestContext.response = new RestResponse();

        System.Test.startTest();
        ProjectManager.syncProject(null, null);
        System.Test.stopTest();

        List<ampi__Project__c> processedProject = Project_TestHelper.getProjectRecords();

        System.assertEquals(
            null,
            processedProject[0].SharePoint_Team_Site_URL__c,
            'Project should be not updated.'
        );
    }

    /**
     * Method to test codition with null parameter passed in callout
     */
    @isTest static void testSyncProjectWithWrongProjectId() {
        List<ampi__Project__c> projectRecords = Project_TestHelper.insertProjectRecords(
            Project_TestFactory.createProjectRecords(1)
        );
        RestContext.response = new RestResponse();

        System.Test.startTest();
        ProjectManager.syncProject('/' + projectRecords[0].Id + 'test', 'www.workspace.com');
        System.Test.stopTest();

        List<ampi__Project__c> processedProject = Project_TestHelper.getProjectRecords();

        System.assertEquals(
            null,
            processedProject[0].SharePoint_Team_Site_URL__c,
            'Project should be not updated.'
        );
    }

}