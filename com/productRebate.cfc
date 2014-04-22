<cfcomponent output="false" accessors="true">

	<!--- 
		  productRebate.cfc Decides if a product has an incentive and what that incentive is.
		  
		  Created: 4/17/2014
		  Created By: Chris Marcello
	--->

<!---<cfproperty name="clientNumber" type="string" required="yes" default="0">
<cfproperty name="clientID" type="numeric" required="yes" default="0">
<cfproperty name="clientFreeShipping" type="numeric" required="yes" default="0">
<cfproperty name="theFreeShippingID" type="numeric" required="yes" default="0">
<cfproperty name="reportSubset" type="numeric" required="yes" default="0">--->

		
	<cffunction name="init" returntype="any" hint="initialization">
		<cfargument name="clientNumber" required="yes">
		<cfargument name="itemNumber" required="yes">
		<cfargument name="orderNumber" required="yes">
		<cfargument name="orderDate" required="yes">
		<cfargument name="unitPrice" required="yes">
		<cfargument name="qtyShipped" required="yes" default="0">
		
	
		<cfset THIS.clientNumber = arguments.clientNumber />
		<cfset THIS.itemNumber = arguments.itemNumber />
		<cfset THIS.orderNumber = arguments.orderNumber />
		<cfset THIS.orderDate = arguments.orderDate />
		<cfset THIS.unitPrice = arguments.unitPrice />
		<cfset THIS.qtyShipped = arguments.qtyShipped />
		<cfset THIS.rebateQuery = queryRebates() />
		<cfset THIS.rebateFlag = setRebateFlag() />
		<cfset THIS.isReplacement = checkReplacement() />
		<cfset THIS.reportType = setProductType() />
		<cfset THIS.unitRebate = setUnitRebate() />
		<cfset THIS.netRebate = setNetRebate() />
		
		
	
	</cffunction>
	<cffunction name="queryRebates" access="private" returntype="query">
	
		<cfset var theRebate = "" />
	
	<cfquery name="theRebate" datasource="#Request.mydns#">
	SELECT RebateProdId AS rebateID, RebateAmount, freeProduct, rebateStartDate, rebateEndDate, isSubRebatedProduct
		FROM RebatedProducts
	WHERE ClientNumber LIKE <cfqueryparam value="#THIS.clientNumber#" cfsqltype="cf_sql_varchar"> AND modelNumber LIKE <cfqueryparam value="#THIS.itemNumber#" cfsqltype="cf_sql_varchar"> AND (rebateStartDate <= <cfqueryparam cfsqltype="cf_sql_date" value="#THIS.orderDate#">) AND (rebateEndDate >= <cfqueryparam cfsqltype="cf_sql_date" value="#THIS.orderDate#">)

	</cfquery>
		<cfreturn theRebate>
		
	
	</cffunction>
	<cffunction name="setRebateFlag" access="private" returntype="any">
	
		<cfset rebateQuery = #THIS.rebateQuery# />
			<cfif rebateQuery.RecordCount GT 0 OR IsDefined("rebateQuery.rebateID") AND rebateQuery.rebateID NEQ ''>
				<cfset rebateFlag = 1 />
					<cfelse>
				<cfset rebateFlag = 0 />		
			</cfif>
		
				<cfreturn rebateFlag>
	
	</cffunction>
	<cffunction name="checkReplacement" access="private" returntype="any">
	
		<cfset theReplacementList = "CA,CB,CC,CD,CE,CF,CG,CH,CI,CJ,CK,CL,CM,CN,CO,CP,CQ,CR,CS,CT,CU,CV,CW,CX,CY,CZ" />
			<cfset theOrder = LEFT(THIS.orderNumber, 2) />
			
			<cfset checkList = ListFind(theReplacementList, theOrder) />
				<cfif checkList IS 0>
					<cfset replaceFlag = 0 />
						<cfelse>
					<cfset replaceFlag = 1 />		
				</cfif>
				<cfreturn replaceFlag>
	
	</cffunction>
	<cffunction name="setProductType" access="private" returntype="any">
	
		<cfset rebateQuery = #THIS.rebateQuery# />
			<cfif rebateQuery.RecordCount GT 0 OR IsDefined("rebateQuery.rebateID") AND rebateQuery.rebateID NEQ ''>
				<cfset typeFlag = rebateQuery.isSubRebatedProduct />
					<cfelse>
				<cfset typeFlag = 0 />		
			</cfif>
				<cfreturn typeFlag>
	
	</cffunction>
	<cffunction name="setUnitRebate" access="private" returntype="any">
	
		<cfset rebateQuery = #THIS.rebateQuery# />
			<cfif THIS.rebateFlag EQ 1>
				<cfif THIS.isReplacement EQ 1 AND THIS.unitPrice GT 0>
						<cfset theRebate = rebateQuery.RebateAmount />
							
					<cfelseif THIS.isReplacement EQ 0 AND THIS.unitPrice GT 0>
						<cfset theRebate = rebateQuery.RebateAmount />
					<cfelse>
						<cfset theRebate = 0 />	
				</cfif>
						<cfelse>
				<cfset theRebate = 0 />			
			</cfif>
				<cfreturn NumberFormat(theRebate, '_.__')>
	
	</cffunction>
	<cffunction name="setNetRebate" access="private" returntype="any">
	
		<cfset rebateQuery = #THIS.rebateQuery# />
			<cfif THIS.rebateFlag EQ 1>
				<cfif THIS.isReplacement EQ 1 AND THIS.unitPrice GT 0>
						<cfset theRebate = rebateQuery.RebateAmount * THIS.qtyShipped />
							
					<cfelseif THIS.isReplacement EQ 0 AND THIS.unitPrice GT 0>
						<cfset theRebate = rebateQuery.RebateAmount * THIS.qtyShipped />
					<cfelse>
						<cfset theRebate = 0 />	
				</cfif>
						<cfelse>
				<cfset theRebate = 0 />			
			</cfif>
				<cfreturn NumberFormat(theRebate, '_.__')>
	
	</cffunction>
</cfcomponent>