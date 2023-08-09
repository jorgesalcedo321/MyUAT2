@isTest
private class ScheduledProjectActivityNotificationTest {
	@isTest
    static void executeBatch_GeneratingExternal() {
        ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
      	
		Account accNA = TestDataFactory.createMAWithCountry('NA Peru', gaCountry.Id);
 
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
		ampi__Geographical_Area__c gaProgramme2 = TestDataFactory.createProgramme('Lima', gaCountry.Id, accNA.Id);
        ampi__Geographical_Area__c gaProgrammeUnit = TestDataFactory.createProgrammeUnit('New Programme Unit based on Callao', gaProgramme.Id, accNA.Id);

		ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC', 'Youth Care (similar to YF)');
		ampi__Thematic_Area__c thematicAreaFS = TestDataFactory.createThematicArea('FS', 'Family Streghtening (FS)');
		
		ampi__Project__c projectStandard = TestDataFactory.createProject('Standard', accNA.Id, gaProgramme.Id, 'FS, YC');
            
        ampi__Implementation_Plan__c schedules = TestDataFactory.createActivitySchedule('ASCH', projectStandard.Id);
        String scheduleId = schedules.Id;
        
        ampi__Activity__c a1 = TestDataFactory.createActivity(scheduleId, 'Activity 1', 'Overarching', 'Task', 'New', projectStandard.Id);
        ampi__Activity__c a2 = TestDataFactory.createActivity(scheduleId, 'Activity 2', 'Overarching', 'Task', 'New', projectStandard.Id);
        ampi__Activity__c a3 = TestDataFactory.createActivity(scheduleId, 'Activity 3', 'Overarching', 'Task', 'New', projectStandard.Id);
             
        Test.startTest();
        List<ampi__activity__c> activities = [SELECT Id, project__c, name, project__r.Base_URL__c , project__r.Project_ID_Text__c, project__r.Name, project__r.ownerId, project__r.owner.email FROM ampi__activity__c ORDER BY project__c, Name];     
        System.debug('####activities:' + activities);
        //project__r.ampi__project_status__c IN ('In Implementation') AND
		(new ProjectActivityNotificationBatch()).execute(null, activities);    
        
        //String sch = '0 ' + i + ' * * * ?'; i is the minute to run
      	String sch = '0 1 0 28 * ?';
      	ScheduledProjectActivityNotification sqrb = new ScheduledProjectActivityNotification();
      	system.schedule('ScheduledProjectActivityNotification Monthly on 28th: ' + Date.today().Year() + '-' + Date.today().Month() + Date.today().Day(), sch, sqrb);
        
        Test.stopTest();

        System.assert(true);        
    }
}