@isTest
private  class createPGAProgrammeTest {
    @isTest
    private static void createPGAProgrammeTest_CreatingProgramme() {
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
		List<Id> newProjectIds = new List<Id>();
        newProjectIds.add(projectStandard.Id);

        List<ampi__Project_Geographic_Area__c> pgas1 = [SELECT Id, ampi__geographic_area__c, ampi__Active__c FROM ampi__Project_Geographic_Area__c WHERE ampi__Project__c IN :newProjectIds];
        System.debug('####pgas 1: ' + pgas1);
        
        projectStandard.Programme_Location__c = gaProgramme2.Id;
        UPDATE projectStandard;
        
        //createPGAProgramme.createPGAProgramme(newProjectIds);   

        List<ampi__Project_Geographic_Area__c> pgas2 = [SELECT Id, ampi__geographic_area__c, ampi__Active__c FROM ampi__Project_Geographic_Area__c WHERE ampi__Project__c IN :newProjectIds];
        System.debug('####pgas 2: ' + pgas2);
        System.assert(pgas2.size() >= 2);
        
        projectStandard.Programme_Location__c = gaProgramme.Id;
        UPDATE projectStandard;
        
        List<ampi__Project_Geographic_Area__c> pgas3 = [SELECT Id, ampi__geographic_area__c, ampi__Active__c FROM ampi__Project_Geographic_Area__c WHERE ampi__Project__c IN :newProjectIds];
        System.debug('####pgas 3: ' + pgas3);
        System.assert(pgas3.size() >= 2);
        
        //createPGAProgramme.createPGAProgramme(newProjectIds);
        Test.stopTest();                
    }
}