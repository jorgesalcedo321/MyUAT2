/****************************************************************************************
* Class: Project_Domain
* Created By: Ajinkya Hingne
----------------------------------------------------------------------------------------
* Description: Domain class for ampi__Project__c object
----------------------------------------------------------------------------------------
* Version History:
* VERSION     DEVELOPER NAME       DATE            DETAIL FEATURES
https://vera.my.salesforce.com/a041O00000e6qhH
  1.0         Ajinkya Hingne       24/10/2019      Initial Development
***************************************************************************************/
public with sharing class Project_Domain {

    public static List<ampi__Project__c> updateProjects(List<ampi__Project__c> projects) {
        update projects;
        return projects;
    }

    public static ampi__Project__c getProjectDetails(Id recordId) {
        return [
            SELECT
                Id,
                Project_ID_raw__c,
                Name,
                ampi__Description__c,
                Owner.Email,
            	Owner.Username,
                Create_Workspace_Callout_Time__c,
                ampi__Project_Status__c,
                SOS_Region__c,
                SOS_Implementing_Organisation__r.Name,
                (
                    SELECT
                        User__r.Username
                    FROM
                        Team_Members__r
                )
            FROM
                ampi__Project__c
            WHERE
                Id = :recordId
        ];
    }
}