public class createPGA {
    @InvocableMethod(label='Create Programme PGA') 
	public Static void createProgramme_PGA(List<FlowInputs> request){
        List<ampi__project_geographic_area__c> checkDuplicates = [SELECT Id, ampi__Active__c FROM ampi__project_geographic_area__c WHERE ampi__Geographic_Area__c =: request[0].programmeId AND ampi__project__c =: request[0].projectId];
        Boolean foundInactiveDuplicates = false;
                
        if (checkDuplicates.size() > 0) {
            for (ampi__project_geographic_area__c pga : checkDuplicates) {
                if (pga.ampi__Active__c == false) {
                    pga.ampi__Active__c = true;
                    foundInactiveDuplicates = true;
                }
            }

            if (foundInactiveDuplicates){
                UPDATE checkDuplicates;
            }
        } else {
            ampi__project_geographic_area__c newPGA = new ampi__project_geographic_area__c();
            newPGA.ampi__Active__c = true;
            newPGA.ampi__Geographic_Area__c = request[0].programmeId;
            newPGA.ampi__project__c = request[0].projectId;
            newPGA.ampi__Geolocation__latitude__s = 0;
            newPGA.ampi__Geolocation__longitude__s = 0;
            INSERT newPGA;
        } 
    }

    public class FlowInputs{    
        @InvocableVariable
        public Id projectId;
        @InvocableVariable
        public Id programmeId;        
    }
}