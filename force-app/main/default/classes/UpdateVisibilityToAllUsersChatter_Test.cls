@isTest 
private class UpdateVisibilityToAllUsersChatter_Test {

	@isTest
	private static void UpdateVisibilityToAllUsersChatter() {
		Id recordTypeIDForProject = Schema.getGlobalDescribe().get('ampi__Project__c').getDescribe().getRecordTypeInfosByName().get('YouthCan! Project').getRecordTypeId();
		date currentToday = date.today();
		Datetime currentDate = Datetime.newInstance(currentToday.year(), currentToday.month(), currentToday.day());
		String formattedDate = currentDate.format('yyyy-MM-dd');
		
		ampi__Project__c newProject = new ampi__Project__c();
		newProject.Name = 'Test Project ' + formattedDate;
		newProject.RecordTypeId = recordTypeIDForProject;
		insert newProject;

		List<ampi__Project__c> newProjects = [SELECT Id FROM ampi__Project__c WHERE Name =: newProject.Name];

		Test.startTest();
		List<FeedItem> newFeedItems = new List<FeedItem>();
		FeedItem newFeedItem = new FeedItem();
		newFeedItem.Type = 'TextPost';
		newFeedItem.ParentId = newProjects.get(0).Id;
		newFeedItem.Body = 'feedItemTest: ' + formattedDate;
		newFeedItem.Title = 'feedItemTest: ' + formattedDate;
		newFeedItem.Visibility = 'InternalUsers';
		newFeedItems.add(newFeedItem);
		Database.insert(newFeedItems);

		newFeedItems = [SELECT Id FROM FeedItem WHERE Title =: newFeedItem.Title AND Visibility = 'AllUsers'];

		System.debug('#### newFeedItems: ' + newFeedItems);
		System.assertEquals(true, newFeedItems.size() > 0);
		Test.stopTest();
	}
}