/****************************************************************************************
* Class: ProjectManager
* Created By: Ajinkya Hingne
----------------------------------------------------------------------------------------
* Description: REST API class for ampi__Project__c related operations
----------------------------------------------------------------------------------------
* Version History:
* VERSION     DEVELOPER NAME       DATE            DETAIL FEATURES
https://vera.my.salesforce.com/a041O00000e6qhH
  1.0         Ajinkya Hingne       24/10/2019      Initial Development
***************************************************************************************/
@RestResource(urlMapping='/project/sync/*')
global class ProjectManager {

    @HttpPost
    global static Void syncProject(String projectUrl, String workspaceUrl) {
        RestResponse res = RestContext.response;
        if (projectUrl == null || workspaceUrl == null) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(
                JSON.serialize(new ResponseBody('false', 'Invalid payload.'))
            );
        }
        else {
            try {
                ampi__Project__c project = new ampi__Project__c(
                    Id = projectUrl.substring(projectUrl.lastIndexOf('/') + 1),
                    SharePoint_Team_Site_URL__c = workspaceURL
                );
                update project;
                res.statusCode = 200;
                res.responseBody = Blob.valueOf(
                    JSON.serialize(new ResponseBody('true', ''))
                );
            }
            catch(Exception ex) {
                res.statusCode = 500;
                res.responseBody = Blob.valueOf(
                    JSON.serialize(new ResponseBody('false', ex.getMessage()))
                );
            }
        }
    }

    public class ResponseBody {
        public String isSuccess;
        public String message;

        public ResponseBody(String isSuccess, String message) {
            this.isSuccess = isSuccess;
            this.message = message;
        }
    }

}