<cfcomponent output="false" accessors="true">

	<!--- 
		  accountRules.cfc checks the account number and makes sure that it fits within a specific rule.
		  
		  Created: 3/25/2014
		  Created By: Chris Marcello
	--->


<cfproperty name="accountRuleID" type="numeric" required="yes" default="0">
<cfproperty name="accountNumber" type="string" required="yes" default="">
<cfproperty name="minLengthFlag" type="numeric" required="yes" default="0">
<cfproperty name="maxLengthFlag" type="numeric" required="yes" default="0">
<cfproperty name="firstMatchFlag" type="numeric" required="yes" default="0">

		
	<cffunction name="init" returntype="any" hint="initialization">
		<cfargument name="accountRuleID" required="yes">
		<cfargument name="accountNumber" required="true" >
		
	
		<cfset THIS.accountRuleID = arguments.accountRuleID />
		<cfset THIS.accountNumber = arguments.accountNumber />
		<cfset THIS.theAccountRule = getRuleQuery() />
		<cfset THIS.minLengthFlag = checkMinLength() />
		<cfset THIS.maxLengthFlag = checkMaxLength() />
		<cfset THIS.firstMatchFlag = checkFirstInt() />
		<cfset THIS.flagArray = createFlagArray() />
		<cfset THIS.accountPassFail = createPassFail() />
		
		
		
	
	</cffunction>
	<cffunction name="getRuleQuery" access="private" returntype="query">
	
		<cfset var ruleQuery = "" />
	
	<cfquery name="ruleQuery" datasource="#Request.mydns#" cachedwithin="#CreateTimeSpan(0, 6, 0, 0)#">
	SELECT `accountRuleID`, `accountMinLength`, `accountMaxLength`, `accountStartingInt` 
	FROM `client_rules_utilityaccounts` 
	WHERE accountRuleID = <cfqueryparam value="#THIS.accountRuleID#" cfsqltype="cf_sql_integer" >
	</cfquery>
	
		<cfreturn ruleQuery>
	
	</cffunction>
	
	<cffunction name="checkMinLength" access="private" returntype="boolean" >
		<cfset mastQuery = #THIS.theAccountRule# />
		
		<cfset accountLen = LEN(THIS.accountNumber) />
			<cfif accountLen LT #mastQuery.accountMinLength# AND #mastQuery.accountMinLength# GT 0>
				<cfset minFlag = 0 />
					<cfelse>
				<cfset minFlag = 1 />		
			</cfif>
		
				<cfreturn minFlag>
	</cffunction>
	
	<cffunction name="checkMaxLength" access="private" returntype="boolean" >
		<cfset mastQuery = #THIS.theAccountRule# />
		
		<cfset accountLen = LEN(THIS.accountNumber) />
			<cfif accountLen GT #mastQuery.accountMaxLength# AND #mastQuery.accountMaxLength# GT 0>
				<cfset maxFlag = 0 />
					<cfelse>
				<cfset maxFlag = 1 />		
			</cfif>
		
				<cfreturn maxFlag>
	</cffunction>
	<cffunction name="checkFirstInt" access="private" returntype="boolean" >
		<cfset mastQuery = #THIS.theAccountRule# />
		
		<cfset accountLen = LEFT(THIS.accountNumber, 1) />
		<cfif mastQuery.accountStartingInt NEQ ''>
			<cfloop list="#mastQuery.accountStartingInt#" index="ac">
				<cfif accountLen EQ #ac#>
					<cfset matchFlag = 1 />
					<cfreturn matchFlag>
							<cfbreak>
						<cfelse>
					<cfset matchFlag = 0 />	
						
				</cfif>
			</cfloop> 
					<cfreturn matchFlag>
					<cfelse>
				<cfset matchFlag = 1 />
				<cfreturn matchFlag>			
		</cfif>	
			
		
				
	</cffunction>
	<cffunction name="createFlagArray" access="private" returntype="array" >
		
		<cfset flagList = "#THIS.minLengthFlag#,#THIS.maxLengthFlag#,#THIS.firstMatchFlag#" />
		
		<cfset flagArray = #ListToArray(flagList)# />
		
		<cfreturn flagArray>
		
				
	</cffunction>
	<cffunction name="createPassFail" access="private" returntype="boolean" >
		
		<cfset makeFlag = ArrayFind(THIS.flagArray, 2) />
		
		<cfif makeFlag EQ 1>
			<cfset theFlag = 0 />
				<cfelse>
			<cfset theFlag = 1 />		
		</cfif>
		
		<cfreturn theFlag>
		
				
	</cffunction>
</cfcomponent>