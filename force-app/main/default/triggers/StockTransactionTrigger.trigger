trigger StockTransactionTrigger on Stock_Transaction__c (before insert) {
    StockTransactionHandler.handleBeforeInsert(Trigger.new);
}