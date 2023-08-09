public class TeamMemberTriggerHandler {
    public void afterInsertSetIORApproverAndPSAReviewer(List<Team_Member__c> newTeamMembers) {
        if (newTeamMembers.size() == 0) {
            return;
        }
        
        String projectId = newTeamMembers[0].Project__c;
        List<ampi__Project__c> projectStandardRelatedToTeamMembers = [SELECT Id, PSA_Reviewer__c, IOR_Approver__c FROM ampi__Project__c WHERE Id =: projectId AND RecordType.Name = 'Standard'];
        
        // System.debug('####projectStandardRelatedToTeamMembers.size():' + projectStandardRelatedToTeamMembers.size());
        if (projectStandardRelatedToTeamMembers.size() == 0) 
            return;

        boolean changed = false;
        for(Team_Member__c tm : newTeamMembers) {            
            // System.debug('####tm.role__c:' + tm.role__c);
            switch on tm.role__c {
                when 'PSA Reviewer' {
                    projectStandardRelatedToTeamMembers[0].PSA_Reviewer__c = tm.User__c;   
                    // System.debug('####projectStandardRelatedToTeamMembers[0].PSA_Reviewer__c:' + projectStandardRelatedToTeamMembers[0].PSA_Reviewer__c);
                    changed = true;
                }
                when 'IOR Approver' {
                    projectStandardRelatedToTeamMembers[0].IOR_Approver__c = tm.User__c;       
                    // System.debug('####projectStandardRelatedToTeamMembers[0].IOR_Approver__c:' + projectStandardRelatedToTeamMembers[0].IOR_Approver__c);
                    changed = true;
                }
            }
            /*if(tm.role__c == 'PSA Reviewer') {
                projectStandardRelatedToTeamMembers[0].PSA_Reviewer__c = tm.UserId;   
            } else if(tm.role__c == 'IOR Approver') {
                projectStandardRelatedToTeamMembers[0].IOR_Approver__c = tm.UserId;                     
            }*/
        }

        if (changed) {
            UPDATE projectStandardRelatedToTeamMembers;
            System.debug('####projectStandardRelatedToTeamMembers:' + projectStandardRelatedToTeamMembers);
        }
    }
}