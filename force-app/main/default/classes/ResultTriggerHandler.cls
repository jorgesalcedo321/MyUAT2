public class ResultTriggerHandler {
    public void beforeInsertUpdateResultsInCommunityProfiles(List<ampi__Result__c> newResults) {
            User currentUser = [SELECT id,Contact.AccountId,Name,Profile.UserLicense.Name, Alias FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
            String license = currentUser.Profile.UserLicense.Name;
            System.debug('####currentUser: ' + currentUser.Name);        
            System.debug('####license: ' + license);        

            List<string> roles = new List<string>();
            roles.add('YouthCan! Global MEL Advisor');
            roles.add('YouthCan! Global Project Manager');
            roles.add('YouthCan! Key Account Manager');
            roles.add('YouthCan! Regional Coordinator');
            roles.add('YouthCan! Coordinator');
            roles.add('YouthCan! Partner');
            roles.add('Project Contributor');

            If (license.toLowerCase().contains('community') || currentUser.Alias.toLowerCase().contains('xxzzzccc')) {
                List<ampi__Result__c> results = newResults;
                System.debug('####results: ' + results);
                for(ampi__Result__c res : results) {
                    List<ampi__project_indicator__c> pi = [SELECT id, ampi__project__c, ampi__project__r.RecordType.Name, ampi__project__r.SOS_Implementing_Organisation__c FROM ampi__project_indicator__c WHERE Id =: res.ampi__Project_Indicator__c];
                    
                    if (pi.size() > 0) {
                        System.debug('####pi[0].ampi__project__c: ' + pi[0].ampi__project__c);
                        System.debug('####currentUser.Id: ' + currentUser.Id);
                        System.debug('####roles: ' + roles);
                        System.debug('####pi[0].ampi__project__r.RecordType.Name: ' + pi[0].ampi__project__r.RecordType.Name);                        
                        if (pi[0].ampi__project__r.RecordType.Name == 'Shadow Project') {
                            if (currentUser.Contact.AccountId != pi[0].ampi__project__r.SOS_Implementing_Organisation__c) {
                                res.addError('INSUFFICIENT_ACCESS_OR_READONLY error for Contact "Organisation" field is different to the project "SOS Implemetation Organisation" field.');
                                // res.addError('INSUFFICIENT_ACCESS_OR_READONLY on "ampi__result__c" row Id:' + res.Id);                                
                            }
                        } else {
                            List<Team_member__c> tms = [SELECT Id FROM Team_member__c WHERE Project__c =: pi[0].ampi__project__c AND User__c =: currentUser.Id AND Role__c IN : roles AND Active__c = true];
                            System.debug('####tms.size(): ' + tms.size());        
                            if(tms.size() == 0) {
                                res.addError('INSUFFICIENT_ACCESS_OR_READONLY error for User is not registered as a "Team member" on the project as Project Contributor or Youthcan roles.');
                                // res.addError('INSUFFICIENT_ACCESS_OR_READONLY on "ampi__result__c" row Id:' + res.Id);
                            }
                        }                        
                    }                    
                }
            }   
    }
}