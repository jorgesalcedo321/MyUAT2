/****************************************************************************************
* Class: Project_TestFactory
* Created By: Ajinkya Hingne
----------------------------------------------------------------------------------------
* Description: Class to create test data for Project object
----------------------------------------------------------------------------------------
* Version History:
* VERSION     DEVELOPER NAME       DATE            DETAIL FEATURES
https://vera.my.salesforce.com/
  1.0         Ajinkya Hingne       04/11/2019      Initial Development
***************************************************************************************/
@isTest
public with sharing class Project_TestFactory {

    public static List<ampi__Project__c> createProjectRecords(Integer count) {
        List<ampi__Project__c> projects = new List<ampi__Project__c>();
        for (Integer i = 1; i <= count; i++) {
            projects.add(
                new ampi__Project__c(
                    Name = 'Test Project ' + i,
                    ampi__Description__c = 'Test Description' + i
                )
            );
        }
        return projects;
    }
}