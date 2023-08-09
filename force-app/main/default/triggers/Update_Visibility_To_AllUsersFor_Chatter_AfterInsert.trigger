trigger Update_Visibility_To_AllUsersFor_Chatter_AfterInsert on FeedItem (after insert)  { 
    List<FeedItem> newFeedItems = [SELECT Id, Type, Visibility FROM FeedItem WHERE Id IN :Trigger.new];
    for (FeedItem newFeedItem : newFeedItems) { 
        if(newFeedItem.Type == 'TextPost') {
            if (Schema.sObjectType.FeedItem.fields.Visibility.isUpdateable()) {
                newFeedItem.Visibility = 'AllUsers';
            }
        }
    }
    UPDATE newFeedItems;
}