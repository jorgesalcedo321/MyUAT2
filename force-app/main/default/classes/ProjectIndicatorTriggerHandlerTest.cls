@isTest
public class ProjectIndicatorTriggerHandlerTest {
    @isTest 
    static void afterInsertProjectIndicators_SetTypeResultAggregated_ReturnsProjectIndicatorsAggregated() {
        ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
      	
		Account accNA = TestDataFactory.createMAWithCountry('NA Peru', gaCountry.Id);
 		accNA.Is_PDB_In_Use__c = 'Yes';
        UPDATE accNA;
            
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
		ampi__Geographical_Area__c gaProgramme2 = TestDataFactory.createProgramme('Lima', gaCountry.Id, accNA.Id);

		ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC', 'Youth Care (similar to YF)');
		ampi__Thematic_Area__c thematicAreaFS = TestDataFactory.createThematicArea('FS', 'Family Streghtening (FS)');
		
		//one test method 
		ampi__Project__c projectStandard = TestDataFactory.createProject('Standard', accNA.Id, gaProgramme.Id, 'FS, YC');
		ampi__Project_Indicator__c pi =  TestDataFactory.createProjectIndicator('indicatorName Test', projectStandard.Id, 'Statistics Handbook V3');

        Test.startTest();
        List<ampi__project_indicator__c> pis = [SELECT Id, ampi__Type_of_Results__c FROM ampi__project_indicator__c WHERE ampi__Catalog_Indicator__r.Source_Document__c = 'Statistics Handbook V3' AND ampi__Catalog_Indicator__r.Level__c <> 'Staff' AND ampi__Type_of_Results__c = 'Aggregated'];
        System.assert(pis.size() > 0);

        Test.stopTest();
	}
}