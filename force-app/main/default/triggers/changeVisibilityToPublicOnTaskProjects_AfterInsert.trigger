trigger changeVisibilityToPublicOnTaskProjects_AfterInsert on Task (after insert)  { 
    System.debug('####enter trigger');
    List<Task> newTasks = [SELECT Id, Project__c, IsVisibleInSelfService FROM Task WHERE Id IN :Trigger.new];
    System.debug('####enter to trigger:' + newTasks);
    for (Task newTask : newTasks) { 
        if(newTask.Project__c != null) {
            if (Schema.sObjectType.Task.fields.IsVisibleInSelfService.isUpdateable()) {
                newTask.IsVisibleInSelfService = true;
            }
        }
    }
    System.debug('####enter to trigger update:' + newTasks);
    UPDATE newTasks;
}