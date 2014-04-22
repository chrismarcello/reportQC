<cfcomponent output="false">

<cfset variables.udfdir = GetDirectoryFromPath(GetCurrentTemplatePath())&"udfs">
<cfset variables.q = "">

<cffunction name="init" access="public" returntype="Any" output="false">
<cfreturn this>
</cffunction>

<cfdirectory action="list" directory="#variables.udfdir#" filter="*.cfm" name="variables.q">

<cfoutput query="variables.q">
<cfinclude template="udfs/#name#">
</cfoutput>

</cfcomponent>