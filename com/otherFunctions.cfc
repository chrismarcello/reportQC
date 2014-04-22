<cfcomponent output="false">

	<cffunction name="init" access="public" returntype="Any" output="false">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="garbageCollection" returntype="void" access="remote">
<cfset this.runtimeObj = CreateObject("java","java.lang.Runtime").getRuntime()> 
<cfset this.threadObj = CreateObject("java", "java.lang.Thread")> 
<cfset this.systemObj = createObject("java","java.lang.System")/> 
<cfset var appRuntime = StructNew()/> 

<cfset var freeMemory = ''/> 
<cfset var totalMemory = ''/> 
<cfset var maxMemory = ''/> 

<cfset appRuntime.freememory = Round( this.runtimeObj.freeMemory() / 1024 / 1024 )/> 
<cfset appRuntime.totalMemory = Round( this.runtimeObj.totalMemory() / 1024 / 1024 )/> 
<cfset appRuntime.maxMemory = Round( this.runtimeObj.maxMemory() / 1024 / 1024 )/> 

<cfif appRuntime.freememory LT 50 > 
<cfset this.threadObj.sleep(2000)> 
<cfset this.systemObj.gc()/> 
<!--- <cfset this.systemObj.runFinalization()/> --->
</cfif>
	</cffunction>
	
	
<cffunction name="emailZachFile" returntype="void" access="remote">
	<cfargument name="theFile" required="true" />
	<cfargument name="fileFor" required="true" />


<cfmail to="Zach Burnham <zburnham@efi.org>" replyto="cmarcello@efi.org" failto="cmarcello@efi.org" from="Chris Marcello <cmarcello@efi.org>" subject="Account File for #arguments.fileFor#" priority="2" mimeattach="#arguments.theFile#">
  Zach, 
  
  Here is a new Account File for <cfoutput>#arguments.fileFor#</cfoutput>.
  
  Thanks,
  Chris
</cfmail> 
	
</cffunction>

<cffunction name="emailTestFile" returntype="void" access="remote">
<cfargument name="theFile" required="true" />
<cfargument name="fileFor" required="true" />


<cfmail to="Zach Burnham <cmarcello@efi.org>" replyto="cmarcello@efi.org" failto="cmarcello@efi.org" from="Chris Marcello <cmarcello@efi.org>" subject="Account File for #arguments.fileFor#" priority="2" mimeattach="#arguments.theFile#">
  Zach, 
  
  Here is a new Account File for <cfoutput>#arguments.fileFor#</cfoutput>.
  
  Thanks,
  Chris
</cfmail> 
	
</cffunction>

<cffunction name="removeDuplicatesFromArrayLoop" returntype="array" access="public" output="false">
	<cfargument name="input" type="array" required="true" />
 
	<cfset var result = [] />
	<cfset var outer = 0 />
	<cfset var inner = 0 />
	<cfset var found = false />
 
	<cfloop array="#arguments.input#" index="outer">
		<cfloop array="#result#" index="inner">
			<cfif outer EQ inner>
				<cfset found = true />
			</cfif>
		</cfloop>
 
		<cfif !found>
			<cfset arrayAppend(result, outer) />
		</cfif>
 
		<cfset found = false />
	</cfloop>
 
	<cfreturn result />
</cffunction>
<cffunction name="getLoopStep" returntype="numeric" access="public" output="false">
	<cfargument name="theRecordCount" required="true">
	
	<cfif arguments.theRecordCount LT 75000>
		<cfset theStep = 8000 />
			<cfelse>
		<cfset theStep = 75000 />	
	</cfif> 
	
	
	
		<cfreturn #theStep#>
</cffunction>
<cffunction name="getStartRange" returntype="numeric" access="public" output="false">
	<cfargument name="theLastNumber" required="true">
	<cfargument name="theLastStep" required="true">
	
	<cfset var startRange = "" />
	
	<cfif #arguments.theLastNumber# LT #arguments.theLastStep#>
		<cfset startRange = 1>
			<cfelse>
		<cfset startRange = #arguments.theLastNumber# - (#arguments.theLastStep# - 1) />	
	</cfif>
	
		<cfreturn #startRange#>
</cffunction>

<cffunction name="makeZipFile" returntype="void" access="remote">

<cfargument name="sendEmail" required="false" />


<cfset chars = "0123456789abcdefghiklmnopqrstuvwxyz" / >
<cfset strLength = 6 / >
<cfset randout = "" / >

<cfloop from="1" to="#strLength#" index="i">
 <cfset rnum = ceiling(rand() * len(chars)) / >
 <cfif rnum EQ 0 ><cfset rnum = 1 / ></cfif>
 <cfset randout = randout & mid(chars, rnum, 1) / >
</cfloop> 

<!--- Zip Account File --->
<cfzip file="#request.webBasePath#\Files\newAccounts_#randout#.zip" source="#Session.fileObj#">
	
<cfif IsDefined("arguments.sendEmail") AND #arguments.sendEmail# NEQ ''>
	<cfinvoke component="otherFunctions" method="emailZachFile">
		<cfinvokeargument name="theFile" value="#request.webBasePath#\files\newAccounts_#randout#.zip">
		<cfinvokeargument name="fileFor" value="#arguments.sendEmail#">
	</cfinvoke>
</cfif>	 
	<!--- Delete load script file. --->
<cfif FileExists(#Session.fileObj#)>
        <cffile action="delete" file="#Session.fileObj#" mode="777">
</cfif>		
</cffunction>

<cffunction name="countInvoicesAdded" access="public" returntype="void" >
	
	<cfif structKeyExists( session, "hitCount" )>
		<!--- Increment. --->
			<cfset session.hitCount++ />
			
	</cfif>
		
</cffunction> 

<cffunction name="killCountSession" access="public" returntype="void" >
	
	<cfset structClear( session ) />
		
</cffunction> 

<cffunction name="getRandomLength" access="remote" returntype="numeric">

	<cfset randomNumber = RandRange(8,12) >
	<cfset NumbOfChars= #randomNumber#>
	
	<cfreturn #NumbOfChars#>

</cffunction>
<cffunction name="generateAlphaNumeric" access="remote" returntype="any">
	<cfargument name="NumbOfChars" required="yes">
	
	
	<cfset NewPass = "">

    <cfloop index="RandAlhpaNumericPass" FROM="1" TO="100">


 <cfset NewPass =
NewPass&Mid(
'ABCDEFGHIJCLMNOPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz123456789'
,RandRange('1','76'),'1') />
	

		<cfif #LEN(NewPass)# EQ #arguments.NumbOfChars#>
					<cfreturn NewPass>
			<cfbreak>
				
		</cfif>

    </cfloop>
		
		
	
</cffunction>
<cffunction name="getOsCFields" access="remote" returnType="array">
        <cfargument name="clientNumber" type="string" required="true">

        <!--- Define variables --->
        <cfset var data="">
        <cfset var result=ArrayNew(1)>
        

        <!--- Get data --->
        <cfquery name="data" datasource="reportsMaster">
        SELECT oscDataID AS id, fieldName AS name
        FROM clientOsCValues
        WHERE clientNumber = '#ARGUMENTS.clientNumber#'
        ORDER BY fieldName
        </cfquery>
    
        <!--- Convert results to array --->
        <cfloop query="data">
    <cfset zipsStruct = StructNew() />
    <cfset zipsStruct["label"] = ToString(zip) & " " & city />
    <!---Had to add leading space to prevent serializeJSON from turning zip into number--->
    <cfset zipsStruct["value"] = " " & zip />
    <cfset zipsStruct["city"] = city />
     
    <cfset ArrayAppend(returnArray,zipsStruct) />

        </cfloop>

        <!--- And return it --->
        <cfreturn result>
    </cffunction>
<cffunction name="addZipCodes" access="remote" returntype="any">
	<cfargument name="dataFile" required="true">
	<cfargument name="theStore" required="true">
	<cfargument name="theDataID" required="true">
	<cfargument name="startRow" required="true">
	<cfargument name="zipColumn" required="true"> 
	<cfargument name="cityColumn" required="true">
	
	<cfset columnHeader = "#arguments.startRow#-65536" />


		<cfset columnsToGet = "#arguments.zipColumn#,#arguments.cityColumn#" />
		

<cftry>

<cfspreadsheet action="read" src="#request.basePath#files\#arguments.dataFile#" query="queryData" excludeheaderrow="true" rows="#columnHeader#" columns="#columnsToGet#">
<cfloop query="queryData">

<cfif queryData.COL_1 NEQ ''>
	
	<cfloop query="queryData">
		<cfquery name="checkExists" datasource="reportsMaster" >
			SELECT *
			FROM clientOsCData
			WHERE custID = '#queryData.COL_1#' AND oscDataID = #arguments.theDataID#
		</cfquery>
			<cfif checkExists.RecordCount GT 0>
			
				<cfquery datasource="reportsMaster" >
				UPDATE clientOsCData
				SET fieldValue = '#queryData.COL_2#'	
				WHERE custID = '#queryData.COL_1#' AND oscDataID = #arguments.theDataID#
				</cfquery>
					<!---<cfelse>
				<cfquery datasource="reportsMaster" >
					INSERT INTO `clientOsCData`(`oscDataID`, `custID`, `fieldValue`) VALUES (#arguments.theDataID#,'#queryData.COL_1#', '#queryData.COL_2#')
				</cfquery>--->
						
			</cfif>
	</cfloop> 
	
</cfif>
</cfloop>

	<!--- Now that the file has been added, let's rename the file and zip it. --->
		<cfset thisFile = "#request.basePath#files\#arguments.dataFile#" />
		<cfset fileInfo = getFileInfo(#thisFile#) >
		<cfset fileExt = "#ListLast(fileInfo.name, ".")#">
		<cfset destdir = "#Request.basePath#files" />
		<cfset zipdestdir = "#Request.basePath#files\ZipFiles" />
		
<cfset yearcode = DateFormat(NOW(), 'YY')>
<cfset monthcode = DateFormat(NOW(), 'MM')>
<cfset daycode = #DateFormat(NOW(), 'DD')#>
<cfset hourcode = #TimeFormat(NOW(), 'hh')#>
<cfset minutecode = #TimeFormat(NOW(), 'mm')#>
<cfset seccode = TimeFormat(NOW(), 'ss')>
<cfset mycode = "#yearcode##monthcode##daycode#-#hourcode##minutecode##seccode#">
		
		<cfset newFileName = "#arguments.theStore#_#mycode#.#fileExt#" />
		<cfset newFile = destdir & "\" & #newFileName#>
	<cffile action="rename" destination="#newFile#" source="#thisFile#" >
	
	<cfset zipFileDestination = "#zipdestdir#\clientChanges.zip" />
						
		<cfzip file="#zipFileDestination#" source="#newFile#">
		<cffile action="delete" file="#newFile#" >

				<cfset theSuccessMsg = "The records have been updated" />
					<cfreturn theSuccessMsg>
	<cfcatch type="any">
			<cfset theFailMsg = "Something wicked terrible has happened." />
					<cfreturn theFailMsg>
	</cfcatch>
</cftry>	
</cffunction>
	
</cfcomponent>