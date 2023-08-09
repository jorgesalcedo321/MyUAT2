@isTest
private class ScheduledDeletingD365Test {
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
            proj.Programme_Location__c = gaProgramme2.Id;
        }
        UPDATE projects;
        
        List<D365_Project_Stand_in__c> projectd365s = [select id, unique_field__c  from D365_Project_Stand_in__c WHERE Project__c =: projectTransition.Id];
        System.debug('###projectd365s: ' + projectd365s);
        
        Test.startTest();
		(new ScheduledDeletingD365ProgrammeProject()).execute(null);        
        DeletingD365ProgrammeProjectBatch dppb = new DeletingD365ProgrammeProjectBatch();
        dppb.execute(null, projectd365s);        
        DataBase.executeBatch(dppb); 
        Test.stopTest();

        System.assert(true);        
    }
}