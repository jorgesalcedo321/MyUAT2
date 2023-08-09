@isTest 
private class changeNARecordTypeRiskForAllFields_Test {

	@isTest
	private static void changeNARecordTypeRiskForAllFields_RecordTypeUpdatedToEdit() {
		User u = TestDataFactory.CreateUserFromSystemAdmin();
		
		Id recordTypeIDForNewNARisk = Schema.getGlobalDescribe().get('ampi__Risk_Assessment__c').getDescribe().getRecordTypeInfosByName().get('New National Security Context').getRecordTypeId();
		Id recordTypeIDForEditNARisk = Schema.getGlobalDescribe().get('ampi__Risk_Assessment__c').getDescribe().getRecordTypeInfosByName().get('National Security Context').getRecordTypeId();
		
		Contact newContact = TestDataFactory.createContact(u.Email);
		System.debug('###newContact:' + newContact);
		
		Account newAccount = TestDataFactory.createOrganisation(newContact.Id);
		System.debug('###newAccount:' + newAccount);		

		ampi__Risk_Assessment__c newRiskAssessment = new ampi__Risk_Assessment__c();
		newRiskAssessment.RecordTypeId = recordTypeIDForNewNARisk;
		newRiskAssessment.National_Association__c = newAccount.Id;
		newRiskAssessment.Name = 'Test name Risk Assessment ' + TestDataFactory.getCurrentDateString();
		newRiskAssessment.Description__c  = 'Test desc Risk Assessment ' + TestDataFactory.getCurrentDateString();
		
		System.debug('##### UserInfo.getUserEmail():' + UserInfo.getUserEmail());
		
		Test.startTest();
		
		System.runAs(u) {
			insert newRiskAssessment;
			System.debug('##### newRiskAssessment:' + newRiskAssessment);
		 
			List<ampi__Risk_Assessment__c> newRiskAssessments = [SELECT RecordTypeId FROM ampi__Risk_Assessment__c WHERE Name =: newRiskAssessment.Name];
			System.debug('##### newRiskAssessment count:' + newRiskAssessments.size());

			System.assertEquals(true, newRiskAssessments.size() > 0 && newRiskAssessments.get(0).RecordTypeId == recordTypeIDForEditNARisk);		
		}

		Test.stopTest();
	}
}