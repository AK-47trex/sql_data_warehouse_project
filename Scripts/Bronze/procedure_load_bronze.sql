/*
======================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
======================================================================
Script Purpose:

    This stored procedure loads data into the 'bronze' schema from external CSV files.
    It performs the following actions:

    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from CSV Files to bronze tables.

Parameters: None.
This stored procedure does not accept any parameters or return any values.
Usage Example:
 EXEC bronze.load_bronze;
======================================================================
*/

create or alter procedure bronze.load_bronze as
Begin
 Declare @start_time datetime , @end_time datetime,@batch_start datetime, @batch_end datetime
   Begin try

   set @batch_start= GETDATE();
--we will make a procedure for it coz this script will going to run everyday to add new column
    print'==================================================';
    print ' LOADING BRONZE LAYER';
    print'==============================================';

    print'==================================================';
    print ' LOADING CRM TABLES';
    print'==============================================';

    set @start_time= GETDATE();
    print'TRUNCTING THE TABLE : bronze.crm_cust_info ';
    Truncate table bronze.crm_cust_info
    print'INSERTING INTO : bronze.crm_cust_info ';
    bulk insert bronze.crm_cust_info
    from 'C:\Users\ADMIN\OneDrive\Documents\SQL\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
    with
    (  firstrow= 2,
        fieldterminator=',',
        tablock
        );
     Set @end_time = GETDATE();
     print'>>>>Load duration is ;' + cast( datediff(second, @start_time,@end_time )as nvarchar) + 'seconds';

      set @start_time= GETDATE();
    print'TRUNCTING THE TABLE : bronze.crm_prd_info ';
    Truncate table bronze.crm_prd_info
    print'INSERTING INTO : bronze.crm_prd_info ';
    bulk insert bronze.crm_prd_info
    from 'C:\Users\ADMIN\OneDrive\Documents\SQL\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
    with
    (  firstrow= 2,
        fieldterminator=',',
        tablock
        );
    Set @end_time = GETDATE();
    print'>>>>Load duration is ;' + cast( datediff(second, @start_time,@end_time)as nvarchar) + 'seconds';

      set @start_time= GETDATE();
    print'TRUNCTING THE TABLE : bronze.crm_sales_details';
    Truncate table bronze.crm_sales_details
    print'INSERTING INTO : bronze.crm_sales_details ';
    bulk insert bronze.crm_sales_details
    from 'C:\Users\ADMIN\OneDrive\Documents\SQL\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
    with
    (  firstrow= 2,
        fieldterminator=',',
        tablock
        );
   Set @end_time = GETDATE();
   print'>>>>Load duration is ;' + cast( datediff(second, @start_time,@end_time)as nvarchar) + 'seconds';

    print'==================================================';
    print ' LOADING ERP TABLES'
    print'==============================================';


     set @start_time= GETDATE();
    print'TRUNCTING THE TABLE : bronze.erp_cust_az12 ';
    Truncate table bronze.erp_cust_az12
    print'INSERTING INTO : bronze.erp_cust_az12';
    bulk insert bronze.erp_cust_az12
    from 'C:\Users\ADMIN\OneDrive\Documents\SQL\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
    with
    (  firstrow= 2,
        fieldterminator=',',
        tablock
        );
  Set @end_time = GETDATE();
  print'>>>>Load duration is ;' + cast( datediff(second, @start_time,@end_time) as nvarchar) + 'seconds';

         set @start_time= GETDATE();
    print'TRUNCTING THE TABLE : bronze.erp_loc_a101 ';
    Truncate table bronze.erp_loc_a101
    print'INSERTING INTO : bronze.erp_loc_a101';
    bulk insert bronze.erp_loc_a101
    from 'C:\Users\ADMIN\OneDrive\Documents\SQL\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
    with
    (  firstrow= 2,
        fieldterminator=',',
        tablock
        );
 Set @end_time = GETDATE();
 print'>>>>Load duration is ;' + cast( datediff(second, @start_time,@end_time)as nvarchar) + 'seconds';

     set @start_time= GETDATE();
    print'TRUNCTING THE TABLE : bronze.erp_px_cat_g1v2c';
    Truncate table bronze.erp_px_cat_g1v2
    print 'INSERTING INTO : bronze.erp_px_cat_g1v2';
    bulk insert bronze.erp_px_cat_g1v2
    from 'C:\Users\ADMIN\OneDrive\Documents\SQL\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
    with
    (  firstrow= 2,
        fieldterminator=',',
        tablock
        );
  Set @end_time = GETDATE();
  print'>>>>Load duration is ;' + cast( datediff(second, @start_time,@end_time)as nvarchar) + 'seconds';
   END try
 Begin CATCH
       print'Error has occurred';
       print'Error message' + error_message();
       print'Error number' + cast(error_number() as nvarchar);
       print'Error location' + cast(error_state() as nvarchar);
 End catch 
 set @batch_end= GETDATE();
 print'>>>>Load duration of batch is ;' + cast( datediff(second, @batch_start,@batch_end)as nvarchar) + 'seconds';

END
