({
    getEvents: function(component, event, helper) {
        var action = component.get("c.getEvents");

        action.setParams({
            accountId: component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var eventMap = response.getReturnValue()
                component.set("v.eventsMap", eventMap);
                for (var i = 0; i < eventMap.length; i++) {
                    console.log(eventMap[i]);
                }
                helper.renderCalendar(component, event, helper)
            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },
    getEventsByContacts: function(component, event, helper) {
        var action = component.get("c.getEventsByContacts");
        var conId = component.get("v.contactsIdList")

        for (var i = 0; i < conId.length; i++) {
            console.log(conId[i]);
        }
        action.setParams({
            accountId: component.get("v.recordId"),
            contactsIdList: component.get("v.contactsIdList"),
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var eventsMap = response.getReturnValue();
                $('#calendar').fullCalendar('removeEventSources', undefined);
                $.each(eventsMap, function(index, value) {
                    var newEvent = {
                        id: value.Id,
                        title: 'Subject: ' + value.title + ' clinician: ' + value.contactName,
                        title2: value.title,
                        start: moment(value.startDateTime),
                        end: moment(value.endDateTime),
                        description: value.description,
                        owner: value.owner
                    }
                    $('#calendar').fullCalendar('renderEvent', newEvent);
                });
            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },
    getContacts: function(component, event, helper) {
        var action = component.get("c.getContacts");
        action.setParams({
            accountId: component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var contList = response.getReturnValue();
                component.set("v.contactsMap", contList);
                var pickListMap = {};
                var selectedContactList = [];
                var contactsIdList = [];
                var contactsSpecMap = {};
                selectedContactList.push({ value: 'all', label: 'All clinicians' })
                for (var i = 0; i < contList.length; i++) {
                    if (pickListMap[contList[i].specjalizationId]) {
                        pickListMap[contList[i].specjalizationId].push({ value: contList[i].id, label: contList[i].name });
                    } else {
                        var list = [{ value: contList[i].id, label: contList[i].name }];
                        pickListMap[contList[i].specjalizationId] = list;
                    }
                    contactsSpecMap[contList[i].id] = contList[i].specjalizationId;
                    selectedContactList.push({ value: contList[i].id, label: contList[i].name })
                    contactsIdList.push(contList[i].id);
                }
                component.set("v.contactsSpecMap", contactsSpecMap);
                component.set("v.contactsIdList", contactsIdList);
                component.set("v.selectedContactList", selectedContactList);
                component.set("v.pickListMap", pickListMap);
            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },
    getSpecjalization: function(component, event, helper) {
        var action = component.get("c.getSpecjalizations");
        action.setParams({
            accountId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var specList = response.getReturnValue();
                component.set("v.specjalizationMap", specList);
                var parentValueList = [];
                var selectedSpecjalizationList = [];
                selectedSpecjalizationList.push({ value: 'all', label: 'All specjalizations' })
                parentValueList.push({ value: null, label: '--- None ---' });
                for (var i = 0; i < specList.length; i++) {
                    parentValueList.push({ value: specList[i].id, label: specList[i].name });
                    selectedSpecjalizationList.push({ value: specList[i].id, label: specList[i].name })
                }
                component.set("v.selectedSpecjalizationList", selectedSpecjalizationList);
                component.set("v.parentList", parentValueList);

            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },
    renderCalendar: function(component, event, helper) {
        var eventsMap = component.get("v.eventsMap");
        console.log(eventsMap)
        $(document).ready(function() {
            var eventArray = [];
            $.each(eventsMap, function(index, value) {
                var newEvent = {
                    id: value.Id,
                    title: 'Subject: ' + value.title + ' clinician: ' + value.contactName,
                    title2: value.title,
                    start: moment(value.startDateTime),
                    end: moment(value.endDateTime),
                    description: value.description,
                    contactId: value.contactId,
                    email: value.email,
                    owner: value.owner
                }
                eventArray.push(newEvent);
            });
            $('#calendar').fullCalendar({
                header: {
                    left: 'today prev,next',
                    center: 'title',
                    right: 'agendaDay,agendaWeek,month'
                },
                defaultView: 'agendaWeek',
                defaultDate: moment().format("YYYY-MM-DD"),
                navLinks: true, // can click day/week names to navigate views
                editable: true,
                height: 650,
                eventLimit: true, // allow "more" link when too many events
                weekends: component.get('v.weekends'),
                eventBackgroundColor: '#CFEBFE',
                eventBorderColor: '#ffffff',
                eventTextColor: '#00396b',
                events: eventArray,
                eventClick: function(calEvent, jsEvent, view) {
                    var contactsSpecMap = component.get("v.contactsSpecMap");

                    component.set('v.titleVal', calEvent.title2);
                    component.set('v.clientEmail', calEvent.email);
                    component.set('v.descriptionVal', calEvent.description);
                    component.set('v.startDateTimeVal', moment(calEvent.start._d).format());
                    component.set('v.endDateTimeVal', moment(calEvent.end._d).format());
                    component.set('v.idVal', calEvent.id);

                    component.set('v.parentValue', contactsSpecMap[calEvent.contactId]);
                    var controllerValue = component.find("parentField").get("v.value"); // We can also use event.getSource().get("v.value")
                    var pickListMap = component.get("v.pickListMap");

                    if (controllerValue != '--- None ---') {
                        //get child picklist value
                        var childValues = pickListMap[controllerValue];
                        var childValueList = [];
                        childValueList.push({ value: null, label: '--- None ---' });
                        for (var i = 0; i < childValues.length; i++) {
                            childValueList.push({ value: childValues[i].value, label: childValues[i].label });
                        }
                        // set the child list
                        component.set("v.childList", childValueList);

                        if (childValues.length > 0) {
                            component.set("v.disabledChildField", false);
                        } else {
                            component.set("v.disabledChildField", true);
                        }

                    } else {
                        component.set("v.childList", ['--- None ---']);
                        component.set("v.disabledChildField", true);
                    }
                    component.set('v.childValue', calEvent.contactId);
                    component.set('v.newOrEdit', 'Edit');
                    helper.openModal(component, event);
                },
                eventDrop: function(event, delta, revertFunc) {
                    var evObj = {
                        "Id": event.id,
                        "title": event.title2,
                        "startDateTime": moment(event.start._i).add(delta).format(),
                        "endDateTime": moment(event.end._i).add(delta).format(),
                        "description": event.description
                    };
                    helper.upsertEvent(component, evObj);
                },
                eventResize: function(event, delta, revertFunc) {
                    var evObj = {
                        "Id": event.id,
                        "title": event.title2,
                        "startDateTime": moment(event.start._i).format(),
                        "endDateTime": moment(event.end._i).add(delta).format(),
                        "description": event.description
                    };
                    helper.upsertEvent(component, evObj);
                },
                dayClick: function(date, jsEvent, view) {
                    if (date._f == "YYYY-MM-DD") {
                        component.set('v.startDateTimeVal', moment(date.format()).add(12, 'hours').format());
                        component.set('v.endDateTimeVal', moment(date.format()).add(13, 'hours').format());
                    } else {
                        component.set('v.startDateTimeVal', moment(date.format()).format());
                        component.set('v.endDateTimeVal', moment(date.format()).add(1, 'hours').format());
                    }
                    component.set('v.newOrEdit', 'New');
                    helper.openModal(component, event);
                }
            });
        });
    },
    openModal: function(component, event) {
        var modal = component.find('modal');
        $A.util.addClass(modal, 'slds-fade-in-open');
        var backdrop = component.find('backdrop');
        $A.util.addClass(backdrop, 'slds-backdrop--open');
    },
    closeModal: function(component, event) {
        var emailField = component.find("clientEmail");
        emailField.set("v.errors", []);
        $A.util.removeClass(emailField, 'slds-has-error');
        component.set('v.titleVal', '');
        component.set('v.idVal', '');
        component.set('v.startDateTimeVal', '');
        component.set('v.endDateTimeVal', '');
        component.set('v.descriptionVal', '');
        component.set('v.parentValue', null);
        component.set('v.childValue', null);
        component.set('v.clientEmail', '');
        var modal = component.find('modal');
        $A.util.removeClass(modal, 'slds-fade-in-open');
        var backdrop = component.find('backdrop');
        $A.util.removeClass(backdrop, 'slds-backdrop--open');
    },
    upsertEvent: function(component, evObj, callback) {
        var action = component.get("c.upsertEvents");

        action.setParams({
            "sEventObj": JSON.stringify(evObj)
        });

        if (callback) {
            action.setCallback(this, callback);
        }

        $A.enqueueAction(action);
    },
    deleteEvent: function(component, event, eventId, callback) {
        var action = component.get("c.deleteEvent");

        action.setParams({
            "eventId": eventId
        });

        if (callback) {
            action.setCallback(this, callback);
        }

        $A.enqueueAction(action);
    }
})