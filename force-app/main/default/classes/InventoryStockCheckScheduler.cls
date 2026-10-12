public with sharing class InventoryStockCheckScheduler
    implements Schedulable {

    // Called automatically when the schedule runs.
    public void execute(SchedulableContext sc) {

        // Start the inventory batch with a scope size of 200.
        Database.executeBatch(
            new InventoryStockCheckBatch(),
            200
        );
    }
}