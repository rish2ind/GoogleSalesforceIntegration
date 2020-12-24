trigger GoogleIntegration on Event (before insert, after insert, after delete) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            if(trigger.new[0].Attendees_Email__c == null){
                trigger.new[0].addError('Please fill Attendees Email field');
            }
        }
    }
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            Event eventList = [Select Subject, StartDateTime, EndDateTime, Attendees_Email__c from Event where Id in :trigger.new];
            System.debug('This is new event : ' + eventList);
            String newSubject = eventList.Subject;
            DateTime endDate = eventList.EndDateTime;
            DateTime startDate = eventList.StartDateTime;
            String emails = eventList.Attendees_Email__c;
            System.debug('Summary : ' + newSubject + ' EndDate : ' + endDate + ' StartDate : ' + startDate + ' Emails : ' + emails);
            GoogleCalendarActionsController.doCreateNewCalendar(newSubject, emails, endDate, startDate, eventList.Id);
        }
       
    }
    if(Trigger.isAfter){
         if(Trigger.isDelete){
            Event eventList = [Select EventId__c from Event where Id = :trigger.old[0].Id ALL ROWS];
            System.debug('This is deleted event : ' + eventList);
            String eventId = eventList.EventId__c;
            System.debug('This is Event Id : ' + eventId);
            GoogleCalendarActionsController.deleteEvents(eventId);
        }
    }
}