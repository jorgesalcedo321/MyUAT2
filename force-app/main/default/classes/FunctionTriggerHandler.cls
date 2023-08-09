public class FunctionTriggerHandler {
    public void beforeInsertUpdateAutoNumberFunctions(List<Function__c> newFunctions) {
        List<Function__c> lista = [SELECT Id, Auto_Number__c FROM Function__c ORDER BY Auto_Number__c DESC LIMIT 1];
        Decimal nextNumber = 1;
        for(Function__c item : lista) {
            if (item.Auto_Number__c != NULL) {
                nextNumber = item.Auto_Number__c + 1;
            }
        } 
        
        for (Function__c item : newFunctions) {
            item.Auto_Number__c = nextNumber;
            nextNumber = nextNumber + 1;
        }
    }
}