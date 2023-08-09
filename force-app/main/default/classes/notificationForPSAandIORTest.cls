@isTest
private class notificationForPSAandIORTest {
    @isTest
    private static void createTeammemberProject_CreatingACR() {
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
		projectStandard.Approval_Process_Actions__c = 'Create Agreement Draft';
        UPDATE projectStandard;
        
        Deliverable__c newDel = new Deliverable__c();
        newDel.Name = 'Partnership agreement';
        newDel.Type__c = 'Agreement';
        newDel.project__c = projectStandard.Id;
        INSERT newDel; 
            
        List<notificationForPSAandIOR.FlowInputs> requests = new List<notificationForPSAandIOR.FlowInputs>();
        notificationForPSAandIOR.FlowInputs request = new notificationForPSAandIOR.FlowInputs();
        request.projectId = projectStandard.Id;
        requests.add(request);
	
        notificationForPSAandIOR.notificationForPSAandIOR_ForStandardProject(requests);
        
        Test.stopTest();                
    }
}