<!--- This will run through all of the correctable data issues. --->

<!--- Set Start Points --->

	<!---<cfset getLastMonth = DateAdd("m", -6, NOW()) />--->
	<cfset beginMonth = CreateDate(YEAR(NOW()),MONTH(NOW()),1) />
	<cfset getTomorrow = DateAdd("d", 1, NOW()) />
<cfoutput>	
From :#beginMonth# To: #getTomorrow#<br><cfflush>
<!--- Start Customer QC'ing --->

<cfquery name="getCusts" datasource="reportsMaster">
	SELECT invoice_customers.*, invoices.order_number
	FROM invoice_customers
		INNER JOIN invoices ON (invoice_customers.CustomerNumber = invoices.customer_number)
	WHERE invoices.invoice_date BETWEEN <cfqueryparam value="#beginMonth#" cfsqltype="cf_sql_date" > AND <cfqueryparam value="#getTomorrow#" cfsqltype="cf_sql_date" >
</cfquery>

	<cfloop query="getCusts">
		<!--- Some additional client variables may be needed, so lets get them. --->
 <!--- Define Client Configuration --->
<cfset SESSION.getClientData = new com.clientConfig(clientNumber="#getCusts.SalesPersonNo#") />
		
		<!--- Check OsCID --->
		
			<cfif getCusts.osCID EQ '' OR IsNull(getCusts.osCID) OR getCusts.osCID EQ 0>
				<cfset oscFlag = 0 />
					<cfelse>
				<cfset oscFlag = 1 />	
			</cfif>
			<cfif oscFlag EQ 0 AND getCusts.order_number NEQ ''>
					
<cfset findOsCid = Request.oscFunctions.getOsCID(orderNumber='#getCusts.order_number#', custNumber='#getCusts.CustomerNumber#') /> OSC #CustomerNumber# <cfdump var="#findOsCid#"><br>
	<cfif findOsCid GT 0> <!--- If the OsCID was found, update both spots in invoice_customers and invoices --->
		<cfset doCorrect = Request.correct.updateCustID(CustomerNumber='#getCusts.CustomerNumber#', osCID=#findOsCid#) />
	</cfif>

					
			</cfif>	
			
	</cfloop>
	
	<!--- Find any missing customer first names. --->
<cfquery name="getFName" datasource="reportsMaster">
	SELECT invoice_customers.*, invoices.order_number
	FROM invoice_customers
		INNER JOIN invoices ON (invoice_customers.CustomerNumber = invoices.customer_number)
	WHERE invoices.invoice_date BETWEEN <cfqueryparam value="#beginMonth#" cfsqltype="cf_sql_date" > AND <cfqueryparam value="#getTomorrow#" cfsqltype="cf_sql_date" >
</cfquery>		
	 <cfloop query="getFName">
	 <cfif getFName.customerFirstName EQ '' OR IsNull(getFName.customerFirstName) OR #LEN(getFName.customerFirstName)# EQ 0>
				
				<cfset fnFlag = 0 />
					<cfelse>
				<cfset fnFlag = 1 />
					
			</cfif>
				<cfif #fnFlag# EQ 0 AND LEN(getFName.osCID) GT 1>
					<cfset findOsCid = Request.oscFunctions.getCustName(orderNumber='#getFName.order_number#', customerNumber='#getFName.osCID#') /> 
	<cfif findOsCid.RecordCount GT 0 AND findOsCid.customers_firstname NEQ ''> <!--- If the OsCID was found, update both spots in invoice_customers and invoices --->
		<cfset doCorrect = Request.correct.updateCustFirstName(CustomerNumber='#getFName.CustomerNumber#', firstName=#findOsCid.customers_firstname#) />
		
	</cfif> 
				</cfif>	
	 </cfloop>
	 
	 <!--- Find any missing customer last names. --->
<cfquery name="getLName" datasource="reportsMaster">
	SELECT invoice_customers.*, invoices.order_number
	FROM invoice_customers
		INNER JOIN invoices ON (invoice_customers.CustomerNumber = invoices.customer_number)
	WHERE invoices.invoice_date BETWEEN <cfqueryparam value="#beginMonth#" cfsqltype="cf_sql_date" > AND <cfqueryparam value="#getTomorrow#" cfsqltype="cf_sql_date" >
</cfquery>		
	 <cfloop query="getLName">
	 <cfif getLName.customerLastName EQ '' OR IsNull(getLName.customerLastName) OR #LEN(getLName.customerLastName)# EQ 0>
				
				<cfset lnFlag = 0 />
					<cfelse>
				<cfset lnFlag = 1 />
					
			</cfif>
				<cfif #lnFlag# EQ 0  AND LEN(getLName.osCID) GT 1>
					<cfset findOsCid = Request.oscFunctions.getCustName(orderNumber='#getLName.order_number#', customerNumber='#getLName.osCID#') /> 
	<cfif findOsCid.RecordCount GT 0 AND findOsCid.customers_lastname NEQ ''> <!--- If the OsCID was found, update both spots in invoice_customers and invoices --->
		<cfset doCorrect = Request.correct.updateCustLastName(CustomerNumber='#getLName.CustomerNumber#', lastName=#findOsCid.customers_lastname#) />

	</cfif>
				</cfif>	
	 </cfloop>
	  <!--- Update any missing extra osc data. --->
<cfquery name="getInvoiceData" datasource="reportsMaster">
	SELECT invoice_customers.*, invoices.order_number
	FROM invoice_customers
		INNER JOIN invoices ON (invoice_customers.CustomerNumber = invoices.customer_number)
	WHERE invoices.invoice_date BETWEEN <cfqueryparam value="#beginMonth#" cfsqltype="cf_sql_date" > AND <cfqueryparam value="#getTomorrow#" cfsqltype="cf_sql_date" >
</cfquery>		
	 <cfloop query="getInvoiceData">
	 	<cfset checkOsCData = getInfo.checkOsCData(clientID="#getInvoiceData.SalesPersonNumber#") />
		 
		 <cfif checkOsCData.RecordCount GT 0>
	
<cfloop query="checkOsCData">	
	<cfswitch expression="#checkOsCData.fieldMainKey#">
		<cfcase value="OsCID">
			<cfset theKey = #getInvoiceData.osCID# />
		</cfcase>
		<cfcase value="CustomersAccountNumber">
			<cfset theKey = '#getInvoiceData.CustomersAccountNumber#' />
		</cfcase>
		<cfcase value="OrderNumber">
			<cfset theKey = '#getInvoiceData.order_number#' />
		</cfcase>
		<cfdefaultcase>
			<cfset theKey = #getInvoiceData.osCID# />
		</cfdefaultcase>
	</cfswitch>
	
		<cfset GetOsCInfo = Request.oscFunctions.getOsCData(fieldMainKey='#checkOsCData.fieldMainKey#', fieldMainKeyValue='#theKey#', dataFromTable='#checkOsCData.dataFromTable#', fromTableField='#checkOsCData.fromTableField#', dataMatchOn='#checkOsCData.dataMatchOn#', datasource='#checkOsCData.dataFromDb#') />
	
	<!--- If there was extra data to collect, then insert it. --->
		<cfif #GetOsCInfo# NEQ ''>
				<!--- Now decide what extra table to insert data to. --->
				extraDataID=#checkOsCData.oscDataId#, custID=#getInvoiceData.CustomerNumber#, fieldValue='#GetOsCInfo#'<br><cfflush>	
						<!---<cfset addTheExtra = Request.correct.addCustOsC(extraDataID=#checkOsCData.oscDataId#, custID=#getInvoiceData.CustomerNumber#, fieldValue='#GetOsCInfo#') />--->
		
			</cfif>
		</cfloop>	
		</cfif>	
		 
	 </cfloop>
</cfoutput>
	<!--- End Customer QC'ing --->
	
	<!--- Update rebates and other product related functions. --->
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
       AND (invoices.invoice_date BETWEEN <cfqueryparam value="#beginMonth#" cfsqltype="cf_sql_date" > AND <cfqueryparam value="#getTomorrow#" cfsqltype="cf_sql_date" >) AND (invoices.invoice_id NOT IN (SELECT invoiceID FROM archivedInvoices))
</cfquery>

<cfoutput>
	
	<cfloop query="theDetails">
<!--- Some additional client variables may be needed, so lets get them. --->
 <!--- Define Client Configuration --->
<cfset SESSION.getClientData = new com.clientConfig(clientNumber="#theDetails.salesperson#") />

	<cfif SESSION.getClientData.clientRebates EQ 1>
		<cfset SESSION.getProductRebate = new com.productRebate(clientNumber="#theDetails.salesperson#", itemNumber="#theDetails.model_number#", orderNumber="#theDetails.order_number#", orderDate="#theDetails.order_date#", unitPrice="#theDetails.unit_price#", qtyShipped=#theDetails.quantity_shipped#) /> 
		<cfif SESSION.getProductRebate.netRebate NEQ 0 AND theDetails.net_rebate NEQ #SESSION.getProductRebate.netRebate#>
			#theDetails.net_rebate# #SESSION.getProductRebate.netRebate#<br><cfflush>
			
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