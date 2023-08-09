trigger DisbursementTrigger on ampi__Disbursement__c (before delete, before update, after insert) {
    DisbursementTriggerHandler disbursementHandler = new DisbursementTriggerHandler(); 
    if (Trigger.isInsert && Trigger.isAfter) {
        disbursementHandler.afterInsertSetOrderPerProject(trigger.new);
    }
     if (Trigger.isUpdate && Trigger.isBefore) {
        disbursementHandler.beforeUpdateRestrictionDeletion(trigger.new, trigger.old);
    } 
    if (Trigger.isDelete && Trigger.isBefore) {
        disbursementHandler.beforeDeleteRestrictionDeletion(trigger.old);
    } 
}