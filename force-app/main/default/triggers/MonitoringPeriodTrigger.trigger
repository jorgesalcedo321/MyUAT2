trigger MonitoringPeriodTrigger on ampi__Reporting_Period__c (before insert, before update) {
    MonitoringPeriodTriggerHandler monitoringPeriodHandler = new MonitoringPeriodTriggerHandler(); 
    if (Trigger.isInsert && Trigger.isBefore) {
        monitoringPeriodHandler.beforeInsertMonitoringPeriods(trigger.new);
    }     
    if (Trigger.isUpdate && Trigger.isBefore) {
        monitoringPeriodHandler.beforeUpdateMonitoringPeriods(trigger.new);
    }     
}