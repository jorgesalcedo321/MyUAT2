@isTest 
private class RiskControllerTest {

    @isTest
	private static void RiskControllerTest_checkIfUserCanManage_Project_ReturnTrue() {
		//Name
		User u = TestDataFactory.CreateUserFromSystemAdmin();
		System.runAs(u) {
			boolean result = RiskController.checkIfUserCanEditObject('ampi__Project__c');
			System.assertEquals(result, true); 
		}

		u = TestDataFactory.CreateUserFromSystemAdmin();
		System.runAs(u) {
			boolean result = RiskController.checkIfUserCanDeleteObject('ampi__Project__c');
			System.assertEquals(result, true); 
		}
        
        u = TestDataFactory.CreateUserFromSystemAdmin();
		System.runAs(u) {
			boolean result = RiskController.checkIfUserCanCreateObject('ampi__Project__c');
			System.assertEquals(result, true); 
		}
        
        u = TestDataFactory.CreateUserFromSystemAdmin();
		System.runAs(u) {
			boolean result = RiskController.checkIfUserCanAccessObject('ampi__Project__c');
			System.assertEquals(result, true); 
		}
	}
    
	@isTest
	private static void RiskControllerTest_checkIfUserCanEditDatafield_ProjectName_ReturnFalse() {
		//Name
		User u = TestDataFactory.CreateUserFromSystemAdmin();
		System.runAs(u) {
			boolean result = RiskController.checkIfUserCanEditDatafield('ampi__Project__c','Name');
			System.assertEquals(result, true); 
		}

		u = TestDataFactory.CreateUserFromReadOnly();
		System.runAs(u) {
			boolean result = RiskController.checkIfUserCanEditDatafield('ampi__Project__c','Name');
			System.assertEquals(result, false); 
		}
	}

	@isTest
	private static void RiskControllerTest_getPickListValuesFromDatafield_ProjectPriority_ReturnListWithValues() {
		//Priority__c
		List<String> values = RiskController.getPickListValuesFromDatafield('ampi__Project__c', 'Priority__c');
		System.assert(values.size() > 0);
	}

	@isTest
	private static void RiskControllerTest_getLabelFromDatafield_Project_ApprovalStatus_ReturnApprovalStatus() {
		//Approval_Status__c
		string value = RiskController.getLabelFromDatafield('ampi__Project__c', 'Approval_Status__c');
		//System.debug(K'####Approval_Status__c:' + Approval_Status__c);
		System.assertEquals(true, String.isNotBlank(value) && value <> 'Approval_Status__c');
	}

	@isTest
	private static void RiskControllerTest_getHelpTextFromDatafield_Project_Actuals_Total_Project_Expenditures_LC_ReturnValue() {
		//Actuals_Total_Project_Expenditures_LC
		string value = RiskController.getHelpTextFromDatafield('ampi__Project__c', 'Actuals_Total_Project_Expenditures_LC__c');
		System.assertEquals(true, String.isNotBlank(value));
	}

	
	@isTest
	private static void RiskControllerTest_isSOSOrganisationMA_NAPeru_ReturnTrueValue() {
		//Actuals_Total_Project_Expenditures_LC
		Account newOrg = TestDataFactory.createOrganisationWithRecordType('SOS Organisation - MA');
		Boolean value = RiskController.isSOSOrganisationMA('Account', newOrg.Id);
		System.assertEquals(true, value);


		Account newOrgFailed = TestDataFactory.createOrganisationWithRecordType('Organization');
		Boolean valueFailed = RiskController.isSOSOrganisationMA('Account', newOrgFailed.Id);
		System.assertEquals(false, valueFailed);

		
	}

    
    @isTest
	private static void RiskControllerTest_AddAddressSOSOrganisationMA_NAPeru_ReturnsTrue() {
		//Actuals_Total_Project_Expenditures_LC
		ampi__Geographical_Area__c gaRegion = TestDataFactory.createRegion('LAAM');
		ampi__Geographical_Area__c gaCountry = TestDataFactory.createCountry('Peru', gaRegion.Id);
      	
		Account accNA = TestDataFactory.createMAWithCountry('NA Peru', gaCountry.Id);
 		ampi__Geographical_Area__c gaProgramme = TestDataFactory.createProgramme('Callao', gaCountry.Id, accNA.Id);

		Account accLE = new Account();
        accLE.Name = 'Legal Entity Test';
        accLE.Type = 'NA';
        accLE.RecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
		INSERT accLE;

        Address__c addrMA = TestDataFactory.createAddress(accNA.Id, gaCountry.Id, accLE.Id);
        Address__c addrPro = TestDataFactory.createAddress(accNA.Id, gaCountry.Id, accLE.Id);
        
        RiskController.updateCorrespondanceAddressFromPU(gaProgramme.Id, 'Yes'); 
        RiskController.updateAddressFromOrganisation(accNA.Id, addrMa.Id);
        RiskController.updateAddressFromPUs(gaProgramme.Id, addrPro.Id, true);
            
        ampi__geographical_area__c ga = RiskController.getCorrespondanceAddressFromPU(gaProgramme.Id);
        List<Address__c> addrFromPro = RiskController.getAddressFromPUs(gaProgramme.Id, false);
        List<Address__c> addrProAdditional = RiskController.getAddressFromPUs(gaProgramme.Id, true);
        List<Address__c> addrFromMA = RiskController.getAddressFromOrganisation(accNA.Id);

		String newAddressId = RiskController.insertAddress('Lima', gaCountry.Id, 'Pueblo Libre', '222222', '2222222', 'Address Test 1', '1122333', 'Lima', gaCountry.Id, '5555222', '44222', accLE.Id, 'La Luz 102', 'ada');
        String updateResult = RiskController.updateAddress(newAddressId, 'Lima Upd', gaCountry.Id, 'Pueblo Libre', '222222', '2222222', 'Address Test 1', '1122333', 'Lima', gaCountry.Id, '5555222', '44222',accLE.Id, 'La Luz 102', 'ada');
        
        String countryName = RiskController.getCountryNameFromAddress(newAddressId);
		List<sObject> resObject = RiskController.getSystemInfoFromObject('address__c', newAddressId);
            
		System.assertEquals(true, ga <> null && ga.Corresponding_address_different__c == 'Yes');		        
        // System.assertEquals(true, addrFromPro.size() > 0 && addrProAdditional.size() > 0 && addrFromMA.size() > 0);		
	}
}