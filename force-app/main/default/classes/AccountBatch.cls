public with sharing class AccountBatch implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Name FROM Account WHERE Name != NULL');
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<Account> accounts = (List<Account>)scope;
        AccountHandler.transformNamesToUpperCase(accounts);
        Database.SaveResult[] saveResults = Database.update(accounts, false);
        for (Database.SaveResult sr : saveResults) {
            if (!sr.isSuccess()) {
                for (Database.Error err : sr.getErrors()) {
                    System.debug('Error updating record: ' + err.getMessage());
                }
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        AsyncApexJob job = [
            SELECT Id, 
            Status, 
            NumberOfErrors, 
            JobItemsProcessed, 
            TotalJobItems, 
            CreatedBy.Email 
            FROM AsyncApexJob 
            WHERE Id = :bc.getJobId()
        ];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'bmacarini@gmail.com'};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Batch Job Status: ' + job.Status);
        mail.setPlainTextBody(
            'The batch job has completed with the following overview:\n\n' +
            'Total Job Items: ' + job.TotalJobItems + '\n' +
            'Job Items Processed: ' + job.JobItemsProcessed + '\n' +
            'Number of Errors: ' + job.NumberOfErrors + ' failures'
        );
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}