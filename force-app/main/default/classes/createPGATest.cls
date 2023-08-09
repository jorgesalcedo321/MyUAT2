@isTest
private  class createPGATest {
    @isTest
    private static void createPGATest_CreatingPGA() {
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
		
        List<createPGA.FlowInputs> requests = new List<createPGA.FlowInputs>();
        createPGA.FlowInputs request = new createPGA.FlowInputs();
        request.projectId = projectStandard.Id;
        request.programmeId = gaProgramme2.Id;
        requests.add(request);

        createPGA.createProgramme_PGA(requests);

        ampi__project_geographic_area__c inactivatePGA = [SELECT Id, ampi__Active__c FROM ampi__project_geographic_area__c WHERE ampi__Geographic_Area__c =: gaProgramme.Id AND ampi__project__c =: projectStandard.Id LIMIT 1];
        inactivatePGA.ampi__Active__c = false;
        UPDATE inactivatePGA;

        List<ampi__project_geographic_area__c> checkPGAs = [SELECT Id, ampi__Geographic_Area__r.Name, ampi__Active__c FROM ampi__project_geographic_area__c WHERE ampi__project__c =: projectStandard.Id];
        
        System.debug('$$$$$ PGAS: ' + checkPGAs);
        System.assert(checkPGAs.size() > 0);

        requests = new List<createPGA.FlowInputs>();
        request = new createPGA.FlowInputs();
        request.projectId = projectStandard.Id;
        request.programmeId = gaProgramme.Id;
        requests.add(request);

        createPGA.createProgramme_PGA(requests);

        List<ampi__project_geographic_area__c> checkPGA2Attempt = [SELECT Id, ampi__Geographic_Area__r.Name, ampi__Active__c FROM ampi__project_geographic_area__c WHERE ampi__project__c =: projectStandard.Id];

        System.debug('$$$$$ PGAS checkPGA2Attempt: ' + checkPGA2Attempt);
        System.assert(checkPGAs.size() == checkPGA2Attempt.size());

                
        Test.stopTest();                
    }
}