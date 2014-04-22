<cfcomponent hint="This updates data." output="false">
<cffunction name="updateCustID" access="remote" returntype="void">
		<cfargument name="CustomerNumber" required="yes">
		<cfargument name="oscID" required="yes">
	
		
			<cfquery datasource="#Request.mydns#">
			UPDATE invoice_customers
				SET OsCID = <cfqueryparam value="#arguments.oscID#" cfsqltype="cf_sql_integer">
			WHERE CustomerNumber = <cfqueryparam value="#arguments.CustomerNumber#" cfsqltype="cf_sql_varchar">
			</cfquery>
			
			<cfquery datasource="#Request.mydns#">
			UPDATE invoices
				SET OsCID = <cfqueryparam value="#arguments.oscID#" cfsqltype="cf_sql_integer">
			WHERE customer_number = <cfqueryparam value="#arguments.CustomerNumber#" cfsqltype="cf_sql_varchar">
			</cfquery>
		
	</cffunction>
	<cffunction name="updateCustFirstName" access="remote" returntype="void">
		<cfargument name="CustomerNumber" required="yes">
		<cfargument name="firstName" required="yes">
	
		
			<cfquery datasource="#Request.mydns#">
			UPDATE invoice_customers
				SET customerFirstName = <cfqueryparam value="#arguments.firstName#" cfsqltype="cf_sql_varchar">
			WHERE CustomerNumber = <cfqueryparam value="#arguments.CustomerNumber#" cfsqltype="cf_sql_varchar">
			</cfquery>
			
			
		
	</cffunction>
	<cffunction name="updateCustLastName" access="remote" returntype="void">
		<cfargument name="CustomerNumber" required="yes">
		<cfargument name="lastName" required="yes">
	
		
			<cfquery datasource="#Request.mydns#">
			UPDATE invoice_customers
				SET customerLastName = <cfqueryparam value="#arguments.lastName#" cfsqltype="cf_sql_varchar">
			WHERE CustomerNumber = <cfqueryparam value="#arguments.CustomerNumber#" cfsqltype="cf_sql_varchar">
			</cfquery>
			
			
		
	</cffunction>
	<cffunction name="addCustOsC" access="remote" returntype="void">
		<cfargument name="extraDataID" required="yes">
		<cfargument name="custID" type="string" required="yes">
		<cfargument name="fieldValue" required="yes">
		
		
	
		<cfquery datasource="#Request.mydns#">
		INSERT INTO clientOsCData (oscDataID, custID, fieldValue)
			VALUES (
						<cfqueryparam value="#arguments.extraDataID#" cfsqltype="cf_sql_integer">,
						<cfqueryparam value="#arguments.custID#" cfsqltype="cf_sql_varchar">,
                        <cfqueryparam value="#arguments.fieldValue#" cfsqltype="cf_sql_varchar">
						
					)
		</cfquery>
	
	</cffunction>
</cfcomponent>