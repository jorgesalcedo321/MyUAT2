@isTest
private class ProjectGeographicArea_AfterUpdate_Test  {

	@isTest static void ProjectGeographicAreaTest(){
		Account accNA = new Account();
		accNA.Name = 'NA Malawi';
		accNA.Type = 'NA';
		accNA.RecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('SOS Organisation - MA').getRecordTypeId();
		insert accNA;

		ampi__Geographical_Area__c gaRegion = new ampi__Geographical_Area__c();
		gaRegion.Name = 'ESAF';
		gaRegion.Long_Name__c = 'Eastern and Southern Africa';
		gaRegion.Code__c = '110';
		gaRegion.RecordTypeId = ampi__Geographical_Area__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Region').getRecordTypeId();
		insert gaRegion;

		ampi__Geographical_Area__c gaCountry = new ampi__Geographical_Area__c();
		gaCountry.Name = 'Malawi';
		gaCountry.ampi__Parent_Geographical_Area__c = gaRegion.Id;
		gaCountry.Continent__c = 'Africa';
		gaCountry.Code__c = 'MWI';
		gaCountry.RecordTypeId = ampi__Geographical_Area__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Country').getRecordTypeId();
		insert gaCountry;

		ampi__Geographical_Area__c gaProgramme = new ampi__Geographical_Area__c();
		gaProgramme.Name = 'Mzuzu';
		gaProgramme.ampi__Parent_Geographical_Area__c = gaCountry.Id;
		gaProgramme.ampi__Type__c = 'Programme';
		gaProgramme.Active__c = 'Yes';
		gaProgramme.Code__c = 'SUM-LOC-00000064';
		gaProgramme.RecordTypeId = ampi__Geographical_Area__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Programme').getRecordTypeId();
		gaProgramme.Parent_MA__c = accNA.Id;
		insert gaProgramme;

		ampi__Thematic_Area__c thematicArea = new ampi__Thematic_Area__c();
		thematicArea.Name = 'YC';
		thematicArea.ampi__Description__c = 'Youth Care (similar to YF)';
		insert thematicArea;

		ampi__Project__c pProgramme = new ampi__Project__c();
		pProgramme.Name = 'Mzuzu-Programme';
		pProgramme.SOS_Implementing_Organisation__c = accNA.Id;
		pProgramme.P_PU__c = gaProgramme.Id;
		pProgramme.RecordTypeId = ampi__Project__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Shadow Project').getRecordTypeId();
		insert pProgramme;

		ampi__Indicator__c indicator = new ampi__Indicator__c();
		indicator.ampi__Description__c = '183D Beneficiaries 0-17 Siblings';
		indicator.ampi__Data_Type__c = 'Number';
		indicator.ampi__Type_of_Results__c = 'Input';
		indicator.Category__c = 'Mandatory';
		indicator.Level__c = 'Children & Young People';
		indicator.ampi__Guideline__c = 'SKF';
		indicator.ampi__Active__c = true;
		indicator.Source_Document__c = 'Statistics Handbook Version Nov 2017';
		indicator.Source_of_Indicator__c = 'Other';
		indicator.Strategic_Measure__c = 'No';
		indicator.Care_Promise_Indicator__c = 'No';
		indicator.ampi__Reporting_Frequency__c = 'Monthly';
		indicator.ampi__Target_Frequency__c = 'Yearly';
		indicator.ampi__Include_In_Catalog__c = true;
		indicator.ampi__Geographical_Disaggregation__c = 'Programme Unit';
		indicator.ampi__Calculate_Total__c = 'Sum Total';
		indicator.ampi__Thematic_Area_Icon__c = 'FS';
		indicator.ampi__Thematic_Area_Ids__c = String.valueOf(thematicArea.Id);
		indicator.ampi__Thematic_Area_Text__c = '#FS';
		insert indicator;

		ampi__Project_Indicator__c pIndicator = new ampi__Project_Indicator__c();
		pIndicator.ampi__Description__c = '183D Beneficiaries 0-17 Siblings';
		pIndicator.ampi__Active__c = true;
		pIndicator.ampi__Project__c = pProgramme.Id;
		pIndicator.ampi__Catalog_Indicator__c = indicator.Id;
		pIndicator.ampi__Reporting_Frequency__c = 'Monthly';
		pIndicator.ampi__Target_Frequency__c = 'Yearly';
		pIndicator.ampi__Type_of_Results__c = 'Input';
		pIndicator.ampi__Guideline__c = 'SKF';
		pIndicator.ampi__Geographical_Disaggregation__c = 'Programme Unit';
		insert pIndicator;

		ampi__Indicator__c indicator2 = new ampi__Indicator__c();
		indicator2.ampi__Description__c = '183D Beneficiaries 0-17 Siblings';
		indicator2.ampi__Data_Type__c = 'Number';
		indicator2.ampi__Type_of_Results__c = 'Input';
		indicator2.Category__c = 'Mandatory';
		indicator2.Level__c = 'Children & Young People';
		indicator2.ampi__Guideline__c = 'SKF';
		indicator2.ampi__Active__c = true;
		indicator2.Source_Document__c = 'Statistics Handbook Version Nov 2017';
		indicator2.Source_of_Indicator__c = 'Other';
		indicator2.Strategic_Measure__c = 'No';
		indicator2.Care_Promise_Indicator__c = 'No';
		indicator2.ampi__Reporting_Frequency__c = 'Monthly';
		indicator2.ampi__Target_Frequency__c = 'Annual';
		indicator2.ampi__Include_In_Catalog__c = true;
		indicator2.ampi__Geographical_Disaggregation__c = 'Programme Unit';
		indicator2.ampi__Calculate_Total__c = 'Sum Total';
		indicator2.ampi__Thematic_Area_Icon__c = 'FS';
		indicator2.ampi__Thematic_Area_Ids__c = String.valueOf(thematicArea.Id);
		indicator2.ampi__Thematic_Area_Text__c = '#FS';
		insert indicator2;

		ampi__Project_Indicator__c pIndicator2 = new ampi__Project_Indicator__c();
		pIndicator2.ampi__Description__c = '183D Beneficiaries 0-17 Siblings';
		pIndicator2.ampi__Active__c = true;
		pIndicator2.ampi__Project__c = pProgramme.Id;
		pIndicator2.ampi__Catalog_Indicator__c = indicator2.Id;
		pIndicator2.ampi__Reporting_Frequency__c = 'Monthly';
		pIndicator2.ampi__Target_Frequency__c = 'Yearly';
		pIndicator2.ampi__Type_of_Results__c = 'Input';
		pIndicator2.ampi__Guideline__c = 'SKF';
		pIndicator2.ampi__Geographical_Disaggregation__c = 'Programme Unit';
		insert pIndicator2;

		ampi__Indicator_Thematic_Area__c ITA = new ampi__Indicator_Thematic_Area__c();
		ITA.ampi__Indicator__c = indicator.Id;
		ITA.ampi__Thematic_Area__c = thematicArea.Id;
		ITA.ampi__Required__c = true;
		insert ITA;	

		ampi__Geographical_Area__c gaOrganisationalUnit = new ampi__Geographical_Area__c();
		gaOrganisationalUnit.Name = 'YC Tel Aviv';
		gaOrganisationalUnit.Long_Name__c = 'R0016023 YC Tel Aviv';
		gaOrganisationalUnit.ampi__Parent_Geographical_Area__c = gaProgramme.Id;
		gaOrganisationalUnit.ampi__Type__c = 'Programme Unit';
		gaOrganisationalUnit.Active__c = 'Yes';
		gaOrganisationalUnit.Program_Unit_Type__c = 'YC-Youth Care-140';
		gaOrganisationalUnit.RecordTypeId = ampi__Geographical_Area__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Organisational Unit').getRecordTypeId();
		gaOrganisationalUnit.SOS_Role__c = 'SOS Is Main Implementer';
		gaOrganisationalUnit.Code__c = 'R0016023';
		gaOrganisationalUnit.Systems_Status_ID__c = 'Released';
		gaOrganisationalUnit.Thematic_Area__c = thematicArea.Id;
		insert gaOrganisationalUnit;		
		
		ampi__Project_Geographic_Area__c pga = new ampi__Project_Geographic_Area__c();
		pga.ampi__Geographic_Area__c = gaOrganisationalUnit.Id;
		pga.ampi__Project__c = pProgramme.Id;
		insert pga;

		List<ampi__Project_Indicator_Geographic_Area__c> lPIGAs = new List<ampi__Project_Indicator_Geographic_Area__c>();
		ampi__Project_Indicator_Geographic_Area__c PIGA1 = new ampi__Project_Indicator_Geographic_Area__c();
		PIGA1.ampi__Project_Indicator__c = pIndicator.Id;
		PIGA1.ampi__Geographic_Area__c = gaOrganisationalUnit.Id;
		lPIGAs.add(PIGA1);

		ampi__Project_Indicator_Geographic_Area__c PIGA2 = new ampi__Project_Indicator_Geographic_Area__c();
		PIGA2.ampi__Project_Indicator__c = pIndicator2.Id;
		PIGA2.ampi__Geographic_Area__c = gaOrganisationalUnit.Id;
		lPIGAs.add(PIGA2);

		insert lPIGAs;

		Test.startTest();
		List<ampi__Project_Indicator_Geographic_Area__c> PIGAs = [SELECT Id, ampi__Geographic_Area__c, ampi__Project_Indicator__r.ampi__Catalog_Indicator__c FROM ampi__Project_Indicator_Geographic_Area__c];
		System.assertEquals(2, PIGAs.size());

		pga.Delete_PIGAs__c = true;
		update pga;

		List<ampi__Project_Indicator_Geographic_Area__c> PIGAsAfter = [SELECT Id, ampi__Geographic_Area__c, ampi__Project_Indicator__r.ampi__Catalog_Indicator__c FROM ampi__Project_Indicator_Geographic_Area__c];
		//TODO: Commented for deactivation of trigger: 
		System.assertEquals(1, PIGAsAfter.size());
		//System.assert(true);
		Test.stopTest();
	}

	@isTest 
	static void ProjectGeographicArea_InsertTest(){
		Account accNA = TestDataFactory.createMA('NA Peru');
		ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);
		ampi__Geographical_Area__c gaProgramme2 = TestDataFactory.createProgramme('Lima', gaCountry.Id, accNA.Id);
		ampi__Geographical_Area__c gaProgrammeUnit = TestDataFactory.createProgrammeUnit('Lima Este', gaProgramme2.Id, accNA.Id);
		
		ampi__Project__c projectTransition = TestDataFactory.createProjectByStatus('Transition', accNA.Id, '', '', 'Construction');

		List<ampi__Budget__c> budgetsBefore = [SELECT Id FROM ampi__Budget__c WHERE ampi__Project__c =: projectTransition.Id];
		
		ampi__Project_Geographic_Area__c pga = new ampi__Project_Geographic_Area__c();
		pga.ampi__Project__c = projectTransition.Id;
		pga.ampi__Geographic_Area__c = gaProgrammeUnit.Id;
		INSERT pga; 

		List<ampi__Budget__c> budgetsAfter = [SELECT Id FROM ampi__Budget__c WHERE ampi__Project__c =: projectTransition.Id];
		
		//TODO: Commented for deactivation of trigger: 
		System.assert(budgetsBefore.size() < budgetsAfter.size());
		//System.assert(true);
	}

}