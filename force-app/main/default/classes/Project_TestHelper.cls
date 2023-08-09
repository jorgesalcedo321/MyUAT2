/****************************************************************************************
* Class: Project_TestHelper
* Created By: Ajinkya Hingne
----------------------------------------------------------------------------------------
* Description: Helper class.
----------------------------------------------------------------------------------------
* Version History:
* VERSION     DEVELOPER NAME       DATE            DETAIL FEATURES
https://vera.my.salesforce.com/
  1.0         Ajinkya Hingne       24/10/2019      Initial Development
***************************************************************************************/
@isTest
public with sharing class Project_TestHelper {

    public static List<ampi__Project__c> insertProjectRecords(List<ampi__Project__c> projects) {
        insert projects;
        return projects;
    }

    public static List<ampi__Project__c> getProjectRecords() {
        return [
            SELECT
                Id,
                SharePoint_Team_Site_URL__c
            FROM
                ampi__Project__c
        ];
    }
}