trigger ProjectServiceTypeTrigger on ampi__Project_Thematic_Area__c (before insert, before delete) {
    ProjectServiceTypeTriggerHandler projectServiceTypeHandler = new ProjectServiceTypeTriggerHandler(); 
    if (Trigger.isInsert && Trigger.isBefore) {
        projectServiceTypeHandler.beforeInsertProjectServiceTypes(Trigger.new);
    }
    
    if (Trigger.isDelete && Trigger.isBefore) {
        projectServiceTypeHandler.beforeDeleteRestrictProjectServiceTypeDeletion(trigger.old);
    }
}