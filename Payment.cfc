<!---
	Title:		FreshBooks Payment CFC
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
<cfcomponent displayname="FreshBooks Payment" hint="Payment Object" extends="Common">

	<!--- Declare properties and private variables. --->
	<cfparam name="THIS.PaymentID" default="#NullInt#" type="numeric" />
	<cfparam name="THIS.ClientID" default="#NullInt#" type="numeric" />
	<cfparam name="THIS.FreshBooksClientID" default="#NullInt#" type="numeric" />
	<cfparam name="THIS.InvoiceID" default="#NullInt#" type="numeric" />
	<cfparam name="THIS.FreshBooksInvoiceID" default="#NullInt#" type="numeric" />
	<cfparam name="THIS.Date" default="#DateFormat(Now(), 'yyyy-mm-dd')#" type="date" />
	<cfparam name="THIS.Amount" default="0" type="numeric" />
	<cfparam name="THIS.CurrencyCode" default="USD" type="string" />
	<cfparam name="THIS.PaymentType" default="Check" type="string" />
	<cfparam name="THIS.Notes" default="#NullString#" type="string" />
	<cfparam name="THIS.UpdatedDate" default="#NullDate#" type="date" />

	
	<cffunction name="Init" access="public" returntype="boolean">
		<cfreturn True />
	</cffunction>
	
	<!---
			MapData
					Maps the data from a query to the properties of this object.
	--->
	<cffunction name="MapData" access="public" returntype="void">
		<cfargument name="qryData" type="query" required="yes" />
		
		<!--- Make sure this is a query and it has records. --->
		<cfif isQuery(Arguments.qryData) AND Arguments.qryData.RecordCount>
		
			<!--- Assign the values to the properties. --->
			<cfscript>
			
				THIS.PaymentID = GetInt(Arguments.qryData, 'freshBooksPaymentID');
				THIS.ClientID = GetInt(Arguments.qryData, 'client_id');
				THIS.FreshBooksClientID = GetInt(Arguments.qryData, 'freshBooksClientID');
				THIS.InvoiceID = GetInt(Arguments.qryData, 'invoice_id');
				THIS.FreshBooksInvoiceID = GetInt(Arguments.qryData, 'freshBooksInvoiceID');
				THIS.Date = GetDate(Arguments.qryData, 'date', DateFormat(Now(), 'yyyy-mm-dd'));
				THIS.Amount = GetInt(Arguments.qryData, 'amount', 0);
				THIS.CurrencyCode = GetString(Arguments.qryData, 'currencyCode');
				THIS.PaymentType = GetString(Arguments.qryData, 'paymentType');
				THIS.Notes = GetString(Arguments.qryData, 'notes');

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

				THIS.PaymentID = Arguments.xmlResponse['response']['payment']['payment_id'].xmlText;
				THIS.FreshBooksClientID = Arguments.xmlResponse['response']['payment']['client_id'].xmlText;
				THIS.FreshBooksInvoiceID = Arguments.xmlResponse['response']['payment']['invoice_id'].xmlText;
				THIS.Date = Arguments.xmlResponse['response']['payment']['date'].xmlText;
				THIS.Amount = Arguments.xmlResponse['response']['payment']['amount'].xmlText;
				THIS.CurrencyCode = Arguments.xmlResponse['response']['payment']['currency_code'].xmlText;
				THIS.PaymentType = Arguments.xmlResponse['response']['payment']['type'].xmlText;
				THIS.Notes = Arguments.xmlResponse['response']['payment']['notes'].xmlText;
				THIS.UpdatedDate = Arguments.xmlResponse['response']['payment']['updated'].xmlText;
				
			</cfscript>
			
		</cfif>
		
	</cffunction>
	
	<cffunction name="MakePayment" access="public" returntype="boolean" output="yes">
	
		<cftry>
		
			<!--- Only do this if FreshBooks is enabled. --->
			<cfif Application.FreshBooksEnabled>
		
				<!--- Create the XML document to transmit. --->
				<cfsavecontent variable="xmlData">
					<cfoutput>
						#XMLencoding#
						<request method="payment.create">
							#SerializeXML()#
						</request>
					</cfoutput>
				</cfsavecontent>
				
				<!--- Pass the XML document to the FreshBooks API and parse the response. --->
				<cfset xmlResponse = XmlParse(Post(xmlData)) />

				<cfif StructKeyExists(xmlResponse['response'], 'payment_id')>
				
					<cfset THIS.PaymentID = xmlResponse['response']['payment_id'].xmlText />

					<cfquery datasource="#Application.DSN#" name="qryUpdatePaymentID">
						UPDATE
								invoice
						SET
								freshbooksPaymentID = #THIS.PaymentID#
						WHERE
								invoice_id = #THIS.InvoiceID#
					</cfquery>

					<cfreturn True />
					
				<cfelse>
				
					<cfreturn False />
					
				</cfif>				
			
			<cfelse>

				<cfreturn False />
			
			</cfif>
			
			<cfcatch><cfreturn False /></cfcatch>
		
		</cftry>

	</cffunction>
	
	<!--- Stub Only --->
	<cffunction name="UpdatePayment" access="public" returntype="boolean">
		
		<cftry>
		
			<cfreturn False />
		
			<cfcatch><cfreturn False /></cfcatch>
			
		</cftry>
		
	</cffunction>
	
	<!--- Stub Only --->
	<cffunction name="GetPayment" access="public" returntype="boolean">
		<cfargument name="PaymentID" type="numeric" required="yes" default="#NullInt#" />
		
		<cftry>
		
			<cfreturn False />
		
			<cfcatch><cfreturn False /></cfcatch>
			
		</cftry>
		
	</cffunction>
	
	<!--- Stub Only --->
	<cffunction name="DeletePayment" access="public" returntype="boolean">
		
		<cftry>
			
			<cfreturn False />
		
			<cfcatch><cfreturn False /></cfcatch>
		
		</cftry>
		
	</cffunction>
	
	<cffunction name="SerializeXML" access="public" returntype="string">
	
		<cfset retVal = "<payment>" />
		<cfset retVal = retVal & "<invoice_id>#THIS.FreshBooksInvoiceID#</invoice_id>" />
		<cfset retVal = retVal & "<date>#DateFormat(THIS.Date, 'yyyy-mm-yy')#</date>" />
		<cfset retVal = retVal & "<amount>#THIS.Amount#</amount>" />
		<cfset retVal = retVal & "<type>#THIS.PaymentType#</type>" />
		<cfset retVal = retVal & "<notes>#THIS.Notes#</notes>" />
		<cfset retVal = retVal & "</payment>" />
		
		<cfreturn retVal />
	
	</cffunction>
	
</cfcomponent>