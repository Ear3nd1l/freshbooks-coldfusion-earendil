<!---
	Title:		FreshBooks InvoiceCollection CFC
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
<cfcomponent displayname="Invoice Collection" hint="Collection of Invoice Objects" extends="BaseCollection">

	<!--- Declare properties and private variables. --->
	<cfparam name="THIS.ClientID" default="#NullInt#" type="numeric" />
	<cfparam name="THIS.StartDate" default="#NullString#" type="string" />
	<cfparam name="THIS.EndDate" default="#NullString#" type="string" />
	<cfparam name="THIS.ClientInfo" default="#CreateObject('component', 'Client')#" type="any" />
	
	<!---
			Init
					Initializes the object with a collection of invoices retrieved from the database.
	--->
	<cffunction name="Init" access="public" returntype="boolean" hint="Initializes the object with a collection of invoices retrieved from the database.">
		<cfargument name="ClientID" type="numeric" required="true" default="#NullInt#" />
		
		<cftry>
				
			<!--- Set the client ID. --->
			<cfset THIS.ClientID = Arguments.ClientID />
			
			<!--- Create the Client object. --->
			<cfset THIS.ClientInfo.Init(THIS.ClientID) />
			
			<!--- Get the invoices. --->
			<cfset GetInvoices() />
			
			<cfreturn True />
			
			<cfcatch><cfreturn False /></cfcatch>
		
		</cftry>
		
	</cffunction>
	
	<!---
			InitWithFreshBooksData
					Initializes the object with a collection of invoices retrieved from FreshBooks.
	--->
	<cffunction name="InitWithFreshBooksData" access="public" returntype="void" hint="Initializes the object with a collection of invoices retrieved from FreshBooks">
		<cfargument name="ClientID" type="numeric" required="true" default="#NullInt#" />
		
		<!--- Set the clientID. --->
		<cfset THIS.ClientID = Arguments.ClientID />
		
		<!--- Create the Client object. --->
		<cfset THIS.ClientInfo.Init(THIS.ClientID) />
		
		<!--- Get the invoices. --->
		<cfset GetInvoicesFromFreshBooks() />

	</cffunction>

	<!---
			MapObjects
					Maps the data from a query to a collection of invoices.
	--->
	<cffunction name="MapObjects" access="private" returntype="void" hint="Maps the data from a query to a collection of invoices.">
		<cfargument name="qryData" type="query" required="true" />
		
		<!--- Make sure this is a query and it has records. --->
		<cfif isQuery(Arguments.qryData) AND Arguments.qryData.RecordCount>
		
			<!--- Loop through it. --->
			<cfloop query="Arguments.qryData">
		
				<cfscript>
				
					Invoice = CreateObject('component', 'Invoice');
					
					Invoice.Amount = GetInt(Arguments.qryData, 'amount');
					Invoice.ClientID = GetInt(Arguments.qryData, 'clientID');
					Invoice.CurrencyCode = GetString(Arguments.qryData, 'currencyCode');
					Invoice.Date = GetDate(Arguments.qryData, 'date');
					Invoice.Discount = GetInt(Arguments.qryData, 'discount');
					Invoice.FreshBooksClientID = GetInt(Arguments.qryData, 'freshBooksClientID');
					Invoice.FreshBooksInvoiceID = GetInt(Arguments.qryData, 'freshBooksInvoiceID');
					Invoice.InvoiceID = GetInt(Arguments.qryData, 'invoiceID');
					Invoice.Language = GetString(Arguments.qryData, 'language');
					Invoice.Notes = GetString(Arguments.qryData, 'notes');
					Invoice.Organization = GetString(Arguments.qryData, 'organization');
					Invoice.PurchaseOrderNumber = GetString(Arguments.qryData, 'purchaseOrderNumber');
					Invoice.InvoiceStatusID = GetInt(Arguments.qryData, 'invoiceStatusID');	
					Invoice.InvoiceStatus = ListGetAt(VARIABLES.InvoiceStatus, Invoice.InvoiceStatusID, ',');			
					Invoice.Terms = GetString(Arguments.qryData, 'terms');
					
					// Add the invoice to the collection.
					Add(Invoice);
				
				</cfscript>
			
			</cfloop>
		
		</cfif>
		
	</cffunction>
	
	<!---
			MapObjectsXML
					Maps the data from an XML document to a collection of invoices.
	--->
	<cffunction name="MapObjectsXML" access="public" returntype="void" hint="Maps the data from an XML document to a collection of invoices.">
		<cfargument name="xmlResponse" type="xml" required="true" />
		
		<!--- Parse the document, just in case it isn't already. --->
		<cfset Arguments.xmlResponse = XmlParse(Arguments.xmlResponse) />
		
		<!--- Get a node list of invoices. --->
		<cfset xmlNode = XmlSearch(Arguments.xmlResponse, '//*[local-name()="invoice"]') />
		
		<!--- If there are nodes in the list... --->
		<cfif ArrayLen(xmlNode)>
		
			<!--- Loop through the node list. --->
			<cfloop from="1" to="#ArrayLen(xmlNode)#" index="i">
			
				<!--- Create a single node for the invoice. --->
				<cfset invoiceObject = xmlNode[i] />
				
				<cfscript>
				
					Invoice = CreateObject('component', 'Invoice');
					
					Invoice.Amount = invoiceObject['amount'].xmlText;
					Invoice.FreshBooksClientID = invoiceObject['client_id'].xmlText;
					Invoice.CurrencyCode = invoiceObject['currency_code'].xmlText;
					Invoice.Date = invoiceObject['date'].xmlText;
					Invoice.Discount = invoiceObject['discount'].xmlText;
					Invoice.FreshBooksInvoiceID = invoiceObject['invoice_id'].xmlText;
					Invoice.Language = invoiceObject['language'].xmlText;
					Invoice.Notes = invoiceObject['notes'].xmlText;
					Invoice.Organization = invoiceObject['organization'].xmlText;
					Invoice.PurchaseOrderNumber = invoiceObject['po_number'].xmlText;
					Invoice.InvoiceStatus = invoiceObject['status'].xmlText;
					Invoice.InvoiceStatusID = ListFind(VARIABLES.InvoiceStatus, Invoice.InvoiceStatus);
					Invoice.Terms = invoiceObject['terms'].xmlText;
					
					//  Add the invoice to the collection.
					Add(Invoice);
				
				</cfscript>
							
			</cfloop>
		
		</cfif>
		
	</cffunction>
	
	<!---
			GetInvoicesFromFreshBooks
					Gets all invoices for a client from FreshBooks.
	--->
	<cffunction name="GetInvoicesFromFreshBooks" access="public" returntype="void" hint="Gets all invoices for a client from FreshBooks.">

		<cftry>
		
			<!--- Only do this if FreshBooks is enabled. --->
			<cfif Application.FreshBooksEnabled>

				<!--- Create the XML document to transmit. --->
				<cfsavecontent variable="xmlData">
					<cfoutput>
						#XMLencoding#
						<request method="invoice.list">
							<client_id>#THIS.ClientID#</client_id>
							<cfif IsDate(THIS.StartDate) AND THIS.StartDate gt NullDate>
								<date_from>#DateFormat(THIS.StartDate, 'yyyy-mm-dd')#</date_from>
								<date_to>#DateFormat(THIS.EndDate, 'yyyy-mm-dd')#</date_to>
							</cfif>
						</request>
					</cfoutput>
				</cfsavecontent>

				<!--- Post the XML and map the response to the collection. --->
				<cfset MapObjectsXML(Post(xmlData)) />
				
				<cfreturn True />
			
			<cfelse>
			
				<cfreturn False />
			
			</cfif>
			
			<cfcatch><cfreturn False /></cfcatch>
			
		</cftry>

	</cffunction>

	<!---
			GetInvoices
					Gets all invoices for a client.
	--->
	<cffunction name="GetInvoices" access="public" returntype="boolean" hint="Gets all invoices for a client.">
		
		<cftry>
		
			<!--- Only do this if FreshBooks is enabled. --->
			<cfif Application.FreshBooksEnabled>

				<!--- Get the client's invoices from the database. --->
				<cfstoredproc datasource="#Application.DSN#" procedure="FB_GetClientInvoices">
					<cfprocparam dbvarname="@ClientID" value="#THIS.ClientID#" cfsqltype="cf_sql_integer" />
					<cfprocresult name="qryGetInvoicesByClientID" />
				</cfstoredproc>
				
				<!--- If nothing was found, throw an error. --->
				<cfif qryGetInvoicesByClientID.RecordCount eq 0>
					<cfthrow message="No records found." />
				</cfif>
				
				<!--- Map the data to the collection. --->
				<cfset MapObjects(qryGetInvoicesByClientID) />
		
				<cfreturn True />
			
			<cfelse>
			
				<cfreturn False />
			
			</cfif>
			
			<cfcatch><cfreturn False /></cfcatch>
			
		</cftry>

	</cffunction>

	<!---
			GetPaidInvoices
					Gets a client's paid invoices.
	--->
	<cffunction name="GetPaidInvoices" access="public" returntype="boolean" hint="Gets a client's paid invoices.">
		
		<cftry>
		
			<!--- Only do this if FreshBooks is enabled. --->
			<cfif Application.FreshBooksEnabled>

				<!--- Get the client's paid invoices from the database. --->
				<cfstoredproc datasource="#Application.DSN#" procedure="FB_GetClientPaidInvoices">
					<cfprocparam dbvarname="@ClientID" value="#THIS.ClientID#" cfsqltype="cf_sql_integer" />
					<cfprocresult name="qryGetPaidInvoicesByClientID" />
				</cfstoredproc>
				
				<!--- If nothing was found, throw an error. --->
				<cfif qryGetPaidInvoicesByClientID.RecordCount eq 0>
					<cfthrow message="No records found." />
				</cfif>
				
				<!--- Map the data to the collection. --->
				<cfset MapObjects(qryGetPaidInvoicesByClientID) />
		
				<cfreturn True />
			
			<cfelse>
			
				<cfreturn False />
			
			</cfif>
			
			<cfcatch><cfreturn False /></cfcatch>
			
		</cftry>

	</cffunction>

	<!---
			GetUnpaidInvoices
					Gets a client's unpaid invoices.
	--->
	<cffunction name="GetUnpaidInvoices" access="public" returntype="boolean" hint="Gets a client's unpaid invoices.">
		
		<cftry>
		
			<!--- Only do this if FreshBooks is enabled. --->
			<cfif Application.FreshBooksEnabled>

				<!--- Get the client's unpaid invoices from the database. --->
				<cfstoredproc datasource="#Application.DSN#" procedure="FB_GetClientUnpaidInvoices">
					<cfprocparam dbvarname="@ClientID" value="#THIS.ClientID#" cfsqltype="cf_sql_integer" />
					<cfprocresult name="qryGetUnpaidInvoicesByClientID" />
				</cfstoredproc>
				
				<!--- If nothing was found, throw an error. --->
				<cfif qryGetUnpaidInvoicesByClientID.RecordCount eq 0>
					<cfthrow message="No records found." />
				</cfif>
				
				<!--- Map the data to the collection. --->
				<cfset MapObjects(qryGetUnpaidInvoicesByClientID) />
		
				<cfreturn True />
			
			<cfelse>
			
				<cfreturn False />
			
			</cfif>
			
			<cfcatch><cfreturn False /></cfcatch>
			
		</cftry>

	</cffunction>


	<!---
			SerializeXML
					Serializes the Invoice Collection into an XML document for transmission to FreshBooks.
					The current version of the FreshBooks API has no method that accepts a collection of invoices.
					However, this method was created in the event that this functionality is added at a later date. 
	--->
	<cffunction name="SerializeXML" access="public" returntype="string" hint="Serializes the Invoice Collection into an XML document for transmission to FreshBooks.">
	
		<!--- Create the invoices element. --->
		<cfset retVal = "<invoices>" />
	
		<!--- Loop through the collection and serialize each invoice. --->
		<cfloop from="1" to="#THIS.Count#" index="i">
		
			<cfset Invoice = THIS.GetAt(i) />
			
			<cfset retVal = retVal & Invoice.SerializeXML() />
		
		</cfloop>
		
		<cfset retVal = retVal & "</invoices>" />
		
		<cfreturn retVal />
	
	</cffunction>

</cfcomponent>