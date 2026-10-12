
@IsTest
private class InventoryStockCheckBatchTest {

    @IsTest
    static void testBatchProcessesInventory() {

        // Create test products.
        Product2 keyboard = new Product2(
            Name = 'Batch Test Keyboard',
            IsActive = true
        );

        Product2 monitor = new Product2(
            Name = 'Batch Test Monitor',
            IsActive = true
        );

        insert new List<Product2>{ keyboard, monitor };


        // Create one low-stock inventory record.
        Inventory_Item__c lowStockItem =
            new Inventory_Item__c(
                Product__c = keyboard.Id,
                Current_Stock__c = 5,
                Reorder_Level__c = 10,
                Reorder_Quantity__c = 20,
                Unit_Price__c = 3000,
                Supplier_Email__c = 'keyboard@example.com',
                Active__c = true
            );

        // Create one normal-stock inventory record.
        Inventory_Item__c normalStockItem =
            new Inventory_Item__c(
                Product__c = monitor.Id,
                Current_Stock__c = 25,
                Reorder_Level__c = 10,
                Reorder_Quantity__c = 15,
                Unit_Price__c = 18000,
                Supplier_Email__c = 'monitor@example.com',
                Active__c = true
            );

        insert new List<Inventory_Item__c>{
            lowStockItem,
            normalStockItem
        };


        // Execute the batch during the test.
        Test.startTest();

        Id jobId = Database.executeBatch(
            new InventoryStockCheckBatch(),
            200
        );

        Test.stopTest();


        // Verify that Salesforce created the batch job
        // and that it completed successfully.
        AsyncApexJob job = [
            SELECT Id, Status, NumberOfErrors
            FROM AsyncApexJob
            WHERE Id = :jobId
        ];

        System.assertEquals(
            'Completed',
            job.Status,
            'The inventory batch should complete successfully.'
        );

        System.assertEquals(
            0,
            job.NumberOfErrors,
            'The inventory batch should have no errors.'
        );
    }
}
