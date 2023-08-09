trigger BudgetTrigger on ampi__Budget__c (before delete, before update, before insert) {
    BudgetTriggerHandler budgetHandler = new BudgetTriggerHandler(); 
    if (Trigger.isUpdate && Trigger.isBefore) {
        budgetHandler.beforeUpdateRestrictionDeletion(trigger.new, trigger.old);
    }     
    
    if (Trigger.isDelete && Trigger.isBefore) {
        budgetHandler.beforeDeleteRestrictionDeletion(trigger.old);
    }     
    
    if (Trigger.isInsert && Trigger.isBefore) {
        budgetHandler.beforeInsertSetOrderPerProject(trigger.new);
    }
}