@isTest 
private class ChangeVisibilityToPublicOnTask_Test {

	@isTest
	private static void CheckIfTaskWasChanged_PublicVisibilityEnabled() {
		Id recordTypeIDForProject = Schema.getGlobalDescribe().get('ampi__Project__c').getDescribe().getRecordTypeInfosByName().get('YouthCan! Project').getRecordTypeId();
		ampi__Project__c newProject = new ampi__Project__c();
		date currentToday = date.today();
		Datetime currentDate = Datetime.newInstance(currentToday.year(), currentToday.month(), currentToday.day());
		String formattedDate = currentDate.format('yyyy-MM-dd');

		newProject.Name = 'Test Project ' + formattedDate;
		newProject.RecordTypeId = recordTypeIDForProject;
		
		insert newProject;
		System.debug('##### newProject:' + newProject);
		 
		List<ampi__Project__c> newProjects = [SELECT Id FROM ampi__Project__c WHERE Name =: newProject.Name];
		System.debug('##### newProject count:' + newProjects.size());

		Test.startTest();
		List<Task> newTasks = new List<Task>();
		Task newTask = new Task();
		newTask.IsVisibleInSelfService = false;
		newTask.Description__c = 'Task Project ' + formattedDate;
		newTask.Project__c = newProjects.get(0).Id;
		newTasks.add(newTask);
		Database.insert(newTasks);

		newTasks = [SELECT Id FROM Task WHERE Description__c =: newTask.Description__c AND IsVisibleInSelfService = true];

		System.debug('#### newTasks: ' + newTasks);
		System.assertEquals(true, newTasks.size() > 0);		
		Test.stopTest();
	}
}