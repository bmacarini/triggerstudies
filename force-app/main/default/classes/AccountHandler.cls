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

    private static void editNames(List<Account> acc, TriggerContext context) {
        if(context.isBefore && context.isInsert) {
            for(Account a : acc) {
                if(a.Name != null) {
                    a.Name = a.Name.toUpperCase();
                }
            }
        }
    }

    public static void execute(
        List<Account> newList, 
        List<Account> oldList, 
        Map<Id, Account> newMap, 
        TriggerContext context
        ) {
            editNames(newList, context);
    }
}