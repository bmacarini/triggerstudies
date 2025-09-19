/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class AccountBatchSchedulerTest {

    @isTest
    static void batchSchedulerTest() {
        List<Account> newListAcc = new List<Account>();
        for(Integer i = 0; i < 20; i++){
            newListAcc.add(new Account(Name = 'bruno ' + i));
        }

        insert newListAcc;

        Test.startTest();

        String sch = '0 0 3 ? * 1L';
        String jobId = System.schedule('Test Account Batch Job', sch, new AccountBatchScheduler());

        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime 
                          FROM CronTrigger WHERE Id = :jobId];
        
        System.assertEquals(sch, ct.CronExpression, 'Cron expression does match');
        System.assertEquals(0, ct.TimesTriggered, 'Job should not have been triggered yet');
        System.assert(ct.NextFireTime > System.now(), 'NextFireTime should be in the future');
        System.assertNotEquals(null, ct.NextFireTime, 'NextFireTime should not be null');

        Test.stopTest();
        
        List<Account> accs = [SELECT Id, Name FROM Account];

        for(Account acc : accs){
            System.assertEquals(acc.Name.toUpperCase(), acc.Name, 'Expected uppercase name');
        }
    }
}