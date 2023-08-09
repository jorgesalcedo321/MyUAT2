trigger ProjectResultStatementTrigger on ampi__Objective__c (before insert, before update, before delete) {
    ProjectResultStatementTriggerHandler psrHandler = new ProjectResultStatementTriggerHandler(); 
    if (Trigger.isInsert && Trigger.isBefore) {
        psrHandler.beforeInsertSetShortDescription(trigger.new);
    }
    
    if (Trigger.isUpdate && Trigger.isBefore) {
        psrHandler.beforeUpdateRestriction(trigger.old, trigger.new);
        psrHandler.beforeUpdateSetShortDescription(trigger.old, trigger.new);
    }
    
    if (Trigger.isDelete && Trigger.isBefore) {
        psrHandler.beforeDeleteRestrictionPRSAccordingToProjectData(trigger.old);
    }
}