trigger ProjectTrigger on ampi__Project__c (before delete, before update, before insert, after insert) {
    //https://sfdcfanboy.com/2017/04/26/7-ways-to-lock-a-record-in-salesforce/
    ProjectTriggerHandler projectHandler = new ProjectTriggerHandler(); 
    if (Trigger.isDelete && Trigger.isBefore) {
        projectHandler.manageProjectsBeforeDeleteByRecordType(trigger.old);
    }      
    
    if (trigger.isInsert && trigger.isBefore) {
        projectHandler.manageProjectsBeforeInsertByRecordType(Trigger.new);
    }

    if (Trigger.isInsert && Trigger.isAfter) {
        projectHandler.manageProjectsAfterInsertByRecordType(trigger.new);
    }
    
    if (Trigger.isUpdate && Trigger.isBefore) {
        projectHandler.manageProjectsBeforeUpdateByRecordType(trigger.old, trigger.new);
    }
}