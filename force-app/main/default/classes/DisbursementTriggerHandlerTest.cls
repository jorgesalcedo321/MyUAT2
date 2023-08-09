@isTest
private class DisbursementTriggerHandlerTest {
    @isTest 
    static void afterInsertDeleteBudget_CheckFinancialsAndBudgetsForTransitionNationalservices() {
    	Account accNA = TestDataFactory.createMA('NA Peru');
		ampi__Project__c projectTransition = TestDataFactory.createProjectByStatus('Transition', accNA.Id, '', '', 'National services');
		
		Test.startTest();
		List<ampi__Disbursement__c> disbursements = [SELECT Id FROM ampi__Disbursement__c WHERE ampi__Project__c =: projectTransition.id];
        Boolean exceptionOccurred = false;

        try{
            delete disbursements;
		}catch (Exception e){
            //Set boolean to true to catch exception being thrown
            exceptionOccurred = e.getMessage().contains('Disbursements are not allowed to be removed or changed');
        }

        System.System.assert(exceptionOccurred);
        
        Test.stopTest();        
    }
}