public class BudgetTriggerHandler {
	public void beforeInsertSetOrderPerProject(List<ampi__Budget__c> newBudgetsToUpdate) {
    	/*if (newBudgets.size() == 0) {
            return;
        }*/
        
        Decimal order = 0;
        Id projectId;
        Boolean hasRecordsToUpdate = false; 
        //Set<Id> ids = (new Map<Id, ampi__Budget__c>(newBudgets)).keySet();
        //List<ampi__Budget__c> newBudgetsToUpdate = newBudgets.deepClone();//[SELECT Id, Order_Project__c, ampi__Project__c FROM ampi__Budget__c WHERE Id =: ids AND ampi__Project__c != ''];
        
        if (newBudgetsToUpdate.size() > 0) {
            projectId = newBudgetsToUpdate[0].ampi__Project__c;
        } else {
            return;
        }
        
        List<ampi__Budget__c> checkOrders = [SELECT Id, Order_Project__c FROM ampi__Budget__c 
                                             WHERE ampi__Project__c =: projectId AND Order_Project__c <> NULL 
                                             ORDER BY Order_Project__c DESC];

        Integer initialBudgetOrderPerProject = 0;        
        Integer countBudgetOrderPerProject = 0;
        if (checkOrders.size() > 0) {
            initialBudgetOrderPerProject = Integer.ValueOf(checkOrders[0].Order_Project__c);
        }
        
        for(ampi__Budget__c newBudget : newBudgetsToUpdate) {            
                if (projectId != newBudget.ampi__Project__c) {
                	projectId = newBudget.ampi__Project__c;
                    order = 0;
                    //List<ampi__Budget__c> checkOrders = [SELECT Id, Order_Project__c FROM ampi__Budget__c WHERE ampi__Project__c =: projectId AND Order_Project__c <> NULL ORDER BY Order_Project__c DESC LIMIT 1];
                    if (initialBudgetOrderPerProject > 0) { 
                        countBudgetOrderPerProject += 1;
            			order = initialBudgetOrderPerProject + countBudgetOrderPerProject;
                    } else {
                        order = order + 1;
                    }
                } else {
                	order = order + 1;
                }           

                if (newBudget.Order_Project__c != order) {
                    hasRecordsToUpdate = true;                
                    newBudget.Order_Project__c = order;
                }   
        }
        
        //if (hasRecordsToUpdate) {
        //    UPDATE newBudgetsToUpdate;
        //}
    }   

    //public void beforeDeleteUpdateRestrictionDeletion(List<ampi__Budget__c> newBudgets) {
    public void beforeUpdateRestrictionDeletion(List<ampi__Budget__c> newBudgets, List<ampi__Budget__c> oldBudgets) {
        //List<ampi__Budget__c> newBudgets = newMapBudgets.keySet();
        System.debug('#queries-4:' + Limits.getQueries() + ' max queries: ' + Limits.getLimitQueries());
        Set<Id> budgetIds = (new Map<Id, ampi__Budget__c>(newBudgets)).keySet();
        
        List<ampi__financial__c> currentFinancials = [SELECT Id, ampi__budget__c FROM ampi__financial__c WHERE ampi__budget__c =: budgetIds AND ampi__Category__c = '3 CMG CI'];
		System.debug('#queries-4:' + Limits.getQueries() + ' max queries: ' + Limits.getLimitQueries());
        for(ampi__Budget__c acc : newBudgets){
            ampi__Budget__c currentBudget;
            for(ampi__Budget__c accold : oldBudgets) {
                if (acc.Id == accold.Id) {
                    currentBudget = accold;
                }
            }    
                
            for(ampi__financial__c currentFinancial : currentFinancials) {
                if (currentFinancial.ampi__budget__c == acc.Id) {
                    if (acc.Order_Project__c == currentBudget.Order_Project__c && acc.Order_Financial__c == currentBudget.Order_Financial__c) {
                        acc.addError('Budgets from category "3 CMG CI" are not allowed to be removed or changed');
                    }
                }            

                if (acc.Is_ReadOnly__c == true) {
                    //if (acc.Id == accold.Id && acc.Order_Project__c == accold.Order_Project__c) {
                    if (acc.Order_Project__c == currentBudget.Order_Project__c && acc.Order_Financial__c == currentBudget.Order_Financial__c) {
                    	//acc.addError('Budgets are not allowed to be removed or changed U: old ' + accold.Order_Financial__c + ' new ' + acc.Order_Financial__c + ' U: old ' + accold.Order_Project__c + ' new ' + acc.Order_Project__c);
                        acc.addError('Budgets are not allowed to be removed or changed');
                    }
                } 
            }
        } 
    }

    public void beforeDeleteRestrictionDeletion(List<ampi__Budget__c> newBudgets) {
        //List<ampi__Budget__c> newBudgets = newMapBudgets.keySet();
        for(ampi__Budget__c acc : newBudgets){
            List<ampi__financial__c> currentFinancials = [SELECT Id, ampi__Category__c FROM ampi__financial__c WHERE ampi__budget__c =: acc.Id];

            for(ampi__financial__c currentFinancial : currentFinancials) {
                if (currentFinancial.ampi__Category__c == '3 CMG CI') {
                    acc.addError('Budgets from category "3 CMG CI" are not allowed to be removed or changed');
                }            

                if (acc.Is_ReadOnly__c == true) {
                    acc.addError('Budgets are not allowed to be removed or changed');
                } 
            }
        } 
    }
}