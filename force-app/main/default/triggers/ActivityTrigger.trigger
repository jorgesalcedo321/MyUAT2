trigger ActivityTrigger on ampi__Activity__c (before insert, after insert, before update, before delete) {
    ActivityTriggerHandler activityHandler = new ActivityTriggerHandler(); 
    if (trigger.isInsert && trigger.isBefore) {
        activityHandler.manageBeforeInsertActivities(Trigger.new);
    }
    
    if (Trigger.isInsert && Trigger.isAfter) {
        activityHandler.manageAfterInsertActivities(trigger.new);
    }
    
    if (Trigger.isUpdate && Trigger.isBefore) {
        activityHandler.manageBeforeUpdateActivities(trigger.old, trigger.new);
    }
    
    if (Trigger.isDelete && Trigger.isBefore) {
        activityHandler.manageBeforeDeleteActivities(trigger.old);
    }
}