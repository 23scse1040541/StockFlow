trigger LowStockEventTrigger on Low_Stock_Event__e (after insert) {
    LowStockEventHandler.handle(Trigger.new);
}