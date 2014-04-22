<cfcomponent output="false" accessors="true">

	<!--- 
		  clientConfig.cfc defines client specific variables for processing during 
		  the reportsMaster database updates.
		  
		  Created: 12/13/2012
		  Created By: Chris Marcello
	--->

<cfproperty name="clientNumber" type="string" required="yes" default="0">
<cfproperty name="clientID" type="numeric" required="yes" default="0">
<cfproperty name="clientFreeShipping" type="numeric" required="yes" default="0">
<cfproperty name="theFreeShippingID" type="numeric" required="yes" default="0">
<cfproperty name="reportSubset" type="numeric" required="yes" default="0">

		
	<cffunction name="init" returntype="any" hint="initialization">
		<cfargument name="clientNumber" required="yes">
		
	
		<cfset THIS.clientNumber = arguments.clientNumber />
		<cfset THIS.clientID = getClientID() />
		<cfset THIS.clientRebates = checkClientRebates() />
		<cfset THIS.clientFreeShipping = checkFreeShipping() />
		<cfset THIS.theFreeShippingID = freeShippingID() />
		<cfset THIS.reportSubset = checkSubReports() />
		
		
	
	</cffunction>
	<cffunction name="getClientID" access="private" returntype="numeric">
	
		<cfset var theClient = "" />
	
	<cfquery name="theClient" datasource="#Request.mydns#" cachedwithin="#CreateTimeSpan(0, 6, 0, 0)#">
	SELECT clients.ClientId
	FROM clients
		WHERE clients.ClientNumber LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#THIS.clientNumber#"> AND clients.clientActive = <cfqueryparam value="0" cfsqltype="cf_sql_tinyint" >
	</cfquery>
	
		<cfif theClient.RecordCount GT 0>
			<cfreturn theClient.ClientId>
				<cfelse>
			<cfreturn 0>	
		</cfif>
	
	</cffunction>
	
	<cffunction name="checkClientRebates" access="private" returntype="numeric">
	
		<cfset var theClient = "" />
	<!--- Discard all cached queries --->
<cfobjectcache action="Clear">
	<cfquery name="theClient" datasource="#Request.mydns#" cachedwithin="#CreateTimeSpan(0, 6, 0, 0)#">
	SELECT clientConfig.Rebates
		FROM clients
			INNER JOIN
				clientConfig
					ON (clients.ClientId = ClientConfig.ClientId)
			INNER JOIN clientDirectories ON (clients.ClientId = clientDirectories.clientID)
		WHERE clients.ClientId = <cfqueryparam cfsqltype="cf_sql_integer" value="#THIS.clientID#"> AND clients.clientActive = <cfqueryparam value="0" cfsqltype="cf_sql_tinyint" >
	</cfquery>
	
		<cfif theClient.RecordCount GT 0>
			<cfreturn theClient.Rebates>
				<cfelse>
			<cfreturn 0>	
		</cfif>
	
	</cffunction>
	
	<cffunction name="checkFreeShipping" access="private" returntype="numeric">
	
		<cfset var theClient = "" />
	
	<cfquery name="theClient" datasource="#Request.mydns#" cachedwithin="#CreateTimeSpan(0, 6, 0, 0)#">
	SELECT *
		FROM freeShipping
		WHERE clientId = <cfqueryparam cfsqltype="cf_sql_integer" value="#THIS.clientID#">  AND isActive = <cfqueryparam value="1" cfsqltype="cf_sql_tinyint">
	</cfquery>
	
		<cfif theClient.RecordCount GT 0>
			<cfreturn 1>
				<cfelse>
			<cfreturn 0>	
		</cfif>
	
	</cffunction>
	
	<cffunction name="freeShippingID" access="private" returntype="numeric">
	
		<cfset var theClient = "" />
	
	<cfquery name="theClient" datasource="#Request.mydns#" cachedwithin="#CreateTimeSpan(0, 6, 0, 0)#">
	SELECT freeId
		FROM freeShipping
		WHERE clientId = <cfqueryparam cfsqltype="cf_sql_integer" value="#THIS.clientID#"> AND isActive = <cfqueryparam value="1" cfsqltype="cf_sql_tinyint">
	</cfquery>
	
		<cfif theClient.RecordCount GT 0>
			<cfreturn theClient.freeId>
				<cfelse>
			<cfreturn 0>	
		</cfif>
	
	</cffunction>
	
	<cffunction name="checkSubReports" access="private" returntype="numeric">
	
		<cfset var theClient = "" />
	
	<cfquery name="theClient" datasource="#Request.mydns#" cachedwithin="#CreateTimeSpan(0, 6, 0, 0)#">
	SELECT clientConfig.reportSubset
		FROM clients
			INNER JOIN
				clientConfig
					ON (clients.ClientId = ClientConfig.ClientId)
			INNER JOIN clientDirectories ON (clients.ClientId = clientDirectories.clientID)
		WHERE clients.ClientId = <cfqueryparam cfsqltype="cf_sql_integer" value="#THIS.clientID#"> AND clients.clientActive = <cfqueryparam value="0" cfsqltype="cf_sql_tinyint" >
	</cfquery>
	
		<cfif theClient.RecordCount GT 0>
			<cfreturn theClient.reportSubset>
				<cfelse>
			<cfreturn 0>	
		</cfif>
	
	</cffunction>	
</cfcomponent>