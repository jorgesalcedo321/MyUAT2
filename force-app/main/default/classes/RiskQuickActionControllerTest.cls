@isTest 
private class RiskQuickActionControllerTest {
    @isTest
	private static void getRecordTypeById_ReturnsValue() {
		Test.startTest();
        String name = RiskQuickActionController.getRecordTypeById('Account', '0121i0000008W2BAAU');
		System.assertEquals(name, 'Organization');
		Test.stopTest();
	}

    @isTest
	private static void getRecordTypeIdByRecordId_ReturnsValue() {
        Account accNA = TestDataFactory.createMA('NA Peru');
		Test.startTest();
        String recordType = RiskQuickActionController.getRecordTypeIdByRecordId('Account', accNA.Id);
        String recordTypeToCompare = 'SOS Organisation - MA';
		System.assertEquals(recordType, recordTypeToCompare);
		Test.stopTest();
	}

}