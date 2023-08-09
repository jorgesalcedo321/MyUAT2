@isTest
private class ExtraCreateObjectsTest {
    @isTest
    static void creatingFinancialWithPU_GetCodeExists() {
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

		List<ampi__reporting_period__c> mps = [SELECT Id FROM ampi__reporting_period__c WHERE ampi__project__c =: projectStandard.Id];
        List<ampi__budget__c> budgets = [SELECT Id FROM ampi__budget__c WHERE ampi__Project__c =: projectStandard.id];
        
        ampi__Implementation_Plan__c ip = TestDataFactory.createActivitySchedule('Test Standard Activities', projectStandard.Id);
        ampi__Activity__c activity = TestDataFactory.createActivity(ip.Id, 'act2', 'Overarching', 'Task', 'Planning', projectStandard.Id);
        		
        ampi__Financial__c financial = ExtraCreateObjects.createFinancialWithPU('financial1', activity.Id, '3 CMG CI', budgets[0].Id, mps[0].Id, true, gaProgrammeUnit.Id);
        System.assert(financial != null);  
        ExtraCreateObjects.createMonitoringPeriodByProjectAndMonth(projectStandard.Id);        
    }
}