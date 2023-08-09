trigger FinancialTrigger on ampi__Financial__c (before delete, before update, before insert, after insert) {
  FinancialTriggerHandler financialHandler = new FinancialTriggerHandler(); 
    if (Trigger.isDelete && Trigger.isBefore) {
        financialHandler.beforeDeleteRestrictionDeletion(trigger.old);
    }     

    if (Trigger.isUpdate && Trigger.isBefore) {
        financialHandler.beforeUpdateRestrictionDeletion(trigger.old, trigger.new);
    }     
    
    if (Trigger.isInsert && Trigger.isBefore) {
      financialHandler.beforeInsertFinancialCategory(trigger.new);
    }
    
    if (Trigger.isInsert && Trigger.isAfter) {
      financialHandler.afterInsertSetOrderPerProject(trigger.new);
    }
}