@isTest
private class BudgetTriggerHandlerTest {
    @isTest 
    static void afterInsertDeleteBudget_CheckFinancialsAndBudgetsForTransitionNationalservices() {
    	Account accNA = TestDataFactory.createMA('NA Peru');
		ampi__Project__c projectTransition = TestDataFactory.createProjectByStatus('Transition', accNA.Id, '', '', 'National services');
		
		Test.startTest();
		List<ampi__budget__c> budgets = [SELECT Id FROM ampi__budget__c WHERE ampi__Project__c =: projectTransition.id];
        Boolean exceptionOccurred = false;

        try{
            delete budgets;
		}catch (Exception e){
            //Set boolean to true to catch exception being thrown
            exceptionOccurred = e.getMessage().contains('Budgets are not allowed to be removed or changed');
        }

        System.assert(exceptionOccurred);
        //System.assert(true);

        /*List<ampi__Disbursement__c> disbursements = [SELECT Id FROM ampi__Disbursement__c WHERE ampi__Project__c =: projectTransition.id];
		System.assert(disbursements.size() > 0);
        
        if (budgets.size() > 0) {
            List<ampi__Financial__c> financials = [SELECT Id FROM ampi__Financial__c WHERE ampi__Budget__c =: budgets[0].id];
            System.assert(financials.size() > 0);
		}*/
        
        Test.stopTest();        
    }
}