({
	navigateTo: function(component, recId) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recId
        });
        navEvt.fire();
    },
    getProjectIdByUrl: function(component, sParam) {
        var paramName = 'id=';
        var nextParamCharacter = '&';
        var text2 = window.location.search.substring(1).replaceAll('%3D', '=').replaceAll('%26', nextParamCharacter);
        
        if (text2.indexOf(paramName) >= 0) {
        	var text3 = text2.substring(text2.indexOf(paramName)).replace(paramName, '');
            
            if (text3.indexOf(nextParamCharacter) >= 0) {
                component.set('v.' + sParam, text3.substring(0, text3.indexOf(nextParamCharacter)));  
                alert(text3.substring(0, text3.indexOf(nextParamCharacter)));
                return;
            }
        }
        alert('no project');
    },
    getUrlParameter: function(component, sParam) {
        var sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&'),
            sParameterName,
            i;
        
        var paramName = 'id=';
        var nextParamCharacter = '&';
        var text2 = window.location.search.substring(1).replaceAll('%3D', '=').replaceAll('%26', nextParamCharacter);
        var text3 = text2.substring(text2.indexOf(paramName));
        text3 = text3.replace(paramName, '');
        text3 = text3.substring(0, text3.indexOf(nextParamCharacter));
        
        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');
            
        	if (sParameterName[0] === sParam) {
                var result = sParameterName[1] === undefined ? true : sParameterName[1];
                component.set('v.' + sParam, result);
                return result;
            }
        }
    },
    getRecordTypeName: function(component, objectName, recordTypeId, field) {
        var action = component.get('c.getRecordTypeById');
        action.setParams({ objectName : objectName, recordTypeId : recordTypeId });
        action.setCallback(this, function(response) {
            component.set('v.' + field, response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    getRecordTypeIdByRecordId: function(component, objectName, recId, field) {
        var action = component.get('c.getRecordTypeIdByRecordId');
        action.setParams({ objectName : objectName, recId : recId });
        action.setCallback(this, function(response) {
            component.set('v.' + field, response.getReturnValue());
        });
        $A.enqueueAction(action);
    }
    
})