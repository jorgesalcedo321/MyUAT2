/****************************************************************************************
* Class: CreateWorkspace_Ctrl
* Created By: Ajinkya Hingne
----------------------------------------------------------------------------------------
* Description: Class to perform server side actions of CreateWorkspace component
----------------------------------------------------------------------------------------
* Version History:
* VERSION     DEVELOPER NAME       DATE            DETAIL FEATURES
https://vera.my.salesforce.com/a041O00000e6qhH
  1.0         Ajinkya Hingne       04/11/2019      Initial Development
***************************************************************************************/
public with sharing class CreateWorkspace_Ctrl {

    @AuraEnabled
    public static Response createWorkspaceForProject(Id projectId) {
        ampi__Project__c project = Project_Domain.getProjectDetails(projectId);
        Response response = new Response();
        if (project.Create_Workspace_Callout_Time__c == null) {
            AuthResponse authResponse = authorizeToSharepoint();
            HttpResponse httpResponse;
            if (authResponse == null || authResponse.access_token == null) {
                // Return an error
                response.message = System.Label.CREATE_WORKSPACE_REQUEST_ERROR_MESSAGE;
                response.isSuccess = false;
            }
            else {
                httpResponse = callCreateWorkspaceAPI(project, authResponse.access_token);
                // Return error or success message
                if (httpResponse.getStatusCode() == 202) {
                    response.message = System.Label.CREATE_WORKSPACE_REQUEST_SUCCESS_MESSAGE;
                    response.isSuccess = true;
                    updateProjectCalloutTime(projectId);
                }
                else {
                    response.message = httpResponse.getStatusCode() + ' ' + httpResponse.getBody();
                    response.isSuccess = false;
                }
            }
        }
        else {
            response.message = System.Label.SHAREPOINT_INTEGRATION_ERROR_MESSAGE;
            response.isSuccess = false;
        }
        return response;
    }

    private static Void updateProjectCalloutTime(Id projectId) {
        ampi__Project__c project = new ampi__Project__c(
            Id = projectId,
            Create_Workspace_Callout_Time__c = System.now()
        );
        Project_Domain.updateProjects(new List<ampi__Project__c>{project});
    }

    private static AuthResponse authorizeToSharepoint() {
        List<Credential__c> credentials = Credential_Domain.getCredential('Sharepoint');

        if (!credentials.isEmpty()) {
            String requestBody = 'grant_type=' + credentials[0].Grant_Type__c +
                '&client_id=' + credentials[0].Client_Id__c +
                '&client_secret=' + credentials[0].Client_Secret__c +
                '&resource=' + credentials[0].Resource__c;

            HttpResponse httpResponse = doCallout(
                System.Label.ACCESS_TOKEN_AUTHORIZATION_URL,
                null,
                requestBody,
                'POST'
            );
            AuthResponse authResponse =
                (AuthResponse)JSON.deserialize(httpResponse.getbody(), AuthResponse.class);
            authResponse.calloutResponse = httpResponse;
            return authResponse;
        }
        return null;
    }

    private static HttpResponse callCreateWorkspaceAPI(
            ampi__Project__c project,
            String accessToken
    ) {
        String projectMembers = '';
        for(Team_Member__c member : project.Team_Members__r) {
            projectMembers += member.User__r.Username + ',';
        }
        projectMembers = projectMembers.removeEnd(',');
        String requestBody =  JSON.serialize(
            new ProjectData(
                project.Project_ID_raw__c,
                project.Name,
                project.ampi__Description__c == null ? '' : project.ampi__Description__c,
                project.Id,
                project.Owner.Username,
                project.ampi__Project_Status__c,
                projectMembers,
                project.SOS_Region__c,
                project.SOS_Implementing_Organisation__r.Name
            )
        );
        Map<String, String> headers = new Map<String, String> {
            'Content-Type' => System.Label.TYPE_APPLICATION_JSON,
            'Origin' => System.Label.SOS_HEADER_ORIGIN_URL,
            'Authorization' => 'Bearer ' + accessToken
        };
        HttpResponse httpResponse = doCallout(
            System.Label.SOS_INTEGRATION_API_URL,
            headers,
            requestBody,
            'POST'
        );
        return httpResponse;
    }

    private static HttpResponse doCallout(
            String endpoint,
            Map<String, String> headers,
            String requestBody,
            String method
    ) {
        HttpRequest request = new HttpRequest();
        request.setEndPoint(endpoint);
        request.setMethod(method);
        request.setBody(requestBody);
        if (headers != null) {
            for (String headerKey : headers.keySet()) {
                request.setHeader(headerKey, headers.get(headerKey));
            }
        }
        Http httpConnection = new Http();
        return httpConnection.send(request);
    }

    /**
     * Wrapper classes
     */
    public class AuthResponse {
        public String access_token;
        public HttpResponse calloutResponse;
    }
    public class Response {
        @AuraEnabled public String message;
        @AuraEnabled public boolean isSuccess;
    }

    public class ProjectData {
        String projectId;
        String projectName;
        String projectDescription;
        String projectUrl;
        String owner;
        String projectStatus;
        String projectMembers;
        String sosRegion;
        String sosImplementingPartner;

        public ProjectData(
            String projectId,
            String projectName,
            String projectDescription,
            Id recordId,
            String owner,
            String projectStatus,
            String projectMembers,
            String sosRegion,
            String sosImplementingPartner
        ) {
            this.projectId = projectId;
            this.projectName = projectName;
            this.projectDescription = projectDescription;
            this.projectUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + recordId;
            this.owner = owner;
            this.projectStatus = projectStatus;
            this.projectMembers = projectMembers;
            this.sosRegion = sosRegion;
            this.sosImplementingPartner = sosImplementingPartner;
        }
    }
}