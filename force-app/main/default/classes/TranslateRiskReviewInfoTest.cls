@isTest 
private class TranslateRiskReviewInfoTest {
	@isTest
	private static void updateCurrentRiskReview_UpdateToSpanishUserMatrix() {
		User u = TestDataFactory.CreateUserFromSystemAdmin();

		Contact newContact = TestDataFactory.createContact(u.Email);
		System.debug('###newContact:' + newContact);
		System.debug('###newUser:' + u);
		
		Account newAccount = TestDataFactory.createOrganisation(newContact.Id);
		System.debug('###newAccount:' + newAccount);		

		Test.startTest();
		System.runAs(u) {
			List<ampi__Risk_Assessment__c> newRiskAssList = TestDataFactory.newRiskAssessment(newAccount, 'es');
			Set<Id> resultIds = (new Map<Id, ampi__Risk_Assessment__c>(newRiskAssList)).keySet();
			List<Id> ids = new List<Id>();
			ids.addAll(resultIds);
			TranslateRiskReviewInfo.updateCurrentRiskReview(ids);
			newRiskAssList = [SELECT Terrorism_Response_Language_1__c FROM ampi__Risk_Assessment__c WHERE Id IN : ids];
			System.debug('######newRiskAssList:' + newRiskAssList.get(0).Terrorism_Response_Language_1__c);
			System.assertEquals(newRiskAssList.get(0).Terrorism_Response_Language_1__c <> 'Terrorism_Response_Language_1__c', true); 
		}
		Test.stopTest();
	}

	@isTest
	private static void updateCurrentRiskReview_GetFullLanguageName() {
		string spa = TranslateRiskReviewInfo.GetFullLanguageName('es');
		string rus = TranslateRiskReviewInfo.GetFullLanguageName('ru');
		string fra = TranslateRiskReviewInfo.GetFullLanguageName('fr');
		string eng = TranslateRiskReviewInfo.GetFullLanguageName('en');
		Test.startTest();
		System.assertEquals(spa, 'Spanish'); 
		System.assertEquals(rus, 'Russian'); 
		System.assertEquals(fra, 'French'); 
		System.assertEquals(eng, 'English'); 
		Test.stopTest();
	}

}