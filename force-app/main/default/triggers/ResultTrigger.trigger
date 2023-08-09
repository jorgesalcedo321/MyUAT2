trigger ResultTrigger on ampi__Result__c (before update, before insert) {
    ResultTriggerHandler resultTrigger = new ResultTriggerHandler();
    if ((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore) {
        resultTrigger.beforeInsertUpdateResultsInCommunityProfiles(Trigger.new);
    }
}