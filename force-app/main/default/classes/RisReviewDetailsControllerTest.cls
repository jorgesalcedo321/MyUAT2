@isTest 
private class RisReviewDetailsControllerTest {

	@isTest
	private static void RisReviewDetailsControllerTest_GetRiskAssessmentById_GetRecordNotNull() {
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
			
			ampi__Risk_Assessment__c result = RisReviewDetailsController.getRiskReviewById(ids.get(0));
			System.assertEquals(true, result.Id <> null); 
		}
		Test.stopTest();		
	}

	@isTest
	private static void RisReviewDetailsControllerTest_SetTranslatedValuesOnProperties_GetCorrectSpanishTranslation() {
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
			
			ampi__Risk_Assessment__c result = RisReviewDetailsController.getRiskReviewById(ids.get(0));
			ApexPages.StandardController sc = new  ApexPages.StandardController(result);            
			RisReviewDetailsController standardCtrl = new RisReviewDetailsController(sc);
			standardCtrl.setTranslatedValuesOnProperties('Spanish');
			System.debug('#####:' + standardCtrl.conflict_Response_Translated);
			System.assertEquals(true, String.isNotBlank(standardCtrl.conflict_Response_Translated)); 
		}
		Test.stopTest();
	}

	@isTest
	private static void RisReviewDetailsControllerTest_SetTranslatedValuesOnProperties_GetCorrectFrench() {
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
			
			ampi__Risk_Assessment__c result = RisReviewDetailsController.getRiskReviewById(ids.get(0));
			ApexPages.StandardController sc = new  ApexPages.StandardController(result);            
			RisReviewDetailsController standardCtrl = new RisReviewDetailsController(sc);
			standardCtrl.setTranslatedValuesOnProperties('French');
			System.debug('#####:' + standardCtrl.conflict_Response_Translated);
			System.assertEquals(true, String.isNotBlank(standardCtrl.conflict_Response_Translated)); 
		}
		Test.stopTest();
	}

	@isTest
	private static void RisReviewDetailsControllerTest_SetTranslatedValuesOnProperties_GetCorrectRussian() {
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
			
			ampi__Risk_Assessment__c result = RisReviewDetailsController.getRiskReviewById(ids.get(0));
			ApexPages.StandardController sc = new  ApexPages.StandardController(result);            
			RisReviewDetailsController standardCtrl = new RisReviewDetailsController(sc);
			standardCtrl.setTranslatedValuesOnProperties('Russian');
			System.debug('#####:' + standardCtrl.conflict_Response_Translated);
			System.assertEquals(true, String.isNotBlank(standardCtrl.conflict_Response_Translated)); 
		}
		Test.stopTest();
	}
	
	@isTest
	private static void RisReviewDetailsControllerTest_GetCurrentShortUserLanguage_GetEn_UsValue() {
		User u = TestDataFactory.CreateUserFromSystemAdminSpanish();
		System.runAs(u) {
			string result = RisReviewDetailsController.getCurrentShortUserLanguage();
			System.assertEquals('Español', result); 
		}
	}

	
	@isTest
	private static void RisReviewDetailsControllerTest_GetFullLanguageName_GetSpanishFromEspanol() {
		User u = TestDataFactory.CreateUserFromSystemAdminSpanish();
		System.runAs(u) {
			string result = RisReviewDetailsController.getFullLanguageName('Español');
			System.assertEquals('Spanish', result); 
		}
	}

	
	
	@isTest
	private static void RisReviewDetailsControllerTest_GetFullLanguageName_GetRussianFromEspanol() {
		User u = TestDataFactory.CreateUserFromSystemAdminSpanish();
		System.runAs(u) {
			string result = RisReviewDetailsController.getFullLanguageName('Русский');
			System.assertEquals('Russian', result); 
		}
	}

	
	
	@isTest
	private static void RisReviewDetailsControllerTest_GetFullLanguageName_GetFrenchFromEspanol() {
		User u = TestDataFactory.CreateUserFromSystemAdminSpanish();
		System.runAs(u) {
			string result = RisReviewDetailsController.getFullLanguageName('Français');
			System.assertEquals('French', result); 
		}
	}
}