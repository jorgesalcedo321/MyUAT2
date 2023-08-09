@isTest
private class ProjectGeographicAreaTriggerHandlerTest {
    @isTest 
    static void afterInsertStandardAndTransition_GrantfinancialSILExists() {
    	ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
		Account accNA = TestDataFactory.createMAWithCountry('NA Peru', gaCountry.Id);
        ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
		ampi__Geographical_Area__c gaProgramme2 = TestDataFactory.createProgramme('Lima', gaCountry.Id, accNA.Id);
		ampi__Geographical_Area__c gaProgramme3 = TestDataFactory.createProgramme('Arequipa', gaCountry.Id, accNA.Id);
		ampi__Geographical_Area__c gaProgramme4 = TestDataFactory.createProgramme('Huaraz', gaCountry.Id, accNA.Id);
        ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC', 'Youth Care (similar to YF)');
		ampi__Thematic_Area__c thematicAreaFS = TestDataFactory.createThematicArea('FS', 'Family Streghtening (FS)');
		ampi__Thematic_Area__c thematicAreaCT = TestDataFactory.createThematicArea('CT', 'Care Training (CT)');
		ampi__Thematic_Area__c thematicAreaER = TestDataFactory.createThematicArea('ER', 'Emergency Response (ER)');
		
        ampi__Geographical_Area__c pu1 = TestDataFactory.createNMU('Programme Unit Test1 New 1', gaProgramme.Id, accNA.Id);
        pu1.Thematic_Area__c = thematicAreaYC.Id;
        UPDATE pu1; 

        ampi__Geographical_Area__c pu2 = TestDataFactory.createNMU('Programme Unit Test1 New 2', gaProgramme2.Id, accNA.Id);
        pu2.Thematic_Area__c = thematicAreaFS.Id;
        UPDATE pu2; 

        ampi__Geographical_Area__c pu3 = TestDataFactory.createNMU('Programme Unit Test1 New 3', gaProgramme3.Id, accNA.Id);
        pu3.Thematic_Area__c = thematicAreaCT.Id;
        UPDATE pu3; 

        ampi__Geographical_Area__c pu4 = TestDataFactory.createNMU('Programme Unit Test1 New 4', gaProgramme4.Id, accNA.Id);
        pu4.Thematic_Area__c = thematicAreaER.Id;
        UPDATE pu4; 

		ampi__Project__c projectTransition = TestDataFactory.createProjectByStatus('Transition', accNA.Id, gaProgramme.Id, '', '');
        projectTransition.Transition_Project_Type__c = 'Grant';
        projectTransition.Programme_location__c = gaProgramme.Id;
        UPDATE projectTransition;

        ampi__Project_Geographic_Area__c pgat = TestDataFactory.createPGA(projectTransition.Id, pu1.Id);
        ampi__Project_Geographic_Area__c pgat2 = TestDataFactory.createPGA(projectTransition.Id, pu2.Id);
		// ampi__Project_Geographic_Area__c pgat3 = TestDataFactory.createPGA(projectTransition.Id, pu3.Id);
        // ampi__Project_Geographic_Area__c pgat4 = TestDataFactory.createPGA(projectTransition.Id, pu4.Id);
		Test.startTest();
		System.debug('###projectTransition values: ' + projectTransition);
		System.debug('###projectTransition.Id: ' + projectTransition.id);
        
        ampi__reporting_period__c reportingPeriod = CreateObjects.manageMonitoringPeriodByProject(projectTransition.Id, 1);
        System.debug('####reportingPeriod:' + reportingPeriod.Id);
        
        List<ampi__Financial__c> financials = [SELECT Id, ampi__Category__c FROM ampi__Financial__c WHERE Name =: pu1.Name AND ampi__Category__c = 'SIL'];
        System.debug('####financials:' + financials);
        System.assert(financials.size() > 0);
        
        List<ampi__project_geographic_area__c> activePGAs = [SELECT Id FROM ampi__project_geographic_area__c WHERE ampi__project__c =: projectTransition.id AND ampi__geographic_area__c =: gaProgramme.Id AND ampi__Active__c = true];
        List<ampi__project_Thematic_area__c> activePSTs = [SELECT Id FROM ampi__project_Thematic_area__c WHERE ampi__project__c =: projectTransition.id];
        System.assert(activePGAs.size() > 0);
        //TODO:System.assert(activePSTs.size() > 0);

        Test.stopTest();       
    }

    @isTest 
    static void afterInsertStandardAndTransition_ChildMoneyGiftFinancialSILExists() {
    	Account accNA = TestDataFactory.createMA('NA Peru');
		ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
		ampi__Geographical_Area__c gaProgramme2 = TestDataFactory.createProgramme('Lima', gaCountry.Id, accNA.Id);
		ampi__Geographical_Area__c gaProgramme3 = TestDataFactory.createProgramme('Arequipa', gaCountry.Id, accNA.Id);
		ampi__Geographical_Area__c gaProgramme4 = TestDataFactory.createProgramme('Huaraz', gaCountry.Id, accNA.Id);
        ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC', 'Youth Care (similar to YF)');
		ampi__Thematic_Area__c thematicAreaFS = TestDataFactory.createThematicArea('FS', 'Family Streghtening (FS)');
		ampi__Thematic_Area__c thematicAreaCT = TestDataFactory.createThematicArea('CT', 'Care Training (CT)');
		ampi__Thematic_Area__c thematicAreaER = TestDataFactory.createThematicArea('ER', 'Emergency Response (ER)');
		
        ampi__Geographical_Area__c pu1 = TestDataFactory.createNMU('Programme Unit Test1 New 1', gaProgramme.Id, accNA.Id);
        pu1.Thematic_Area__c = thematicAreaYC.Id;
        UPDATE pu1; 

        ampi__Geographical_Area__c pu2 = TestDataFactory.createNMU('Programme Unit Test1 New 2', gaProgramme2.Id, accNA.Id);
        pu2.Thematic_Area__c = thematicAreaFS.Id;
        UPDATE pu2; 

        ampi__Geographical_Area__c pu3 = TestDataFactory.createNMU('Programme Unit Test1 New 3', gaProgramme3.Id, accNA.Id);
        pu3.Thematic_Area__c = thematicAreaCT.Id;
        UPDATE pu3; 

        ampi__Geographical_Area__c pu4 = TestDataFactory.createNMU('Programme Unit Test1 New 4', gaProgramme4.Id, accNA.Id);
        pu4.Thematic_Area__c = thematicAreaER.Id;
        UPDATE pu4; 

		ampi__Project__c projectTransition = TestDataFactory.createProjectByStatus('Transition', accNA.Id, gaProgramme.Id, '', '');
        projectTransition.Transition_Project_Type__c = 'Child Money Gift';
        projectTransition.Programme_location__c = gaProgramme.Id;
        UPDATE projectTransition;

        ampi__Project_Geographic_Area__c pgat = TestDataFactory.createPGA(projectTransition.Id, pu1.Id);
        ampi__Project_Geographic_Area__c pgat2 = TestDataFactory.createPGA(projectTransition.Id, pu2.Id);
		// ampi__Project_Geographic_Area__c pgat3 = TestDataFactory.createPGA(projectTransition.Id, pu3.Id);
        // ampi__Project_Geographic_Area__c pgat4 = TestDataFactory.createPGA(projectTransition.Id, pu4.Id);
		Test.startTest();
		System.debug('###projectTransition values: ' + projectTransition);
		System.debug('###projectTransition.Id: ' + projectTransition.id);
        
        ampi__reporting_period__c reportingPeriod = CreateObjects.manageMonitoringPeriodByProject(projectTransition.Id, 1);
        System.debug('####reportingPeriod:' + reportingPeriod.Id);
        
        // List<ampi__Financial__c> financials = [SELECT Id, ampi__Category__c FROM ampi__Financial__c WHERE Name =: pu1.Name AND ampi__Category__c = '3 CMG CI'];
        // System.debug('####financials:' + financials);
        // System.assert(financials.size() > 0);
        
        List<ampi__project_geographic_area__c> activePGAs = [SELECT Id FROM ampi__project_geographic_area__c WHERE ampi__project__c =: projectTransition.id AND ampi__geographic_area__c =: gaProgramme.Id AND ampi__Active__c = true];
        List<ampi__project_Thematic_area__c> activePSTs = [SELECT Id FROM ampi__project_Thematic_area__c WHERE ampi__project__c =: projectTransition.id];
        System.assert(activePGAs.size() > 0);
        System.assert(activePSTs.size() == 0);

        Test.stopTest();       
    }  

     @isTest 
    static void afterInsertStandardAndTransition_RunningCostsfinancialSILExists() {
    	ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
		Account accNA = TestDataFactory.createMAWithCountry('NA Peru', gaCountry.Id);
        ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
		ampi__Geographical_Area__c gaProgramme2 = TestDataFactory.createProgramme('Lima', gaCountry.Id, accNA.Id);
        ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC', 'Youth Care (similar to YF)');
		ampi__Thematic_Area__c thematicAreaFS = TestDataFactory.createThematicArea('FS', 'Family Streghtening (FS)');
		
        ampi__Geographical_Area__c pu1 = TestDataFactory.createNMU('Programme Unit New 1', gaProgramme.Id, accNA.Id);
        pu1.Thematic_Area__c = thematicAreaYC.Id;
        UPDATE pu1; 

		ampi__Project__c projectTransition = TestDataFactory.createProjectByStatus('Transition', accNA.Id, gaProgramme.Id, '', '');
        projectTransition.Transition_Project_Type__c = 'Running Costs';
        UPDATE projectTransition;

        ampi__Project_Geographic_Area__c pgat = TestDataFactory.createPGA(projectTransition.Id, pu1.Id);
		
		Test.startTest();
		System.debug('###projectTransition values: ' + projectTransition);
		System.debug('###projectTransition.Id: ' + projectTransition.id);
        
        ampi__reporting_period__c reportingPeriod = CreateObjects.manageMonitoringPeriodByProject(projectTransition.Id, 1);
        System.debug('####reportingPeriod:' + reportingPeriod.Id);
        
        List<ampi__Financial__c> financials = [SELECT Id, ampi__Category__c FROM ampi__Financial__c WHERE Name =: pu1.Name AND ampi__Category__c = 'SIL'];
        System.debug('####financials:' + financials);
        System.assert(financials.size() > 0);
        
        Test.stopTest();       
    } 

     @isTest 
    static void afterInsertStandardAndTransition_EmergencyfinancialSILExists() {
    	Account accNA = TestDataFactory.createMA('NA Peru');
		ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
		ampi__Geographical_Area__c gaProgramme2 = TestDataFactory.createProgramme('Lima', gaCountry.Id, accNA.Id);
        ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC', 'Youth Care (similar to YF)');
		ampi__Thematic_Area__c thematicAreaFS = TestDataFactory.createThematicArea('FS', 'Family Streghtening (FS)');
		
        ampi__Geographical_Area__c pu1 = TestDataFactory.createNMU('Programme Unit New 1', gaProgramme.Id, accNA.Id);
        pu1.Thematic_Area__c = thematicAreaYC.Id;
        UPDATE pu1; 

		ampi__Project__c projectTransition = TestDataFactory.createProjectByStatus('Transition', accNA.Id, gaProgramme.Id, '', '');
        projectTransition.Transition_Project_Type__c = 'Emergency';
        UPDATE projectTransition;

        ampi__Project_Geographic_Area__c pgat = TestDataFactory.createPGA(projectTransition.Id, pu1.Id);
		
		Test.startTest();
		System.debug('###projectTransition values: ' + projectTransition);
		System.debug('###projectTransition.Id: ' + projectTransition.id);
        
        ampi__reporting_period__c reportingPeriod = CreateObjects.manageMonitoringPeriodByProject(projectTransition.Id, 1);
        System.debug('####reportingPeriod:' + reportingPeriod.Id);
        
        List<ampi__Financial__c> financials = [SELECT Id, ampi__Category__c FROM ampi__Financial__c WHERE Name =: pu1.Name AND ampi__Category__c = 'SIL'];
        System.debug('####financials:' + financials);
        System.assert(financials.size() > 0);
        
        Test.stopTest();       
    } 
    
    @isTest 
    static void ProjectGeographicAreaTest(){
        ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('ESAF');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Malawi', gaRegion.Id);
		Account accNA = TestDataFactory.createMAWithCountry('NA Malawi', gaCountry.Id);

        ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Mzuzu', gaCountry.Id, accNA.Id);

		ampi__Thematic_Area__c thematicArea = new ampi__Thematic_Area__c();
		thematicArea.Name = 'YC';
        thematicArea.ampi__Active__c = true;
		thematicArea.ampi__Description__c = 'Youth Care (similar to YF)';
        
		insert thematicArea;

		ampi__Project__c pProgramme = new ampi__Project__c();
		pProgramme.Name = 'Mzuzu-Programme';
		pProgramme.SOS_Implementing_Organisation__c = accNA.Id;
		pProgramme.P_PU__c = gaProgramme.Id;
		pProgramme.RecordTypeId = ampi__Project__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Shadow Project').getRecordTypeId();
		insert pProgramme;

		ampi__Indicator__c indicator = new ampi__Indicator__c();
		indicator.ampi__Description__c = '183D Beneficiaries 0-17 Siblings';
		indicator.ampi__Data_Type__c = 'Number';
		indicator.ampi__Type_of_Results__c = 'Input';
		indicator.Category__c = 'Mandatory';
		indicator.Level__c = 'Children & Young People';
		indicator.ampi__Guideline__c = 'SKF';
		indicator.ampi__Active__c = true;
		indicator.Source_Document__c = 'Statistics Handbook Version Nov 2017';
		indicator.Source_of_Indicator__c = 'Other';
		indicator.Strategic_Measure__c = 'No';
		indicator.Care_Promise_Indicator__c = 'No';
		indicator.ampi__Reporting_Frequency__c = 'Monthly';
		indicator.ampi__Target_Frequency__c = 'Yearly';
		indicator.ampi__Include_In_Catalog__c = true;
		indicator.ampi__Geographical_Disaggregation__c = 'Programme Unit';
		indicator.ampi__Calculate_Total__c = 'Sum Total';
		indicator.ampi__Thematic_Area_Icon__c = 'FS';
		indicator.ampi__Thematic_Area_Ids__c = String.valueOf(thematicArea.Id);
		indicator.ampi__Thematic_Area_Text__c = '#FS';
		insert indicator;

		ampi__Project_Indicator__c pIndicator = new ampi__Project_Indicator__c();
		pIndicator.ampi__Description__c = '183D Beneficiaries 0-17 Siblings';
		pIndicator.ampi__Active__c = true;
		pIndicator.ampi__Project__c = pProgramme.Id;
		pIndicator.ampi__Catalog_Indicator__c = indicator.Id;
		pIndicator.ampi__Reporting_Frequency__c = 'Monthly';
		pIndicator.ampi__Target_Frequency__c = 'Yearly';
		pIndicator.ampi__Type_of_Results__c = 'Input';
		pIndicator.ampi__Guideline__c = 'SKF';
		pIndicator.ampi__Geographical_Disaggregation__c = 'Programme Unit';
		insert pIndicator;

		ampi__Indicator__c indicator2 = new ampi__Indicator__c();
		indicator2.ampi__Description__c = '183D Beneficiaries 0-17 Siblings';
		indicator2.ampi__Data_Type__c = 'Number';
		indicator2.ampi__Type_of_Results__c = 'Input';
		indicator2.Category__c = 'Mandatory';
		indicator2.Level__c = 'Children & Young People';
		indicator2.ampi__Guideline__c = 'SKF';
		indicator2.ampi__Active__c = true;
		indicator2.Source_Document__c = 'Statistics Handbook Version Nov 2017';
		indicator2.Source_of_Indicator__c = 'Other';
		indicator2.Strategic_Measure__c = 'No';
		indicator2.Care_Promise_Indicator__c = 'No';
		indicator2.ampi__Reporting_Frequency__c = 'Monthly';
		indicator2.ampi__Target_Frequency__c = 'Annual';
		indicator2.ampi__Include_In_Catalog__c = true;
		indicator2.ampi__Geographical_Disaggregation__c = 'Programme Unit';
		indicator2.ampi__Calculate_Total__c = 'Sum Total';
		indicator2.ampi__Thematic_Area_Icon__c = 'FS';
		indicator2.ampi__Thematic_Area_Ids__c = String.valueOf(thematicArea.Id);
		indicator2.ampi__Thematic_Area_Text__c = '#FS';
		insert indicator2;

		ampi__Project_Indicator__c pIndicator2 = new ampi__Project_Indicator__c();
		pIndicator2.ampi__Description__c = '183D Beneficiaries 0-17 Siblings';
		pIndicator2.ampi__Active__c = true;
		pIndicator2.ampi__Project__c = pProgramme.Id;
		pIndicator2.ampi__Catalog_Indicator__c = indicator2.Id;
		pIndicator2.ampi__Reporting_Frequency__c = 'Monthly';
		pIndicator2.ampi__Target_Frequency__c = 'Yearly';
		pIndicator2.ampi__Type_of_Results__c = 'Input';
		pIndicator2.ampi__Guideline__c = 'SKF';
		pIndicator2.ampi__Geographical_Disaggregation__c = 'Programme Unit';
		insert pIndicator2;

		ampi__Indicator_Thematic_Area__c ITA = new ampi__Indicator_Thematic_Area__c();
		ITA.ampi__Indicator__c = indicator.Id;
		ITA.ampi__Thematic_Area__c = thematicArea.Id;
		ITA.ampi__Required__c = true;
		insert ITA;	

        ampi__Geographical_Area__c gaOrganisationalUnit = TestDataFactory.createProgrammeUnit('YC Tel Aviv', gaProgramme.Id, accNA.Id);
		gaOrganisationalUnit.Thematic_Area__c = thematicArea.Id;
        UPDATE gaOrganisationalUnit; 
        
        ampi__Project_Geographic_Area__c pga = TestDataFactory.createPGA(pProgramme.Id, gaOrganisationalUnit.Id);
		
		List<ampi__Project_Indicator_Geographic_Area__c> lPIGAs = new List<ampi__Project_Indicator_Geographic_Area__c>();
		ampi__Project_Indicator_Geographic_Area__c PIGA1 = new ampi__Project_Indicator_Geographic_Area__c();
		PIGA1.ampi__Project_Indicator__c = pIndicator.Id;
		PIGA1.ampi__Geographic_Area__c = gaOrganisationalUnit.Id;
		lPIGAs.add(PIGA1);

		ampi__Project_Indicator_Geographic_Area__c PIGA2 = new ampi__Project_Indicator_Geographic_Area__c();
		PIGA2.ampi__Project_Indicator__c = pIndicator2.Id;
		PIGA2.ampi__Geographic_Area__c = gaOrganisationalUnit.Id;
		lPIGAs.add(PIGA2);

		insert lPIGAs;

		Test.startTest();
		List<ampi__Project_Indicator_Geographic_Area__c> PIGAs = [SELECT Id, ampi__Geographic_Area__c, ampi__Project_Indicator__r.ampi__Catalog_Indicator__c FROM ampi__Project_Indicator_Geographic_Area__c];
		System.assertEquals(2, PIGAs.size());

		pga.Delete_PIGAs__c = true;
		update pga;

		List<ampi__Project_Indicator_Geographic_Area__c> PIGAsAfter = [SELECT Id, ampi__Geographic_Area__c, ampi__Project_Indicator__r.ampi__Catalog_Indicator__c FROM ampi__Project_Indicator_Geographic_Area__c];
		//TODO: Commented for deactivation of trigger: 
		System.assertEquals(2, PIGAsAfter.size());
		//System.assert(true);
		Test.stopTest();
	}

	@isTest 
	static void ProjectGeographicArea_InsertTest(){
		ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
		Account accNA = TestDataFactory.createMAWithCountry('NA Peru', gaCountry.Id);
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
		ampi__Geographical_Area__c gaProgramme2 = TestDataFactory.createProgramme('Lima', gaCountry.Id, accNA.Id);
		ampi__Geographical_Area__c gaProgrammeUnit = TestDataFactory.createProgrammeUnit('Lima Este', gaProgramme2.Id, accNA.Id);
		
		ampi__Project__c projectTransition = TestDataFactory.createProjectByStatus('Transition', accNA.Id, '', '', 'Construction');
		ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC1', 'Youth Care (similar to YF)');
        ampi__project_thematic_area__c pta = TestDataFactory.createProjectThematicArea(projectTransition.Id, thematicAreaYC.Id, gaProgrammeUnit.Id);
        
		List<ampi__Budget__c> budgetsBefore = [SELECT Id FROM ampi__Budget__c WHERE ampi__Project__c =: projectTransition.Id];
		
        gaProgrammeUnit.Thematic_Area__c = thematicAreaYC.Id;
        UPDATE gaProgrammeUnit; 
        
        ampi__Project_Geographic_Area__c pga = TestDataFactory.createPGA(projectTransition.Id, gaProgrammeUnit.Id);
		
		List<ampi__Budget__c> budgetsAfter = [SELECT Id FROM ampi__Budget__c WHERE ampi__Project__c =: projectTransition.Id];
		
		//TODO: Commented for deactivation of trigger: 
		System.assert(budgetsBefore.size() < budgetsAfter.size());
		//System.assert(true);
	}
}