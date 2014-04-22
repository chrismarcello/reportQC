<cfcomponent
	displayname="Application"
	output="true"
	hint="Handle the application.">
 
 
	<!--- Set up the application. --->
	<cfset THIS.Name = "reportQC" />
	<cfset THIS.ApplicationTimeout = CreateTimeSpan( 1, 0, 0, 0 )>
   <cfset THIS.sessiontimeout = createtimespan(0,2,0,0)>
   <cfset THIS.SessionManagement = true>
   <cfset THIS.SetClientCookies = true>
   <cfset THIS.SetDomainCookies = false>
   <cfset THIS.ClientManagement = false>
   <cfset THIS.loginStorage = "session">
   <cfset THIS.ScriptProtect = "all">
 
 
	<!--- Define the page request properties. --->
	
 
 
	<cffunction
		name="OnApplicationStart"
		access="public"
		returntype="boolean"
		output="false"
		hint="Fires when the application is first created.">
 
 

 <cfset Application.myUtils = CreateObject("component", "com.udfs").init()>
 
		<!--- Return out. --->
		<cfreturn true />
	</cffunction>
 <!--- Fired when user requests a CFM that doesn't exist. --->
<cffunction name="onMissingTemplate" returnType="boolean" output="false">
   <cfargument name="thePage" type="string" required="true">
   <cflog file="missingtemplatelog" text="#arguments.thePage#">
   <cflocation url="404.cfm?thepage=#urlEncodedFormat(arguments.thePage)#" addToken="false">
</cffunction>
 
	<cffunction
		name="OnSessionStart"
		access="public"
		returntype="void"
		output="false"
		hint="Fires when the session is first created.">


		<!---
			Set up a hit count variable so that we can see
			how many page requests are recorded in this user's
			session.
			--->
				<cfset session.hitCount = 0 />


		<!--- Return out. --->
		<cfreturn />
	</cffunction>
 
 
	<cffunction name="OnRequestStart" access="public"
		hint="Fires when prior to page processing.">
 
		<!--- Define arguments. --->
<cfargument name = "thisRequest" type="string"
			required="true"
			hint="I am the template requested by the user."
			/>
			
		<cfset Request.mydns = "reportsMaster">
		<cfset Request.mydns2 = "efi">
		
		<cfset Request.oscFunctions = CreateObject("component", "com.oscFunctions")>
		<cfset Request.correct = CreateObject("component", "com.corrections")>
		<cfset Request.other = CreateObject("component", "com.otherFunctions")>
		<cfset Request.myUtils = CreateObject("component", "com.udfs").init()>
		
		<cfset Request.CurrentPage=GetFileFromPath(GetTemplatePath())>
	<!--- Define the local scope. --->
		<cfset local = {} />
 
		<!--- Define request settings. --->
		<cfsetting showdebugoutput="false" />
 
		<!---
			Set the value of the web root. Since we know that this
			template (Application.cfc) is in the web root for this
			application, all we have to do is figure out the
			difference between this template and the requested
			template. Every directory difference will require our
			webroot to have a "../" in it.
		--->
 
		<!---
			Get the current (Application.cfc) directory path based
			on the current template path.
		--->
		<cfset local.basePath = getDirectoryFromPath(
			getCurrentTemplatePath()
			) />
			
		<cfset webBasePath = Replace(local.basePath, "\", "/", "ALL") />
			
		<cfset request.basePath = #local.basePath# />
		<cfset request.webBasePath = #webBasePath# />	
 
		<!---
			Get the target (script_name) directory path based on
			expanded script name.
		--->
		<cfset local.targetPath = getDirectoryFromPath(
			expandPath( arguments.thisRequest )
			) />
 
		<!---
			Now that we have both paths, all we have to do is
			find the difference in path. We can treat the paths
			as slash-delimmited lists. To do this, let's calculate
			the depth of sub directories.
		--->
		<cfset local.requestDepth = (
			listLen( local.targetPath, "\/" ) -
			listLen( local.basePath, "\/" )
			) />
 <cfset request.requestDepth = #local.requestDepth# />
		<!---
			With the request depth, we can easily create our
			web root by repeating "../" the appropriate number
			of times.
		--->
		<cfset request.webRoot = repeatString(
			"../",
			local.requestDepth
			) />
 
		<!---
			While we wouldn't normally do this for every page
			request (it would normally be cached in the
			application initialization), I'm going to calculate
			the site URL based on the web root.
		--->
		<cfset request.siteUrl = (
			"http://" &
			cgi.server_name &
			reReplace(
				getDirectoryFromPath( arguments.thisRequest ),
				"([^\\/]+[\\/]){#local.requestDepth#}$",
				"",
				"one"
				)
			) />		
			
 
		<!--- Return out. --->
		<cfreturn true />
	</cffunction>
 
 
	
 
 
	<cffunction
		name="OnRequestEnd"
		access="public"
		returntype="void"
		output="true"
		hint="Fires after the page processing is complete.">
 
		<!--- Return out. --->
		<cfreturn />
	</cffunction>
 
 
	<cffunction
		name="OnSessionEnd"
		access="public"
		returntype="void"
		output="false"
		hint="Fires when the session is terminated.">
 
		<cfargument name = "SessionScope" required=true/>
    <cflog file="#This.Name#" type="Information" text="Session:
            #arguments.SessionScope.sessionid# ended">

 
		<!--- Return out. --->
		<cfreturn />
	</cffunction>
 
 
	<cffunction
		name="OnApplicationEnd"
		access="public"
		returntype="void"
		output="false"
		hint="Fires when the application is terminated.">
 
		<!--- Define arguments. --->
		<cfargument
			name="ApplicationScope"
			type="struct"
			required="false"
			default="#StructNew()#"
			/>
 
		<!--- Return out. --->
		<cfreturn />
	</cffunction>
 
 
	<!--- Runs on error --->
	<cffunction name="onError" returnType="void" output="true">
   <cfargument name="exception" required="true">
   <cfargument name="eventname" type="string" required="true">
   <cfset var errortext = "">

   <cflog file="myapperrorlog" text="#arguments.exception.message#">
   
   <cfsavecontent variable="errortext">
   <cfoutput>
   An error occurred: http://#cgi.server_name##cgi.script_name#?#cgi.query_string#<br />
   Time: #dateFormat(now(), "short")# #timeFormat(now(), "short")#<br />
   
   <cfdump var="#arguments.exception#" label="Error">
   <cfdump var="#form#" label="Form">
   <cfdump var="#url#" label="URL">
   
   </cfoutput>
   </cfsavecontent>
<cfset CurrentTemplatePath=GetCurrenttemplatePath()>  
<cfset CurrentDirectory=GetDirectoryFromPath(CurrentTemplatePath)> 
<cfset yearcode = DateFormat(NOW(), 'YY')>
<cfset monthcode = DateFormat(NOW(), 'MM')>
<cfset daycode = #DateFormat(NOW(), 'DD')#>
<cfset hourcode = #TimeFormat(NOW(), 'hh')#>
<cfset minutecode = #TimeFormat(NOW(), 'mm')#>
<cfset seccode = TimeFormat(NOW(), 'ss')>
<cfset mycode = "#yearcode##monthcode##daycode##hourcode##minutecode##seccode#">
		<cffile
		   action = "append"
		   file = "#CurrentDirectory#errorlogs\error_#mycode#.html"
		   output = "#errortext#"
		>
 
		<!--- <cflocation url="#request.webRoot#error.cfm"> --->
	</cffunction>
 
</cfcomponent>