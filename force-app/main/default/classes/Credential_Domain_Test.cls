/****************************************************************************************
* Class: Credential_Domain_Test
* Created By: Ajinkya Hingne
----------------------------------------------------------------------------------------
* Description: Class to perform server side actions of CreateWorkspace component
----------------------------------------------------------------------------------------
* Version History:
* VERSION     DEVELOPER NAME       DATE            DETAIL FEATURES
https://vera.my.salesforce.com/a041O00000e6qhH
  1.0         Ajinkya Hingne       04/11/2019      Initial Development
***************************************************************************************/
@isTest
public with sharing class Credential_Domain_Test {

    @isTest static void testGetCredential() {
        Credential_TestHelper.insertCredentialRecords(
            Credential_TestFactory.createCredentialRecords(1, 'Sharepoint')
        );

        System.Test.startTest();
        List<Credential__c> existingCredentials = Credential_Domain.getCredential('Sharepoint');
        System.Test.stopTest();

        System.assertEquals(
            false,
            existingCredentials.isEmpty(),
            'One Credential record should be present'
        );
    }

}