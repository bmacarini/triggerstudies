public with sharing class AccountHandler {

    public class TriggerContext {
        public Boolean isBefore;
        public Boolean isAfter;
        public Boolean isInsert;
        public Boolean isUpdate;
        public Boolean isDelete;
        public Boolean isUndelete;

        public TriggerContext() {
            isBefore = Trigger.isBefore;
            isAfter = Trigger.isAfter;
            isInsert = Trigger.isInsert;
            isUpdate = Trigger.isUpdate;
            isDelete = Trigger.isDelete;
            isUndelete = Trigger.isUndelete;
        }
    }

    public static void transformNamesToUpperCase(List<Account> acc) {
        for(Account a : acc) {
            if(a.Name != null) {
                a.Name = a.Name.toUpperCase();
            }
        }
    }

    private static void handleBeforeInsertContext(List<Account> acc, TriggerContext context) {
        if(context.isBefore && context.isInsert) {
            transformNamesToUpperCase(acc);
        }
    }

    public static void execute(
        List<Account> newList, 
        List<Account> oldList, 
        Map<Id, Account> newMap, 
        TriggerContext context
        ) {
            handleBeforeInsertContext(newList, context);
    }
}