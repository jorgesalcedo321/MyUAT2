trigger TeamMemberTrigger on Team_Member__c(after insert, before insert) {
    TeamMemberTriggerHandler teamMemberHandler = new TeamMemberTriggerHandler(); 
    if (Trigger.isInsert && Trigger.isAfter) {
        teamMemberHandler.afterInsertSetIORApproverAndPSAReviewer(trigger.new);
    }
}