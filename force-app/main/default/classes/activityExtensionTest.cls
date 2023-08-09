@isTest
private class activityExtensionTest {
    @isTest
    private static void activityExtensionTest_CreatingTests() {
        Test.startTest();
        
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
		
		ampi__Implementation_Plan__c ip = TestDataFactory.createActivitySchedule('Test Standard Activities', projectStandard.Id);
		
		ampi__Objective__c obj1 = TestDataFactory.createProjectResultStatement('Impact', 1, '', projectStandard.Id);
		ampi__Objective__c obj2 = TestDataFactory.createProjectResultStatement('Outcome', 2, obj1.Id, projectStandard.Id);
		ampi__Objective__c obj3 = TestDataFactory.createProjectResultStatement('Output', 3, obj2.Id, projectStandard.Id);
		
        TestDataFactory.createActivityWithDates(ip.Id, 'act 1', 'Results-Based', 'Task', 'New', projectStandard.Id, Date.newInstance(2023, 1, 1), Date.newInstance(2023, 1, 21), obj3.Id, '1');
        TestDataFactory.createActivityWithDates(ip.Id, 'act 2', 'Results-Based', 'Task', 'New', projectStandard.Id, Date.newInstance(2022, 1, 1), Date.newInstance(2022, 1, 21), obj3.Id, '2');
        TestDataFactory.createActivityWithDates(ip.Id, 'act 3', 'Results-Based', 'Task', 'New', projectStandard.Id, Date.newInstance(2023, 1, 1), Date.newInstance(2023, 1, 21), obj3.Id, '3');
	    
		List<ampi__project__c> projs = activityExtension.getProjectInfoStatus(projectStandard.Id);
		System.assert(projs.size() > 0);

		List<ampi__objective__c> objs = activityExtension.getProjectResultStatementFromProject(projectStandard.Id);
		System.assert(objs.size() > 0);
		
		Integer earlyYear = activityExtension.getEarlyStartDateFromActivity(projectStandard.Id);
		System.assert(earlyYear > 0);

		Integer endingYear = activityExtension.getLateStartDateFromActivity(projectStandard.Id);
		System.assert(endingYear > 0);

		List<ampi__activity__c> activities = activityExtension.getActivitiesFromYearAndResultAndProject(earlyYear, objs[0].Id, projectStandard.Id);
		System.assert(activities.size() > 0);

		List<ampi__activity__c> activities2 = activityExtension.getMainActivitiesFromYearAndNewStatus(earlyYear, projectStandard.Id);
		System.assert(activities2.size() > 0);

		String result = activityExtension.updateMainActivitiesFromYearAndNewStatusToPlanning(earlyYear, projectStandard.Id);
		System.assert(result == '');

		List<activityExtension.LabelValue> statuses = activityExtension.getStatusesFromActivity();
		System.assert(statuses.size() > 0);

        Test.stopTest();                
    }
}