public class DisbursementTriggerHandler {
	public void afterInsertSetOrderPerProject(List<ampi__Disbursement__c> newDisbursements) {
    	if (newDisbursements.size() == 0) {
            return;
        }
        
        Decimal order = 0;
        Id projectId;
        Boolean hasRecordsToUpdate = false; 
        Set<Id> ids = (new Map<Id, ampi__Disbursement__c>(newDisbursements)).keySet();
        List<ampi__Disbursement__c> newDisbursementsToUpdate = [SELECT Id, Order_Project__c, ampi__Project__c FROM ampi__Disbursement__c WHERE Id =: ids AND ampi__Project__c != ''];

        for(ampi__Disbursement__c newDisbursement : newDisbursementsToUpdate) {     
                if (projectId != newDisbursement.ampi__Project__c) {
                    projectId = newDisbursement.ampi__Project__c;
                	order = 0;
                    List<ampi__Disbursement__c> checkOrders = [SELECT Id, Order_Project__c FROM ampi__Disbursement__c WHERE ampi__Project__c =: projectId AND Order_Project__c <> NULL ORDER BY Order_Project__c DESC LIMIT 1];
            		if (checkOrders.size() > 0) {
            			order = checkOrders[0].Order_Project__c + 1;
                    } else {
                        order = order + 1;
                    }
                } else {
                	order = order + 1;
                }

                if (newDisbursement.Order_Project__c != order) {
                    hasRecordsToUpdate = true;                
                    newDisbursement.Order_Project__c = order;
                }
        }
        
        if (hasRecordsToUpdate) {
            UPDATE newDisbursementsToUpdate;
        }
    }   
    public void beforeDeleteRestrictionDeletion(List<ampi__Disbursement__c> newDisbursements) {
        for(ampi__Disbursement__c acc : newDisbursements){
            if (acc.Is_ReadOnly__c == true) {
                acc.addError('Disbursements are not allowed to be removed or changed');
            } 
        } 
    }
    public void beforeUpdateRestrictionDeletion(List<ampi__Disbursement__c> newDisbursements, List<ampi__Disbursement__c> oldDisbursements) {
        for(ampi__Disbursement__c acc : newDisbursements){
            if (acc.Is_ReadOnly__c == true) {
                for(ampi__Disbursement__c accold : oldDisbursements) {
                    if (acc.Id == accold.Id && acc.Order_Project__c == accold.Order_Project__c) {
                        acc.addError('Disbursements are not allowed to be removed or changed');
                    }
                }
            } 
        } 
    }
}