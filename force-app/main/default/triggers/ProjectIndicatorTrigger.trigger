trigger ProjectIndicatorTrigger on ampi__Project_Indicator__c  (before insert) {
 ProjectIndicatorTriggerHandler projectHandler = new ProjectIndicatorTriggerHandler(); 
 if (Trigger.isInsert && Trigger.isBefore ) {
     projectHandler.beforeInsertProjectIndicators_SetTypeResultAggregated(trigger.new);
 }
}