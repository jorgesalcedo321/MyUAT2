trigger ProjectGeographicArea_AfterUpdate on ampi__Project_Geographic_Area__c (after update){
    
    ProjectGeographicAreaHandler handler = new ProjectGeographicAreaHandler(trigger.new, trigger.oldMap);
    
    if(trigger.isAfter){
        if(trigger.isUpdate){
            handler.afterUpdate();
        }
    }
}