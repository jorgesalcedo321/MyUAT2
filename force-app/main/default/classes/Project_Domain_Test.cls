/****************************************************************************************
* Class: Project_Domain_Test
* Created By: Ajinkya Hingne
----------------------------------------------------------------------------------------
* Description: Test class for Project_Domain class.
----------------------------------------------------------------------------------------
* Version History:
* VERSION     DEVELOPER NAME       DATE            DETAIL FEATURES
https://vera.my.salesforce.com/
  1.0         Ajinkya Hingne       04/11/2019      Initial Development
***************************************************************************************/
@isTest
public with sharing class Project_Domain_Test {

    @isTest static void testUpdateProjects() {
        CreateWorkspace_Ctrl.Response response = new CreateWorkspace_Ctrl.Response();
        List<ampi__Project__c> projects = Project_TestHelper.insertProjectRecords(
            Project_TestFactory.createProjectRecords(1)
        );
        for (Integer i = 0; i < projects.size(); i++) {
            projects[i].Name = 'Test Updated Project ' + i;
        }

        System.Test.startTest();
        List<ampi__Project__c> updatedProjects = Project_Domain.updateProjects(projects);
        System.Test.stopTest();

        System.assertEquals(
            'Test Updated Project 0',
            updatedProjects[0].Name,
            'Success message mismatched'
        );
    }

    @isTest static void testGetProjectDetails() {
        CreateWorkspace_Ctrl.Response response = new CreateWorkspace_Ctrl.Response();
        List<ampi__Project__c> projects = Project_TestHelper.insertProjectRecords(
            Project_TestFactory.createProjectRecords(1)
        );

        System.Test.startTest();
        ampi__Project__c project = Project_Domain.getProjectDetails(projects[0].Id);
        System.Test.stopTest();

        System.assertNotEquals(null, project, 'Project record should be returned');
    }

}