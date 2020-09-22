({
    scriptsLoaded: function(component, event, helper) {
        helper.getEvents(component, event, helper);
        helper.getContacts(component, event, helper);
        helper.getSpecjalization(component, event, helper);
    },
    renderCalendar: function(component, event, helper) {
        helper.renderCalendar(component, event, helper);
    },
    createRecord: function(component, event, helper) {
        var emailField = component.find("clientEmail");
        var emailFieldValue = emailField.get("v.value");
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

        if (!$A.util.isEmpty(emailFieldValue)) {
            console.log('test')
            if (emailFieldValue.match(regExpEmailformat)) {
                emailField.set("v.errors", []);
                $A.util.removeClass(emailField, 'slds-has-error');
            } else {
                $A.util.addClass(emailField, 'slds-has-error');
                emailField.set("v.errors", [{ message: "Please Enter a Valid Email Address" }]);
                return;
            }
        } else {
            $A.util.addClass(emailField, 'slds-has-error');
            emailField.set("v.errors", [{ message: "Client email is required" }]);
            return;
        }

        var evObj = {
            "title": component.get('v.titleVal'),
            "startDateTime": moment(component.get('v.startDateTimeVal')).format(),
            "endDateTime": moment(component.get('v.endDateTimeVal')).format(),
            "description": component.get('v.descriptionVal'),
            "accountId": component.get('v.recordId'),
            "contactId": component.get('v.childValue'),
            "email": component.get('v.clientEmail')
        };
        if (component.get('v.idVal')) {
            evObj.id = component.get('v.idVal');
            $('#calendar').fullCalendar('removeEvents', component.get('v.idVal'));
        }
        helper.upsertEvent(component, evObj, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var newEvent = {
                    id: response.getReturnValue().Id,
                    title: 'Subject: ' + response.getReturnValue().title + ' Clinician: ' + response.getReturnValue().contactName,
                    title2: response.getReturnValue().title,
                    start: moment(response.getReturnValue().startDateTime),
                    end: moment(response.getReturnValue().endDateTime),
                    description: response.getReturnValue().description,
                    email: response.getReturnValue().email,
                    contactId: response.getReturnValue().contactId,
                    owner: response.getReturnValue().owner
                }
                $('#calendar').fullCalendar('renderEvent', newEvent);

                helper.closeModal(component, event);
            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: 'Error',
                            message: 'Clinician already have a meeting at that time',
                            duration: ' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
    },
    deleteRecord: function(component, event, helper) {
        helper.deleteEvent(component, event, event.getSource().get("v.value"), function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                $('#calendar').fullCalendar('removeEvents', response.getReturnValue());
                helper.closeModal(component, event);
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
    },
    openModal: function(component, event, helper) {
        helper.openModal(component, event);
    },
    closeModal: function(component, event, helper) {
        helper.closeModal(component, event);
    },
    parentFieldChange: function(component, event, helper) {
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
    },
    specFieldChange: function(component, event, helper) {
        var controllerValue = component.find("specField").get("v.value"); // We can also use event.getSource().get("v.value")
        var pickListMap = component.get("v.pickListMap");

        if (controllerValue == 'all') {
            var contactMap = component.get("v.contactsMap");
            var selectedContactList = [];
            selectedContactList.push({ value: 'all', label: 'All clinicians' })
            for (var i = 0; i < contactMap.length; i++) {
                selectedContactList.push({ value: contactMap[i].id, label: contactMap[i].name })

            }
            component.set("v.selectedContactList", selectedContactList);
            var eventsMap = component.get("v.eventsMap");
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

        } else {
            var childValues = pickListMap[controllerValue];
            var selectedContactList = [];
            var contactsIdList = [];
            selectedContactList.push({ value: 'all', label: 'All clinicians' })
            for (var i = 0; i < childValues.length; i++) {
                selectedContactList.push({ value: childValues[i].value, label: childValues[i].label });
                contactsIdList.push(childValues[i].value);
            }
            component.set("v.contactsIdList", contactsIdList);
            component.set("v.selectedContactList", selectedContactList);
            helper.getEventsByContacts(component, event, helper);
        }
    },
    clinicianFieldChange: function(component, event, helper) {
        var controllerValue = component.find("clinicianField").get("v.value"); // We can also use event.getSource().get("v.value")
        var specValue = component.find("specField").get("v.value"); // We can also use event.getSource().get("v.value")

        var pickListMap = component.get("v.pickListMap");
        if (specValue == 'all') {
            if (controllerValue == 'all') {
                var eventsMap = component.get("v.eventsMap");
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

            } else {
                component.set("v.contactsIdList", [controllerValue]);
                helper.getEventsByContacts(component, event, helper);

            }
        } else {
            if (controllerValue == 'all') {
                var childValues = pickListMap[specValue];
                var selectedContactList = [];
                var contactsIdList = [];
                selectedContactList.push({ value: 'all', label: 'All clinicians' })
                for (var i = 0; i < childValues.length; i++) {
                    selectedContactList.push({ value: childValues[i].value, label: childValues[i].label });
                    contactsIdList.push(childValues[i].value);
                }
                component.set("v.contactsIdList", contactsIdList);
                component.set("v.selectedContactList", selectedContactList);
                helper.getEventsByContacts(component, event, helper);
            } else {
                component.set("v.contactsIdList", [controllerValue]);
                helper.getEventsByContacts(component, event, helper);
            }


        }
    }
})