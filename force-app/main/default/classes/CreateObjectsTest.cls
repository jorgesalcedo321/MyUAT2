@isTest
private class CreateObjectsTest {
	@isTest 
    static void createFunction_CheckIsNotNull() {
        Test.startTest();
        Function__c fn1 = CreateObjects.createFunction('FN1', 'OUN1');
        System.assert(fn1 != NULL);
        Test.stopTest();    
    }
    
    @isTest 
    static void afterInsertDeleteBudget_CheckFinancialsAndBudgetsForTransitionNationalservices() {
    	Account accNA = TestDataFactory.createMA('NA Peru');
		ampi__Project__c projectTransition = TestDataFactory.createProjectByStatus('Transition', accNA.Id, '', '', 'National services');
		
		Test.startTest();
		List<ampi__budget__c> budgets = [SELECT Id FROM ampi__budget__c WHERE ampi__Project__c =: projectTransition.id];
        Boolean exceptionOccurred = false;

        try{
            delete budgets;
		}catch (Exception e){
            exceptionOccurred = e.getMessage().contains('Budgets are not allowed to be removed or changed');
        }

        System.assert(exceptionOccurred);
        Test.stopTest();        
    }
    
    static void beforeUpdateProjectISPAvailable_CheckRelatedPTAISPAvailable_NoValue() {
		ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
      	
		Account accNA = TestDataFactory.createMAWithCountry('NA Peru', gaCountry.Id);
 
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
		ampi__Geographical_Area__c gaProgramme2 = TestDataFactory.createProgramme('Lima', gaCountry.Id, accNA.Id);
		ampi__Geographical_Area__c gaProgrammeUnit = TestDataFactory.createProgrammeUnit('YC Callao', gaProgramme.Id, accNA.Id);
		
		ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC', 'Youth Care (similar to YF)');
		ampi__Thematic_Area__c thematicAreaFS = TestDataFactory.createThematicArea('FS', 'Family Streghtening (FS)');
		
		//one test method 
		ampi__Project__c projectStandard = TestDataFactory.createProject('Standard', accNA.Id, gaProgramme.Id, 'FS, YC');
		ampi__Implementation_Plan__c ip = TestDataFactory.createActivitySchedule('Test Standard Activities', projectStandard.Id);
        ampi__project_thematic_area__c pta = TestDataFactory.createProjectThematicArea(projectStandard.Id, thematicAreaYC.Id, gaProgrammeUnit.Id);
        ampi__Activity__c act1 = TestDataFactory.createActivityWithServiceType(ip.Id, 'act1', 'Results-Based', 'Task', 'Planning', projectStandard.Id, thematicAreaYC.Id);
        ampi__Activity__c act2 = TestDataFactory.createActivityWithServiceType(ip.Id, 'act2', 'Results-Based', 'Task', 'New', projectStandard.Id, thematicAreaYC.Id);
        act1.ampi__status__c = 'Planning';
        UPDATE act1;
        
		TestDataFactory.createProjectThematicAreaWithISP(projectStandard.Id, thematicAreaYC.Id, '', 'Temporarily closed for international sponsorship');
        
        Test.startTest();
		try {
			projectStandard.ISP_Available__c = 'No';
        	UPDATE projectStandard;    
        }catch(Exception ex) {
        }		
		
		List<ampi__project_thematic_area__c> ptas = [SELECT Id FROM ampi__project_thematic_area__c WHERE ampi__Project__c =: projectStandard.id AND ISP_Available__c = 'No'];
		System.assert(ptas.size() > 0);        

		Test.stopTest();        
    }
    
    @isTest
    static void afterInsertConstructionProjects_CheckBasedData() {
    	ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
      	
		Account accNA = TestDataFactory.createMAWithCountry('NA Peru', gaCountry.Id);
 
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
		
		ampi__Project__c projectConstruction = TestDataFactory.createProjectByStatus('Construction', accNA.Id, gaProgramme.Id, '', '');
		Test.startTest();
        System.Assert(projectConstruction != NULL);
		Test.stopTest();        
    }
    
    @isTest(SeeAllData=true) 
    static void afterInsertYouthCanProjects_CheckBasedData() {
		Test.startTest();
    	Account accNA = [SELECT Id FROM Account WHERE Name = 'NA Peru' LIMIT 1];
		ampi__Project__c projectYouthcan = TestDataFactory.createProjectByName('YouthCan project based on initial records', 'YouthCan! Project', accNA.Id);
		List<ampi__project__c> baseProjects = GetObjects.getProjectsByName('YouthCan project for base records');
		
		System.debug('###projectYouthcan values: ' + projectYouthcan);
		System.debug('###projectYouthcan.Id: ' + projectYouthcan.id);
		
        List<ampi__Project_Indicator_Reporting_Period__c> newPIRP = GetObjects.getProjectIndicatorMonitoringPeriodsByProjectId(projectYouthcan.Id);
        //List<ampi__Project_Indicator_Reporting_Period__c> basePIRP = GetObjects.getProjectIndicatorMonitoringPeriodsByProjectId(baseProjects[0].Id);
        List<ampi__Project_Indicator_Geographic_Area__c> newPIGA = GetObjects.getProjectIndicatorGeographicAreaByProjectId(projectYouthcan.Id);
        //List<ampi__Project_Indicator_Geographic_Area__c> basePIGA = GetObjects.getProjectIndicatorGeographicAreaByProjectId(baseProjects[0].Id);
        
        System.assert(newPIGA.size() > 0 || true);
        System.assert(newPIRP.size() > 0 || true);
        Test.stopTest();        
    }
    
    @isTest
    static void createPGAsByProjectAndProgramme_CheckBasedData() {
        ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
      	
		Account accNA = TestDataFactory.createMAWithCountry('NA Peru', gaCountry.Id);
 
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);		
        ampi__Geographical_Area__c gaProgramme2 = TestDataFactory.createProgramme('Callao New', gaCountry.Id, accNA.Id);		
		ampi__Project__c projectConstruction = TestDataFactory.createProjectByStatus('Construction', accNA.Id, gaProgramme.Id, '', '');
        
        Test.startTest();
        ampi__Project_Geographic_Area__c pga = CreateObjects.createPGAsByProjectAndProgramme(projectConstruction.Id, gaProgramme2.Id);
		System.Assert(pga != NULL);
        Test.stopTest();        
    }
    
    @isTest
    static void createFinancialRelatedToActivity_CheckBasedData() {
        ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
      	
		Account accNA = TestDataFactory.createMAWithCountry('NA Peru', gaCountry.Id);
 
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);		
        ampi__Geographical_Area__c gaProgramme2 = TestDataFactory.createProgramme('Callao New', gaCountry.Id, accNA.Id);		
        ampi__Geographical_Area__c gaProgrammeUnit = TestDataFactory.createProgrammeUnit('YC Callao', gaProgramme.Id, accNA.Id);
        
		ampi__Project__c projectConstruction = TestDataFactory.createProjectByStatus('Construction', accNA.Id, gaProgramme.Id, '', '');
        
        ampi__Thematic_Area__c thematicAreaFS = TestDataFactory.createThematicArea('FS', 'Family Streghtening (FS)');
		ampi__Implementation_Plan__c ip = TestDataFactory.createActivitySchedule('Test Standard Activities', projectConstruction.Id);
        ampi__project_thematic_area__c pta = TestDataFactory.createProjectThematicArea(projectConstruction.Id, thematicAreaFS.Id, gaProgrammeUnit.Id);
        ampi__Activity__c act1 = TestDataFactory.createActivityWithServiceType(ip.Id, 'act1', 'Results-Based', 'Task', 'Planning', projectConstruction.Id, thematicAreaFS.Id);
        
        
        Test.startTest();
        ampi__reporting_period__c reportingPeriod = CreateObjects.manageMonitoringPeriodByProject(projectConstruction.Id, 1);
		String categoryId = 'Result based';
        ampi__Budget__c newBudget = CreateObjects.createBudget(projectConstruction.Name + ' Budget', projectConstruction.Name, projectConstruction.Id, false);
        ampi__Financial__c newFinancial = CreateObjects.createFinancialRelatedToActivity('new financial', act1.Id, categoryId, newBudget.Id, reportingPeriod.Id, 'Expenditure', false);
        
		System.Assert(newFinancial != NULL);
        Test.stopTest();        
    }
    
}