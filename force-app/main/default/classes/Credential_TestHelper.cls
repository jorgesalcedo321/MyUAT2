/****************************************************************************************
* Class: Credential_TestHelper
* Created By: Ajinkya Hingne
----------------------------------------------------------------------------------------
* Description:
----------------------------------------------------------------------------------------
* Version History:
* VERSION     DEVELOPER NAME       DATE            DETAIL FEATURES
https://vera.my.salesforce.com/a041O00000e6qhH
  1.0         Ajinkya Hingne       04/11/2019      Initial Development
***************************************************************************************/
public with sharing class Credential_TestHelper {

    public static List<Credential__c> insertCredentialRecords(List<Credential__c> credentials) {
        insert credentials;
        return credentials;
    }
}