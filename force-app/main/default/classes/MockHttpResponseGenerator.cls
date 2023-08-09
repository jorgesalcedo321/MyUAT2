/****************************************************************************************
* Class: MockHttpResponseGenerator
* Created By: Ajinkya Hingne
----------------------------------------------------------------------------------------
* Description: Class to generate mock response.
----------------------------------------------------------------------------------------
* Version History:
* VERSION     DEVELOPER NAME       DATE            DETAIL FEATURES
https://vera.my.salesforce.com/
  1.0         Ajinkya Hingne       24/10/2019      Initial Development
***************************************************************************************/
@isTest
global with sharing class MockHttpResponseGenerator implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        if (request.getEndpoint().endsWith('/token')) {
            response.setBody(
                '{ ' +
                    '"statusId" : 1, ' +
                    '"access_token" : "DUMMY_TOKEN", ' +
                    '"message" : "Token Generated Successfully"' +
                '}'
            );
            response.setStatusCode(200);
        }
        else if (request.getEndpoint().endsWith('/Async')) {
            response.setBody('{"message" : "Workspace creation Initiated"}');
            response.setStatusCode(202);
        }
        return response;
    }
}