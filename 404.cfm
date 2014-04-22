<cfparam name="url.thePage" default="">

<cfif not len(trim(url.thePage))>
   <cflocation url="index.cfm" addToken="false">
</cfif>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../favicon.ico" rel="shortcut icon">
<title>Invoice Updates: File Not Found</title>
<link href="css/reports.css" rel="stylesheet" type="text/css" />
</head>

<body>
<!--Begin Wrapper-->	
	<div id="wrapper" align="center">
		<!--Begin Header-->
			<div id="header">
				<!---Header Includeded Here--->
				<cfinclude template="includes/header.cfm">	
				<div class="clear"></div>
						<!--Begin Top Nav-->
						<div class="topnav">
						<!---Pages--->
							<table width="100%" align="right" border="0" cellpadding="0" cellspacing="0">
								<tr>
									<td width="70%">&nbsp;</td>
									<td align="right"><a href="index.cfm" class="nav">Home</a></td>
								</tr>
							</table>
						</div>
						<!--End Top Nav-->
			</div>


<h2>Page Not Found</h2>

<p class="maincontent">
Sorry, but the page you requested, <cfoutput>#url.thePage#</cfoutput>, was not
found on this site.
</p>
<div class="clear"></div>
								<!--Begin Footer-->
									<div id="footer">
										<cfinclude template="includes/footer.cfm">
									</div>
</div>
</body>
</html>
