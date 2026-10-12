
public with sharing class StockTransactionHandler {

    public static void handleBeforeInsert(
        List<Stock_Transaction__c> transactions
    ) {
        Set<Id> inventoryIds = new Set<Id>();

        for (Stock_Transaction__c txn : transactions) {
            if (txn.Inventory_Item__c != null) {
                inventoryIds.add(txn.Inventory_Item__c);
            }
        }

        Map<Id, Inventory_Item__c> inventoryMap =
            new Map<Id, Inventory_Item__c>([
                SELECT Id, Name, Current_Stock__c
                FROM Inventory_Item__c
                WHERE Id IN :inventoryIds
                FOR UPDATE
            ]);

        Map<Id, Decimal> stockChanges = new Map<Id, Decimal>();

        for (Stock_Transaction__c txn : transactions) {
            if (txn.Inventory_Item__c == null) {
                txn.addError('Please select an Inventory Item.');
                continue;
            }

            if (txn.Transaction_Type__c == null) {
                txn.addError('Please select Stock In or Stock Out.');
                continue;
            }

            if (txn.Quantity__c == null || txn.Quantity__c <= 0) {
                txn.addError('Quantity must be greater than zero.');
                continue;
            }

            Inventory_Item__c item =
                inventoryMap.get(txn.Inventory_Item__c);

            if (item == null) {
                txn.addError('Selected Inventory Item was not found.');
                continue;
            }

            Decimal changeAmount = txn.Quantity__c;

            if (txn.Transaction_Type__c == 'Stock Out') {
                changeAmount = -changeAmount;
            } else if (txn.Transaction_Type__c != 'Stock In') {
                txn.addError('Invalid Transaction Type.');
                continue;
            }

            Decimal previousChange = stockChanges.containsKey(item.Id)
                ? stockChanges.get(item.Id)
                : 0;

            stockChanges.put(
                item.Id,
                previousChange + changeAmount
            );
        }

        for (Id itemId : stockChanges.keySet()) {
            Inventory_Item__c item = inventoryMap.get(itemId);
            Decimal currentStock = item.Current_Stock__c == null
                ? 0
                : item.Current_Stock__c;

            Decimal newStock = currentStock + stockChanges.get(itemId);

            if (newStock < 0) {
                for (Stock_Transaction__c txn : transactions) {
                    if (txn.Inventory_Item__c == itemId) {
                        txn.addError(
                            'Insufficient stock for ' + item.Name +
                            '. Available stock: ' + currentStock
                        );
                    }
                }
            } else {
                item.Current_Stock__c = newStock;
            }
        }

        List<Inventory_Item__c> itemsToUpdate =
            new List<Inventory_Item__c>();

        for (Inventory_Item__c item : inventoryMap.values()) {
            if (stockChanges.containsKey(item.Id) &&
                item.Current_Stock__c != null) {
                itemsToUpdate.add(item);
            }
        }

        if (!itemsToUpdate.isEmpty()) {
            update itemsToUpdate;
        }
    }
}
