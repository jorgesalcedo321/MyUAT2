@isTest 
private class customRelatedListsTest {
	@isTest
	private static void getProjectGeographicAreaByProjectId_ForGrantProject_InactivatingOneGA() {
		Account accNA = TestDataFactory.createMA('NA Peru');
		ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao 3', gaCountry.Id, accNA.Id);
		ampi__Geographical_Area__c gaProgramme2 = TestDataFactory.createProgramme('Lima 3', gaCountry.Id, accNA.Id);
		ampi__Geographical_Area__c gaProgramme3 = TestDataFactory.createProgramme('Areq 3', gaCountry.Id, accNA.Id);

		ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC', 'Youth Care (similar to YF)');
		ampi__Thematic_Area__c thematicAreaFS = TestDataFactory.createThematicArea('FS', 'Family Streghtening (FS)');
		
		ampi__Project__c projectGrant = TestDataFactory.createProject('Grant', accNA.Id, gaProgramme.Id, 'FS, YC');
		ampi__Project_Geographic_Area__c pga = TestDataFactory.createPGA(projectGrant.Id, gaProgramme2.Id);
		ampi__Project_Geographic_Area__c pga2 = TestDataFactory.createPGA(projectGrant.Id, gaProgramme3.Id);
		//ampi__Project_Geographic_Area__c pga2 = TestDataFactory.createPGA(projectGrant.Id, gaProgramme2.Id);

		TestDataFactory.updateProgrammeStatus(gaProgramme, false);

		Test.startTest();
		System.debug('###projectGrant values: ' + projectGrant);
		System.debug('###projectGrant.Id: ' + projectGrant.id);

		List<customRelatedLists.RelatedPGAListWrapper> pgas = customRelatedLists.getProjectGeographicAreaByProjectId(projectGrant.id, 100, 0);
		System.assertEquals(2, pgas.size());
		Test.stopTest();
	}

	
	@isTest
	private static void getProjectGeographicAreaByProjectId_ForGrantProject() {
		Account accNA = TestDataFactory.createMA('NA Peru');
		ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao 2', gaCountry.Id, accNA.Id);
		ampi__Geographical_Area__c gaProgramme2 = TestDataFactory.createProgramme('Lima 2', gaCountry.Id, accNA.Id);
		ampi__Geographical_Area__c gaProgramme3 = TestDataFactory.createProgramme('Areq 2', gaCountry.Id, accNA.Id);

		ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC', 'Youth Care (similar to YF)');
		ampi__Thematic_Area__c thematicAreaFS = TestDataFactory.createThematicArea('FS', 'Family Streghtening (FS)');
		
		ampi__Project__c projectGrant = TestDataFactory.createProject('Grant', accNA.Id, gaProgramme.Id, 'FS, YC');
		ampi__Project_Geographic_Area__c pga = TestDataFactory.createPGA(projectGrant.Id, gaProgramme2.Id);
		ampi__Project_Geographic_Area__c pga2 = TestDataFactory.createPGA(projectGrant.Id, gaProgramme3.Id);

		Test.startTest();
		System.debug('###projectGrant values: ' + projectGrant);
		System.debug('###projectGrant.Id: ' + projectGrant.id);

		List<customRelatedLists.RelatedPGAListWrapper> pgas = customRelatedLists.getProjectGeographicAreaByProjectId(projectGrant.id, 100, 0);
		System.assertEquals(3, pgas.size());
		Test.stopTest();
	}


	@isTest
	private static void getProjectsByOrganisationId_OrganisationId() {
		Account accNA = TestDataFactory.createMA('NA Peru');
		ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao 3', gaCountry.Id, accNA.Id);
		ampi__Geographical_Area__c gaProgramme2 = TestDataFactory.createProgramme('Lima 3', gaCountry.Id, accNA.Id);
		ampi__Geographical_Area__c gaProgramme3 = TestDataFactory.createProgramme('Areq 3', gaCountry.Id, accNA.Id);

		ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC', 'Youth Care (similar to YF)');
		ampi__Thematic_Area__c thematicAreaFS = TestDataFactory.createThematicArea('FS', 'Family Streghtening (FS)');
		
		ampi__Project__c projectGrant = TestDataFactory.createProject('Grant', accNA.Id, gaProgramme.Id, 'FS, YC');
		ampi__Project__c projectGrant2 = TestDataFactory.createProject('Grant', accNA.Id, gaProgramme.Id, 'FS, YC');
		ampi__Project__c projectGrant3 = TestDataFactory.createProject('Grant', accNA.Id, gaProgramme.Id, 'FS, YC');

		ampi__Project_Geographic_Area__c pga = TestDataFactory.createPGA(projectGrant.Id, gaProgramme2.Id);
		ampi__Project_Geographic_Area__c pga2 = TestDataFactory.createPGA(projectGrant2.Id, gaProgramme3.Id);

		Test.startTest();
		System.debug('###projectGrant values: ' + projectGrant);
		System.debug('###projectGrant.Id: ' + projectGrant.id);

		List<customRelatedLists.RelatedProjectListWrapper> projects = customRelatedLists.getProjectsByOrganisationId(accNA.Id, 100, 0);
		System.assertEquals(3, projects.size());
		Test.stopTest();
	}

	
	@isTest
	private static void getGeographicAreaByAccountId() {
		Account accNA = TestDataFactory.createMA('NA Peru');
		ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
		ampi__Geographical_Area__c gaProgramme2 = TestDataFactory.createProgramme('Lima', gaCountry.Id, accNA.Id);

		Test.startTest();
		List<customRelatedLists.RelatedGAListWrapper> geographicAreas = customRelatedLists.getGeographicAreaByAccountId(accNA.Id, true, true, true, 100, 0);
		System.assertEquals(2, geographicAreas.size());

		geographicAreas = customRelatedLists.getGeographicAreaByAccountId(accNA.Id, false, true, true, 100, 0);
		System.assertEquals(0, geographicAreas.size());
		Test.stopTest();
	}
	
	@isTest
	private static void getDescriptionRiskDatafieldName_CountTwoAccounts() {
		User u = TestDataFactory.CreateUserFromSystemAdminSpanish();
		System.runAs(u) {
			String spa= customRelatedLists.getDescriptionRiskDatafieldName();
			System.assert(spa == 'Risk_Description_Language_1__c');
		}
		u = TestDataFactory.CreateUserFromSystemAdminFrench();
		System.runAs(u) {
			String fra= customRelatedLists.getDescriptionRiskDatafieldName();
			System.assert(fra == 'Risk_Description_Language_2__c');
		}
		u = TestDataFactory.CreateUserFromSystemAdminRussian();
		System.runAs(u) {
			String rus= customRelatedLists.getDescriptionRiskDatafieldName();
			System.assert(rus == 'Risk_Description_Language_3__c');
		}
		u = TestDataFactory.CreateUserFromSystemAdmin();
		System.runAs(u) {
			String eng= customRelatedLists.getDescriptionRiskDatafieldName();
			System.assert(eng == 'ampi__Description__c');
		}
	}

	@isTest
	private static void getRisksByProgrammeId_CountTwoAccounts_NotIncludingSafety() {
		Account accNA = TestDataFactory.createMA('NA Peru');
		ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
		TestDataFactory.createRisk('Name 1', gaProgramme.Id, accNA.Id, true, '');
		TestDataFactory.createRisk('Name 2', gaProgramme.Id, accNA.Id, true, '');
		TestDataFactory.createRisk('Name 3', gaProgramme.Id, accNA.Id, true, '');
		TestDataFactory.createRisk('Name 4', gaProgramme.Id, accNA.Id, true, '');
		TestDataFactory.createRisk('Name 5', gaProgramme.Id, accNA.Id, false, '');
		TestDataFactory.createRisk('Name 6', gaProgramme.Id, accNA.Id, false, '');
		List<SObject> spa= customRelatedLists.getRisksByProgrammeId(gaProgramme.Id, '', false, 0, 0);
		System.assert(spa.size() == 2);
	}

	@isTest
	private static void getRisksByProgrammeId_CountTwoAccounts_IncludingSafety() {
		Account accNA = TestDataFactory.createMA('NA Peru');
		ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
		TestDataFactory.createRisk('Name 1', gaProgramme.Id, accNA.Id, true, '');
		TestDataFactory.createRisk('Name 2', gaProgramme.Id, accNA.Id, true, '');
		TestDataFactory.createRisk('Name 3', gaProgramme.Id, accNA.Id, true, '');
		TestDataFactory.createRisk('Name 4', gaProgramme.Id, accNA.Id, true, '');
		TestDataFactory.createRisk('Name 5', gaProgramme.Id, accNA.Id, false, '');
		TestDataFactory.createRisk('Name 6', gaProgramme.Id, accNA.Id, false, '');
		List<SObject> spa= customRelatedLists.getRisksByProgrammeId(gaProgramme.Id, '', true, 0, 0);
		System.assert(spa.size() == 4);
	}

	@isTest
	private static void getNumberRisksByProgrammeId_CountTwoAccounts_IncludingSafety() {
		Account accNA = TestDataFactory.createMA('NA Peru');
		ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
		TestDataFactory.createRisk('Name 1', gaProgramme.Id, accNA.Id, true, '');
		TestDataFactory.createRisk('Name 2', gaProgramme.Id, accNA.Id, true, '');
		TestDataFactory.createRisk('Name 3', gaProgramme.Id, accNA.Id, true, '');
		TestDataFactory.createRisk('Name 4', gaProgramme.Id, accNA.Id, true, '');
		TestDataFactory.createRisk('Name 5', gaProgramme.Id, accNA.Id, false, '');
		TestDataFactory.createRisk('Name 6', gaProgramme.Id, accNA.Id, false, '');
		Integer spa= customRelatedLists.getNumberRisksByProgrammeId(gaProgramme.Id, '', true);
		System.assert(spa == 4);
	}

	@isTest
	private static void getNumberRisksByProgrammeId_CountTwoAccounts_NotIncludingSafety() {
		Account accNA = TestDataFactory.createMA('NA Peru');
		ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
		TestDataFactory.createRisk('Name 1', gaProgramme.Id, accNA.Id, true, '');
		TestDataFactory.createRisk('Name 2', gaProgramme.Id, accNA.Id, true, '');
		TestDataFactory.createRisk('Name 3', gaProgramme.Id, accNA.Id, true, '');
		TestDataFactory.createRisk('Name 4', gaProgramme.Id, accNA.Id, true, '');
		TestDataFactory.createRisk('Name 5', gaProgramme.Id, accNA.Id, false, '');
		TestDataFactory.createRisk('Name 6', gaProgramme.Id, accNA.Id, false, '');
		Integer spa= customRelatedLists.getNumberRisksByProgrammeId(gaProgramme.Id, '', false);
		System.assert(spa == 2);
	}

	@isTest
	private static void getMAName_ReturnNA_Peru() {
		Account accNA = TestDataFactory.createMA('NA Peru');
		String spa= customRelatedLists.getMAName(accNA.Id);
		System.assert(spa == 'NA Peru');
	}
	
	
	@isTest
	private static void getRecordTypeIdByName_ReturnNotEmpty() {
		Account accNA = TestDataFactory.createMA('NA Peru');
		String spa= customRelatedLists.getRecordTypeIdByName('Programme Location Risk');
		System.assert(String.isNotBlank(spa));
	}

	@isTest
	private static void isInternal_ReturnTrue() {
		Boolean result = customRelatedLists.isInternal();
		System.assert(result == true);
	}
	

	@isTest
	private static void getRisksByRiskRegisterId_CountSixRisks() {
		Account accNA = TestDataFactory.createMA('NA Peru');
		ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);

		TestDataFactory.createRiskRegister('Name 1', gaProgramme.Id);
		ampi__Risk_Register__c riskRegister = [SELECT Id FROM ampi__Risk_Register__c WHERE Name = 'Name 1' LIMIT 1];
		String riskRegisterId = riskRegister.Id;
		TestDataFactory.createRisk('Name 1', gaProgramme.Id, accNA.Id, true, riskRegisterId);
		TestDataFactory.createRisk('Name 2', gaProgramme.Id, accNA.Id, true, riskRegisterId);
		TestDataFactory.createRisk('Name 3', gaProgramme.Id, accNA.Id, true, riskRegisterId);
		TestDataFactory.createRisk('Name 4', gaProgramme.Id, accNA.Id, true, riskRegisterId);
		TestDataFactory.createRisk('Name 5', gaProgramme.Id, accNA.Id, false, riskRegisterId);
		TestDataFactory.createRisk('Name 6', gaProgramme.Id, accNA.Id, false, riskRegisterId);
		List<SObject> spa= customRelatedLists.getRisksByRiskRegisterId(riskRegisterId, '', 0, 0);
		System.assert(spa.size() == 6);
	}

	@isTest
	private static void getNumberOfRisksByRiskRegisterId_CountSixRisks() {
		Account accNA = TestDataFactory.createMA('NA Peru');
		ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);

		TestDataFactory.createRiskRegister('Name 1', gaProgramme.Id);
		ampi__Risk_Register__c riskRegister = [SELECT Id FROM ampi__Risk_Register__c WHERE Name = 'Name 1' LIMIT 1];
		String riskRegisterId = riskRegister.Id;
		TestDataFactory.createRisk('Name 1', gaProgramme.Id, accNA.Id, true, riskRegisterId);
		TestDataFactory.createRisk('Name 2', gaProgramme.Id, accNA.Id, true, riskRegisterId);
		TestDataFactory.createRisk('Name 3', gaProgramme.Id, accNA.Id, true, riskRegisterId);
		TestDataFactory.createRisk('Name 4', gaProgramme.Id, accNA.Id, true, riskRegisterId);
		TestDataFactory.createRisk('Name 5', gaProgramme.Id, accNA.Id, false, riskRegisterId);
		TestDataFactory.createRisk('Name 6', gaProgramme.Id, accNA.Id, false, riskRegisterId);
		Integer spa= customRelatedLists.getNumberOfRisksByRiskRegisterId(riskRegisterId, '');
		System.assert(spa == 6);
	}
	
	@isTest
	private static void getResultsQueryDynamic_CountTwoAccounts() {
		TestDataFactory.createOrganisation('');
		TestDataFactory.createOrganisation('');
		List<SObject> count = customRelatedLists.getResultsQueryDynamic('Account', 'Id, Name', '', 3, 0);
		System.assert(count.size() == 2);
	}


	@isTest
	private static void getNumberResultsQueryDynamic_CountTwoAccounts() {
		TestDataFactory.createOrganisation('');
		TestDataFactory.createOrganisation('');
		integer count = customRelatedLists.getNumberResultsQueryDynamic('Account', '');
		System.assert(count == 2);
	}
	
}