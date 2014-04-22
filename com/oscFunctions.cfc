<cfcomponent>
<cffunction name="getOsCID" access="public" returntype="any">
	<cfargument name="orderNumber" required="yes">
	<cfargument name="custNumber" required="yes">
	
	<cfset var getOsC = "" />
	
	
	<cfquery name="getOsC" datasource="efi">
	SELECT customers.customers_id
			FROM customers
				INNER JOIN orders
					ON (customers.customers_id = orders.customers_id)
		WHERE orders.orders_id LIKE <cfqueryparam value="#arguments.orderNumber#" cfsqltype="cf_sql_varchar">
	</cfquery>
		<cfif getOsC.RecordCount GT 0>
			<cfset theCustID = getOsC.customers_id />
				<cfelse>
	<cfquery name="getOsCID" datasource="efi">
	SELECT Shopper 
FROM  `mas_eccs` 
WHERE  `CustomerNo` LIKE <cfqueryparam value="50#arguments.custNumber#" cfsqltype="cf_sql_varchar">
	</cfquery>			
		<cfif getOsCID.RecordCount GT 0>
			<cfset theCustID = getOsCID.Shopper />
				<cfelse>
			<cfset theCustID = getOsCID.Shopper />		
		</cfif>
			
		
		</cfif>
	
		<cfreturn #theCustID#>
	</cffunction>
	
	<cffunction name="getOrderTotal" access="public" returntype="any"> 
	<cfargument name="orderID" required="yes">
	
	<cfset var getOrderTotal = "" />
	
	<cfquery name="getOrderTotal" datasource="#Request.mydns2#">
	SELECT value AS theTotal
		FROM orders_total
	WHERE orders_id LIKE <cfqueryparam value="#arguments.orderID#" cfsqltype="cf_sql_varchar">
	AND class LIKE <cfqueryparam value="ot_subtotal" cfsqltype="cf_sql_varchar">
	</cfquery>
	
	<cfreturn getOrderTotal.theTotal>
	</cffunction>
	
	<cffunction name="getCustName" access="public" returntype="any">
		<cfargument name="customerNumber" type="string" required="yes">
		
		
		<cfset var theCount = "" />
		
		<cfquery name="theCount" datasource="#Request.mydns2#">
		SELECT customers_firstname, customers_lastname, customers_telephone 
		FROM customers
	    WHERE customers_id = <cfqueryparam value="#arguments.customerNumber#" cfsqltype="cf_sql_integer">
		</cfquery>
		
		<cfset myResult="#theCount#">
		<cfreturn myResult>
	</cffunction>
	<cffunction name="getCustOrderInfo" access="public" returntype="any">
		<cfargument name="orderNumber" type="string" required="yes">
		
		
		<cfset var theCount = "" />
		
		<cfquery name="theCount" datasource="#Request.mydns2#">
		SELECT customers_company, customers_street_address, customers_street_address2, customers_city, customers_postcode, customers_state  
		FROM orders
	    WHERE orders_id = <cfqueryparam value="#arguments.orderNumber#" cfsqltype="cf_sql_varchar">
		</cfquery>
		
		<cfset myResult="#theCount#">
		<cfreturn myResult>
	</cffunction>
	<cffunction name="getCoupons" access="public" returntype="any">
		<cfargument name="orderNumber" type="string" required="yes">
	
	<cfset var getcoups = "" />
		
<cfquery name="getcoups" datasource="efi">
SELECT coupon_redeem_track.*, coupons.coupon_type, coupons.coupon_code, coupons.coupon_amount, coupons.coupon_free_shipping
FROM coupon_redeem_track
	INNER JOIN coupons ON (coupon_redeem_track.coupon_id = coupons.coupon_id)
WHERE coupon_redeem_track.order_id = <cfqueryparam value="#arguments.orderNumber#" cfsqltype="cf_sql_varchar">
</cfquery>
		
		<cfset myResult = #getcoups#>
		<cfreturn myResult>
	</cffunction>
	
	<cffunction name="getVouchers" access="public" returntype="any">
		<cfargument name="custNumber" type="string" required="yes">
		<cfargument name="theStartDate" type="date" required="yes">
	
	<cfset var getcoups = "" />
		
<cfquery name="getcoups" datasource="efi" cachedwithin="#CreateTimeSpan(0, 6, 0, 0)#">
SELECT coupon_redeem_track.*, coupons.coupon_type, coupons.coupon_code, coupons.coupon_amount, coupons.coupon_free_shipping
FROM coupon_redeem_track
	INNER JOIN coupons ON (coupon_redeem_track.coupon_id = coupons.coupon_id)
WHERE coupon_redeem_track.customer_id = <cfqueryparam value="#arguments.custNumber#" cfsqltype="cf_sql_integer"> AND coupon_type = <cfqueryparam value="G" cfsqltype="cf_sql_char"> AND DATE(coupon_redeem_track.redeem_date) BETWEEN <cfqueryparam value="#arguments.theStartDate#" cfsqltype="cf_sql_date"> AND <cfqueryparam value="#NOW()#" cfsqltype="cf_sql_date">
</cfquery>

<!---<cfquery name="getcoups" datasource="efi">
SELECT coupon_redeem_track.*, coupons.coupon_type, coupons.coupon_code, coupons.coupon_amount, coupons.coupon_free_shipping
FROM coupon_redeem_track
	INNER JOIN coupons ON (coupon_redeem_track.coupon_id = coupons.coupon_id)
WHERE coupon_redeem_track.customer_id = <cfqueryparam value="#arguments.custNumber#" cfsqltype="cf_sql_integer"> AND DATE(coupon_redeem_track.redeem_date) BETWEEN <cfqueryparam value="#arguments.theStartDate#" cfsqltype="cf_sql_date"> AND <cfqueryparam value="#NOW()#" cfsqltype="cf_sql_date">
</cfquery>--->
		
		<cfset myResult = #getcoups#>
		<cfreturn myResult>
	</cffunction>
	
	<cffunction name="getActualFreight" access="public" returntype="any">
		<cfargument name="orderNumber" type="string" required="yes">
		<cfargument name="dateShipped" type="string" required="yes">
	
	<cfset var tracker = "" />
<cfset replaceList = "CB,CC,CN,CK,CR" />		
			<cfquery name="tracker" datasource="reportsMaster">
			SELECT SUM(Ship_Charge) AS theShippingCharge
			FROM tracking_numbers
			WHERE invoiceNumber = <cfqueryparam value="#arguments.orderNumber#" cfsqltype="cf_sql_varchar"> AND date_sent = <cfqueryparam value="#arguments.dateShipped#" cfsqltype="cf_sql_date"> <cfloop list="#replaceList#" index="rl">
AND orders_id NOT LIKE <cfqueryparam value="#rl#%" cfsqltype="cf_sql_varchar">
</cfloop>
			</cfquery>
		
		<cfset myResult = #tracker#>
		<cfreturn myResult>
	</cffunction>
	
	<cffunction name="getShippingMethod" access="public" returntype="any">
		<cfargument name="orderNumber" type="string" required="yes">
		<cfargument name="dateShipped" type="string" required="yes">
	
	<cfset var tracker = "" />
		
			<cfquery name="tracker" datasource="reportsMaster">
			SELECT DISTINCT method
			FROM tracking_numbers
			WHERE invoiceNumber = <cfqueryparam value="#arguments.orderNumber#" cfsqltype="cf_sql_varchar"> AND date_sent = <cfqueryparam value="#arguments.dateShipped#" cfsqltype="cf_sql_date">
			LIMIT 1
			</cfquery>
		
		<cfset myResult = #tracker.method#>
		<cfreturn myResult>
	</cffunction>
	
	<cffunction name="updateTracking" access="remote" returntype="void">
		<cfargument name="trackid" type="string" required="yes">
		<cfargument name="invoiceID" required="yes">
	
		
			<cfquery datasource="#Request.mydns#">
			UPDATE tracking_numbers
				SET reported = <cfqueryparam value="#arguments.invoiceID#" cfsqltype="cf_sql_integer">
			WHERE track_id = <cfqueryparam value="#arguments.trackid#" cfsqltype="cf_sql_integer">
			</cfquery>
		
	</cffunction>
	
	<cffunction name="getProductId" access="public" returntype="any">
		<cfargument name="modelNumber" type="string" required="yes">
	
	<cfset var tracker = "" />
		
			<cfquery name="tracker" datasource="efi">
			SELECT products_id, products_model
				FROM products
				WHERE products_model = <cfqueryparam value="#arguments.modelNumber#" cfsqltype="cf_sql_varchar">
			</cfquery>
		
		<cfset myResult = #tracker#>
		<cfreturn myResult>
	</cffunction>
	<cffunction name="getOsCData" access="public" returntype="any">
		<cfargument name="fieldMainKey" type="string" required="yes">
		<cfargument name="fieldMainKeyValue" required="yes">
		<cfargument name="dataFromTable" type="string" required="yes">
		<cfargument name="fromTableField" type="string" required="yes">
		<cfargument name="dataMatchOn" type="string" required="yes">
		<cfargument name="datasource" type="string" required="yes">
	
	<cfset var extra = "" />
		
			<cfquery name="extra" datasource="#arguments.datasource#">
			SELECT DISTINCT #arguments.fromTableField# AS theOsCData
				FROM #arguments.dataFromTable#
				WHERE #arguments.dataMatchOn#
				<cfif arguments.fieldMainKey EQ 'OcCID'>
			= <cfqueryparam value="#arguments.fieldMainKeyValue#" cfsqltype="cf_sql_integer">	
				<cfelseif arguments.fieldMainKey EQ 'CustomersAccountNumber'>
				<cfset theAccountNo = Replace(arguments.fieldMainKeyValue, "-", "", "ALL") />
				<cfset theAccountNo = Replace(#theAccountNo#, " ", "", "ALL") />
				<cfset theAccountNo = Rereplace(#theAccountNo#, "^0+", "") />
			LIKE <cfqueryparam value="%#theAccountNo#" cfsqltype="cf_sql_varchar">
					<cfelse>	
			LIKE <cfqueryparam value="#arguments.fieldMainKeyValue#" cfsqltype="cf_sql_varchar">		
				</cfif>
				 
			</cfquery>
		
		<cfset myResult = #extra.theOsCData#>
		<cfreturn myResult>
	</cffunction>
</cfcomponent>