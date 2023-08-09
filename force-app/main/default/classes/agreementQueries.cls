public without sharing class agreementQueries {
    
    @AuraEnabled(cacheable=true)
    public static Deliverable__c getAgreementFromProjectId(String projectId) {													
        List<Deliverable__c> res = [SELECT Id, Status__c FROM Deliverable__c WHERE project__c =: projectId AND recordType.Name =: 'Agreement'];
        
        if (res.size() > 0) {
            return res[0];
        }
        return null;
    }
    
    
    public static List<Deliverable__c> getAgreementsFromProjects(Set<Id> projIds) {
        return [SELECT Id, project__c FROM deliverable__c WHERE project__c IN : projIds AND recordType.Name =: 'Agreement'];
    } 
    
    public static boolean existsAgreementFromProject(List<Deliverable__c> deliverables, String projectId) {
        for(deliverable__c aggr : deliverables) {
			if (aggr.project__c == projectId) {
            	return true;
            }
        }
        return false;
    }
}