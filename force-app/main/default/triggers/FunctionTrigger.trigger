trigger FunctionTrigger on Function__c(before insert) {
  FunctionTriggerHandler functionHandler = new FunctionTriggerHandler(); 
  if (Trigger.isInsert && Trigger.isBefore) {
        functionHandler.beforeInsertUpdateAutoNumberFunctions(trigger.new);
  }
}