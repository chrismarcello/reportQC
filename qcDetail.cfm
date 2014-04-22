<cfset getYesterday = DateAdd("d", -6, NOW()) />
	
<cfset getTomorrow = DateAdd("d", 1, NOW()) />


<cfquery name="theDetails" datasource="#Request.mydns#">
		SELECT invoice_products.invoice_products_id,
       invoice_products.lineSeqNo,
       invoice_products.model_number,
       invoice_products.IsKit,
       invoice_products.quantity_shipped,
       invoice_products.unit_price,
       invoice_products.net_price,
       invoice_products.unit_rebate,
       invoice_products.net_rebate,
 
       invoices.invoice_id,
       invoices.invoice_number,
       invoices.order_number,
       invoices.invoice_date,
       invoices.order_date,
       invoices.salesperson,
       invoices.invoice_type
  FROM reportsMaster.invoices invoices
        INNER JOIN reportsMaster.invoice_products invoice_products
           ON (invoice_products.invoice_id = invoices.invoice_id)
       
 WHERE     (invoice_products.IsKit != 'C')
       AND (invoice_products.quantity_shipped != 0)
       AND (invoices.invoice_date BETWEEN <cfqueryparam value="#getYesterday#" cfsqltype="cf_sql_date" > AND <cfqueryparam value="#getTomorrow#" cfsqltype="cf_sql_date" >) 
</cfquery>

<cfoutput>
	
	<cfloop query="theDetails">
<!--- Some additional client variables may be needed, so lets get them. --->
 <!--- Define Client Configuration --->
<cfset SESSION.getClientData = new com.clientConfig(clientNumber="#theDetails.salesperson#") />
<!---clientNumber="#theDetails.salesperson#", itemNumber="#theDetails.model_number#", orderNumber="#theDetails.order_number#", orderDate="#theDetails.order_date#", unitPrice="#theDetails.unit_price#", netRebate="#theDetails.net_rebate#"<br><cfflush>--->
	<cfif SESSION.getClientData.clientRebates EQ 1>
		<cfset SESSION.getProductRebate = new com.productRebate(clientNumber="#theDetails.salesperson#", itemNumber="#theDetails.model_number#", orderNumber="#theDetails.order_number#", orderDate="#theDetails.order_date#", unitPrice="#theDetails.unit_price#", qtyShipped=#theDetails.quantity_shipped#) /> 
		<cfif SESSION.getProductRebate.netRebate NEQ 0 AND theDetails.net_rebate NEQ #SESSION.getProductRebate.netRebate#>
			#theDetails.net_rebate# #SESSION.getProductRebate.netRebate#<br><cfflush>
			<!---<cfdump var="#SESSION.getProductRebate#">--->
			<cfquery datasource="reportsMaster">
					UPDATE invoice_products
					SET unit_rebate = <cfqueryparam value="#SESSION.getProductRebate.unitRebate#" cfsqltype="cf_sql_money">,
					 
					net_rebate = <cfqueryparam value="#SESSION.getProductRebate.netRebate#" cfsqltype="cf_sql_money">,
					
					reportType = #SESSION.getProductRebate.reportType#,
					
					lastUpdated = <cfqueryparam value="#NOW()#" cfsqltype="cf_sql_timestamp">
					
					WHERE invoice_products_id = <cfqueryparam value="#theDetails.invoice_products_id#" cfsqltype="cf_sql_integer">
			</cfquery>
		</cfif>
	</cfif>

	</cfloop> 
	
</cfoutput>		