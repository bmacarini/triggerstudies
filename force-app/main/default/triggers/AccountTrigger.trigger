trigger AccountTrigger on Account (
    before insert, 
    before update,
    before delete,
    after insert, 
    after update,
    after delete,
    after undelete
    ) {
        AccountHandler.execute(
            Trigger.new,
            Trigger.old,
            Trigger.newMap,
            new AccountHandler.TriggerContext()
        );
}