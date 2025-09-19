public with sharing class AccountBatchScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        AccountBatch accBatch = new AccountBatch();
        Database.executeBatch(accBatch);
    }
}