trigger change_NARecordType_ForViewAllFields on ampi__Risk_Assessment__c (before insert) {
    Id recordTypeIDForNewNARisk = Schema.getGlobalDescribe().get('ampi__Risk_Assessment__c').getDescribe().getRecordTypeInfosByName().get('New National Security Context').getRecordTypeId();
    Id recordTypeIDForEditNARisk = Schema.getGlobalDescribe().get('ampi__Risk_Assessment__c').getDescribe().getRecordTypeInfosByName().get('National Security Context').getRecordTypeId();
    
    System.debug('####recordTypeIDForNewNARisk: ' + recordTypeIDForNewNARisk);
    System.debug('####recordTypeIDForEditNARisk: ' + recordTypeIDForEditNARisk);
    
    for (ampi__Risk_Assessment__c review : Trigger.new){
        if (review.RecordTypeId == recordTypeIDForNewNARisk) {
            review.RecordTypeId = recordTypeIDForEditNARisk;
        }        
    }
}