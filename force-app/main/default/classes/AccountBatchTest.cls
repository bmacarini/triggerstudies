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
private class AccountBatchTest {

    @isTest
    static void upperCaseNamesBatch() {
        List<Account> newListAcc = new List<Account>();
        for(Integer i = 0; i < 20; i++){
            newListAcc.add(new Account(Name = 'bruno ' + i));
        }
        insert newListAcc;

        Test.startTest();
        AccountBatch batch = new AccountBatch();
        Database.executeBatch(batch);
        Test.stopTest();
        
        List<Account> accs = [SELECT Id, Name FROM Account];

        for(Account acc : accs){
            System.assertEquals(acc.Name.toUpperCase(), acc.Name, 'Expected uppercase name');
        }
        System.assertEquals(newListAcc.size(), accs.size(), 'Expected all accounts to be processed');
    }

    @isTest
    static void noDataToProcess() {
        List<Account> newListAcc = new List<Account>();
        for(Integer i = 0; i < 20; i++){
            newListAcc.add(new Account(Name = 'BRUNO ' + i));
        }
        insert newListAcc;

        Test.startTest();
        AccountBatch batch = new AccountBatch();
        Database.executeBatch(batch);
        Test.stopTest();
        
        List<Account> accs = [SELECT Id, Name FROM Account];

        for(Account acc : accs){
            System.assertEquals(acc.Name.toUpperCase(), acc.Name, 'Expected uppercase name');
        }
        System.assertEquals(newListAcc.size(), accs.size(), 'Expected no accounts to be processed');
    }

    @isTest
    static void batchHandlesInvalidAccount() {
        List<Account> newListAcc = new List<Account>();
        for(Integer i = 0; i < 19; i++){
            newListAcc.add(new Account(Name = 'bruno ' + i));
        }
        newListAcc.add(new Account(Name = null));
        Database.insert(newListAcc, false);

        Test.startTest();
        AccountBatch batch = new AccountBatch();
        Database.executeBatch(batch);
        Test.stopTest();
        
        List<Account> accs = [SELECT Id, Name FROM Account];

        for(Account acc : accs){
            System.assertEquals(acc.Name.toUpperCase(), acc.Name, 'Expected uppercase name');
        }
        System.assertEquals(newListAcc.size() - 1, accs.size(), 'Expected 19 accounts to be processed');
    }

    @isTest
    static void batchJobCompletionTest() {
        List<Account> newListAcc = new List<Account>();
        for(Integer i = 0; i < 20; i++){
            newListAcc.add(new Account(Name = 'bruno ' + i));
        }
        insert newListAcc;

        Test.startTest();
        AccountBatch batch = new AccountBatch();
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();
        
        AsyncApexJob batchProcessed = [
            SELECT Id, 
            Status, 
            JobItemsProcessed, 
            TotalJobItems 
            FROM AsyncApexJob 
            WHERE Id = :batchId
        ];

        System.assertEquals('Completed', batchProcessed.Status, 'Expected a completed status for the batch');
        System.assertEquals(batchProcessed.JobItemsProcessed, batchProcessed.TotalJobItems, 'Expected all batch items to be processed');
    }
}