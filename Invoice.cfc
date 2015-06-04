<!---
	Title:		FreshBooks Invoice CFC
	Author:		Chris Hampton
	Version:	1.0
	History:	1.0 Initial Release (January 2011)
	Copyright:	2011 Christian M Hampton http://christianhampton.com
	License:
	
	This file is part of ColdFusion FreshBooks Library.
	
	ColdFusion FreshBooks Library is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.
	
	ColdFusion FreshBooks Library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with ColdFusion FreshBooks Library; if not, write to the Free Software
	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

--->
<cfcomponent displayname="FreshBooks Invoice" hint="Invoice Object" extends="Common">

	<!--- Declare properties and private variables. --->
	<cfparam name="THIS.Amount" default="0" type="numeric" /> <!--- Read-Only from FreshBooks. --->
	<cfparam name="THIS.AmountOutstanding" default="0" type="numeric" /> <!--- Read-Only from FreshBooks. --->
	<cfparam name="THIS.ClientID" default="#NullInt#" type="numeric" />
	<cfparam name="THIS.ClientView" default="" type="string" /> <!--- Read-Only from FreshBooks. --->
	<cfparam name="THIS.CurrencyCode" default="USD" type="string" />
	<cfparam name="THIS.Date" default="#DateFormat(Now(), 'yyyy-mm-dd')#" type="date" />
	<cfparam name="THIS.Discount" default="0" type="numeric" />
	<cfparam name="THIS.EditURL" default="#NullString#" type="string" /> <!--- Read-Only from FreshBooks. --->
	<cfparam name="THIS.FreshBooksClientID" default="#NullInt#" type="numeric" />
	<cfparam name="THIS.FreshBooksInvoiceID" default="#NullInt#" type="numeric" />
	<cfparam name="THIS.InvoiceItems" default="#CreateObject('component', 'InvoiceItemCollection')#" type="any" />
	<cfparam name="THIS.InvoiceID" default="#NullInt#" type="numeric" />
	<cfparam name="THIS.Language" default="en" type="string" />
	<cfparam name="THIS.Notes" default="#NullString#" type="string" />
	<cfparam name="THIS.Number" default="#NullString#" type="string" /> <!--- InvoiceID --->
	<cfparam name="THIS.Organization" default="#NullString#" type="string" />
	<cfparam name="THIS.PurchaseOrderNumber" default="" type="string" />
	<cfparam name="THIS.InvoiceStatusID" default="4" type="numeric" /> <!--- Default to Draft status --->
	<cfparam name="THIS.InvoiceStatus" default="#ListGetAt(VARIABLES.InvoiceStatus, THIS.InvoiceStatusID, ',')#" type="string" />
	<cfparam name="THIS.Terms" default="#NullString#" type="string" />
	<cfparam name="THIS.UpdatedDate" default="#NullString#" type="string" /> <!--- Read-Only from FreshBooks. --->
	<cfparam name="THIS.ViewURL" default="#NullString#" type="string" /> <!--- Read-Only from FreshBooks. --->
	
	<!---
			Init
					Initializes an object by its invoice ID.
	--->
	<cffunction name="Init" access="public" returntype="boolean" hint="Initializes an object by its invoice ID">
		<cfargument name="InvoiceID" type="numeric" required="true" default="#NullInt#" />
		
		<cftry>
		
			<!--- Set the invoice ID. --->
			<cfset THIS.InvoiceID = Arguments.InvoiceID />
			
			<!--- Get the invoice's data and map it. --->
			<cfset GetInvoiceByID(Arguments.InvoiceID) />
			
			<!--- Get the line items. --->
			<cfset THIS.InvoiceItems.Init(Arguments.InvoiceID) />
			
			<cfreturn True />
			
			<cfcatch><cfreturn False /></cfcatch>
		
		</cftry>
	
	</cffunction>
	
	<!---
			MapData
					Maps the data from a query to the properties of this object.
	--->
	<cffunction name="MapData" access="private" returntype="void" hint="Maps the data from a query to the properties of this object">
		<cfargument name="qryData" type="query" required="true" />
		
		<!--- Make sure this is a query and it has records. --->
		<cfif isQuery(Arguments.qryData) AND Arguments.qryData.RecordCount>
		
			<!--- Assign the values to the properties. --->
			<cfscript>
			
				THIS.Amount = GetInt(Arguments.qryData, 'amount', 0);
				THIS.ClientID = GetInt(Arguments.qryData, 'clientID');
				THIS.CurrencyCode = GetString(Arguments.qryData, 'currencyCode');
				THIS.Date = GetDate(Arguments.qryData, 'date', DateFormat(Now(), 'yyyy-mm-dd'));
				THIS.Discount = GetInt(Arguments.qryData, 'discount', 0);
				THIS.FreshBooksClientID = GetInt(Arguments.qryData, 'freshBooksClientID');
				THIS.FreshBooksInvoiceID = GetInt(Arguments.qryData, 'freshBooksInvoiceID');
				THIS.InvoiceID = GetInt(Arguments.qryData, 'invoiceID');
				THIS.Language = GetString(Arguments.qryData, 'language');
				THIS.Notes = GetString(Arguments.qryData, 'notes');
				THIS.Organization = GetString(Arguments.qryData, 'organization');
				THIS.PurchaseOrderNumber = GetString(Arguments.qryData, 'purchaseOrderNumber');
				THIS.InvoiceStatusID = GetInt(Arguments.qryData, 'invoiceStatusID', 4);
				try
				{	
					THIS.InvoiceStatus = ListGetAt(VARIABLES.InvoiceStatus, THIS.InvoiceStatusID, ',');
				}
				catch(Any ex)
				{
				}			
				THIS.Terms = GetString(Arguments.qryData, 'terms');
			
			</cfscript>
		
		</cfif>
	
	</cffunction>
	
	<!---
			MapDataXML
					Maps the data from an XML document to the properties of this object.
	--->
	<cffunction name="MapDataXML" access="private" returntype="void" hint="Maps the data from an XML document to the properties of this object">
		<cfargument name="xmlResponse" type="xml" required="true" />

		<!--- Make sure this is an XML document. --->
		<cfif isXMLDoc(Arguments.xmlResponse)>
		
			<!--- Parse it into an object. --->
			<cfset Arguments.xmlResponse = XmlParse(Arguments.xmlResponse) />
		
			<!--- Assign the values to the properties. --->
			<cfscript>

				THIS.Amount = Arguments.xmlResponse['response']['invoice']['amount'].xmlText;
				THIS.FreshBooksClientID = Arguments.xmlResponse['response']['invoice']['client_id'].xmlText;
				THIS.CurrencyCode = Arguments.xmlResponse['response']['invoice']['currency_code'].xmlText;
				THIS.Date = Arguments.xmlResponse['response']['invoice']['date'].xmlText;
				THIS.Discount = Arguments.xmlResponse['response']['invoice']['discount'].xmlText;
				THIS.FreshBooksInvoiceID = Arguments.xmlResponse['response']['invoice']['invoice_id'].xmlText;
				THIS.Language = Arguments.xmlResponse['response']['invoice']['language'].xmlText;
				THIS.Notes = Arguments.xmlResponse['response']['invoice']['notes'].xmlText;
				THIS.Organization = Arguments.xmlResponse['response']['invoice']['organization'].xmlText;
				THIS.PurchaseOrderNumber = Arguments.xmlResponse['response']['invoice']['po_number'].xmlText;
				THIS.InvoiceStatus = Arguments.xmlResponse['response']['invoice']['status'].xmlText;
				THIS.InvoiceStatusID = ListFind(VARIABLES.InvoiceStatus, THIS.InvoiceStatus);
				THIS.Terms = Arguments.xmlResponse['response']['invoice']['terms'].xmlText;
				
			</cfscript>
			
		</cfif>
		
	</cffunction>
	
	<!---
			GetInvoiceByID
					Gets a recordset of data by invoice ID.
	--->
	<cffunction name="GetInvoiceByID" access="public" returntype="boolean" hint="Gets a recordset of data by invoice ID">
		<cfargument name="InvoiceID" type="numeric" required="true" default="#NullInt#" />
		
		<cftry>
		
			<!--- Get the invoice's data from the database. --->
			<cfstoredproc datasource="#Application.DSN#" procedure="FB_GetInvoiceByID">
				<cfprocparam dbvarname="@InvoiceID" value="#Arguments.InvoiceID#" cfsqltype="cf_sql_integer" />
				<cfprocresult name="qryGetInvoiceByID" />
			</cfstoredproc>
			
			<!--- If nothing was found, throw an error. --->
			<cfif qryGetInvoiceByID.RecordCount eq 0>
				<cfthrow message="No Records Found" />
			</cfif>
			
			<!--- Map the data to the object. --->
			<cfset MapData(qryGetInvoiceByID) />
			
			<cfreturn True />
			
			<cfcatch><cfreturn False /></cfcatch>
		
		</cftry>
			
	</cffunction>
	
	<!---
			CreateInvoice
					Adds an invoice to FreshBooks.
	--->
	<cffunction name="CreateInvoice" access="public" returntype="boolean" hint="Adds an invoice to FreshBooks">
	
		<cftry>
		
			<!--- Only do this if FreshBooks is enabled. --->
			<cfif Application.FreshBooksEnabled>
		
				<!--- Create the XML document to transmit. --->
				<cfsavecontent variable="xmlData">
					<cfoutput>
						#XMLencoding#
						<request method="invoice.create">
							#SerializeXML()#
						</request>
					</cfoutput>
				</cfsavecontent>
				
				<!--- Pass the XML document to the FreshBooks API and parse the response. --->
				<cfset xmlResponse = XmlParse(Post(xmlData)) />
				
				<!--- Set the FreshBooksInvoiceID property to the value received from the API. --->
				<cfset THIS.FreshBooksInvoiceID = xmlResponse['response']['invoice_id'].xmlText />
				
				<!--- Update the invoice's record with the FreshBooksInvoiceID value. --->
				<cfstoredproc datasource="#Application.DSN#" procedure="FB_AddFreshBooksInvoiceID">
					<cfprocparam dbvarname="@InvoiceID" value="#THIS.InvoiceID#" cfsqltype="cf_sql_integer" />
					<cfprocparam dbvarname="@FreshBooksInvoiceID" value="#THIS.FreshBooksInvoiceID#" cfsqltype="cf_sql_integer" />
					<cfprocresult name="qryAddFreshBooksInvoiceID" />
				</cfstoredproc>
	
				<cfreturn True />
			
			<cfelse>
			
				<cfreturn False />
			
			</cfif>
			
			<cfcatch><cfreturn False /></cfcatch>
		
		</cftry>
		
	
	</cffunction>
	
	<!---
			UpdateInvoice
					Updates an invoice in FreshBooks.
	--->
	<cffunction name="UpdateInvoice" access="public" returntype="boolean" hint="Updates an invoice in FreshBooks">
	
		<cftry>
		
			<!--- Only do this if FreshBooks is enabled. --->
			<cfif Application.FreshBooksEnabled>

				<!--- Make sure the invoice is already in FreshBooks. --->
				<cfif THIS.FreshBooksInvoiceID gt NullInt>
		
					<!--- Create the XML document to transmit. --->
					<cfsavecontent variable="xmlData">
						<cfoutput>
							#XMLencoding#
							<request method="invoice.update">
								#SerializeXML(IncludeFreshBooksInvoiceID=True)#
							</request>
						</cfoutput>
					</cfsavecontent>
					
					<!--- Pass the XML document to the FreshBooks API and parse the response. --->
					<cfset xmlResponse = XmlParse(Post(xmlData)) />
		
					<!--- If the invoice was not updated, return False. --->
					<cfif IsDefined("xmlResponse['response']['error']")>
						<cfreturn False />
					<cfelse>
						<cfreturn True />
					</cfif>
					
				<cfelse>
				
					<cfset CreateInvoice() />
				
				</cfif>

			<cfelse>
			
				<cfreturn False />
				
			</cfif>

			<cfcatch><cfreturn False /></cfcatch>
		
		</cftry>
		
	
	</cffunction>

	<!---
			GetInvoice
					Gets an Invoice fron FreshBooks.
	--->
	<cffunction name="GetInvoice" access="public" returntype="boolean" hint="Gets an Invoice fron FreshBooks.">
	
		<cftry>
		
			<!--- Only do this if FreshBooks is enabled. --->
			<cfif Application.FreshBooksEnabled>
		
				<!--- Create the XML document to transmit. --->
				<cfsavecontent variable="xmlData">
					<cfoutput>
						#XMLencoding#
						<request method="invoice.get">
						  <invoice_id>#THIS.InvoiceID#</invoice_id>
						</request>
					</cfoutput>
				</cfsavecontent>
				
				<!--- Pass the XML document to the FreshBooks API and parse the response. --->
				<cfset xmlResponse = xmlParse(Post(xmlData)) />
			
				<!--- Map the data to the object's properties. --->
				<cfset MapDataXML(xmlResponse) />
				
				<!--- Map the line items. --->
				<cfset THIS.InvoiceItems.MapObjectsXML(xmlResponse) />
				
				<cfreturn True />
			
			<cfelse>
			
				<cfreturn False />
				
			</cfif>
			
			<cfcatch><cfreturn False /></cfcatch>
		
		</cftry>
		
	
	</cffunction>
	
	<!---
			DeleteInvoice
					Deletes an Invoice from FreshBooks. Currently does nothing.
	--->
	<cffunction name="DeleteInvoice" access="public" returntype="boolean" hint="Deletes an Invoice from FreshBooks. Currently does nothing.">
	
		<cftry>
		
			<cfreturn False />
			
			<cfcatch><cfreturn False /></cfcatch>
		
		</cftry>
		
	
	</cffunction>
	
	<!---
			Refresh
					Refreshes the status enum of an invoice.
	--->
	<cffunction name="Refresh" access="public" returntype="void" hint="Refreshes the status enum of an invoice">
		
		<cfset THIS.InvoiceStatus = ListGetAt(VARIABLES.InvoiceStatus, THIS.InvoiceStatusID, ',') />
		
	</cffunction>
	
	<!---
			SerialzeXML
					Serializes the object for transmission to FreshBooks.
	--->
	<cffunction name="SerializeXML" access="public" returntype="String" hint="Serializes the object for transmission to FreshBooks">
		<cfargument name="IncludeFreshBooksInvoiceID" type="boolean" required="false" default="False" /> 
	
		<!--- Create the client object. --->
		<cfobject component="Client" name="ClientObject" />
		<cfset ClientObject.Init(THIS.ClientID) />
		
		<!--- Get the line items. --->
		<cfobject component="InvoiceItemCollection" name="InvoiceItems" />
		<cfset InvoiceItems.Init(THIS.InvoiceID) />
	
		<cfset retVal = "<invoice>" />
		<cfif Arguments.IncludeFreshBooksInvoiceID>
			<cfset retVal = retVal & "<invoice_id>#THIS.FreshBooksInvoiceID#</invoice_id>" />
		</cfif>
		<cfset retVal = retVal & "<client_id>#THIS.FreshBooksClientID#</client_id>" />
		<cfset retVal = retVal & "<number>#THIS.InvoiceID#</number>" />
		<cfset retVal = retVal & "<status>#ListGetAt(VARIABLES.InvoiceStatus, THIS.InvoiceStatusID, ',')#</status>" />
		<cfset retVal = retVal & "<date>#DateFormat(THIS.Date, 'yyyy-mm-dd')#</date>" />
		<cfset retVal = retVal & "<po_number>#THIS.PurchaseOrderNumber#</po_number>" />
		<cfset retVal = retVal & "<discount>#THIS.Discount#</discount>" />
		<cfset retVal = retVal & "<notes>#THIS.Notes#</notes>" />
		<cfset retVal = retVal & "<currency_code>#THIS.CurrencyCode#</currency_code>" />
		<cfset retVal = retVal & "<language>#THIS.Language#</language>" />
		<cfset retVal = retVal & "<terms>#THIS.Terms#</terms>" />
		<cfset retVal = retVal & ClientObject.SerializeXMLForInvoice() />
		<cfset retVal = retVal & InvoiceItems.SerializeXML() />	
		<cfset retVal = retVal & "</invoice>" />
		
		<cfreturn retVal />
	
	</cffunction>
	
	<!---
			Clear
					Clears the property values of this object.
	--->
	<cffunction name="Clear" access="public" returntype="void" hint="Clears the property values of this object">
	
		<cfscript>
		
			THIS.Amount = NullInt;
			THIS.ClientID = NullInt;
			THIS.CurrencyCode = NullString;
			THIS.Date = NullDate;
			THIS.Discount = 0;
			THIS.FreshBooksClientID = NullInt;
			THIS.FreshBooksInvoiceID = NullInt;
			THIS.InvoiceID = NullInt;
			THIS.Language = NullString;
			THIS.Notes = NullString;
			THIS.Organization = NullString;
			THIS.PurchaseOrderNumber = NullString;
			THIS.InvoiceStatusID = 1;
			THIS.InvoiceStatus = ListGetAt(VARIABLES.InvoiceStatus, THIS.InvoiceStatusID, ',');
			THIS.Terms = NullString;
		
		</cfscript>

	</cffunction>

</cfcomponent>