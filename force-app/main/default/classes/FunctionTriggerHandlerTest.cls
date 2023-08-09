@isTest
private class FunctionTriggerHandlerTest {
	@isTest 
    static void beforeInsertUpdateAutoNumberFunctions_CheckAutoNumber() {
        Test.startTest();
        List<Function__c> lista = [SELECT Id, Auto_Number__c FROM Function__c ORDER BY Auto_Number__c DESC LIMIT 1];
        Decimal index = 0;
        for(Function__c item : lista) {
            index = item.Auto_Number__c;
        }
        
        Function__c fn1 = CreateObjects.createFunction('FN1', 'OUN1');
        Function__c fn2 = CreateObjects.createFunction('FN2', 'OUN2');
        System.assert((index + 1) == 1);
        System.assert((index + 2) == 2);        
        Test.stopTest();   
    }
}