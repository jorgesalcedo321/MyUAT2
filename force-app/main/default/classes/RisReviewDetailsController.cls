public class RisReviewDetailsController {
     public ampi__Risk_Assessment__c riskReview {get;set;}
     public String language {get;set;}
     public String description_Translated {get;set;}
     public String conflict_Response_Translated {get;set;}
     public String crime_Security_Response_Translated {get;set;}
     public String social_Political_Response_Translated {get;set;}
     public String terrorism_Response_Translated {get;set;}
     public String kidnap_Response_Translated {get;set;}
     public String humanitarian_Space_Response_Translated {get;set;}
     public String infrastructure_Response_Translated {get;set;}

     public RisReviewDetailsController(ApexPages.StandardController controller){
         ampi__Risk_Assessment__c currentRecord = (ampi__Risk_Assessment__c) controller.getRecord();
         riskReview = getRiskReviewById(currentRecord.Id);
         language = getFullLanguageName(getCurrentShortUserLanguage());
         setTranslatedValuesOnProperties(language);
    }
    
    public void setTranslatedValuesOnProperties(String currentUserLanguage) {
        if (currentUserLanguage == 'Spanish') {
        	conflict_Response_Translated = riskReview.Conflict_Response_Language_1__c;
            crime_Security_Response_Translated = riskReview.Crime_Security_Response_Language_1__c;
            social_Political_Response_Translated = riskReview.Social_Political_Response_Language_1__c;
            terrorism_Response_Translated = riskReview.Terrorism_Response_Language_1__c;
            kidnap_Response_Translated = riskReview.Kidnap_Response_Language_1__c;
            humanitarian_Space_Response_Translated = riskReview.Humanitarian_Space_Response_Language_1__c;
            infrastructure_Response_Translated = riskReview.Infrastructure_Response_Language_1__c;
            description_Translated =  riskReview.Description_Language_1__c;
        } else if (currentUserLanguage == 'French') {
        	conflict_Response_Translated = riskReview.Conflict_Response_Language_2__c;
            crime_Security_Response_Translated = riskReview.Crime_Security_Response_Language_2__c;
            social_Political_Response_Translated = riskReview.Social_Political_Response_Language_2__c;
            terrorism_Response_Translated = riskReview.Terrorism_Response_Language_2__c;
            kidnap_Response_Translated = riskReview.Kidnap_Response_Language_2__c;
            humanitarian_Space_Response_Translated = riskReview.Humanitarian_Space_Response_Language_2__c;
            infrastructure_Response_Translated = riskReview.Infrastructure_Response_Language_2__c;
            description_Translated =  riskReview.Description_Language_2__c;
        } else if (currentUserLanguage == 'Russian') {
        	conflict_Response_Translated = riskReview.Conflict_Response_Language_3__c;
            crime_Security_Response_Translated = riskReview.Crime_Security_Response_Language_3__c;
            social_Political_Response_Translated = riskReview.Social_Political_Response_Language_3__c;
            terrorism_Response_Translated = riskReview.Terrorism_Response_Language_3__c;
            kidnap_Response_Translated = riskReview.Kidnap_Response_Language_3__c;
            humanitarian_Space_Response_Translated = riskReview.Humanitarian_Space_Response_Language_3__c;
            infrastructure_Response_Translated = riskReview.Infrastructure_Response_Language_3__c;
            description_Translated =  riskReview.Description_Language_3__c;
        } else {
        	conflict_Response_Translated = riskReview.Conflict_Response__c;        
            crime_Security_Response_Translated = riskReview.Crime_Security_Response__c;
            social_Political_Response_Translated = riskReview.Social_Political_Response__c;
            terrorism_Response_Translated = riskReview.Terrorism_Response__c;
            kidnap_Response_Translated = riskReview.Kidnap_Response__c;
            humanitarian_Space_Response_Translated = riskReview.Humanitarian_Space_Response__c;
            infrastructure_Response_Translated = riskReview.Infrastructure_Response__c;
            description_Translated =  riskReview.Description__c;
        }
        
        
    }
	public static ampi__Risk_Assessment__c getRiskReviewById(String riskAssessmentId) {
		return [SELECT Conflict_Comments__c, 
                Conflict_Response__c,
                Conflict_Response_Language_1__c,
                Conflict_Response_Language_2__c,
                Conflict_Response_Language_3__c,
                Conflict_Score__c,
                Crime_Security_Comments__c,
                Crime_Security_Response__c,
                Crime_Security_Response_Language_1__c,
                Crime_Security_Response_Language_2__c,
                Crime_Security_Response_Language_3__c,
                Crime_Security_Score__c,
                Description__c,
                Description_Language_1__c,
                Description_Language_2__c,
                Description_Language_3__c,
                Description_Translated__c,
                Humanitarian_Space_Comments__c,
                Humanitarian_Space_Response__c,
                Humanitarian_Space_Response_Language_1__c,
                Humanitarian_Space_Response_Language_2__c,
                Humanitarian_Space_Response_Language_3__c,
                Humanitarian_Space_Score__c,
                Id,
                Infrastructure_Comments__c,
                Infrastructure_Response__c,
                Infrastructure_Response_Language_1__c,
                Infrastructure_Response_Language_2__c,
                Infrastructure_Response_Language_3__c,
                Infrastructure_Score__c,
                Kidnap_Comments__c,
                Kidnap_Response__c,
                Kidnap_Response_Language_1__c,
                Kidnap_Response_Language_2__c,
                Kidnap_Response_Language_3__c,
                Kidnap_Score__c,
                Language_Info__c,
                Social_Political_Comments__c,
                Social_Political_Response__c,
                Social_Political_Response_Language_1__c,
                Social_Political_Response_Language_2__c,
                Social_Political_Response_Language_3__c,
                Social_Political_Score__c,
                Terrorism_Comments__c,
                Terrorism_Response__c,
                Terrorism_Response_Language_1__c,
                Terrorism_Response_Language_2__c,
                Terrorism_Response_Language_3__c,
                Terrorism_Score__c,
				Total_Score__c FROM ampi__Risk_Assessment__c WHERE Id =: riskAssessmentId];
	}
    public static String getCurrentShortUserLanguage() {
        User u = [SELECT toLabel(LanguageLocaleKey) FROM User WHERE Id = :UserInfo.getUserId()];		
		return u.LanguageLocaleKey.trim();    
    }
    
    public static String getFullLanguageName(String shortLanguageCode) { 
		System.debug('#### getFullLanguageName: ' + shortLanguageCode);
        if (shortLanguageCode == 'Español') {
              return 'Spanish';
        } else if (shortLanguageCode == 'Русский') {
			  return 'Russian';
        } else if (shortLanguageCode == 'Français') {
              return 'French';
        } else {
			return 'English';
		}
    }
}