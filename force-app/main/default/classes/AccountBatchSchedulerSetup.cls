public with sharing class AccountBatchSchedulerSetup {
    public static void scheduleWeeklyBatch() {
        System.schedule('Weekly Account Batch',
        '0 0 3 ? * 1L', 
        new AccountBatchScheduler());
    }
}