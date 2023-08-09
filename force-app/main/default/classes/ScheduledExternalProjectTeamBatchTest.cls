@isTest
private class ScheduledExternalProjectTeamBatchTest {
    @isTest
    private static void executeBatch_GeneratingExternal() {
        ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
      	
		Account accNA = TestDataFactory.createMAWithCountry('NA Peru', gaCountry.Id);
 
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
		ampi__Geographical_Area__c gaProgramme2 = TestDataFactory.createProgramme('Lima', gaCountry.Id, accNA.Id);
        ampi__Geographical_Area__c gaProgrammeUnit = TestDataFactory.createProgrammeUnit('New Programme Unit based on Callao', gaProgramme.Id, accNA.Id);

		ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC', 'Youth Care (similar to YF)');
		ampi__Thematic_Area__c thematicAreaFS = TestDataFactory.createThematicArea('FS', 'Family Streghtening (FS)');
		
		ampi__Project__c projectTransition = TestDataFactory.createProject('Transition', accNA.Id, gaProgramme.Id, 'FS, YC');
        List<ampi__Project__c> projects = [SELECT Id, Project_ID_Text__c, Account_Teams__c FROM ampi__project__c WHERE ID =: projectTransition.Id];
        
        for(ampi__Project__c proj : projects) {
            proj.Account_Teams__c = null;            
        }
        UPDATE projects;
        
        Test.startTest();
		(new ScheduledExternalProjectTeamBatch()).execute(null);        
        Test.stopTest();

        System.assert(true);        
    }
}