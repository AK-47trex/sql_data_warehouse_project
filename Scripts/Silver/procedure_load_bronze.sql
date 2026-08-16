Create or alter procedure silver.load_silver AS
Begin 
    Declare @start_time datetime , @end_time datetime,@batch_start datetime, @batch_end datetime
   Begin try

   set @batch_start= GETDATE();

    print'==================================================';
    print ' LOADING SILVER LAYER';
    print'==============================================';

    print'==================================================';
    print ' LOADING CRM TABLES';
    print'==============================================';

 -------------------------------------------------------------------------------------------------------------------------------------------------  

        set @start_time= GETDATE();
        
        print'-truncating table silver.crm_cust_info';
        truncate table silver.crm_cust_info 
       

        print'--insert into silver.crm_cust_info';
        --insert into silver schema
        insert into Silver.crm_cust_info
        (cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
        )


        

        select 
        
        cst_id,
        cst_key,
        trim(cst_firstname) as cst_firstname,
        trim(cst_lastname) as cst_lastname,
      
        case
        
        when upper(trim(cst_gndr)) ='S' then 'Single'
        when upper(trim(cst_gndr)) ='M' then 'Married'
        else 'unknown'
        END as cst_marital_status,
        
        case
        
        when upper(trim(cst_gndr)) ='F' then 'Female'
        when upper(trim(cst_gndr)) ='M' then 'Male'
        else 'unknown'
        END cst_gndr,
        cst_create_date
        from
        (select *,
        ROW_NUMBER() over(partition by cst_id order by  cst_create_date desc) as flag_last 
        from Bronze.crm_cust_info
        )t
        where flag_last = 1 and cst_id is not null;
        print 'Free from duplicate values and null';
        print'creating next table';
         Set @end_time = GETDATE();
     print'>>>>Load duration is ;' + cast( datediff(second, @start_time,@end_time )as nvarchar) + 'seconds';
-----------------------------------------------------------------------------------------------------------------------------------------

        set @start_time= GETDATE();
        
        print' - truncating the table silver.crm_prd_info'
        truncate table Silver.crm_prd_info
        

      
        print'---inserting into silver.crm_prd_info'
        ---inserting into silver schema

        Insert into Silver.crm_prd_info
        (
            prd_id,     
            cat_id ,
            prd_key,
            prd_nm ,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt 
    
            )
        select 
        prd_id ,
        
        replace(substring(prd_key, 1,5), '-', '_') as prd_cat,
      
        substring(prd_key ,7,len(prd_key)) as prd_key,
        prd_nm,
        
        coalesce (prd_cost,0) as prd_cost,
      
        case 
          when UPPER(Trim(prd_line)) = 'M' then 'Mountain'
          when UPPER(Trim(prd_line)) = 'R' then 'Road'
          when UPPER(Trim(prd_line)) = 'S' then 'Sales Other'
          when UPPER(Trim(prd_line)) = 'T' then 'Touring'
          else 'Unknown'
         End as prd_line,
        
         cast(prd_start_dt as date) as prd_start_dt,
         
        cast(lead(prd_start_dt) over (partition by prd_key order by prd_start_dt asc)-1 as date ) as prd_end_dttest

        from Bronze.crm_prd_info
        print 'Free from duplicate values and null'
        print'creating next table'
         Set @end_time = GETDATE();
     print'>>>>Load duration is ;' + cast( datediff(second, @start_time,@end_time )as nvarchar) + 'seconds';
-------------------------------------------------------------------------------------------------------------------------------------------
         set @start_time= GETDATE();
        
        print' - truncating the table silver.crm_sales_details'
        truncate table Silver.crm_sales_details

        print'-- inserting into silver.crm_sales_details'
        -- inserting into silver schema

        insert into Silver.crm_sales_details
        ( sls_ord_num ,
            sls_prd_key,
            sls_cust_id ,
            sls_order_dt,
            sls_ship_dt ,   
            sls_due_dt ,
            sls_sales  ,
            sls_quantity,
            sls_price   
        )

        select
            sls_ord_num ,
            sls_prd_key ,
            sls_cust_id ,
            -- invalid date or 0
            case
             when sls_order_dt = 0 or len(sls_order_dt) != 8 then null
        
             else cast(cast(sls_order_dt as nvarchar) as date)
             end as sls_order_dt,
   
            --repeating the process for ship date
            case
             when sls_ship_dt = 0 or len(sls_ship_dt) != 8 then null
             -- we cannot cast integer to date in sql server 
             else cast(cast(sls_ship_dt as nvarchar) as date)
             end as sls_ship_dt,

            --repeating the process for due date
            case
             when sls_due_dt = 0 or len(sls_due_dt) != 8 then null
          
             else cast(cast(sls_due_dt as nvarchar) as date)
             end as sls_due_dt,
        --if sales is -ve ,zero or null, derive it using quantity and price
          case 
           when sls_sales = 0 Or sls_sales is null Or sls_sales != sls_price * sls_quantity
           then sls_price * abs(sls_price)
           else sls_sales
         end  sls_sales,

         sls_quantity,

        --if price is zero or null , calculate it using sales and quantity
        --if price is -ve , convert it to a +ve value
            case 
             when sls_price <= 0 Or sls_price is null
             then sls_sales / nullif(sls_quantity,0)
             else sls_price
           End as sls_price
        from Bronze.crm_sales_details

        print 'Free from duplicate values and null'
        print'creating next table'
         Set @end_time = GETDATE();
     print'>>>>Load duration is ;' + cast( datediff(second, @start_time,@end_time )as nvarchar) + 'seconds';
------------------------------------------------------------------------------------------------------------------------------------------------
    print'==================================================';
    print ' LOADING ERP TABLES'
    print'==============================================';
        set @start_time= GETDATE();
      
        print' - truncating the table silver.erp_cust_az12'
        truncate table Silver.erp_cust_az12


        print'--inserting into silver.erp_cust_az12'
        --inserting into silver.erp_cust_az12
         Insert into silver.erp_cust_az12
         ( cid,
         bdate,
         gen
         )

        select  
        
        CASE 
         when cid like 'NAS%' then SUBSTRING( cid, 4, len(cid))
         else cid
        END as cid,
        
        case
         when bdate> GETDATE() then null
         else bdate
        END as bdate,
        
         CASE 
          when UPPER( trim(gen)) = 'F' then 'Female'
          when upper(trim(gen)) = 'M' then 'Male'
          when gen = '' or  gen is null then 'unknown'
          else gen
        End as new_gen
        from Bronze.erp_cust_az12

        print 'Free from duplicate values and null'
        print'creating next table'
         Set @end_time = GETDATE();
     print'>>>>Load duration is ;' + cast( datediff(second, @start_time,@end_time )as nvarchar) + 'seconds';
------------------------------------------------------------------------------------------------------------------------------------------------
         
         set @start_time= GETDATE();
         
        print' - truncating the table silver.erp_loc_a101'
        truncate table Silver.erp_loc_a101

        print'--inserting into silver.erp_loc_a101';
        --inserting into silver.erp_loc_a101
        insert into Silver.erp_loc_a101
        ( cid,
          cntry
          )

        select 
        
         REPLACE(cid,'-','')as cid,
        
        case 
         when upper(trim(cntry))= 'DE' then 'Denmark'
         when trim(cntry) = '' or cntry Is null then 'Unknown'
         when upper(trim(cntry)) in ('USA' , 'US') then 'United states'
         else trim (cntry)
         end as cntry
        from Bronze.erp_loc_a101

        print 'Free from duplicate values and null';
        print'creating next table';
         Set @end_time = GETDATE();
     print'>>>>Load duration is ;' + cast( datediff(second, @start_time,@end_time )as nvarchar) + 'seconds';
---------------------------------------------------------------------------------------------------------------------------------------------------
        set @start_time= GETDATE();
        
        print' - truncating the table silver.erp_px_cat_g1v2';
        truncate table Silver.erp_px_cat_g1v2

        print'---inserting into silver.erp_px_cat_g1v2';
        ---inserting into silver.erp_px_cat_g1v2

         insert into  Silver.erp_px_cat_g1v2
         ( id,
         cat,
         subcat,
         maintenance
         )

        -- All data is correct , No need for correction
        select id,
        cat,
        subcat,
        maintenance
        from Bronze.erp_px_cat_g1v2
        print 'Free from duplicate values and null';
        print'All files are loaded in there resp. tables';
         Set @end_time = GETDATE();
     print'>>>>Load duration is ;' + cast( datediff(second, @start_time,@end_time )as nvarchar) + 'seconds';
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

