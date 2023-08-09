/****************************************************************************************
* Class: Credential_TestFactory
* Created By: Ajinkya Hingne
----------------------------------------------------------------------------------------
* Description: Class to create test data for Credentials object.
----------------------------------------------------------------------------------------
* Version History:
* VERSION     DEVELOPER NAME       DATE            DETAIL FEATURES
https://vera.my.salesforce.com/a041O00000e6qhH
  1.0         Ajinkya Hingne       04/11/2019      Initial Development
***************************************************************************************/
public with sharing class Credential_TestFactory {

    public static List<Credential__c> createCredentialRecords(Integer count, String recordName) {
        List<Credential__c> credentials = new List<Credential__c>();
        for (Integer i = 1; i <= count; i++) {
            Credential__c credential = new Credential__c(
                Name = recordName,
                Grant_Type__c = 'client_credentials',
                Client_Id__c = '3bcfb7f0-80be-442b-b034-9954070b450b',
                Client_Secret__c = 'EY6odM%2BpAMDCJpup%2F1bxoX09GSu8YYZDUYqI5wfygXE%3D',
                Resource__c = '3bcfb7f0-80be-442b-b034-9954070b450b'
            );
            credentials.add(credential);
        }
        return credentials;
    }
}