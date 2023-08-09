public with sharing class ProjectGeographicAreaHandler  {

	final List<ampi__Project_Geographic_Area__c> newRecords;
    final Map<Id, ampi__Project_Geographic_Area__c> oldMap;

	public ProjectGeographicAreaHandler(List<ampi__Project_Geographic_Area__c> newRecords, Map<Id, ampi__Project_Geographic_Area__c> oldMap){
        this.newRecords = newRecords;
        this.oldMap = oldMap;
    }

    public void afterUpdate(){
		ProjectGeographicAreaService.deletePIGAs(newRecords,oldMap);
    }
}