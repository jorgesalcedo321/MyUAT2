trigger ProjectGeographicAreaTrigger  on ampi__Project_Geographic_Area__c (before insert, after insert, after update) {
    ProjectGeographicAreaTriggerHandler pgaHandler = new ProjectGeographicAreaTriggerHandler(); 
    if (Trigger.isInsert) {
        if (Trigger.isBefore) {
            pgaHandler.manageBeforeInsertPGAs(trigger.new);
        } else {
            pgaHandler.manageAfterInsertPGAs(trigger.new);
        }
    } else if (Trigger.isUpdate) {
        if (Trigger.isAfter) {
            pgaHandler.manageAfterUpdatePGAs(trigger.new, trigger.oldMap);
        }
    }
}