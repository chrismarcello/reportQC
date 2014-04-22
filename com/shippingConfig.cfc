<cfcomponent output="false">

		<!--- 
		  shippingConfig.cfc defines all shipping variables and then figures
		  out what the actual freight and if we are charging it to the clients.
		  
		  Created: 12/13/2012
		  Created By: Chris Marcello
	--->

<cfproperty name="invoiceNumber" type="string" required="yes" default="0">
<cfproperty name="freeShippingID" type="numeric" required="yes" default="0">
<cfproperty name="freeShipType" type="string" required="yes" default="0">
<cfproperty name="minFreight" type="any" required="yes" default="0.00">
<cfproperty name="maxFreight" type="any" required="yes" default="0.00">

		
	<cffunction name="init" returntype="any" hint="initialization">
		<cfargument name="invoiceNumber" required="yes">
		<cfargument name="freeShippingID" required="yes">
		<cfargument name="freightCharged" required="yes">
		<cfargument name="orderNumber" required="yes">
	
		<cfset THIS.invoiceNumber = arguments.invoiceNumber />
		<cfset THIS.freeShippingID = arguments.freeShippingID />
		<cfset THIS.dateShipped = arguments.dateShipped />
		<cfset THIS.freeShipCoupon = arguments.couponFreeShip />
		<cfset THIS.freeShipType = getfreeShipType() />
		<cfset THIS.minFreight = getMinShipAmount() />
		<cfset THIS.maxFreight = getMaxShipAmount() />
		<cfset THIS.diffFreight = getDiffShipAmount() />
		<cfset THIS.freightCharged = arguments.freightCharged />
		<cfset THIS.orderNumber = arguments.orderNumber />
		<cfset THIS.orderTotal = getOrderTotal() />
		<cfset THIS.orderShip = getOrderShip() />
		<cfset THIS.withinStandardRange = inStandardRange() />
		<cfset THIS.actualFreightCost = getActualFreight() />
		<cfset THIS.shipVia = getShippingCarrier() />
		<cfset THIS.finalFreightCost = freightSetter() />
		
		
		
	
	</cffunction>
	<cffunction name="getfreeShipType" access="private" returntype="string">
	
		<cfset var theShip = "" />
	<!--- Discard all cached queries --->
<cfobjectcache action="Clear">
	<cfif THIS.freeShipCoupon EQ 0>
	
	<cfquery name="theShip" datasource="#Request.mydns#">
	SELECT freeShipType
	FROM freeShipping
		WHERE freeId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#THIS.freeShippingID#"> AND isActive = <cfqueryparam value="1" cfsqltype="cf_sql_tinyint" >
	</cfquery>
	
		
			<cfreturn theShip.freeShipType>
			
				<cfelse>
				
				<cfset theType = "C" />
				
			<cfreturn #theType#>	
	</cfif>
	</cffunction>
	
	<cffunction name="getOrderTotal" access="private" returntype="string">
	
	<cfset var getOrderTotal = "" />
	
	
	<cfquery name="getOrderTotal" datasource="#Request.mydns2#" cachedwithin="#CreateTimeSpan(0, 6, 0, 0)#">
	SELECT value AS theTotal
		FROM orders_total
	WHERE orders_id LIKE <cfqueryparam value="#THIS.orderNumber#" cfsqltype="cf_sql_varchar">
	AND class LIKE <cfqueryparam value="ot_subtotal" cfsqltype="cf_sql_varchar">
	</cfquery>
	
		<cfif getOrderTotal.RecordCount GT 0>
			<cfreturn getOrderTotal.theTotal>
				<cfelseif THIS.freeShipType	EQ 'Z'>
			<cfreturn 1>	
			<cfelse>
			<cfreturn 0>
		</cfif>
	
	</cffunction>
	
	<cffunction name="getOrderShip" access="private" returntype="string">
	
	<cfset var getOrderTotal = "" />
	
	
	<cfquery name="getOrderTotal" datasource="#Request.mydns2#" cachedwithin="#CreateTimeSpan(0, 6, 0, 0)#">
	SELECT value AS theTotal
		FROM orders_total
	WHERE orders_id LIKE <cfqueryparam value="#THIS.orderNumber#" cfsqltype="cf_sql_varchar">
	AND class LIKE <cfqueryparam value="ot_shipping" cfsqltype="cf_sql_varchar">
	</cfquery>
	
		<cfif getOrderTotal.RecordCount GT 0>
			<cfreturn getOrderTotal.theTotal>	
			<cfelse>
			<cfreturn 0>
		</cfif>
	
	</cffunction>
	
	<cffunction name="getMinShipAmount" access="private" returntype="numeric">
	
		<cfset var theShip = "" />
	
	<cfquery name="theShip" datasource="#Request.mydns#">
	SELECT minAmount
	FROM freeShipping
		WHERE freeId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#THIS.freeShippingID#"> AND isActive = <cfqueryparam value="1" cfsqltype="cf_sql_tinyint" >
	</cfquery>
	
		<cfif theShip.RecordCount GT 0>
			<cfreturn theShip.minAmount>
				<cfelse>
			<cfreturn 0>	
		</cfif>
	
		
			
	
	</cffunction>
	
	<cffunction name="getMaxShipAmount" access="private" returntype="numeric">
	
		<cfset var theShip = "" />
	
	<cfquery name="theShip" datasource="#Request.mydns#">
	SELECT maxAmount
	FROM freeShipping
		WHERE freeId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#THIS.freeShippingID#"> AND isActive = <cfqueryparam value="1" cfsqltype="cf_sql_tinyint" >
	</cfquery>
	
		
			<cfif theShip.RecordCount GT 0>
				<cfif theShip.maxAmount EQ 0>
					<cfreturn 2000>
						<cfelse>
					<cfreturn theShip.maxAmount>	
				</cfif>
			
				<cfelse>
				<cfreturn 125>
		</cfif>
	
	</cffunction>
	
	<cffunction name="getDiffShipAmount" access="private" returntype="numeric">
	
		<cfset var theShip = "" />
	
	<cfquery name="theShip" datasource="#Request.mydns#">
	SELECT diffAmount
	FROM freeShipping
		WHERE freeId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#THIS.freeShippingID#"> AND isActive = <cfqueryparam value="1" cfsqltype="cf_sql_tinyint" >
	</cfquery>
	
		
			<cfif theShip.RecordCount GT 0>
			<cfreturn theShip.diffAmount>
				<cfelse>
			<cfreturn 0>	
		</cfif>
	
	</cffunction>
	
	<cffunction name="inStandardRange" access="private" returntype="boolean">
	
		<cfif THIS.orderTotal NEQ 0 AND THIS.orderTotal LTE #THIS.maxFreight#>
			<cfset withinRange = 1 />
			
				<cfelse>
			<cfset withinRange = 0 />	
		</cfif>
	
		
			<cfreturn withinRange>
	
	</cffunction>
	
	<cffunction name="getActualFreight" access="private" returntype="any">
	
		<cfset actualFrght = Request.oscFunctions.getActualFreight(orderNumber='#THIS.invoiceNumber#', dateShipped='#THIS.dateShipped#') />
	
		<cfif actualFrght.theShippingCharge EQ ''>
			<cfset theActualAmount = 0.00 />
				<cfelse>
			<cfset theActualAmount = actualFrght.theShippingCharge />	
		</cfif>
		<cfif theActualAmount EQ ''>
			<cfset theActualAmount = 0.00>
		</cfif>
			<cfreturn theActualAmount>
	
	</cffunction>
	
<cffunction name="getShippingCarrier" access="private" returntype="any">
	
		<cfset getCarrier = Request.oscFunctions.getShippingMethod(orderNumber='#THIS.invoiceNumber#', dateShipped='#THIS.dateShipped#') />
		<cfif getCarrier EQ ''>
			<cfset theCarrier = '' />
				<cfelse>
			<cfset theCarrier = "#getCarrier#" />	
		</cfif>
		
			<cfreturn theCarrier>
	
	</cffunction>

<cffunction name="freightSetter" access="private" returntype="any" hint="Sets the freight to charge clients">
	<cfif THIS.freeShipType EQ 'G'>
	
		<cfif THIS.withinStandardRange EQ 1>
			<cfreturn THIS.actualFreightCost />
				<cfelse>
			<cfreturn 0.00 />	
		</cfif>
	
	</cfif>
	
	<cfif THIS.freeShipType EQ 'T'>
		<cfif THIS.withinStandardRange EQ 1 AND THIS.actualFreightCost NEQ 0> <!--- If in range, process here. --->
			<cfif THIS.freightCharged EQ THIS.minFreight>
				<cfset freightDiff = THIS.actualFreightCost - THIS.freightCharged />
				
					<cfif THIS.maxFreight GT 0>
						<cfif #freightDiff# NEQ 0 AND #freightDiff# LTE #THIS.maxFreight#>
						<cfreturn #freightDiff# />
							<cfelse>
						<cfreturn 0.00 />	
					</cfif>
							<cfelse>
					<cfif #freightDiff# NEQ 0>
						<cfreturn #freightDiff# />
							<cfelse>
						<cfreturn 0.00 />	
					</cfif>		
							
				</cfif>
				
				
				<cfelse>
				<cfreturn 0.00 />
			</cfif>
		
		
			<cfelse> <!--- If freight not in standard range. --->
			<cfreturn 0.00 />
		</cfif>
	</cfif>
	<cfif THIS.freeShipType EQ 'D'>
		
		<cfif THIS.freightCharged EQ 5 AND LEFT(THIS.orderNumber, 1) EQ "S" OR THIS.freightCharged EQ 0 AND LEFT(THIS.orderNumber, 1) EQ "S">
				<cfif THIS.freightCharged EQ THIS.minFreight>
					<cfset freightDiff = THIS.actualFreightCost - THIS.freightCharged - 1.50 />
						<cfif freightDiff GT 0>
							<cfreturn #freightDiff# />
								<cfelse>
							<cfreturn 0.00 />		
						</cfif>
				</cfif>
				<cfif THIS.freightCharged EQ 0>
						<cfif THIS.actualFreightCost LTE 1.50>
							<cfreturn 0.00 />
								<cfelse>
							<cfset freightDiff = THIS.actualFreightCost - 1.50 />
							<cfreturn #freightDiff# />		
						</cfif>
				</cfif>
			<cfelse>
				<cfreturn 0.00 />
		</cfif>
		<!---
		
		<cfif THIS.withinStandardRange EQ 1 AND THIS.actualFreightCost NEQ 0> <!--- If in range, process here. --->
			<cfif THIS.freightCharged EQ THIS.minFreight> <!--- Added $1.50 as EFI Subsidy --->
				<cfset freightDiff = THIS.actualFreightCost - THIS.freightCharged - 1.50 />
				
					<cfif THIS.maxFreight GT 0>
						<cfif #freightDiff# GT 0 AND #freightDiff# LTE #THIS.maxFreight#>
							<cfreturn #freightDiff# />
						<cfelse>
							<cfreturn 0.00 />	
						</cfif>
						
						
						
					<cfelse>
							
							
					</cfif>
				
				
				<cfelse>
						<cfif THIS.actualFreightCost LTE 1.50>
							<cfreturn 0.00 />
								<cfelse>
							<cfset freightDiff = THIS.actualFreightCost - 1.50 />
							<cfreturn #freightDiff# />		
						</cfif>
			</cfif>
		
		
			<cfelse> <!--- If freight not in standard range. --->
			<cfreturn 0.00 />
		</cfif>--->
	</cfif>
	<cfif THIS.freeShipType EQ 'N'>
	
		
			<cfif THIS.withinStandardRange EQ 1 AND THIS.actualFreightCost NEQ 0> <!--- If in range, process here. --->
				<cfif THIS.freightCharged EQ 0 AND THIS.orderTotal GT 25>
					<cfreturn #THIS.actualFreightCost# />
						<cfelseif THIS.freightCharged EQ THIS.diffFreight>
					<cfset freightDiff = THIS.actualFreightCost - THIS.freightCharged />
						<cfreturn #freightDiff# />
						<!---<cfelseif THIS.orderTotal GT 25>
					<cfreturn #THIS.actualFreightCost# />--->	
					<cfelse>
				<cfreturn 0.00 />	
				</cfif>
			<cfelse> <!--- If freight not in standard range. --->
			<cfreturn 0.00 />
		</cfif>
				
	
	</cfif>
	
	<cfif THIS.freeShipType EQ 'S'>
	
	<cfset theTotalShip = THIS.freightCharged + THIS.orderShip>
	
		<cfif THIS.withinStandardRange EQ 1 AND #theTotalShip# EQ 0>
			<cfreturn THIS.diffFreight />
				<cfelse>
			<cfreturn 0.00 />	
		</cfif>
	
	</cfif>
	<cfif THIS.freeShipType EQ 'C' OR THIS.freeShipType EQ 'Z'>
	
		
			<cfreturn THIS.actualFreightCost />
				
	
	</cfif>
</cffunction>
</cfcomponent>