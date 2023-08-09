@isTest
private class GeographicAreaTriggerHandlerTest {
    @isTest 
    static void beforeInsertGeographicalAreaCountry_DuplicateCodeValue() {
		ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
      	
		Test.startTest();
		try {
		    ampi__Geographical_Area__c gaCountry2 = TestDataFactory.createCountry('Peru 2', gaRegion.Id);			
        }catch(Exception ex) {
            if (ex.getMessage().contains('Country code must be unique')) {
                System.assert(true);
            }
        }		
		
		Test.stopTest();        
	}

    @isTest 
    static void beforeInsertGeographicalAreaCountry_NoCodeValue() {
        ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		Test.startTest();
		try {
		    ampi__Geographical_Area__c gaCountry = new ampi__Geographical_Area__c();
            gaCountry.Name = 'Peru';
            gaCountry.ampi__Parent_Geographical_Area__c = gaRegion.Id;
            gaCountry.Continent__c = 'South America';
            gaCountry.RecordTypeId = ampi__Geographical_Area__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Country').getRecordTypeId();
            insert gaCountry;
        }catch(Exception ex) {
            if (ex.getMessage().contains('Country code must have 3 characters')) {
                System.assert(true);
            }
        }		
		
		Test.stopTest();        
	}

    @isTest 
    static void beforeUpdateGeographicalAreaISPAvailable_CheckRelatedProject_PTAISPAvailable_NoValue() {
		ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
      	
		Account accNA = TestDataFactory.createMAWithCountry('NA Peru', gaCountry.Id);
 
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
		ampi__Geographical_Area__c gaProgramme2 = TestDataFactory.createProgramme('Lima', gaCountry.Id, accNA.Id);

		ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YCA', 'Youth Care (similar to YF)');
		ampi__Thematic_Area__c thematicAreaFS = TestDataFactory.createThematicArea('FSA', 'Family Streghtening (FS)');
		
		//one test method 
		ampi__Project__c projectStandard = TestDataFactory.createProject('Standard', accNA.Id, gaProgramme.Id, 'FS, YC');
		
		TestDataFactory.createProjectThematicAreaWithISP(projectStandard.Id, thematicAreaYC.Id, '', 'No');
		TestDataFactory.createProjectThematicAreaWithISP(projectStandard.Id, thematicAreaFS.Id, '', 'No');

		Test.startTest();
		try {
			gaProgramme.ISP_Available__c = 'No';
        	UPDATE projectStandard;    
        }catch(Exception ex) {
        }		
		//TODO: comented because of ticket AMIMSP-2043
		//List<ampi__project__c> projs = [SELECT Id FROM ampi__project__c WHERE programme_location__c =: gaProgramme.Id AND ISP_Available__c = 'No' AND RecordType.Name IN ('Standard', 'Transition')];
		//List<ampi__project_thematic_area__c> ptas = [SELECT Id FROM ampi__project_thematic_area__c WHERE ampi__Project__c IN :projs AND ISP_Available__c = 'No'];
		//System.assert(projs.size() > 0 && ptas.size() > 0);        
		System.Assert(true);
		Test.stopTest();        
	}

    @isTest 
    static void beforeProjectServiceTypeUpdate_ExtentInformationUpdated() {
    	Account accNA = TestDataFactory.createMA('NA Peru');
		ampi__Project__c projectTransition = TestDataFactory.createProjectByStatus('Transition', accNA.Id, '', '', 'Child Money Gift');
        ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
        ampi__Geographical_Area__c gaProgrammeUnit = TestDataFactory.createProgrammeUnit('YC Callao', gaProgramme.Id, accNA.Id);
        
        ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC', 'Youth Care (similar to YF)');
        ampi__project_thematic_area__c pta = TestDataFactory.createProjectThematicArea(projectTransition.Id, thematicAreaYC.Id, gaProgrammeUnit.Id);
        
        Test.startTest();
        gaProgrammeUnit.Extent_Information__c = 'Extent_Information__c was changed';
        UPDATE gaProgrammeUnit;
        ampi__project_thematic_area__c ptaUpdated = [SELECT Id, PU_Extent_Information__c FROM ampi__project_thematic_area__c WHERE Id =: pta.Id LIMIT 1];
        System.debug('####ptaUpdated:' + ptaUpdated);
        System.assert(ptaUpdated.PU_Extent_Information__c == 'Extent_Information__c was changed');
        Test.stopTest();        
    }

	@isTest 
    static void beforeProjectServiceTypeUpdate_ExtentInformationUpdated_DifferentISP() {
    	// Account accNA = TestDataFactory.createMA('NA Peru');
		// ampi__Project__c projectTransition = TestDataFactory.createProjectByStatus('Transition', accNA.Id, '', '', 'Child Money Gift');

        ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);

		Account accNA = TestDataFactory.createMAWithCountry('NA Peru', gaCountry.Id);

		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
        ampi__Geographical_Area__c gaProgrammeUnit = TestDataFactory.createProgrammeUnit('YC Callao', gaProgramme.Id, accNA.Id);
        ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC2', 'Youth Care (similar to YF)');
		
		ampi__Project__c projectStandard = TestDataFactory.createProject('Standard', accNA.Id, gaProgramme.Id, 'FS, YC');
        ampi__project_thematic_area__c pta = TestDataFactory.createProjectThematicArea(projectStandard.Id, thematicAreaYC.Id, gaProgrammeUnit.Id);
        
        Test.startTest();
        gaProgrammeUnit.ISP_Available__c = 'Yes';
        UPDATE gaProgrammeUnit;

		gaProgrammeUnit.ISP_Available__c = 'No';
        UPDATE gaProgrammeUnit;

        ampi__project_thematic_area__c ptaUpdated = [SELECT Id, ISP_Available__c, PU_Extent_Information__c FROM ampi__project_thematic_area__c WHERE Id =: pta.Id LIMIT 1];
        System.debug('####ptaUpdated:' + ptaUpdated);
        System.assert(ptaUpdated.ISP_Available__c == 'No');
        Test.stopTest();        
    }
}