@isTest
private class csvUploaderControllerTest {
    @isTest
    static void csvUploaderController_saveFile_CountMoreThanZero() {
        String str = JSON.serialize('Name,Site,Account Source\nGoogle,https://google.com,Web');        
         List<Account> accs = csvUploaderController.saveFile(str);     
         List<Contact> accNew = csvUploaderController.getAccountDataToExport();
         System.assert(accs.size() > 0);
    }
}