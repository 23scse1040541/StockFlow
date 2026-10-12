
String cronExpression = '0 0 2 * * ?';

String jobId = System.schedule(
    'StockFlow Daily Inventory Check',
    cronExpression,
    new InventoryStockCheckScheduler()
);

System.debug('Scheduled Job ID: ' + jobId);
