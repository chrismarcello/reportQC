<!---
 Capitalizes the first letter in each word.
 Made udf use strlen, rkc 3/12/02
 v2 by Sean Corfield.
 
 @param string 	 String to be modified. (Required)
 @return Returns a string. 
 @author Raymond Camden (ray@camdenfamily.com) 
 @version 2, March 9, 2007 
--->
<cffunction name="CapFirst" returntype="string" output="false">
	<cfargument name="str" type="string" required="true" />
	
	<cfset var newstr = "" />
	<cfset var word = "" />
	<cfset var separator = "" />
	
	<cfloop index="word" list="#arguments.str#" delimiters=" ">
		<cfset newstr = newstr & separator & UCase(left(word,1)) />
		<cfif len(word) gt 1>
			<cfset newstr = newstr & right(word,len(word)-1) />
		</cfif>
		<cfset separator = " " />
	</cfloop>

	<cfreturn newstr />
</cffunction>

<cfscript>
/**
 * Strips unnecessary characters from phone numbers and returns a consistent looking phone number and extension, if necessary.
 * 
 * @param phoneNum 	 Phone number string to "clean." (Required)
 * @return Returns a string. 
 * @author Jeff Horne (&#106;&#101;&#102;&#102;&#46;&#104;&#111;&#114;&#110;&#101;&#64;&#116;&#114;&#105;&#122;&#101;&#116;&#116;&#111;&#46;&#99;&#111;&#109;) 
 * @version 0, June 24, 2011 
 */
function cleanPhone(PhoneNum) {
	var thisCleanPhone ="";

	PhoneNum = ReReplace(trim(PhoneNum), "[^[:digit:]]", "", "all");
	
	// Trim away leading 1 in phone numbers.  No area codes start with 1 
	
	if (Left(Trim(PhoneNum),1) eq 1) {
      PhoneNum = Replace(PhoneNum,'1','');
	}

	thisCleanPhone = Request.myUtils.PhoneFormat(Left(PhoneNum,10));
	
	// if phone number is greater that 10 digits, use remaining digits as an extension
	
	if (len(trim(PhoneNum)) gt 10) {
		thisCleanPhone = thisCleanPhone &" x"& Right(PhoneNum,(len(trim(PhoneNum))-10));	
	}
	
	return trim(thisCleanPhone);

}
</cfscript>

<!---
 Converts an entire string to namecase (JARED RYPKA-HAUER becomes Jared Rypka-Hauer).
 
 @param string 	 String to format. (Required)
 @return Returns a string. 
 @author Jared Rypka-Hauer (&#106;&#97;&#114;&#101;&#100;&#64;&#119;&#101;&#98;&#45;&#114;&#101;&#108;&#101;&#118;&#97;&#110;&#116;&#46;&#99;&#111;&#109;) 
 @version 2, January 1, 2006 
--->
<cffunction name="nameCase" access="public" returntype="string" output="false">
    <cfargument name="name" type="string" required="true" />
    <cfset arguments.name = ucase(arguments.name)>
    <cfreturn reReplace(arguments.name,"([[:upper:]])([[:upper:]]*)","\1\L\2\E","all") />
</cffunction>

<cfscript>
/**
 * Allows you to specify the mask you want added to your phone number.
 * v2 - code optimized by Ray Camden
 * v3.01 
 * v3.02 added code for single digit phone numbers from John Whish   
 * v4 make a default format - by James Moberg
 * 
 * @param varInput 	 Phone number to be formatted. (Required)
 * @param varMask 	 Mask to use for formatting. x represents a digit. Defaults to (xxx) xxx-xxxx (Optional)
 * @return Returns a string. 
 * @author Derrick Rapley (&#97;&#100;&#114;&#97;&#112;&#108;&#101;&#121;&#64;&#114;&#97;&#112;&#108;&#101;&#121;&#122;&#111;&#110;&#101;&#46;&#99;&#111;&#109;) 
 * @version 4, February 11, 2011 
 */
function phoneFormat(varInput) {
       var curPosition = "";
       var i = "";
       var varMask = "xxx-xxx-xxxx";
       var newFormat = "";
       var startpattern = "";
   if (arrayLen(arguments) gte 2){ varMask = arguments[2]; }
       newFormat = trim(ReReplace(varInput, "[^[:digit:]]", "", "all"));
       startpattern = ReReplace(ListFirst(varMask, "- "), "[^x]", "", "all");
       if (Len(newFormat) gte Len(startpattern)) {
               varInput = trim(varInput);
               newFormat = " " & reReplace(varInput,"[^[:digit:]]","","all");
               newFormat = reverse(newFormat);
               varmask = reverse(varmask);
               for (i=1; i lte len(trim(varmask)); i=i+1) {
                       curPosition = mid(varMask,i,1);
                       if(curPosition neq "x") newFormat = insert(curPosition,newFormat, i-1) & " ";
               }
               newFormat = reverse(newFormat);
               varmask = reverse(varmask);
       }
       return trim(newFormat);
}
</cfscript>

<cfscript>
/**
 * Takes a full State name (i.e. California) and returns the two letter abbreviation (i.e. CA).
 * 
 * @param state 	 The state to convert. 
 * @return Returns a string. 
 * @author Sivan Leoni (&#115;&#108;&#101;&#111;&#110;&#105;&#64;&#108;&#101;&#111;&#110;&#105;&#122;&#46;&#99;&#111;&#109;) 
 * @version 1, January 7, 2002 
 */
function StateToAbbr(State) {
  var states = "ALABAMA,ALASKA,AMERICAN
SAMOA,ARIZONA,ARKANSAS,CALIFORNIA,COLORADO,CONNECTICUT,DELAWARE,DISTRICT OF COLUMBIA,FEDERATED STATES OF MICRONESIA,FLORIDA,GEORGIA,GUAM,HAWAII,IDAHO,ILLINOIS,INDIANA,IOWA,KANSAS,KENTUCKY,LOUISIANA,MAINE,MARSHALL ISLANDS,MARYLAND,MASSACHUSETTS,MICHIGAN,MINNESOTA,MISSISSIPPI,MISSOURI,M
ONTANA,NEBRASKA,NEVADA,NEW HAMPSHIRE,NEW JERSEY,NEW MEXICO,NEW YORK,NORTH CAROLINA,NORTH DAKOTA,NORTHERN MARIANA
ISLANDS,OHIO,OKLAHOMA,OREGON,PALAU,PENNSYLVANIA,PUERTO RICO,RHODE ISLAND,SOUTH CAROLINA,SOUTH DAKOTA,TENNESSEE,TEXAS,UTAH,VERMONT,VIRGIN ISLANDS,VIRGINIA,WASHINGTON,WEST VIRGINIA,WISCONSIN,WYOMING";
  var abbr =
"AL,AK,AS,AZ,AR,CA,CO,CT,DE,DC,FM,FL,GA,GU,HI,ID,IL,IN,IA,KS,KY,LA,ME,MH,MD,MA,MI,MN,MS,MO,MT,NE,NV,NH,NJ,NM,NY,NC,ND,MP,OH,OK,OR,PW,PA,PR,RI,SC,SD,TN,TX,UT,VT,VI,VA,WA,WV,WI,WY";
  if(listFindNoCase(states,State))
	State=listGetAt(abbr,listFindNoCase(states,state));
  return State;
}
</cfscript>