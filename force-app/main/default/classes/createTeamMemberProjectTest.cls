@isTest
private class createTeamMemberProjectTest {
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
		
        List<createTeamMemberProject.FlowInputs> requests = new List<createTeamMemberProject.FlowInputs>();
        createTeamMemberProject.FlowInputs request = new createTeamMemberProject.FlowInputs();
        request.projectId = projectStandard.Id;
        request.userId = UserInfo.getUserId();
        request.role = 'Project Contributor';
        requests.add(request);
	
        createTeamMemberProject.createTeammember_Project(requests);
        
        String accountId = '';
        String contactId = '';
		List<User> contacts = [SELECT Id, Firstname, ContactId, Contact.AccountId FROM User WHERE Id =: request.userId];         
        
        System.assert(contacts.size() > 0);

        if (contacts.size() > 0) {
            contactId = contacts[0].Id;
            accountId = contacts[0].Contact.AccountId;            
        }
        
        ampi__project__c project = [SELECT Id, Account_Teams__c FROM ampi__project__c WHERE Id =: projectStandard.Id LIMIT 1];            
        List<AccountContactRelation> acrs = [SELECT AccountId, ContactId, IsActive FROM AccountContactRelation WHERE ContactId =: contactId AND AccountId =: project.Account_Teams__c];
        
        System.debug('####CTMP Test contacts:' + contacts);
        System.debug('####CTMP Test acrs:' + acrs);
        System.debug('###CTMP Test: contactId:' + contactId);
        System.debug('###CTMP Test: project.Account_Teams__c:' + project.Account_Teams__c);
        for(AccountContactRelation acr : acrs) {
            acr.IsActive = false;
        }
        UPDATE acrs;
        
        createTeamMemberProject.createTeammember_Project(requests);
        
        //System.debug('###acrs: contacts:' + contacts);
		//System.debug('###acrs: contactId:' + contactId);
        //System.debug('###acrs: accountId:' + accountId);
        //List<AccountContactRelation> acrs = [SELECT ID FROM AccountContactRelation WHERE ContactId =: contactId AND AccountId =: accountId];
        //System.assert(acrs.size() > 0);
        
        Test.stopTest();                
    }
}