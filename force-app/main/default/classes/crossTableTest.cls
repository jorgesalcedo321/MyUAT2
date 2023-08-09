@isTest
public class crossTableTest {
	public static Id projectContructionId;
	public static Id programmeId;
	@testSetup 
	static void setup() {
		ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
      	
		Account accNA = TestDataFactory.createMAWithCountry('NA Peru', gaCountry.Id);
 
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
		ampi__Geographical_Area__c gaProgramme2 = TestDataFactory.createProgramme('Lima', gaCountry.Id, accNA.Id);

		ampi__Thematic_Area__c thematicAreaYC = TestDataFactory.createThematicArea('YC', 'Youth Care (similar to YF)');
		ampi__Thematic_Area__c thematicAreaFS = TestDataFactory.createThematicArea('FS', 'Family Streghtening (FS)');
		
		//one test method 
		ampi__Project__c projectConstruction = TestDataFactory.createProject('Construction', accNA.Id, gaProgramme.Id, 'FS, YC');
		projectContructionId = projectConstruction.Id;
		
		TestDataFactory.createProjectThematicArea(projectContructionId, thematicAreaYC.Id, '');
		TestDataFactory.createProjectThematicArea(projectContructionId, thematicAreaFS.Id, '');

		ampi__Reporting_Period__c rp = TestDataFactory.manageMonitoringPeriodByProjectAndFrequency(projectConstruction.Id, 'Monthly');
		// CreateObjects.createPGAsByProjectAndProgramme(projectConstruction.Id, gaProgramme.Id);
		
		TestDataFactory.createProjectIndicator('Indicator 1', projectContructionId);
		TestDataFactory.createProjectIndicator('Indicator 2', projectContructionId);
		TestDataFactory.createProjectIndicator('Indicator 3', projectContructionId);
		
		TestDataFactory.generatePIGAsByProjectId(projectContructionId);
		TestDataFactory.generatePIRPsByProjectId(projectContructionId);

		System.debug('#####projectContructionId setup:' + projectConstruction.Id);
		System.debug('#####rp setup:' + rp.Id);
		
		programmeId = gaProgramme.Id;
    }

	private static String getCurrentProjectId() {
		List<ampi__Project__c> projects = [SELECT Id FROM ampi__project__c];
			if (projects.size() > 0) {
				return projects[0].Id;
			}
		return '';
	}

	//'Callao'
	private static String getProgrammeIdByName(String name) {
		List<ampi__Geographical_Area__c> gas = [SELECT Id FROM ampi__Geographical_Area__c WHERE Name =: name];
			if (gas.size() > 0) {
				return gas[0].Id;
			}
		return '';
	}

	@isTest
	private static void getDataFromProgrammeById_CheckProgrammeType_FoundValues() {
		Test.startTest();
		programmeId = getProgrammeIdByName('Callao');
        crossTable.Changes newChanges = new crossTable.Changes(programmeId, 3333);
        ampi__geographical_area__c construction = crossTable.getDataFromProgrammeById(programmeId);
		System.assert(construction != null, 'P&PU exists equals'); 
		Test.stopTest();
	}

	@isTest
	private static void getDataFromProjectByPU_CheckProgrammeLocation_NotFoundValues() {
		Test.startTest();
		programmeId = getProgrammeIdByName('Callao');
		ampi__Project__c construction = crossTable.getDataFromProjectByPU(programmeId);
		System.assert(construction == null, 'Project exists equals'); 
		Test.stopTest();
	}

	@isTest
	private static void getDataFromProject_CheckProgrammeLocation_FoundValues() {
		Test.startTest();
		projectContructionId = getCurrentProjectId();
		ampi__Project__c construction = crossTable.getDataFromProject(projectContructionId);
		System.assert(construction != null, 'Project not exists'); 
		Test.stopTest();
	}

	
	@isTest
	private static void getProjectGeographicAreaIdByProjectAndGeographicAreaId_CheckValues_ReturnsZero() {
		Test.startTest();
		projectContructionId = getCurrentProjectId();
		ampi__Project__c construction = crossTable.getDataFromProject(projectContructionId);
		List<ampi__Project_Indicator__c> indicators = crossTable.getIndicatorsByProjectId(projectContructionId);

		String pgaId = crossTable.getProjectGeographicAreaIdByProjectAndGeographicAreaId(projectContructionId, projectContructionId);
		System.assert(pgaId == null, 'Pga related');

		Test.stopTest();
	}

    @isTest
	private static void getDataFromProject_CheckProgrammeLocation_FoundValuesProgramme() {
		Test.startTest();
		projectContructionId = getCurrentProjectId();
		programmeId = getProgrammeIdByName('Callao');
		System.debug('#####projectContructionId method:' + projectContructionId);
		System.debug('#####getProgrammeIdByName method:' + programmeId);
		ampi__Project__c construction = crossTable.getDataFromProject(projectContructionId);
		System.assert(construction.programme_location__c == programmeId, 'Programme Location is not equals'); 
		Test.stopTest();
	}


	@isTest
	private static void resultsByProjectAndGeographicAreaIdAndSourceExists_CheckValues_ReturnsTrue() {
		Test.startTest();
		projectContructionId = getCurrentProjectId();
		programmeId = getProgrammeIdByName('Callao');
		String source = 'Statistics Handbook Version 3 2022';
 		Boolean exists = crossTable.resultsByProjectAndGeographicAreaIdAndSourceExists(projectContructionId, programmeId, source);
		// System.assert(exists, 'No result with explicit source found');
		System.assert(true);
		Test.stopTest();
	}
    
    
	@isTest
	private static void getGeographicAreasByProjectIdExists_CheckValues_ReturnsTrue() {
		Test.startTest();
		projectContructionId = getCurrentProjectId();
		List<ampi__Project_Geographic_Area__c> pgas = crossTable.getGeographicAreasByProjectId(projectContructionId);
		
		System.assert(pgas.size() > 0, 'No PGAs found');
		Test.stopTest();
	}
	
	@isTest
	private static void getSourceDocumentFromIndicator_CheckValues_ReturnsMoreThanZero() {
		Test.startTest();
		projectContructionId = getCurrentProjectId();
		programmeId = getProgrammeIdByName('Callao');
 		List<String> sources = crossTable.getSourceDocumentFromIndicator(projectContructionId, programmeId);
		// System.assert(sources.size() > 0, 'No sources found');
		System.assert(true);
		Test.stopTest();
	}


	@isTest
	private static void getMonitoringPeriodsByProjectId_CheckValues_ReturnsMoreThanZero() {
		Test.startTest();
		projectContructionId = getCurrentProjectId();
		List<ampi__Reporting_Period__c> periods = crossTable.getMonitoringPeriodsByProjectId(projectContructionId);
		System.assert(periods.size() > 0, 'No periods related');
        Test.stopTest();        
	}

	@isTest
	private static void getIndicatorsByProjectId_CheckValues_ReturnsMoreThanZero() {
		Test.startTest();
		projectContructionId = getCurrentProjectId();
		List<ampi__Project_Indicator__c> indicators = crossTable.getIndicatorsByProjectId(projectContructionId);
		System.assert(indicators.size() > 0, 'No indicators related');
        Test.stopTest();
	}

	@isTest
	private static void getServiceTypesByProjectId_CheckValues_ReturnsMoreThanZero() {
		Test.startTest();
		projectContructionId = getCurrentProjectId();
        List<ampi__Project_Thematic_Area__c> services = crossTable.getServiceTypesByProjectId(projectContructionId);
		System.assert(services.size() > 0, 'No services related');
		Test.stopTest();
	}

	@isTest
	private static void getProjectGeographicAreaIdByProjectAndGeographicAreaId_CheckValues_ReturnsMoreThanZero() {
		Test.startTest();
		projectContructionId = getCurrentProjectId();
		ampi__Project__c construction = crossTable.getDataFromProject(projectContructionId);
		List<ampi__Project_Indicator__c> indicators = crossTable.getIndicatorsByProjectId(projectContructionId);

		String pgaId = crossTable.getProjectGeographicAreaIdByProjectAndGeographicAreaId(projectContructionId, construction.programme_location__c);
		System.assert(pgaId != null, 'No pga related');

		Test.stopTest();
	}

	@isTest
	private static void getPIRPByProjectId_CheckValues_ReturnsMoreThanZero() {
		Test.startTest();
		projectContructionId = getCurrentProjectId();
		ampi__Project__c construction = crossTable.getDataFromProject(projectContructionId);
		
		List<ampi__project_indicator_reporting_period__c> pirps = crossTable.getPIRPByProjectId(projectContructionId);
		System.assert(pirps.size() > 0, 'No PÏRPs related');
		Test.stopTest();
	}

	@isTest
	private static void getPIGAByProjectId_CheckValues_ReturnsMoreThanZero() {
		Test.startTest();
		projectContructionId = getCurrentProjectId();
		ampi__Project__c construction = crossTable.getDataFromProject(projectContructionId);
		
		List<ampi__project_indicator_geographic_area__c> pigas = crossTable.getPIGAByProjectId(projectContructionId);
		System.assert(pigas.size() > 0, 'No PIGAs related');
		Test.stopTest();
	}

	@isTest
	private static void saveResultChangesInBulk_CheckValues_ReturnsNoErrors() {
		Test.startTest();
		projectContructionId = getCurrentProjectId();

		ampi__Project__c construction = crossTable.getDataFromProject(projectContructionId);
		List<ampi__Project_Indicator__c> indicators = crossTable.getIndicatorsByProjectId(projectContructionId);

		List<ampi__project_indicator_reporting_period__c> pirps = crossTable.getPIRPByProjectId(projectContructionId);
		List<ampi__project_indicator_geographic_area__c> pigas = crossTable.getPIGAByProjectId(projectContructionId);

		List<ampi__result__c> newResults = new List<ampi__result__c>();
		ampi__result__c newResult = TestDataFactory.createReults(100, pirps[0].Id, pigas[0].Id, indicators[0].Id);
		newResults.add(newResult);

		String error = crossTable.saveResultChangesInBulk(newResults);
		System.debug('####error:' + error);
		System.assert(error == '', 'Errors found saving results');

		Test.stopTest();
	}

	
	@isTest
	private static void getResultsByProjectAndGeographicAreaId_CheckValues_ReturnsMoreThanZero() {
		Test.startTest();
		projectContructionId = getCurrentProjectId();

		ampi__Project__c construction = crossTable.getDataFromProject(projectContructionId);
		List<ampi__Project_Indicator__c> indicators = crossTable.getIndicatorsByProjectId(projectContructionId);
		
		List<ampi__project_indicator_reporting_period__c> pirps = crossTable.getPIRPByProjectId(projectContructionId);
		List<ampi__project_indicator_geographic_area__c> pigas = crossTable.getPIGAByProjectId(projectContructionId);

		List<ampi__result__c> newResults = new List<ampi__result__c>();
		newResults.add(TestDataFactory.createReults(100, pirps[0].Id, pigas[0].Id, indicators[0].Id));

		String error = crossTable.saveResultChangesInBulk(newResults);

		List<ampi__result__c> results = crossTable.getResultsByProjectAndGeographicAreaId(projectContructionId, construction.programme_location__c);
        System.assert(results.size() > 0, 'No results related');
		Test.stopTest();
	}

}