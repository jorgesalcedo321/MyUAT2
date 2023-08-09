public class notificationForPSAandIOR {
        @InvocableMethod(label='Notification For PSA and IOR') 
        public Static void notificationForPSAandIOR_ForStandardProject(List<FlowInputs> request) {
            //Approval process topic: https://salesforce.stackexchange.com/questions/1298/how-to-check-if-a-record-is-locked-or-not-in-apex-during-an-approval-process
            //Email Messaging: https://developer.salesforce.com/forums/?id=9060G000000I8UNQA0
            System.debug('###notificationForPSAandIOR request[0].projectId: ' + request[0].projectId);
            System.debug('###notificationForPSAandIOR Approval.isLocked(request[0].projectId): ' + Approval.isLocked(request[0].projectId));
            // if (Approval.isLocked(request[0].projectId) || Test.isRunningTest()) {
                //Please replace "Your Email Template Unique Name" with your template name
                String emailTemplateName = request[0].emailTemplate;
                List<EmailTemplate> lstEmailTemplates = [SELECT Id, HtmlValue, Body, Subject from EmailTemplate where DeveloperName =: emailTemplateName];
                System.debug('###notificationForPSAandIOR emailTemplateName: ' + emailTemplateName);
                System.debug('###notificationForPSAandIOR lstEmailTemplates: ' + lstEmailTemplates);
                System.debug('###notificationForPSAandIOR lstEmailTemplates.size(): ' + lstEmailTemplates.size());
            
                List<ampi__project__c> currentProjectInfo = [SELECT Project_ID_Text__c, Name, ampi__Description__c, Phase__c, ampi__Project_Status__c, SharePoint_Team_Site_URL__c, IOR_Approver__r.Name, IOR_Approver__c, IOR_Approver__r.Email, PSA_Reviewer__r.Name, PSA_Reviewer__c, PSA_Reviewer__r.Email FROM ampi__project__c WHERE Id =: request[0].projectId AND RecordType.Name = 'Standard'];
                // List<agreement__c> currentProjectAgreement = [SELECT Id, Status__c FROM agreement__c WHERE project__c =: request[0].projectId];
                List<deliverable__c> currentProjectAgreement = [SELECT Id, Status__c FROM deliverable__c WHERE project__c =: request[0].projectId AND Type__c = 'Agreement' AND Name LIKE 'Partnership agreement%'];
                System.debug('###notificationForPSAandIOR currentProjectInfo: ' + currentProjectInfo);
            
                if (currentProjectInfo.size() > 0 && lstEmailTemplates.size() > 0 && currentProjectAgreement.size() > 0) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateId(lstEmailTemplates[0].Id);
                    mail.setSaveAsActivity(false);
                    mail.setTargetObjectId(userinfo.getUserId());// Any contact or User id of your record

                    List<String> receivers = new List<String>();
                    Set<String> receiverIds = new Set<String>();
                    
                    String checkers = '';
                    if (currentProjectInfo[0].PSA_Reviewer__r.Email <> null && currentProjectInfo[0].PSA_Reviewer__r.Email <> '') {
                        checkers = 'PSA Reviewer: ' + currentProjectInfo[0].PSA_Reviewer__r.Name + ' / ';
                        receivers.add(currentProjectInfo[0].PSA_Reviewer__r.Email);
                        receiverIds.add(currentProjectInfo[0].PSA_Reviewer__c);
                    }
                    if (currentProjectInfo[0].IOR_Approver__r.Email <> null && currentProjectInfo[0].IOR_Approver__r.Email <> '') {
                        checkers += 'IOR Approver: ' + currentProjectInfo[0].IOR_Approver__r.Name;
                        receivers.add(currentProjectInfo[0].IOR_Approver__r.Email);
                        receiverIds.add(currentProjectInfo[0].IOR_Approver__c);
                    }
                    
                    System.debug('###notificationForPSAandIOR receivers: ' + receivers);
                    
                    String plainBody = lstEmailTemplates[0].Body;
                    plainBody = plainBody.replace('{!ampi__Project__c.Project_ID_Text__c}', ' ' + currentProjectInfo[0].Project_ID_Text__c);
                    plainBody = plainBody.replace('{!ampi__Project__c.Name}', ' ' + currentProjectInfo[0].Name);
                    plainBody = plainBody.replace('{!ampi__Project__c.ampi__Description__c}', currentProjectInfo[0].ampi__Description__c == null ? ' No Info Available' : ' ' + currentProjectInfo[0].ampi__Description__c);
                    plainBody = plainBody.replace('{!ampi__Project__c.Phase__c}', ' ' + currentProjectInfo[0].Phase__c);
                    plainBody = plainBody.replace('{!ampi__Project__c.ampi__Project_Status__c}', ' ' + currentProjectInfo[0].ampi__Project_Status__c);
                    plainBody = plainBody.replace('{!ampi__Project__c.Link}', currentProjectInfo[0].SharePoint_Team_Site_URL__c == null ? ' No Info Available' : ' ' + currentProjectInfo[0].SharePoint_Team_Site_URL__c);
                    plainBody = plainBody.replace('{!ApprovalRequest.Process_Assignee}', ' Agreement is changed to status: "' + currentProjectAgreement[0].Status__c + '" ' + checkers);
                    mail.setToAddresses(receivers);
                    mail.setPlainTextBody(plainBody);

                    //https://stackoverflow.com/questions/11105086/setwhatid-in-salesforce-using-email-template
                    // mail.setWhatId(request[0].projectId); // Enter your record Id whose merge field you want to add in template
                    // set data to email template:
                    // Project Id:
                    // Project Name:
                    // Project Description:
                    // Phase:
                    // Project Status:
                    System.debug('###notificationForPSAandIOR mail: ' + mail);
                    Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    
                    String title = 'Please Check New Agreement On Standard Project';
                    String message = 'New agreement was created for a Standard Project. The record is ready for your review. Project Name: ' + currentProjectInfo[0].Name;

                    notifyUsers(receiverIds, request[0].projectId, title, message);
                    System.debug('###notificationForPSAandIOR resultMail: ' + resultMail);
                }
            // }
        }

        public static void notifyUsers(Set<String> recipientsIds, String targetId, String title, String message) {
            // Get the Id for our custom notification type
            CustomNotificationType notificationType = 
                [SELECT Id, DeveloperName 
                FROM CustomNotificationType 
                WHERE DeveloperName='notification_PSA_IOR' LIMIT 1];
            
            // Create a new custom notification
            Messaging.CustomNotification notification = new Messaging.CustomNotification();

            // Set the contents for the notification
            notification.setTitle(title);
            notification.setBody(message);

            // Set the notification type and target
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(targetId);
            
            // Actually send the notification
            try {
                notification.send(recipientsIds);
            }
            catch (Exception e) {
                System.debug('Problem sending notification: ' + e.getMessage());
            }
        }

        public class FlowInputs{    
            @InvocableVariable
            public Id projectId;
            @InvocableVariable
            public String emailTemplate = 'Standard_Project_Notify_For_New_Agreement';
        }
}