@isTest
private  class createPGACountry_GrantProjectTest {
    @isTest
    private static void createPGACountry_GrantProjectTest_CreatingCountry() {
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
		ampi__Project__c projectStandard = TestDataFactory.createProject('Grant', accNA.Id, gaProgramme.Id, 'FS, YC');
		List<Id> newProjectIds = new List<Id>();
        newProjectIds.add(projectStandard.Id);

        List<ampi__Project__c> projects = [SELECT SOS_Implementing_Organisation__r.Country__c FROM ampi__Project__c WHERE Id IN: (newProjectIds)];

        if (projects.size() > 0) {
            System.debug('####SOS_Implementing_Organisation__r.Country__c: ' + projects[0].SOS_Implementing_Organisation__r.Country__c);
        }
        
        createPGACountry_GrantProject.createPGACountry_GrantProject(newProjectIds);        
        Test.stopTest();                
    }
}