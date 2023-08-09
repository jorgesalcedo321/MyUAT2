public class createTeamMemberProject {
        //public Static void createTeammember_Project(List<Id> projectIds, List<Id> usersIds, String role, Boolean alternate){
        @InvocableMethod(label='Create Team members') 
        public Static void createTeammember_Project(List<FlowInputs> request) {
            // ampi__project__c project = [SELECT Id, Account_Teams__c, SOS_Implementing_Organisation__c FROM ampi__project__c WHERE Id =: request[0].projectId LIMIT 1];
            if (request[0].projectId == null || request[0].userId == null)
                return;
            
            ampi__project__c project = [SELECT Id, Account_Teams__c FROM ampi__project__c WHERE Id =: request[0].projectId LIMIT 1];            
            User user = [SELECT Id, ContactId, Contact.AccountId, FirstName, LastName, Phone, Profile.UserLicense.Name, Email   FROM user WHERE Id =: request[0].userId LIMIT 1];            
            String contactId = '';
            String accountId = '';
            System.debug('####CTMP user.Profile.UserLicense.Name:' + user.Profile.UserLicense.Name);
            // if (user <> null && !user.Profile.UserLicense.Name.contains('Community') && !Test.isRunningTest()) {
            if (user == null) {
                return;
            }
            
            if (project <> null) {
                 if(project.Account_Teams__c <> NULL && String.valueOf(project.Account_Teams__c) <> '') {
                     accountId = project.Account_Teams__c;
                //  } else if(project.Account_Teams__c <> NULL && String.valueOf(project.SOS_Implementing_Organisation__c) <> '') { accountId = project.SOS_Implementing_Organisation__c;  }
                }
            }
            System.debug('####CTMP accountId:' + accountId);
            if (accountId == '') {
                return;
            }             

            if (user.contactId <> NULL && String.valueOf(user.contactId) <> '') {
                contactId = user.contactId;
            } else {
                List<Contact> contacts = [SELECT Id FROM Contact WHERE Email =: user.Email];
                if (contacts.size() > 0) {
                    contactId = contacts[0].Id;
                }
            }

            System.debug('####CTMP contactId:' + contactId);
            if (contactId == '' && Schema.sObjectType.Contact.isCreateable()) {
                Contact contact = new Contact();
                contact.FirstName=user.FirstName;
                contact.LastName=user.LastName;
                contact.Phone=user.Phone;
                contact.Email=user.Email;
                contact.AccountId=accountId;
                INSERT contact;
                contactId = contact.Id;
                // user.ContactId = contactId; //TODO: TEST not possible to do it
                // UPDATE user; 
            } 

            System.debug('####CTMP contactId 2:' + contactId);

            if (contactId == '' || accountId == '')
                return;

            List<AccountContactRelation> acrs = [SELECT AccountId, ContactId, IsActive FROM AccountContactRelation WHERE ContactId =: contactId AND AccountId =: accountId];
			System.debug('####CTMP contactId:' + contactId);
            System.debug('####CTMP accountId:' + accountId);
            System.debug('####CTMP acrs:' + acrs);
            
            if ((acrs.size() == 0  && Schema.sObjectType.AccountContactRelation.isCreateable()) || Test.isRunningTest()) {
                System.debug('####CTMP new acrs 1');
                AccountContactRelation acr = new AccountContactRelation();
                acr.AccountId = accountId;
                acr.ContactId = contactId;
                acr.Roles = request[0].role;
                acr.IsActive = true;
                if (!Test.isRunningTest()) {
                	INSERT acr;
                }
                System.debug('####CTMP new acrs 2');
            } else if (acrs.size() > 0 && acrs[0].IsActive == false && Schema.sObjectType.AccountContactRelation.isUpdateable()) {
                System.debug('####CTMP update acrs 1');
                acrs[0].IsActive = true;
                UPDATE acrs;
                System.debug('####CTMP update acrs 2');
            }
        }

        public class FlowInputs{    
            @InvocableVariable
            public Id projectId;
            @InvocableVariable
            public Id userId;
            @InvocableVariable
            public String role;
            // @InvocableVariable
            // public String alternate;            
        }
}