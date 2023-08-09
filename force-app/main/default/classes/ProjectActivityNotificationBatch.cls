global class ProjectActivityNotificationBatch implements Database.Batchable<sObject> {
  private String query;
    
  /*
      //Execute Apex Jobs / Check on Setup => Environments => Jobs => Apex Jobs or Scheduled Jobs
	  //String sch = '0 ' + i + ' * * * ?'; i is the minute to run
      String sch = '0 1 0 28 * ?';
      ScheduledProjectActivityNotification sqrb = new ScheduledProjectActivityNotification();
      system.schedule('ScheduledProjectActivityNotification Monthly on 28th: ' + Date.today().Year() + '-' + Date.today().Month() + Date.today().Day(), sch, sqrb);
  */
    
  global ProjectActivityNotificationBatch (){
  }
    
  // The batch job starts
  global Database.Querylocator start(Database.BatchableContext bc){
    // String m = Date.today().Month() > 9 ? Date.today().Month() : '0' + Date.today().Month();
    // String d = Date.today().Day() > 9 ? Date.today().Day() : '0' + Date.today().Day();
    // String currentPeriod = Date.today().Year() + '-' + m + '-' + d;  
    // String query = 'SELECT Id, project__c, name, project__r.Base_URL__c , project__r.Project_ID_Text__c, project__r.Name, project__r.Link, project__r.owner.email FROM ampi__activity__c WHERE ampi__status__c = \'' + 'New'  + '\' AND project__r.ampi__project_status__c IN (\'' + 'In Implementation' + '\') AND project__r.owner.email <> NULL AND project__c NOT IN (SELECT Related_Project__c FROM Notification__c WHERE Period_Identifier__c = \'' + currentPeriod + '\') ORDER BY project__c, Name LIMIT 100';     
    String query = 'SELECT Id, project__c, name, project__r.Base_URL__c , project__r.Project_ID_Text__c, project__r.Name, project__r.ownerId, project__r.owner.email FROM ampi__activity__c WHERE ampi__status__c = \'' + 'New'  + '\' AND project__r.ampi__project_status__c IN (\'' + 'In Implementation' + '\') AND project__r.owner.email <> NULL ORDER BY project__c, Name';     
    System.debug('>>>> start ' + query);
    return Database.getQuerylocator(query);
  } 
  
  // The batch job executes and operates on one batch of records
  global void execute(Database.BatchableContext bc, List<sObject> scope){
  System.debug('>>>> execute ' + scope.size());
	List<ampi__activity__c > periods = new List<ampi__activity__c >();
	String emailTemplateName = 'Projects_In_Implementation_Notify_For_New_Activities_Monthly';
    
        List<EmailTemplate> lstEmailTemplates = [SELECT Id, HtmlValue, Body, Subject from EmailTemplate where DeveloperName =: emailTemplateName];
        System.debug('###notificationForPSAandIOR emailTemplateName: ' + emailTemplateName);
        System.debug('###notificationForPSAandIOR lstEmailTemplates: ' + lstEmailTemplates);
        System.debug('###notificationForPSAandIOR lstEmailTemplates.size(): ' + lstEmailTemplates.size());
                
        if (lstEmailTemplates.size() > 0) {
            String projectName = '';
            String projectID = '';
            String project = '';
            String ownerEmail = '';
            String ownerId = '';
            String projectLink = '';
            String activitiesFromProject = '';
            Set<String> owners = new Set<String>();
            for(sObject activity : scope) {    
                if ((String)activity.getSobject('project__r').get('Name') != projectName) {
                    if (projectName != '') {
                        owners = new Set<String> {ownerId};
                        sendNotification(projectName, owners, project);                                  
                        sendActivityEmailToOwners(lstEmailTemplates[0], ownerEmail, projectID, projectName, activitiesFromProject, projectLink);                        
                        insertNotification(project);
                    }
                    // activitiesFromProject = '<a href= "/ampi__activity__c/' + (String)activity.get('Id') + '">' + (String)activity.get('Name') + '</a><br>';
                    activitiesFromProject = (String)activity.get('Name');
                    project = (String)activity.get('project__c');
                    projectName = (String)activity.getSobject('project__r').get('Name');
                    projectLink = (String)activity.getSobject('project__r').get('Base_URL__c') + '/' + project;
                    projectID = (String)activity.getSobject('project__r').get('Project_ID_Text__c');
                    if (Test.isRunningTest()) {
                        ownerEmail = 'jorge.salcedo@sos-kd.org';
                        ownerId = UserInfo.getUserId();
                    } else {
                        ownerEmail = (String)activity.getSobject('project__r').getSobject('owner').get('email');                        
                        ownerId = (String)activity.getSobject('project__r').get('ownerId');                        
                    }
                }
                // activitiesFromProject += ' / ' + '<a href= "/ampi__activity__c/' + (String)activity.get('Id') + '">' + (String)activity.get('Name') + '</a><br>';
                activitiesFromProject += ' / ' + (String)activity.get('Name');
          	}
            
            if (scope.size() > 0 && ownerEmail <> '') {
              owners = new Set<String> {ownerId};
              sendNotification(projectName, owners, project);                                  
            	sendActivityEmailToOwners(lstEmailTemplates[0], ownerEmail, projectID, projectName, activitiesFromProject, projectLink);
              insertNotification(project);   
            }
    	}
  }
  
   global void sendNotification(String projectName, Set<String> recipientsIds, String targetId) {
        String title = 'Please Check Activities in status New From Projects';
        String message = 'Hello! Activities in status "New" from Project "' + projectName + '" which status is "In Implementation" are sent for revision.';
        notifyUsers(recipientsIds, targetId, title, message);
    }    
    
    global void notifyUsers(Set<String> recipientsIds, String targetId, String title, String message) {
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

    global void insertNotification(String projectId) {
        // Notification__c pi = new Notification__c();
        // String m = Date.today().Month() > 9 ? '' + Date.today().Month() : '0' + Date.today().Month();
        // String d = Date.today().Day() > 9 ? '' + Date.today().Day() : '0' + Date.today().Day();
        // pi.Period_Identifier__c = Date.today().Year() + '-' + m + '-' + d;  
        // pi.Related_Project__c = projectId;
        // INSERT pi;
    }
    
    global void sendActivityEmailToOwners(EmailTemplate template, String ownerEmail, String projectID, String projectName, String activitiesFromProject, String projectLink) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(template.Id);
        mail.setSaveAsActivity(false);
        mail.setTargetObjectId(userinfo.getUserId());// Any contact or User id of your record
                
        List<String> receivers = new List<String>();
        receivers.add(ownerEmail);
        String plainBody = template.Body;
                        
        plainBody = plainBody.replace('{!ampi__Project__c.Project_ID_Text__c}', ' ' + projectID);
        plainBody = plainBody.replace('{!ampi__Project__c.Name}', ' ' + projectName);
        plainBody = plainBody.replace('{!ampi__Project__c.Link}', ' ' + projectLink);
        plainBody = plainBody.replace('{!ampi__Project__c.Activities}', ' ' + activitiesFromProject);
        mail.setToAddresses(receivers);
        mail.setPlainTextBody(plainBody);
        Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        //INSERT LOG ACTIVITY SEND EMAIL RECORD
    }
  
  // The batch job finishes
  global void finish(Database.BatchableContext bc){
    AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :bc.getJobId()]; 
    System.debug('>>>> finish ' + job.Status);
  }
}