public class ComponentService {
    @AuraEnabled
    public static list<EventObj> getEvents(String accountId){
        List<Event> eventlist =[SELECT Id, EndDateTime,StartDateTime,Subject,Description,OwnerId,WhoId,Account__c,who.name,Client_Email__c FROM Event WHERE Account__c =:accountId];
        List<EventObj> eventRecords = new List<EventObj>();
      
        for (Event evt : eventlist) {
            EventObj newEv = new EventObj(evt.Id,evt.Subject,evt.StartDateTime,evt.EndDateTime,evt.Description,evt.OwnerId,evt.WhoId,evt.Account__c,evt.who.name,evt.Client_Email__c);                          
            eventRecords.add(newEv);
        }
      
        return eventRecords;
    }

    @AuraEnabled
    public static list<EventObj> getEventsByContacts(String accountId,List<String> contactsIdList){
        List<Event> eventlist =[SELECT Id, EndDateTime,StartDateTime,Subject,Description,OwnerId,WhoId,Account__c,who.name,Client_Email__c FROM Event WHERE Account__c =:accountId AND WhoId IN:contactsIdList];
        List<EventObj> eventRecords = new List<EventObj>();
      
        for (Event evt : eventlist) {
            EventObj newEv = new EventObj(evt.Id,evt.Subject,evt.StartDateTime,evt.EndDateTime,evt.Description,evt.OwnerId,evt.WhoId,evt.Account__c,evt.who.name,evt.Client_Email__c);                          
            eventRecords.add(newEv);
        }
      
        return eventRecords;
    }

    @AuraEnabled
    public static list<ClinicanObj> getContacts(String accountId){
        List<Contact> contactlist =[SELECT Id,Name,Appointment_Price__c,Specialization__r.Name,Specialization__c FROM Contact WHERE AccountId =:accountId];
        List<ClinicanObj> contactRecords = new List<ClinicanObj>();
      
        for (Contact con : contactlist) {
            ClinicanObj newCon = new ClinicanObj(con.Id,con.Name,con.Specialization__r.Name,con.Specialization__c,String.valueOf(con.Appointment_Price__c));                          
            contactRecords.add(newCon);
        }
      
      return contactRecords;
    }

    @AuraEnabled
    public static list<SpcecjalizationObj> getSpecjalizations(String accountId){
        List<Contact> contactlist =[SELECT Id,Specialization__c FROM Contact WHERE AccountId =:accountId];
        Set<String> specIdSet = new Set<String>();
        for (Contact con : contactlist) {
            specIdSet.add(con.Specialization__c);
        }
        List<Specialization__c> specjalizationlist = [SELECT Id,Name FROM Specialization__c WHERE Id =:specIdSet];
        List<SpcecjalizationObj> specjalizationRecords = new List<SpcecjalizationObj>();
      
        for (Specialization__c spec : specjalizationlist) {
            SpcecjalizationObj newSpec = new SpcecjalizationObj(spec.Id,spec.Name);                          
            specjalizationRecords.add(newSpec);
      }
      
      return specjalizationRecords;
    }


    @AuraEnabled
    public static EventObj upsertEvents(String sEventObj){
        EventObj upsertingEvent = (EventObj)JSON.deserialize(sEventObj, EventObj.class);
        Event evt = new Event(
          Id = upsertingEvent.Id,
          Subject = upsertingEvent.title,
          StartDateTime = upsertingEvent.startDateTime,
          EndDateTime = upsertingEvent.endDateTime,
          Description = upsertingEvent.description,
          WhoId = upsertingEvent.contactId,
          Account__c = upsertingEvent.accountId,
          Client_Email__c = upsertingEvent.email
        );
        
        try {
            upsert evt;
            evt =[SELECT Id, EndDateTime,StartDateTime,Subject,Description,OwnerId,WhoId,Account__c,who.name,Client_Email__c FROM Event WHERE Id =:evt.Id];

            EventObj newEv = new EventObj(evt.Id,evt.Subject,evt.StartDateTime,evt.EndDateTime,evt.Description,evt.OwnerId,evt.WhoId,evt.Account__c,evt.who.name,evt.Client_Email__c);                          

            return newEv;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }

    @AuraEnabled
    public static String deleteEvent(String eventId){
        Event evt = [SELECT Id FROM Event WHERE Id =:eventId];
        try {
            delete evt;
            return eventId;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
        
    }

    public class EventObj {
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String title {get;set;}
        @AuraEnabled
        public DateTime startDateTime {get;set;}
        @AuraEnabled
        public DateTime endDateTime {get;set;}
        @AuraEnabled
        public String description {get;set;}
        @AuraEnabled
        public String owner {get;set;}
        @AuraEnabled
        public String contactId {get;set;}
        @AuraEnabled
        public String accountId {get;set;}
        @AuraEnabled
        public String contactName {get;set;}
        @AuraEnabled
        public String email {get;set;}

        public EventObj(String i,String t, DateTime s, DateTime e, String d, String o,String w,String a){
            this.Id = i;
            this.title = t;
            this.startDateTime = s;
            this.endDateTime = e;
            this.description = d;
            this.owner = o;
            this.contactId = w;
            this.accountId = a;
        }
      
        public EventObj(String i,String t, DateTime s, DateTime e, String d, String o,String w,String a, String n,String em){
            this.Id = i;
            this.title = t;
            this.startDateTime = s;
            this.endDateTime = e;
            this.description = d;
            this.owner = o;
            this.contactId = w;
            this.accountId = a;
            this.contactName = n;
            this.email = em;
        }
      
    }

    public class ClinicanObj {
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String specjalization {get;set;}
        @AuraEnabled
        public String specjalizationId {get;set;}
        @AuraEnabled
        public String price {get;set;}

        public ClinicanObj(String i,String n, String s,String si, String p){
            this.Id = i;
            this.name = n;
            this.specjalization = s;
            this.specjalizationId = si;
            this.price = p;
        }

    }

    public class SpcecjalizationObj {
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String name {get;set;}
        
        public SpcecjalizationObj(String i,String n){
            this.Id = i;
            this.name = n;
        }
    }
}