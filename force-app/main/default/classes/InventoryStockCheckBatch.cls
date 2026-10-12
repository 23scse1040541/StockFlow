
public with sharing class InventoryStockCheckBatch
    implements Database.Batchable<Inventory_Item__c> {

    public Iterable<Inventory_Item__c> start(
        Database.BatchableContext bc
    ) {
        return [
            SELECT Id, Name, Product__c, Product__r.Name,
                   Current_Stock__c, Reorder_Level__c,
                   Reorder_Quantity__c, Supplier_Email__c
            FROM Inventory_Item__c
            WHERE Active__c = TRUE
        ];
    }

    public void execute(
        Database.BatchableContext bc,
        List<Inventory_Item__c> scope
    ) {
        List<Low_Stock_Event__e> eventsToPublish =
            new List<Low_Stock_Event__e>();

        for (Inventory_Item__c item : scope) {
            if (
                item.Current_Stock__c != null &&
                item.Reorder_Level__c != null &&
                item.Current_Stock__c <= item.Reorder_Level__c
            ) {
                Low_Stock_Event__e stockEvent =
                    new Low_Stock_Event__e(
                        Inventory_Item_ID__c = item.Id,
                        Product_Name__c = item.Product__r.Name,
                        Current_Stock__c = item.Current_Stock__c,
                        Reorder_Level__c = item.Reorder_Level__c
                    );

                eventsToPublish.add(stockEvent);
            }
        }

        if (!eventsToPublish.isEmpty()) {
            List<Database.SaveResult> results =
                EventBus.publish(eventsToPublish);

            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    for (Database.Error err :
                         results[i].getErrors()) {
                        System.debug(
                            LoggingLevel.ERROR,
                            'Platform Event publish failed: ' +
                            err.getMessage()
                        );
                    }
                }
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug(
            LoggingLevel.INFO,
            'StockFlow inventory batch processing completed.'
        );
    }
}
