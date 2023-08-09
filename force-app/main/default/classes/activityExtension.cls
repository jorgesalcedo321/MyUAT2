public without sharing class activityExtension {
    
    @AuraEnabled
    public static List<ampi__project__c> getProjectInfoStatus(String projectId) {													
        return [SELECT Id, ampi__project_status__c, phase__c FROM ampi__project__c WHERE Id =: projectId];
    }   

    @AuraEnabled
    public static List<ampi__objective__c> getProjectResultStatementFromProject(String projectId) {													
        return [SELECT Id, ampi__Label__c, ampi__Description__c FROM ampi__objective__c WHERE ampi__Project__c =: projectId AND ampi__Deactivated__c = false AND IsDeleted = false AND ampi__Level__c = 'Output' ORDER BY ampi__Label__c DESC]; // AND recordTypeId =: '0123O000002OQC0QAO'];
    }    
    @AuraEnabled
    public static Integer getEarlyStartDateFromActivity(String projectId) {
        List<ampi__activity__c> activities = [SELECT Id, ampi__Actual_Start_Date__c FROM ampi__activity__c WHERE project__c =: projectId AND IsDeleted = false AND ampi__Actual_Start_Date__c <> null ORDER BY ampi__Actual_Start_Date__c ASC]; 

        if (activities.size() == 0)
            return 0;

        return activities[0].ampi__Actual_Start_Date__c.year();
    }
    @AuraEnabled
    public static Integer getLateStartDateFromActivity(String projectId) {
        List<ampi__activity__c> activities = [SELECT Id, ampi__Actual_Start_Date__c FROM ampi__activity__c WHERE project__c =: projectId AND IsDeleted = false AND ampi__Actual_Start_Date__c <> null ORDER BY ampi__Actual_Start_Date__c DESC]; 
        //ampi__Actual_End_Date__c
        if (activities.size() == 0)
            return 0;

        return activities[0].ampi__Actual_Start_Date__c.year();
    } 
    @AuraEnabled
    public static List<ampi__activity__c> getActivitiesFromYearAndResultAndProject(Integer year, String result, String projectId) {
        return [SELECT Id, Name, ampi__Status__c, Activity_ID__c, thematic_area__r.Name FROM ampi__activity__c WHERE CALENDAR_YEAR(ampi__Actual_Start_Date__c) =: year AND project__c =: projectId AND ampi__Project_Objective__c =: result AND IsDeleted = false ORDER BY Name DESC]; 
    }
    @AuraEnabled
    public static List<ampi__activity__c> getMainActivitiesFromYearAndNewStatus(Integer year, String projectId) {
        return [SELECT Id, Name, ampi__Status__c, Activity_ID__c, thematic_area__r.Name FROM ampi__activity__c WHERE CALENDAR_YEAR(ampi__Actual_Start_Date__c) =: year AND project__c =: projectId AND ampi__Status__c = 'New' AND ampi__Parent_Activity__c = null AND IsDeleted = false ORDER BY Name DESC]; 
    }
    @AuraEnabled
    public static String updateMainActivitiesFromYearAndNewStatusToPlanning(Integer year, String projectId) {
         List<ampi__activity__c> activities = [SELECT Id, ampi__Status__c FROM ampi__activity__c WHERE CALENDAR_YEAR(ampi__Actual_Start_Date__c) =: year AND project__c =: projectId AND ampi__Status__c = 'New' AND ampi__Parent_Activity__c = null AND IsDeleted = false]; 

         for (ampi__activity__c act : activities) {
             act.ampi__Status__c = 'Planning';
         }

         try {
            UPDATE activities;             
         } catch(Exception ex) {
             return ex.getMessage();
         }
         return '';
    }
    @AuraEnabled(cacheable=true)
    public static List<LabelValue> getStatusesFromActivity() {
        Schema.DescribeFieldResult fieldDetail = ampi__activity__c.ampi__Status__c.getDescribe(); 
        List<Schema.PicklistEntry> values = fieldDetail.getPicklistValues();
        List<LabelValue> picklist = new List<LabelValue>();
        for (Schema.PicklistEntry value : values) {
            //values.getValue()
            //values.getLabel()
            if (value.isActive()) {
                LabelValue newItem = new LabelValue();
                newItem.label = value.getLabel();
                newItem.value = value.getValue();
                picklist.add(newItem);
            }
            //values.isDefaultValue()
        }
        return picklist;
    }

    public class LabelValue{    
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }

}