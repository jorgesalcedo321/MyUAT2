public class checkAndCreatePGAForProgrammeLocation {

    @InvocableMethod(label='Create PGA Programme Location With Validation') 
	public Static void createPGAProgrammeLocationWithValidation(List<Id> projectIds){
        
        // List<ampi__Project__c> projects = [SELECT Id, Programme_Location__c, Programme_Location__r.ampi__Geolocation__latitude__s, Programme_Location__r.ampi__Geolocation__longitude__s   FROM ampi__Project__c WHERE Id IN: (projectIds)];
        List<ampi__Project__c> projects = [SELECT Id, Programme_Location__c FROM ampi__Project__c WHERE Id IN: (projectIds)];

        for(ampi__Project__c proj : projects) {
            String programmeLocation = proj.Programme_Location__c;
            String projectId = proj.Id;
            if (programmeLocation != null) {
                List<ampi__Project_Geographic_Area__c> pgas = [SELECT Id FROM ampi__Project_Geographic_Area__c WHERE ampi__Project__c =: projectId AND ampi__Geographic_Area__c =: programmeLocation];
                
                if (pgas.size() == 0) {
                    ampi__Project_Geographic_Area__c newPGA = new ampi__Project_Geographic_Area__c();
                    newPGA.ampi__Geographic_Area__c = programmeLocation;
                    newPGA.ampi__Project__c = projectId;
                    newPGA.ampi__Geolocation__latitude__s = 0;
                    newPGA.ampi__Geolocation__longitude__s = 0;
                    //newPGA.ampi__Geolocation__latitude__s = proj.Programme_Location__r.ampi__Geolocation__latitude__s;
                    //newPGA.ampi__Geolocation__longitude__s = proj.Programme_Location__r.ampi__Geolocation__longitude__s;
                    insert newPGA;
            
                    System.debug('####createPGAProgrammeLocationWithValidation newPGA C:' + newPGA.Id);
                }
            }

        }
        
    }
}