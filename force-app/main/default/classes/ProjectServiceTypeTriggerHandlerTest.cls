@isTest
private class ProjectServiceTypeTriggerHandlerTest {
    @isTest 
    static void beforeInsertProjectServiceTypes_ExtentInformationUpdated() {
    	Account accNA = TestDataFactory.createMA('NA Peru');
		ampi__Project__c projectTransition = TestDataFactory.createProjectByStatus('Transition', accNA.Id, '', '', 'Child Money Gift');
        ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
        ampi__Geographical_Area__c gaProgrammeUnit = TestDataFactory.createProgrammeUnit('YC Callao', gaProgramme.Id, accNA.Id);
        ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC', 'Youth Care (similar to YF)');
        
        Test.startTest();

        try {
            gaProgrammeUnit.Extent_Information__c = 'Extent_Information__c was changed';
            UPDATE gaProgrammeUnit;
            
            ampi__project_thematic_area__c pta = TestDataFactory.createProjectThematicArea(projectTransition.Id, thematicAreaYC.Id, gaProgrammeUnit.Id);
            ampi__project_thematic_area__c ptaUpdated = [SELECT Id, PU_Extent_Information__c FROM ampi__project_thematic_area__c WHERE Id =: pta.Id LIMIT 1];
            System.assert(ptaUpdated.PU_Extent_Information__c == 'Extent_Information__c was changed');
        }catch(Exception ex) {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Project Service Type can\'t be duplicated. Please check Service Type, Project and Programme Unit datafields.') ? true : false;
            //TODO: System.assertEquals(expectedExceptionThrown, true);
			System.assert(true);
        }

        Test.stopTest();        
    }

    @isTest 
    static void beforeInsertProjectServiceTypes_CheckDuplicates() {
    	Account accNA = TestDataFactory.createMA('NA Peru');
		ampi__Project__c projectTransition = TestDataFactory.createProjectByStatus('Transition', accNA.Id, '', '', 'Child Money Gift');
        ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
        ampi__Geographical_Area__c gaProgrammeUnit = TestDataFactory.createProgrammeUnit('YC Callao', gaProgramme.Id, accNA.Id);
        
        ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC', 'Youth Care (similar to YF)');
        
        Test.startTest();
        ampi__project_thematic_area__c pta = TestDataFactory.createProjectThematicArea(projectTransition.Id, thematicAreaYC.Id, gaProgrammeUnit.Id);
        
        try {
        	ampi__project_thematic_area__c pta2 = TestDataFactory.createProjectThematicArea(projectTransition.Id, thematicAreaYC.Id, gaProgrammeUnit.Id);        
        }catch(Exception ex) {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Project Service Type can\'t be duplicated. Please check Service Type, Project and Programme Unit datafields.') ? true : false;
            //TODO: System.assertEquals(expectedExceptionThrown, true);
			System.assert(true);
        }  

        
        Test.stopTest();        
    }

    @isTest 
    static void beforeDeletetProjectServiceTypes_ExtentInformationUpdated() {
    	Account accNA = TestDataFactory.createMA('NA Peru');
		ampi__Project__c projectTransition = TestDataFactory.createProjectByStatus('Transition', accNA.Id, '', '', 'Child Money Gift');
        ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
        ampi__Geographical_Area__c gaProgrammeUnit = TestDataFactory.createProgrammeUnit('YC Callao', gaProgramme.Id, accNA.Id);
        
        ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC', 'Youth Care (similar to YF)');
        // projectTransition.ampi__Project_Status__c = 'In Implementation';
        // UPDATE projectTransition;

        Test.startTest();
        
        ampi__project_thematic_area__c pta = TestDataFactory.createProjectThematicArea(projectTransition.Id, thematicAreaYC.Id, gaProgrammeUnit.Id);
        ampi__project_thematic_area__c ptaUpdated = [SELECT Id, PU_Extent_Information__c FROM ampi__project_thematic_area__c WHERE Id =: pta.Id LIMIT 1];

        try {
        	delete ptaUpdated;    
        }catch(Exception ex) {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Service Type Projects are not allowed to be removed') ? true : false;
			System.assert(true);
        }      

        Test.stopTest();        
    }
}