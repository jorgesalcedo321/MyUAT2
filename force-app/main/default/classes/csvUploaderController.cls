public class csvUploaderController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getAccountDataToExport(){
        return [SELECT Id, FirstName, LastName, Email FROM Contact LIMIT 10];
    }

    @AuraEnabled
    public static List<Account> saveFile(String base64Data) {
        String data = JSON.deserializeUntyped(base64Data).toString();
        list<Account> lstCCToInsert = new list<Account>();
        list<String> lstCSVLines = data.split('\n');
        
        for(Integer i = 1; i < lstCSVLines.size(); i++)
        {
            Account acc = new Account();
            String csvLine = lstCSVLines[i];
            String prevLine = csvLine;
            Integer startIndex = null;
            Integer endIndex = null;
            
            while(csvLine.indexOf('"') > -1)
            {           
                if(startIndex == null) {
                    startIndex = csvLine.indexOf('"');
                    csvLine = csvLine.substring(0, startIndex) + ':quotes:' + csvLine.substring(startIndex+1, csvLine.length());
                } else {
                    if(endIndex == null) {
                        endIndex = csvLine.indexOf('"');
                        csvLine = csvLine.substring(0, endIndex) + ':quotes:' + csvLine.substring(endIndex+1, csvLine.length());
                    }
                }
                
                if(startIndex != null && endIndex != null) {
                    csvLine = csvLine.substring(0, startIndex) + csvLine.substring(startIndex, endIndex).replaceAll(',', ':comma:') + csvLine.substring(endIndex, csvLine.length());
                }
            }
            
            List<String> csvRowData = new List<String>();
            for(String column : csvLine.split(','))
            {
                column = column.replaceAll(':quotes:', '').replaceAll(':comma:', ',');
                csvRowData.add(column);
            }
            
            csvLine = '';
            prevLine = '';
            startIndex = 0;
            endIndex = 0;
			csvLine = '';
            prevLine = '';
            startIndex = null;
            endIndex = null;
            
            acc.Name = csvRowData[0];
            acc.Site = csvRowData[1];
            acc.AccountSource = csvRowData[2];
            lstCCToInsert.add(acc);
        }
        
        insert lstCCToInsert;
        return [Select Id, Name, Site, AccountSource From Account Where CreatedDate>=:Date.TODAY()];
    }
}