@isTest
private class ResultTriggerHandlerTest {
    @isTest
    private static void beforeInsertUpdateResultsInCommunityProfiles_CheckIfPossibleToSaveWithCommunityUser_ControllingException() {
		ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
      	
		Account accNA = TestDataFactory.createMAWithCountry('NA Peru', gaCountry.Id);
 
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
		ampi__Geographical_Area__c gaProgramme2 = TestDataFactory.createProgramme('Lima', gaCountry.Id, accNA.Id);
        ampi__Geographical_Area__c gaProgrammeUnit = TestDataFactory.createProgrammeUnit('New Programme Unit based on Callao', gaProgramme.Id, accNA.Id);

		ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC', 'Youth Care (similar to YF)');
		ampi__Thematic_Area__c thematicAreaFS = TestDataFactory.createThematicArea('FS', 'Family Streghtening (FS)');
		
		//one test method 
		ampi__Project__c projectStandard = TestDataFactory.createProject('Standard', accNA.Id, gaProgramme.Id, 'FS, YC');
		ampi__Reporting_Period__c mp = TestDataFactory.manageMonitoringPeriodByProjectAndFrequency(projectStandard.Id, 'Monthly');
        // ampi__Project_Geographic_Area__c pga = TestDataFactory.createPGA(projectStandard.Id, gaProgramme.Id);
        // ampi__Project_Geographic_Area__c pga = TestDataFactory.createPGA(projectStandard.Id, gaProgrammeUnit.Id);

        ampi__Project_Indicator__c pi1 = TestDataFactory.createProjectIndicator('Indicator 1', projectStandard.Id);
        ampi__Project_Indicator__c pi2 = TestDataFactory.createProjectIndicator('Indicator 2', projectStandard.Id);
        
        List<ampi__project_indicator_reporting_period__c> pirps = TestDataFactory.generatePIRPsByProjectId(projectStandard.Id);
        List<ampi__project_indicator_geographic_area__c> pigas = TestDataFactory.generatePIGAsByProjectId(projectStandard.Id);

		Test.startTest();

        User newUser = TestDataFactory.CreateUserFromSystemAdminByAlias('xxzzzccc');
        //Team_member__c tm = TestDataFactory.createTeammember(projectStandard.Id, newUser.Id, 'Project Contributor', accNA.Id);        
        Team_member__c tm = TestDataFactory.createTeammember(projectStandard.Id, newUser.Id, 'YouthCan! Partner', accNA.Id);                

        System.runAs(newUser) {
            try {
                ampi__result__c res = TestDataFactory.createReults(30, pirps[0].Id, pigas[0].Id, pi1.Id);
                INSERT res;    
                
                if (res.Id == null) {
                    System.assert(false);
                    return;
                }
            }catch(Exception ex) {
                Boolean expectedExceptionThrown = ex.getMessage().contains('INSUFFICIENT_ACCESS_OR_READONLY') ? true : false;
                if (expectedExceptionThrown) {
                    System.assert(false);
                    return;
                }
            }
        }		
		
		System.assert(true);
        Test.stopTest();        
	}


    @isTest
    private static void beforeInsertUpdateResultsInCommunityProfiles_CheckIfPossibleToSaveWithCommunityUser_ThrowsException() {
		ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
      	
		Account accNA = TestDataFactory.createMAWithCountry('NA Peru', gaCountry.Id);
 
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
		ampi__Geographical_Area__c gaProgramme2 = TestDataFactory.createProgramme('Lima', gaCountry.Id, accNA.Id);
        ampi__Geographical_Area__c gaProgrammeUnit = TestDataFactory.createProgrammeUnit('New Programme Unit based on Callao', gaProgramme.Id, accNA.Id);

		ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC', 'Youth Care (similar to YF)');
		ampi__Thematic_Area__c thematicAreaFS = TestDataFactory.createThematicArea('FS', 'Family Streghtening (FS)');
		
		//one test method 
		ampi__Project__c projectStandard = TestDataFactory.createProject('Standard', accNA.Id, gaProgramme.Id, 'FS, YC');
		ampi__Reporting_Period__c mp = TestDataFactory.manageMonitoringPeriodByProjectAndFrequency(projectStandard.Id, 'Monthly');
        
        ampi__Project_Indicator__c pi1 = TestDataFactory.createProjectIndicator('Indicator 1', projectStandard.Id);
        ampi__Project_Indicator__c pi2 = TestDataFactory.createProjectIndicator('Indicator 2', projectStandard.Id);
        
        List<ampi__project_indicator_reporting_period__c> pirps = TestDataFactory.generatePIRPsByProjectId(projectStandard.Id);
        List<ampi__project_indicator_geographic_area__c> pigas = TestDataFactory.generatePIGAsByProjectId(projectStandard.Id);

		Test.startTest();
        User newUser = TestDataFactory.CreateUserFromSystemAdminByAlias('xxzzzccc');
        
        System.runAs(newUser) {
            try {
                ampi__result__c res = TestDataFactory.createReults(30, pirps[0].Id, pigas[0].Id, pi1.Id);
                INSERT res;    
                if (res.Id == null) {
                    System.assert(true);
                    return;
                }
            }catch(Exception ex) {
                Boolean expectedExceptionThrown = ex.getMessage().contains('INSUFFICIENT_ACCESS_OR_READONLY') ? true : false;
                if (expectedExceptionThrown) {
                    System.assert(true);
                    return;
                }
            }
        }		
		
		System.assert(false);
        Test.stopTest();        
	}
    
}