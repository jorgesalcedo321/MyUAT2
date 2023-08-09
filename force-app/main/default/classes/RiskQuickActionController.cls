public class RiskQuickActionController {
	@AuraEnabled
    public static String getRecordTypeById(String objectName, Id recordTypeId){
        return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
    }
    
    @AuraEnabled
    public static String getRecordTypeIdByRecordId(String objectName, Id recId){
        sObject currentRecord = Database.query('SELECT recordTypeId FROM ' + objectName + ' WHERE Id =  \'' + recId + '\' LIMIT 1');
        if (currentRecord == NULL) {
            return '';
        }
        return getRecordTypeById(objectName, currentRecord.get('recordTypeId') + '');
    }
}