trigger LeadTrigger on Lead (before update) {
    List<Historical_Lead__c> historicalLeadList = new List<Historical_Lead__c>();
    for(Lead lead:System.Trigger.new) {
        if (Lead.IsConverted){s
            historicalLeadList.add(new Historical_Lead__c(
                Lead__c = lead.Id,
                Contact__c = lead.ConvertedContactId
            ));
        }
        //do somethign here with converted leads
    }

    insert historicalLeadList;
}