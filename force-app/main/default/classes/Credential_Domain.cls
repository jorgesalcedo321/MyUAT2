/****************************************************************************************
* Class: Credential_Domain
* Created By: Ajinkya Hingne
----------------------------------------------------------------------------------------
* Description: Class to perform server side actions of CreateWorkspace component
----------------------------------------------------------------------------------------
* Version History:
* VERSION     DEVELOPER NAME       DATE            DETAIL FEATURES
https://vera.my.salesforce.com/a041O00000e6qhH
  1.0         Ajinkya Hingne       04/11/2019      Initial Development
***************************************************************************************/
public with sharing class Credential_Domain {

    public static List<Credential__c> getCredential(String credentialName) {
        return [
            SELECT
                Grant_Type__c,
                Client_Id__c,
                Client_Secret__c,
                Resource__c
            FROM
                Credential__c
            WHERE
                Name =: credentialName
        ];
    }

}