@isTest
public class ComponentService_Test {
    @isTest
    static void getEventsTest() {
        Specialization__c spec = new Specialization__c(Name = 'test', Appointment_Price__c = 200);
        insert spec;
        Account acc = new Account(Name = 'testAcc');
        insert acc;
        Contact con = new Contact(LastName = 'testCon', Specialization__c = spec.Id,AccountId = acc.Id);
        insert con;

        Event evt = new Event(
            Subject = 'test',
            StartDateTime = DateTime.now(),
            EndDateTime = DateTime.now().addHours(2),
            Description = 'test desc',
            WhoId = con.Id,
            Account__c = acc.Id,
            Client_Email__c = 'test@testtoptalemai.com'
        );
        Test.startTest();
        insert evt;
        System.assertEquals(1,ComponentService.getEvents(acc.Id).size());
        Test.stopTest();
    }

    @isTest
    static void getEventsByContactsTest() {
        Specialization__c spec = new Specialization__c(Name = 'test', Appointment_Price__c = 200);
        insert spec;
        Account acc = new Account(Name = 'testAcc');
        insert acc;
        Contact con = new Contact(LastName = 'testCon', Specialization__c = spec.Id,AccountId = acc.Id);
        insert con;

        Event evt = new Event(
            Subject = 'test',
            StartDateTime = DateTime.now(),
            EndDateTime = DateTime.now().addHours(2),
            Description = 'test desc',
            WhoId = con.Id,
            Account__c = acc.Id,
            Client_Email__c = 'test@testtoptalemai.com'
        );
        Test.startTest();
        insert evt;
        System.assertEquals(1,ComponentService.getEventsByContacts(acc.Id, new List<String>{con.Id}).size());
        Test.stopTest();
    }

    @isTest
    static void getContactsTest() {
        Specialization__c spec = new Specialization__c(Name = 'test', Appointment_Price__c = 200);
        insert spec;
        Account acc = new Account(Name = 'testAcc');
        insert acc;
        Contact con = new Contact(LastName = 'testCon', Specialization__c = spec.Id,AccountId = acc.Id);
        
        Test.startTest();
        insert con;
        System.assertEquals(1,ComponentService.getContacts(acc.Id).size());
        Test.stopTest();
    }

    @isTest
    static void getSpecjalizationsTest() {
        Specialization__c spec = new Specialization__c(Name = 'test', Appointment_Price__c = 200);
        insert spec;
        Account acc = new Account(Name = 'testAcc');
        insert acc;
        Contact con = new Contact(LastName = 'testCon', Specialization__c = spec.Id,AccountId = acc.Id);
        Test.startTest();
        insert con;
        System.assertEquals(1,ComponentService.getSpecjalizations(acc.Id).size());
        Test.stopTest();
    }

    @isTest
    static void upsertEventsTest() {
        Specialization__c spec = new Specialization__c(Name = 'test', Appointment_Price__c = 200);
        insert spec;
        Account acc = new Account(Name = 'testAcc');
        insert acc;
        Contact con = new Contact(LastName = 'testCon', Specialization__c = spec.Id,AccountId = acc.Id);
        insert con;
        ComponentService.EventObj evtObj = new ComponentService.EventObj(null,'test',DateTime.now(),DateTime.now().addHours(2),'test','test',con.Id,acc.Id,'test','testEmail@toptest.com');
        Test.startTest();
        ComponentService.upsertEvents(JSON.serialize(evtObj));
        System.assertEquals(1,ComponentService.getEvents(acc.Id).size());
        Test.stopTest();

    }

    @isTest
    static void deleteEventTest() {
        Specialization__c spec = new Specialization__c(Name = 'test', Appointment_Price__c = 200);
        insert spec;
        Account acc = new Account(Name = 'testAcc');
        insert acc;
        Contact con = new Contact(LastName = 'testCon', Specialization__c = spec.Id,AccountId = acc.Id);
        insert con;
        Event evt = new Event(
            Subject = 'test',
            StartDateTime = DateTime.now(),
            EndDateTime = DateTime.now().addHours(2),
            Description = 'test desc',
            WhoId = con.Id,
            Account__c = acc.Id,
            Client_Email__c = 'test@testtoptalemai.com'
        );
        insert evt;
        Test.startTest();
        ComponentService.deleteEvent(evt.Id);
        System.assertEquals(0,ComponentService.getEvents(acc.Id).size());
        Test.stopTest();
    }
    
    @isTest
    static void upsertEventsValidationTest() {
        Specialization__c spec = new Specialization__c(Name = 'test', Appointment_Price__c = 200);
        insert spec;
        Account acc = new Account(Name = 'testAcc');
        insert acc;
        Contact con = new Contact(LastName = 'testCon', Specialization__c = spec.Id,AccountId = acc.Id,Google_Calendar_Ready__c = true,Google_Calendar__c ='test');
        insert con;
        Contact con2 = new Contact(LastName = 'testCon2', Specialization__c = spec.Id,AccountId = acc.Id);
        insert con2;
        Event evt = new Event(
            Subject = 'test1',
            StartDateTime = DateTime.now(),
            EndDateTime = DateTime.now().addHours(2),
            Description = 'test desc',
            WhoId = con.Id,
            Account__c = acc.Id,
            Client_Email__c = 'test@testtoptalemai.com'
        );
        Event evt2 = new Event(
            Subject = 'test2',
            StartDateTime = DateTime.now().addHours(-2),
            EndDateTime = DateTime.now(),
            Description = 'test desc',
            WhoId = con.Id,
            Account__c = acc.Id,
            Client_Email__c = 'test@testtoptalemai.com'
        );
        Event evt3 = new Event(
            Subject = 'test3',
            StartDateTime = DateTime.now().addHours(2),
            EndDateTime = DateTime.now().addHours(4),
            Description = 'test desc',
            WhoId = con.Id,
            Account__c = acc.Id,
            Client_Email__c = 'test@testtoptalemai.com'
        );
        Event evt4 = new Event(
            Subject = 'test4',
            StartDateTime = DateTime.now(),
            EndDateTime = DateTime.now().addHours(1),
            Description = 'test desc',
            WhoId = con.Id,
            Account__c = acc.Id,
            Client_Email__c = 'test@testtoptalemai.com'
        );
        Event evt5 = new Event(
            Subject = 'test5',
            StartDateTime = DateTime.now(),
            EndDateTime = DateTime.now().addHours(2),
            Description = 'test desc',
            WhoId = con.Id,
            Account__c = acc.Id,
            Client_Email__c = 'test@testtoptalemai.com'
        );
        Event evt6 = new Event(
            Subject = 'test6',
            StartDateTime = DateTime.now().addHours(1),
            EndDateTime = DateTime.now().addHours(3),
            Description = 'test desc',
            WhoId = con.Id,
            Account__c = acc.Id,
            Client_Email__c = 'test@testtoptalemai.com'
        );
        Event evt7 = new Event(
            Subject = 'test7',
            StartDateTime = DateTime.now().addHours(-1),
            EndDateTime = DateTime.now().addHours(3),
            Description = 'test desc',
            WhoId = con.Id,
            Account__c = acc.Id,
            Client_Email__c = 'test@testtoptalemai.com'
        );
        Event evt8 = new Event(
            Subject = 'test8',
            StartDateTime = DateTime.now(),
            EndDateTime = DateTime.now().addHours(2),
            Description = 'test desc',
            WhoId = con2.Id,
            Account__c = acc.Id,
            Client_Email__c = 'test@testtoptalemai.com'
        );
        List<Event> testList = new List<Event>{evt2,evt3,evt4,evt5,evt6,evt7,evt8};
        insert evt;
        Integer exceptions = 0;
        Test.startTest();
        for(Event e : testList){
            try{
                insert e;
            }catch(Exception ex){
                system.debug(e.subject);
                exceptions++;
            }
        }
        
        System.assertEquals(4,ComponentService.getEvents(acc.Id).size());
        System.assertEquals(4,exceptions);
        Test.stopTest();
    }
}