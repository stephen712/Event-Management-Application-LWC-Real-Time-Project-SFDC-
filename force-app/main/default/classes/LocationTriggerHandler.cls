public class LocationTriggerHandler {
    @future(callout=true)
    public static void verifyAddress(String recordId){
        Location__c loc = [SELECT Id,Name,Street__c,City__c,Postal_Code__c,
                           State__c FROM Location__c WHERE Id=: recordId];
        String baseURL  = 'https://us-street.api.smartystreets.com/street-address?auth-id=83335904-49f9-8fde-f0ef-11c680114ff1&auth-token=vH7n0rE9Q5adL75k11b5';
        baseURL += '&street='+EncodingUtil.urlEncode(loc.Street__c, 'UTF-8')+
            		'&city=' +EncodingUtil.urlEncode(loc.City__c, 'UTF-8') +
            		'&state='+EncodingUtil.urlEncode(loc.State__c, 'UTF-8')
            	    +'&zipcode='+EncodingUtil.urlEncode(loc.Postal_Code__c, 'UTF-8')
            	    +'&match=invalid&candidates=10';
        
        HttpRequest httpReq = new HttpRequest();
        httpReq.setMethod('GET');
        httpReq.setEndpoint(baseURL);
        
        Http http = new Http();
        HttpResponse httpRes = new HttpResponse();
        
        
         try{
            httpRes = http.send(httpReq);
            System.debug(' ResponseBody '+httpRes.getBody());
            if( httpRes.getStatusCode() == 200 && httpRes.getStatus() =='OK'){
                String responseBody = httpRes.getBody();
                if(!String.isBlank(responseBody) && responseBody.length() > 2){
                    loc.Verified__c = true;
                }else{
                    loc.Verified__c = false;
                }
                update loc;
            }else{
                TransactionLogHandler.doHandleExceptionWithError( httpRes.getBody() , 'LocationTriggerHandler');
            }
        }catch(System.CalloutException ex ){
            System.debug(' Exception Executed '+ex.getStackTraceString());
            TransactionLogHandler.doHandleException(ex, 'LocationTriggerHandler');
        }
        
    }
}