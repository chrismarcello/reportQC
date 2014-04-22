<!--- Set Start Points --->

	<!---<cfset getLastMonth = DateAdd("m", -1, NOW()) />--->
	<cfset beginMonth = CreateDate(YEAR(NOW()),MONTH(NOW()),1) />
	<cfset getTomorrow = DateAdd("d", 1, NOW()) />
	

<!--- Start Customer QC'ing --->

<cfquery name="getInvoices" datasource="reportsMaster">
	SELECT invoice_customers.*
	FROM invoice_customers
		INNER JOIN invoices ON (invoice_customers.CustomerNumber = invoices.customer_number)
	WHERE invoices.invoice_date BETWEEN <cfqueryparam value="#beginMonth#" cfsqltype="cf_sql_date" > AND <cfqueryparam value="#getTomorrow#" cfsqltype="cf_sql_date" >
</cfquery>
<cfoutput>
	<cfloop query="getInvoices">
		<!--- Some additional client variables may be needed, so lets get them. --->
 <!--- Define Client Configuration --->
<cfset SESSION.getClientData = new com.clientConfig(clientNumber="#getInvoices.SalesPersonNo#") />
		
		<!--- Get Account Number Rules, then QC --->
	<cfquery name="checkAccountRules" datasource="#Request.mydns#">
	SELECT `accountRuleID` 
	FROM `client_rules_utilityaccounts` 
	WHERE clientNumber = <cfqueryparam value="#getInvoices.SalesPersonNo#" cfsqltype="cf_sql_varchar" >
	</cfquery>
		<cfif checkAccountRules.RecordCount GT 0>
			<cfset SESSION.getAccountRules = new com.accountRules(accountRuleID=#checkAccountRules.accountRuleID#, accountNumber='#getInvoices.CustomersAccountNumber#') /> 
				<cfif SESSION.getAccountRules.accountPassFail EQ 0>
					<!--- Log error or do something here --->
					<cfdump var="#SESSION.getAccountRules#">
				</cfif>
		</cfif>
		
		<!--- Get State Rules, then QC --->
	<cfquery name="checkStateRules" datasource="#Request.mydns#">
	SELECT `stateRuleID`, `stateRule` 
	FROM `client_rules_state` 
	WHERE clientNumber = <cfqueryparam value="#getInvoices.SalesPersonNo#" cfsqltype="cf_sql_varchar" >
	</cfquery>
		<cfif checkStateRules.RecordCount GT 0>
			<cfif checkStateRules.stateRule NEQ '#getInvoices.CustState#'>
				<cfset stateFlag = 0 />
					<cfelse>
				<cfset stateFlag = 1 />		
			</cfif>
				<cfif stateFlag EQ 0>
					
					<!--- Log error or do something here --->
					
				#getInvoices.CustomerNumber# #SalesPersonNo# #CustState# #CustomersAccountNumber# Failed! <br><cfflush>
				</cfif>
		</cfif>
		
		<!--- Check OsCID --->
		
			<cfif getInvoices.osCID EQ '' OR IsNull(getInvoices.osCID) OR getInvoices.osCID EQ 0>
				<cfset oscFlag = 0 />
					<cfelse>
				<cfset oscFlag = 1 />	
			</cfif>
			<cfif oscFlag EQ 0>
					#getInvoices.CustomerNumber# Failed - No OsC ID! <br><cfflush>
			</cfif>	
			<!--- Check First Name --->
		
			<cfif getInvoices.customerFirstName EQ '' OR IsNull(getInvoices.customerFirstName) OR #LEN(getInvoices.customerFirstName)# EQ 0>
				
				<cfset fnFlag = 0 />
					<cfelse>
				<cfset fnFlag = 1 />
					
			</cfif>
				<cfif #fnFlag# EQ 0>
					#getInvoices.CustomerNumber# Failed - No First Name! <br><cfflush>
					</cfif>	
			<!--- Check Last Name --->
			<cfif getInvoices.customerLastName EQ '' OR IsNull(getInvoices.customerLastName) OR #LEN(getInvoices.customerLastName)# EQ 0>
				<cfset lnFlag = 0 />
					<cfelse>
				<cfset lnFlag = 1 />
			</cfif>
				<cfif lnFlag EQ 0>
					#getInvoices.CustomerNumber# Failed - No Last Name! <br><cfflush>
					</cfif>		
			<!--- Check PO Box Address for some clients --->
	</cfloop> 
</cfoutput>
	<!--- End Customer QC'ing --->

	<!--- Invoice QC's --->
<cfquery name="qcInvoices" datasource="reportsMaster">
	SELECT invoices.customer_number, invoices.salesperson, invoice_customers.SalesPersonNo
	FROM invoices
		INNER JOIN invoice_customers ON (invoices.customer_number = invoice_customers.CustomerNumber)
	WHERE invoices.invoice_date BETWEEN <cfqueryparam value="#beginMonth#" cfsqltype="cf_sql_date" > AND <cfqueryparam value="#getTomorrow#" cfsqltype="cf_sql_date" >
</cfquery>
		<!--- Checking to make sure that the invoice.salesperson matches the invoice_customers.SalesPersonNo. --->
<cfoutput>
	<cfloop query="qcInvoices">
		<cfif qcInvoices.salesperson NEQ qcInvoices.SalesPersonNo>
		#customer_number# #qcInvoices.SalesPersonNo# Fail!<br><cfflush>
		</cfif>
	</cfloop> 
</cfoutput>

	<!--- Invoice Details QC --->
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
       AND (invoices.invoice_date BETWEEN <cfqueryparam value="#beginMonth#" cfsqltype="cf_sql_date" > AND <cfqueryparam value="#getTomorrow#" cfsqltype="cf_sql_date" >) 
</cfquery>

<cfoutput>
	
	<cfloop query="theDetails">
<!--- Some additional client variables may be needed, so lets get them. --->
 <!--- Define Client Configuration --->
<cfset SESSION.getClientData = new com.clientConfig(clientNumber="#theDetails.salesperson#") />

	<cfif SESSION.getClientData.clientRebates EQ 1>
		<cfset SESSION.getProductRebate = new com.productRebate(clientNumber="#theDetails.salesperson#", itemNumber="#theDetails.model_number#", orderNumber="#theDetails.order_number#", orderDate="#theDetails.order_date#", unitPrice="#theDetails.unit_price#", qtyShipped=#theDetails.quantity_shipped#) /> 
		<cfif SESSION.getProductRebate.netRebate NEQ 0 AND theDetails.net_rebate NEQ #SESSION.getProductRebate.netRebate#>
			#theDetails.unit_rebate# #theDetails.net_rebate# #SESSION.getProductRebate.unitRebate# #SESSION.getProductRebate.netRebate#
			<cfdump var="#SESSION.getProductRebate#"><br><cfflush>
			
		</cfif>
	</cfif>

	</cfloop> 
	
</cfoutput>	