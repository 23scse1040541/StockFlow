
Id batchJobId = Database.executeBatch(
    new InventoryStockCheckBatch(),
    200
);

System.debug('StockFlow Batch Job ID: ' + batchJobId);
