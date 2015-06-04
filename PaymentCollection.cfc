<!---
	Title:		FreshBooks PaymentCollection CFC
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
<cfcomponent displayname="PaymentCollection" hint="Collection of Payment Objects" extends="BaseCollection">

	<cffunction name="Init" access="public" returntype="boolean">
		<cfargument name="InvoiceID" type="numeric" required="yes" default="#NullInt#" />
		
		<cftry>
		
			<cfset GetPaymentsByInvoiceID(Arguments.InvoiceID) />
			
			<cfreturn THIS.Count gt 0 />
		
			<cfcatch><cfreturn False /></cfcatch>
		
		</cftry>
		
	</cffunction>
	
	<cffunction name="MapObjects" access="private" returntype="void">
		<cfargument name="qryData" type="query" required="true" />
		
		<!--- Make sure this is a query and it has records. --->
		<cfif isQuery(Arguments.qryData) AND Arguments.qryData.RecordCount>
		
			<!--- Loop through it. --->
			<cfloop query="Arguments.qryData">
		
				<cfscript>
					
					Payment = CreateObject('component', 'Payment');
					
					Payment.PaymentID = GetInt(Arguments.qryData, 'freshBooksPaymentID');
					Payment.ClientID = GetInt(Arguments.qryData, 'client_id');
					Payment.FreshBooksClientID = GetInt(Arguments.qryData, 'freshBooksClientID');
					Payment.InvoiceID = GetInt(Arguments.qryData, 'invoice_id');
					Payment.FreshBooksInvoiceID = GetInt(Arguments.qryData, 'freshBooksInvoiceID');
					Payment.Date = GetDate(Arguments.qryData, 'date');
					Payment.Amount = GetInt(Arguments.qryData, 'amount');
					Payment.CurrencyCode = GetString(Arguments.qryData, 'currencyCode');
					Payment.PaymentType = GetString(Arguments.qryData, 'paymentType');
					Payment.Notes = GetString(Arguments.qryData, 'notes');
					
					Add(Payment);
					
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
		<cfset xmlNode = XmlSearch(Arguments.xmlResponse, '//*[local-name()="payment"]') />
		
		<!--- If there are nodes in the list... --->
		<cfif ArrayLen(xmlNode)>
		
			<!--- Loop through the node list. --->
			<cfloop from="1" to="#ArrayLen(xmlNode)#" index="i">
			
				<!--- Create a single node for the invoice. --->
				<cfset paymentObject = xmlNode[i] />
				
				<cfscript>
				
					Payment = CreateObject('component', 'Invoice');
					
					Payment.PaymentID = paymentObject['payment_id'].xmlText;
					Payment.FreshBooksInvoiceID = paymentObject['invoice_id'].xmlText;
					Payment.Date = paymentObject['date'].xmlText;
					Payment.PaymentType = paymentObject['type'].xmlText;
					Payment.Notes = paymentObject['notes'].xmlText;
					Payment.FreshBooksClientID = paymentObject['client_id'].xmlText;
					Payment.CurrencyCode = paymentObject['currency_code'].xmlText;
					Payment.UpdatedDate = paymentObject['updated'].xmlText;
					Payment.Amount = paymentObject['amount'].xmlText;
					
					//  Add the invoice to the collection.
					Add(Payment);
				
				</cfscript>
							
			</cfloop>
		
		</cfif>
		
	</cffunction>
	
	<!--- Stub Only --->
	<cffunction name="GetPaymentsByInvoiceID" access="public" returntype="boolean">
		<cfargument name="InvoiceID" type="numeric" required="yes" default="#NullInt#" />
		
		<cftry>
		
			<cfreturn False />
		
			<cfcatch><cfreturn False /></cfcatch>
			
		</cftry>
		
	</cffunction>
	
	<!--- Stub Only --->
	<cffunction name="GetPaymentsByClientID" access="public" returntype="boolean">
		<cfargument name="ClientID" type="numeric" required="yes" default="#NullInt#" />
		
		<cftry>
		
			<cfreturn False />
		
			<cfcatch><cfreturn False /></cfcatch>
			
		</cftry>
		
	</cffunction>

</cfcomponent>