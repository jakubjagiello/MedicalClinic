public with sharing class GoogleCalendarService {
    
    public static final String AUTH_URL = 'https://www.googleapis.com/oauth2/v4/token';
    public static final String CALENDAR_ID = 'CALENDARID';
    public static final String CALENDAR_URL = 'https://www.googleapis.com/calendar/v3/calendars/' + CALENDAR_ID + '/events';
    public static final String POST_CALL = 'POST';


    public static Map<String,String> googleAuthentication(List<Contact> conList){
        Map<String,String> contactIdToTokenMap = new Map<String,String>();
        for(Contact con : conList){
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setEndpoint(AUTH_URL);
            httpRequest.setMethod(POST_CALL);
            httpRequest.setBody(buildAuthBody(con));
            Http http = new Http();
            if(!System.Test.isRunningTest()){
                HttpResponse response = http.send(httpRequest);
                system.debug(response.getBody());
                GoogleToken googleToken = (GoogleToken)JSON.deserialize(response.getBody(), GoogleToken.class);
                system.debug('Bearer ' + googleToken.access_token);
                contactIdToTokenMap.put(con.Id,'Bearer ' + googleToken.access_token);
                
            }else{
                contactIdToTokenMap.put(con.Id,'token');
            }
        }
        return contactIdToTokenMap;
    }

    

    @future(callout=true)
    public static void sendEventsToGoogleCalendar(List<String> eventIdList){
        List<Event> eventlist =[SELECT Id, EndDateTime,StartDateTime,Subject,Description,OwnerId,WhoId,Account__c,who.name,Client_Email__c 
            FROM Event WHERE Id in:eventIdList];
        Set<String> contactIdSet = new Set<String>();
        for(Event e : eventlist){
            contactIdSet.add(e.WhoId);
        }
        Map<Id,Contact> contactMap = new Map<Id,Contact>([SELECT Id,Google_Secret_Key__c,Google_Token__c,Google_Id__c,Google_Calendar__c FROM Contact WHERE Id in:contactIdSet ]);
        Map<String,String> contactIdToTokenMap = googleAuthentication(contactMap.values());
        for(Event e : eventlist){
            Contact con = contactMap.get(e.WhoId);
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setEndpoint(CALENDAR_URL.replace(CALENDAR_ID,con.Google_Calendar__c));
            httpRequest.setMethod(POST_CALL);
            httpRequest.setHeader('Authorization', contactIdToTokenMap.get(e.WhoId));
            httpRequest.setHeader('Accept', 'application/json');
            httpRequest.setHeader('Content-Type', 'application/json');
            httpRequest.setBody(buildCalendarBody(e));
            Http http = new Http();
            if(!System.Test.isRunningTest()){
                HttpResponse response = http.send(httpRequest);
                system.debug(response);
            }
        }
        

    }

    public static string buildAuthBody(Contact con){
        String authBody = '';
        String clientSecret = 'client_secret=' + con.Google_Secret_Key__c;
        String grantType = 'grant_type=refresh_token&refresh_token=' + con.Google_Token__c;
        String clientId = 'client_id=' + con.Google_Id__c;
        String scope ='scope=https://www.googleapis.com/auth/calendar https://www.googleapis.com/auth/calendar.events';
        String escape = '&';
        authBody += clientSecret + escape + grantType + escape + clientId + escape + scope;
        return authBody;
    }

    public static string buildCalendarBody(Event e){
        String startDate = e.StartDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'+01:00\'');
        String endDate = e.EndDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'+01:00\''); 
        String eventBody = '{"end":{"dateTime":"'+endDate+'"},"start":{"dateTime":"'+startDate+'"},"summary":"'+e.Subject+'","description":"Description: '+e.Description+'"}';
        return eventBody;
    }

    public class GoogleToken{
        public String access_token {get;set;}
        public Integer expires_in {get;set;}
        public String scope {get;set;}
        public String token_type {get;set;}
    }
}