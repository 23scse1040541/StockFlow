
@IsTest
private class StockTransactionHandlerTest {

    @TestSetup
    static void setupData() {
        Product2 product = new Product2(
            Name = 'Test Laptop',
            IsActive = true
        );
        insert product;

        Inventory_Item__c item = new Inventory_Item__c(
            Product__c = product.Id,
            Current_Stock__c = 10,
            Reorder_Level__c = 3,
            Reorder_Quantity__c = 5,
            Unit_Price__c = 50000,
            Active__c = true
        );
        insert item;
    }

    private static Inventory_Item__c getInventoryItem() {
        return [
            SELECT Id, Current_Stock__c
            FROM Inventory_Item__c
            WHERE Product__r.Name = 'Test Laptop'
            LIMIT 1
        ];
    }

    @IsTest
    static void testStockIn() {
        Inventory_Item__c item = getInventoryItem();

        Test.startTest();
        insert new Stock_Transaction__c(
            Inventory_Item__c = item.Id,
            Transaction_Type__c = 'Stock In',
            Quantity__c = 5,
            Transaction_Date__c = Date.today()
        );
        Test.stopTest();

        item = getInventoryItem();
        System.assertEquals(
            Decimal.valueOf(15),
            item.Current_Stock__c,
            'Stock In should increase stock from 10 to 15.'
        );
    }

    @IsTest
    static void testStockOut() {
        Inventory_Item__c item = getInventoryItem();

        Test.startTest();
        insert new Stock_Transaction__c(
            Inventory_Item__c = item.Id,
            Transaction_Type__c = 'Stock Out',
            Quantity__c = 4,
            Transaction_Date__c = Date.today()
        );
        Test.stopTest();

        item = getInventoryItem();
        System.assertEquals(
            Decimal.valueOf(6),
            item.Current_Stock__c,
            'Stock Out should decrease stock from 10 to 6.'
        );
    }

    @IsTest
    static void testInsufficientStock() {
        Inventory_Item__c item = getInventoryItem();

        Test.startTest();
        try {
            insert new Stock_Transaction__c(
                Inventory_Item__c = item.Id,
                Transaction_Type__c = 'Stock Out',
                Quantity__c = 20,
                Transaction_Date__c = Date.today()
            );
            System.assert(false, 'Expected insufficient stock error.');
        } catch (DmlException e) {
            System.assert(
                e.getMessage().contains('Insufficient stock'),
                'Expected an insufficient stock validation error.'
            );
        }
        Test.stopTest();

        item = getInventoryItem();
        System.assertEquals(
            Decimal.valueOf(10),
            item.Current_Stock__c,
            'Stock must remain unchanged after a rejected transaction.'
        );
    }
}
