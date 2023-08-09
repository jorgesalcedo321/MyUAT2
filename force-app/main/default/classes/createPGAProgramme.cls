public class createPGAProgramme {
    @InvocableMethod(label='Create PGA Programme') 
	public Static void createPGAProgramme(List<Id> projectIds){
        List<ampi__Project__c> projects = [SELECT Id, Programme_Location__c FROM ampi__Project__c WHERE Id IN: (projectIds)];

        if (Schema.sObjectType.ampi__Project_Geographic_Area__c.isCreateable() && Schema.sObjectType.ampi__Project_Geographic_Area__c.isUpdateable() && projects.size() > 0 && projects[0].Programme_Location__c != null) {
            String programmeId = projects[0].Programme_Location__c;
        	System.debug('####createPGAProgramme Location:' + programmeId);
        
            List<ampi__Project_Geographic_Area__c> pgas = [SELECT Id, ampi__Active__c FROM ampi__Project_Geographic_Area__c WHERE ampi__Project__c IN :projectIds AND ampi__Geographic_Area__c =: programmeId];
            List<ampi__Project_Geographic_Area__c> newPGAs = new List<ampi__Project_Geographic_Area__c>();
            String projectId = projectIds[0];
    		
            System.debug('####createPGAProgramme pgas B:' + pgas.size());
            
            if (pgas.size() == 0) {
            	ampi__Project_Geographic_Area__c newPGA = new ampi__Project_Geographic_Area__c();
                newPGA.ampi__Geographic_Area__c = programmeId;
                newPGA.ampi__Project__c = projectId;
                newPGA.ampi__Geolocation__latitude__s = 0;
                newPGA.ampi__Geolocation__longitude__s = 0;
                INSERT newPGA;                
            }
            
            for (ampi__Project_Geographic_Area__c pga : pgas) {
                 if (pgas[0].ampi__Active__c ==  false) {
                    pga.ampi__Active__c = true;                    
                    UPDATE pga;
                }
            }
        }
    }
}