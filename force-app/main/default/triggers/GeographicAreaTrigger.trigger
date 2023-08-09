trigger GeographicAreaTrigger on ampi__Geographical_Area__c (before insert, before update) {
    GeographicAreaTriggerHandler geographicAreaHandler = new GeographicAreaTriggerHandler(); 
    if (trigger.isInsert && trigger.isBefore) {
        geographicAreaHandler.manageBeforeInsertGA(Trigger.new);
    }
    
    if (Trigger.isUpdate && Trigger.isBefore) {
        geographicAreaHandler.manageBeforeUpdateGA(trigger.old, trigger.new);
    }
}