global class DeleteEventBatch implements Database.Batchable<sObject>  {

    global Database.QueryLocator start(Database.BatchableContext batchContext){
        String Query = 'Select Id,Name From Event__c Where Live__c = true AND End_Date_Time__c < LAST_N_MONTHS:2';
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext batchContext,List<Event__c> eventList){
        if(!eventList.isEmpty()) {
            List<Database.DeleteResult> deleteResult = Database.delete(eventList);
            for(Database.DeleteResult	dr : deleteResult){
                if(!dr.isSuccess()){
                    List<Database.Error> errors = dr.getErrors();
                    String errorInString = String.join(errors, ',');
                    TransactionLogHandler.doHandleExceptionWithError(errorInString, 'DeleteEventBatch');
                }
                
            }
        }       
    }
    
    global void finish(Database.BatchableContext batchContext){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setSubject('Batch Processing Completed');  
        List<String> toaddress = new List<String>();
        toaddress.add('toshashank.singh98@gmail.com');
        mail.setToAddresses(toaddress);
        mail.setSenderDisplayName('Shashank Singh');
        mail.setHtmlBody('The deleteEventBatch processing has been completed');
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {mail});
    }
    
}