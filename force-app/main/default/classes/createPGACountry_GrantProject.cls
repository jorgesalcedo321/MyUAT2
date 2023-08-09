public class createPGACountry_GrantProject {

    @InvocableMethod(label='Create PGA Country for Grant Projects') 
	public Static void createPGACountry_GrantProject(List<Id> projectIds){
        
        List<ampi__Project__c> projects = [SELECT SOS_Implementing_Organisation__r.Country__c, RecordType.Name FROM ampi__Project__c WHERE Id IN: (projectIds)];

        if (projects.size() == 0) {
            return;
        }
        
        String countryId = projects[0].SOS_Implementing_Organisation__r.Country__c;
        System.debug('####createPGACountry_GrantProject Country A:' + countryId);
        
        if ((countryId != null && projects[0].RecordType.Name == 'Grant')) {
            List<ampi__Project_Geographic_Area__c> pgas = [SELECT Id FROM ampi__Project_Geographic_Area__c WHERE ampi__Project__c IN :projectIds AND ampi__Geographic_Area__c =: countryId];
            String projectId = projectIds[0];
    		
            System.debug('####createPGACountry_GrantProject pgas B:' + pgas.size());
        
            System.debug('####Schema.sObjectType.ampi__Project_Geographic_Area__c.isCreateable():' + Schema.sObjectType.ampi__Project_Geographic_Area__c.isCreateable());
            System.debug('####Schema.sObjectType.ampi__Project_Geographic_Area__c.isUpdateable():' + Schema.sObjectType.ampi__Project_Geographic_Area__c.isUpdateable());
            if (pgas.size() == 0 && Schema.sObjectType.ampi__Project_Geographic_Area__c.isCreateable() && Schema.sObjectType.ampi__Project_Geographic_Area__c.isUpdateable()) {
                ampi__Project_Geographic_Area__c newPGA = new ampi__Project_Geographic_Area__c();
                System.debug('####Schema.sObjectType.ampi__Project_Geographic_Area__c.isCreateable() 1');
                newPGA.ampi__Geographic_Area__c = projects[0].SOS_Implementing_Organisation__r.Country__c;
                System.debug('####Schema.sObjectType.ampi__Project_Geographic_Area__c.isCreateable() 2');
                newPGA.ampi__Project__c = projectId;
                newPGA.ampi__Geolocation__latitude__s = 0;
                newPGA.ampi__Geolocation__longitude__s = 0;
                insert newPGA;
                System.debug('####Schema.sObjectType.ampi__Project_Geographic_Area__c.isCreateable() 3');
        
                System.debug('####createPGACountry_GrantProject newPGA C:' + newPGA.Id);
        	}
        }
    }
}