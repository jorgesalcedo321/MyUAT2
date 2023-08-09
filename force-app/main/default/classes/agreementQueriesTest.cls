@isTest
public class agreementQueriesTest {
    @isTest
	private static void getAgreementFromProjectId_CheckAgreement_IsNotNull() {
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
        Set<Id> projIds = new Set<Id>();
        projIds.add(projectStandard.Id);
        Deliverable__c a1 = agreementQueries.getAgreementFromProjectId(projectStandard.Id);
        List<Deliverable__c> a2 = agreementQueries.getAgreementsFromProjects(projIds);
        boolean a3 = agreementQueries.existsAgreementFromProject(new List<Deliverable__c>(), projectStandard.Id);

        System.Assert(a1 == null);
        System.Assert(a2.size() == 0);
        System.Assert(a3 == false);
    } 
}