public class GoogleIntegrationQueueable implements Queueable,Database.AllowsCallouts{
    public  String Summary;
    public  String eventId;
    public  DateTime endDate;
    public  DateTime startDate;
    public  string email;
    
    public void execute(QueueableContext qc){
             System.debug('Event ID aa rhi h !!' + eventId);
        System.debug('Summary : ' + Summary);
        System.debug('Email : ' + email);
        System.debug('endDate : ' + endDate);
        System.debug('startDate : ' + startDate);
        Event eventList = [Select Id, EventId__c from Event where Id = :eventId LIMIT 1];
        List<GoogleCalendarInfo__c> googleSettingInfoList1 = new List<GoogleCalendarInfo__c>();
        googleSettingInfoList1 = GoogleCalendarInfo__c.getAll().values();
        String accessToken = googleSettingInfoList1[0].Access_Token__c;
        if(Summary == null || Summary == ''){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Enter Calendar Title!'));
            return ;
        }
     //   String accessToken = 'ya29.a0AfH6SMDfgunzTP-QS-rrxff2LgQobbxnzFwjJ9YBmRgUtYESd6oTp-plevl2wHQoKaZba5zvxX2CId-9-MygLpXb0YKI5IEMDVGkGy_S0LLbl8KchXVdALterpwN0e9E-Rl0a-FxvXKnljGZFPSTFebvBlwU7Rve4nLcLL7_jzokcQ_q4w';
        String nEndDate = String.valueOfGmt(endDate);
        String[] newEndDate = nEndDate.split(' ');
        String currentEndDate = newEndDate[0]+'T'+newEndDate[1]+'-00:00';
        
        String nStartDate = String.valueOfGmt(startDate);
        String[] newStartDate = nStartDate.split(' ');
        String currentStartDate = newStartDate[0]+'T'+newStartDate[1]+'-00:00';
    //    String requestBody = '{\r\n  \"end\": {\r\n    \"dateTime\": \"'+currentEndDate+'\"\r\n  },\r\n  \"start\": {\r\n    \"dateTime\": \"'+currentStartDate+'\"\r\n  },\r\n  \"summary\": \"'+Summary+'\",\r\n  \"attendees\": [\r\n    {\r\n      \"email\": \"'+email+'\"\r\n    }\r\n  ]\r\n}';
        String[] allEmails = email.split(';');
        System.debug('This is the length of string : ' + allEmails.size());
        String incomingEmails = '';
        String requestBody = '{\r\n  \"end\": {\r\n    \"dateTime\": \"'+currentEndDate+'\"\r\n  },\r\n  \"start\": {\r\n    \"dateTime\": \"'+currentStartDate+'\"\r\n  },\r\n  \"summary\": \"'+Summary+'\",\r\n  \"attendees\": [\r\n   '; 
        for(integer i = 0; i< allEmails.size(); i++){
            requestBody += '{\r\n      \"email\": \"'+allEmails[i]+'\"\r\n    },\n';
            if(i == allEmails.size()-1){
           //     System.debug('Isme aa rha h !!! \n' + requestBody);
               requestBody = requestBody.removeEnd('\n');
               requestBody = requestBody.removeEnd(',');
			//System.debug('Isme bhi aa rha h !!! \n' + requestBody);
            }
        }
        requestBody += '\r\n  ]\r\n}';
        System.debug('This is new request Body ' + requestBody);
        System.debug('#### requestBody '+requestBody);
        Http http1 = new Http();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse HttpRes = new HttpResponse();
        
		//httpReq.setEndpoint('https://www.googleapis.com/calendar/v3/calendars');
		String calendarId = 'c_iig0hkicblg79fl4ckbct81np0@group.calendar.google.com';
		String newEndpoint = 'https://www.googleapis.com/calendar/v3/calendars/' + calendarId + '/events';
		httpReq.setEndpoint(newEndpoint);
          
        httpReq.setMethod('POST');
     //   httpReq.setEndpoint('callout:Calendar'); 
        httpReq.setBody(requestBody);
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setHeader('Authorization','Bearer '+accessToken);
        try{
            HttpRes = http1.send(httpReq);
            if(HttpRes.getStatusCode() == 200){
             
                System.debug('This is new Event ! :' + HttpRes.getBody());
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(HttpRes.getBody());
                System.debug('This is map response : ' + responseMap.get('id'));
                
                String calendarEventId = String.valueOf(responseMap.get('id'));
                System.debug('This is event ID : ' + calendarEventId);
                eventList.EventId__c = calendarEventId;
                update eventList;
                System.debug('This is updated event list : ' + eventList);
            /*    ApexPages.addmessage(new ApexPages.message(
                    	  ApexPages.severity.CONFIRM,'Event Created Successfully  '+'\n'+' '+
                			HttpRes.getBody())); */
            }
                 }catch(System.Exception e){
            System.debug('#### Exception Executed : '+e.getMessage() + '  '+e.getStackTraceString() + ' '+e.getLineNumber());
        }
    }
    public GoogleIntegrationQueueable(String Summary, String eventId, DateTime endDate, DateTime startDate, String email){
        this.Summary = Summary;
        this.eventId = eventId;
        this.endDate = endDate;
        this.startDate = startDate;
        this.email = email;
    }
}