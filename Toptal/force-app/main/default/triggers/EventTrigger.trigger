trigger EventTrigger on Event (before insert,before update,after insert) {
    if(Trigger.isBefore){
        Set<String> contactIdSet = new Set<String>();
        Map<String,List<Event>> contactIdEventMap = new Map<String,List<Event>>();
        List<Event> eventList = new List<Event>();
        if(Trigger.isInsert){
            for(Event e : Trigger.New){
                if(e.Client_Email__c != null){
                    contactIdSet.add(e.whoId);
                }
            }
            eventList = [SELECT StartDateTime,EndDateTime,WhoId FROM Event WHERE WhoId in:contactIdSet AND StartDateTime >=: datetime.now() AND Client_Email__c != null];
              
        }
        if(Trigger.isUpdate){
            Set<String> currenctEventIdSet = new Set<String>();
            for(Event e : Trigger.New){
                if(e.Client_Email__c != null){
                    contactIdSet.add(e.whoId);
                    currenctEventIdSet.add(e.Id);
                }
            }
            eventList = [SELECT StartDateTime,EndDateTime,WhoId FROM Event WHERE WhoId in:contactIdSet AND StartDateTime >=: DateTime.now() AND Client_Email__c != null AND Id !=: currenctEventIdSet];
              
        }
        for(Event e : eventList){
            if(contactIdEventMap.containsKey(e.WhoId)){
                contactIdEventMap.get(e.WhoId).add(e);
            }else{
                contactIdEventMap.put(e.WhoId,new List<Event>{e});
            }
        }  
        for(Event e : Trigger.New){
            if(contactIdEventMap.containsKey(e.WhoId)){
                for(Event eOld : contactIdEventMap.get(e.WhoId)){
                    if(e.EndDateTime > eold.StartDateTime && e.EndDateTime<=eold.EndDateTime){
                        e.addError('Clinician already have a meeting at that time');
                    }else if(e.StartDateTime >= eold.StartDateTime && e.StartDateTime<eold.EndDateTime){
                        e.addError('Clinician already have a meeting at that time');
                    }else if(e.StartDateTime >= eold.StartDateTime && e.EndDateTime<=eold.EndDateTime){
                        e.addError('Clinician already have a meeting at that time');
                    }else if(e.StartDateTime <= eold.StartDateTime && e.EndDateTime>eold.EndDateTime){
                        e.addError('Clinician already have a meeting at that time');
                    }
                }
            }
        }
        
    }
    if(Trigger.isAfter && Trigger.isInsert){
        Set<String> contactIdSet = new Set<String>();
        List<String> eventForSycIdList = new List<String>();
        system.debug('start');

        for(Event e : Trigger.New){
            if(e.Account__c != null){
                contactIdSet.add(e.whoId);
            }
        }
        Map<Id,Contact> contactMap = new Map<Id,Contact>([SELECT Id,Google_Calendar_Ready__c FROM Contact WHERE Id =:contactIdSet]);
        for(Event e : Trigger.New){
            if(e.Account__c != null){
                if(contactMap.get(e.WhoId).Google_Calendar_Ready__c){
                    eventForSycIdList.add(e.Id);
                }
            }
        }
        if(!eventForSycIdList.isEmpty()){
            system.debug(eventForSycIdList);
            GoogleCalendarService.sendEventsToGoogleCalendar(eventForSycIdList);
        }
    }


}