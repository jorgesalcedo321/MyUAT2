public class TranslateRiskReviewInfo {
  @InvocableMethod(label='Update Risk Reviews' description='Updating current risk review with the according translation by current user language.' category='Risk Review')
  public static void updateCurrentRiskReview(List<ID> ids) {
	List<ampi__Risk_Assessment__c> listRiskReviews = [SELECT Id, Language_Info__c, 
																 Kidnap_Response__c, Kidnap_Response_Language_1__c, Kidnap_Response_Language_2__c, Kidnap_Response_Language_3__c,
																 Infrastructure_Response__c, Infrastructure_Response_Language_1__c, Infrastructure_Response_Language_2__c, Infrastructure_Response_Language_3__c,
																 Humanitarian_Space_Response__c, Humanitarian_Space_Response_Language_1__c, Humanitarian_Space_Response_Language_2__c, Humanitarian_Space_Response_Language_3__c,
																 Crime_Security_Response__c, Crime_Security_Response_Language_1__c, Crime_Security_Response_Language_2__c, Crime_Security_Response_Language_3__c,
																 Conflict_Response__c, Conflict_Response_Language_1__c, Conflict_Response_Language_2__c, Conflict_Response_Language_3__c,
																 Social_Political_Response__c, Social_Political_Response_Language_1__c, Social_Political_Response_Language_2__c, Social_Political_Response_Language_3__c,
																 Terrorism_Response__c, Terrorism_Response_Language_1__c, Terrorism_Response_Language_2__c, Terrorism_Response_Language_3__c
                                                      FROM ampi__Risk_Assessment__c WHERE Id =:ids];
    
	User u = [SELECT toLabel(LanguageLocaleKey) FROM User WHERE Id = :UserInfo.getUserId()];
	String shortDestination = u.LanguageLocaleKey.left(2).toLowerCase();
    String destination = GetFullLanguageName(shortDestination);
            
    String query = 'SELECT Description_Russian__c, Description_Spanish__c,  Description_English__c, Description_French__c FROM NA_Risk_Matrix__mdt';
	List<sObject> matrix = Database.query(query);  
    System.debug('####Matrix items: ' + matrix);

	for (sObject item: matrix) {
        //System.debug('##### listRiskReviews[0].Kidnap_Response__c:' + listRiskReviews[0].Kidnap_Response__c);
        //System.debug('##### (String)item.get(Description_destination__c):' + (String)item.get('Description_' + destination + '__c'));
        if (listRiskReviews[0].Kidnap_Response__c == (String)item.get('Description_' + destination + '__c')) {
            System.debug('!Enterhere');
			listRiskReviews[0].Kidnap_Response__c = (String)item.get('Description_English__c');
            listRiskReviews[0].Kidnap_Response_Language_1__c = (String)item.get('Description_Spanish__c');
            listRiskReviews[0].Kidnap_Response_Language_2__c = (String)item.get('Description_French__c');
            listRiskReviews[0].Kidnap_Response_Language_3__c = (String)item.get('Description_Russian__c');
        }
		if (listRiskReviews[0].Infrastructure_Response__c == (String)item.get('Description_' + destination + '__c')) {
            System.debug('!Enterhere1');
			listRiskReviews[0].Infrastructure_Response__c = (String)item.get('Description_English__c');
            listRiskReviews[0].Infrastructure_Response_Language_1__c = (String)item.get('Description_Spanish__c');
            listRiskReviews[0].Infrastructure_Response_Language_2__c = (String)item.get('Description_French__c');
            listRiskReviews[0].Infrastructure_Response_Language_3__c = (String)item.get('Description_Russian__c');
        }
        if (listRiskReviews[0].Humanitarian_Space_Response__c == (String)item.get('Description_' + destination + '__c')) {
            System.debug('!Enterhere2');
			listRiskReviews[0].Humanitarian_Space_Response__c = (String)item.get('Description_English__c');
            listRiskReviews[0].Humanitarian_Space_Response_Language_1__c = (String)item.get('Description_Spanish__c');
            listRiskReviews[0].Humanitarian_Space_Response_Language_2__c = (String)item.get('Description_French__c');
            listRiskReviews[0].Humanitarian_Space_Response_Language_3__c = (String)item.get('Description_Russian__c');            
        }
        if (listRiskReviews[0].Crime_Security_Response__c == (String)item.get('Description_' + destination + '__c')) {
            System.debug('!Enterhere3');
			listRiskReviews[0].Crime_Security_Response__c = (String)item.get('Description_English__c');
            listRiskReviews[0].Crime_Security_Response_Language_1__c = (String)item.get('Description_Spanish__c');
            listRiskReviews[0].Crime_Security_Response_Language_2__c = (String)item.get('Description_French__c');
            listRiskReviews[0].Crime_Security_Response_Language_3__c = (String)item.get('Description_Russian__c');
        }
        if (listRiskReviews[0].Conflict_Response__c == (String)item.get('Description_' + destination + '__c')) {
            System.debug('!Enterhere4');
			listRiskReviews[0].Conflict_Response__c = (String)item.get('Description_English__c');
            listRiskReviews[0].Conflict_Response_Language_1__c = (String)item.get('Description_Spanish__c');
            listRiskReviews[0].Conflict_Response_Language_2__c = (String)item.get('Description_French__c');
            listRiskReviews[0].Conflict_Response_Language_3__c = (String)item.get('Description_Russian__c');
        }
        if (listRiskReviews[0].Social_Political_Response__c == (String)item.get('Description_' + destination + '__c')) {
            System.debug('!Enterhere5');
			listRiskReviews[0].Social_Political_Response__c = (String)item.get('Description_English__c');
            listRiskReviews[0].Social_Political_Response_Language_1__c = (String)item.get('Description_Spanish__c');
            listRiskReviews[0].Social_Political_Response_Language_2__c = (String)item.get('Description_French__c');
            listRiskReviews[0].Social_Political_Response_Language_3__c = (String)item.get('Description_Russian__c');
        }
        if (listRiskReviews[0].Terrorism_Response__c == (String)item.get('Description_' + destination + '__c')) {
			System.debug('!Enterhere6');
            listRiskReviews[0].Terrorism_Response__c = (String)item.get('Description_English__c');
            listRiskReviews[0].Terrorism_Response_Language_1__c = (String)item.get('Description_Spanish__c');
            listRiskReviews[0].Terrorism_Response_Language_2__c = (String)item.get('Description_French__c');
            listRiskReviews[0].Terrorism_Response_Language_3__c = (String)item.get('Description_Russian__c');            
        }
     }
	 listRiskReviews[0].Language_Info__c = shortDestination;            
     update listRiskReviews;
   }
    
    public static String GetFullLanguageName(String shortLanguageCode) { 
        if (shortLanguageCode == 'es') {
              return 'Spanish';
        } else if (shortLanguageCode == 'ru') {
              return 'Russian';
        } else if (shortLanguageCode == 'fr') {
              return 'French';
        }
        return 'English';
    }
}