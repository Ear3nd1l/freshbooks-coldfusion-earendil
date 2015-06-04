<!---
	Title:		FreshBooks InvoiceItemCollection CFC
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
<cfcomponent displayname="Invoice Item Collection" hint="Array of Invoice Items" extends="BaseCollection">

	<!--- Declare properties and private variables. --->
	<cfparam name="THIS.InvoiceID" default="#NullInt#" type="numeric" />

	<!---
			Init
					Initializes the object with a collection of line items for an invoice.
	--->
	<cffunction name="Init" access="public" returntype="boolean" hint="Initializes the object with a collection of line items for an invoice.">
		<cfargument name="InvoiceID" type="numeric" required="true" default="0" />
		
		<cftry>
		
			<!--- Set the invoice ID. --->
			<cfset THIS.InvoiceID = Arguments.InvoiceID />
			
			<!--- Get the invoice items. --->
			<cfset GetInvoiceItems(Arguments.InvoiceID) />
			
			<cfreturn True />
			
			<cfcatch><cfreturn False /></cfcatch>
		
		</cftry>
	
	</cffunction>

	<!---
			MapObjects
					Maps the data from a query to a collection of line items.
	--->
	<cffunction name="MapObjects" access="private" returntype="void" hint="Maps the data from a query to a collection of line items.">
		<cfargument name="qryData" type="query" required="true" />
		
		<!--- Make sure this is a query and it has records. --->
		<cfif isQuery(Arguments.qryData) AND Arguments.qryData.RecordCount>
		
			<!--- Loop through it. --->
			<cfloop query="Arguments.qryData">
		
				<cfscript>
				
					InvoiceItem = CreateObject('component', 'InvoiceItem');
					
					InvoiceItem.Description = GetString(Arguments.qryData, 'description');
					InvoiceItem.Name = GetString(Arguments.qryData, 'name');
					InvoiceItem.Quantity = GetInt(Arguments.qryData, 'quantity');
					InvoiceItem.Tax1Name = GetString(Arguments.qryData, 'tax1Name');
					InvoiceItem.Tax1Percent = GetInt(Arguments.qryData, 'tax1Percent');
					InvoiceItem.Tax2Name = GetString(Arguments.qryData, 'tax2Name');
					InvoiceItem.Tax2Percent = GetInt(Arguments.qryData, 'tax2Percent');
					InvoiceItem.UnitCost = GetInt(Arguments.qryData, 'unitCost');
					
					// Add the invoice item to the collection.
					Add(InvoiceItem);
				
				</cfscript>
			
			</cfloop>
		
		</cfif>
		
	</cffunction>
	
	<!---
			MapObjectsXML
					Maps the data from an XML document to a collection of line items.
	--->
	<cffunction name="MapObjectsXML" access="public" returntype="void" hint="Maps the data from an XML document to a collection of line items.">
		<cfargument name="xmlResponse" type="xml" required="true" />
		
		<!--- Make sure this is an XML document. --->
		<cfif isXMLDoc(Arguments.xmlResponse)>
		
			<!--- Parse it into an object. --->
			<cfset Arguments.xmlResponse = XmlParse(Arguments.xmlResponse) />
			
			<!--- Get a node list of line items. --->
			<cfset xmlNode = XmlSearch(Arguments.xmlResponse, '//*[local-name()="line"]') />
			
			<!--- If there are nodes in the list... --->
			<cfif ArrayLen(xmlNode)>
			
				<!--- Loop through the node list. --->
				<cfloop from="1" to="#ArrayLen(xmlNode)#" index="i">
				
					<!--- Create a single node for the line item. --->
					<cfset lineItem = xmlNode[i] />
					
					<cfscript>
					
						InvoiceItem = CreateObject('component', 'InvoiceItem');
						
						InvoiceItem.Description = lineItem['description'].xmlText;
						InvoiceItem.Name = lineItem['name'].xmlText;
						InvoiceItem.Quantity = lineItem['quantity'].xmlText;
						InvoiceItem.Tax1Name = lineItem['tax1_name'].xmlText;
						InvoiceItem.Tax1Percent = lineItem['tax1_percent'].xmlText;
						InvoiceItem.Tax2Name = lineItem['tax2_name'].xmlText;
						InvoiceItem.Tax2Percent = lineItem['tax2_percent'].xmlText;
						InvoiceItem.UnitCost = lineItem['unit_cost'].xmlText;
						
						// Add the line item to the collection.
						Add(InvoiceItem);
					
					</cfscript>
								
				</cfloop>
			
			</cfif>
			
		</cfif>
		
	</cffunction>

	<!---
			GetInvoiceItems
					Gets line items for an invoice.
	--->
	<cffunction name="GetInvoiceItems" access="public" returntype="boolean" hint="Gets line items for an invoice.">
		<cfargument name="InvoiceID" type="numeric" required="true" default="#NullInt#" />
		
		<cftry>
		
			<!--- Only do this if FreshBooks is enabled. --->
			<cfif Application.FreshBooksEnabled>
		
				<!--- Get a list of line items from the database. --->
				<cfstoredproc datasource="#Application.DSN#" procedure="FB_GetInvoiceItems">
					<cfprocparam dbvarname="@InvoiceID" value="#THIS.InvoiceID#" cfsqltype="cf_sql_integer" />
					<cfprocresult name="qryGetInvoiceItems" />
				</cfstoredproc>
				
				<!--- If nothing was found, throw an error. --->
				<cfif qryGetInvoiceItems.RecordCount eq 0>
					<cfthrow message="No records found." />
				</cfif>
				
				<!--- Map the data to the collection. --->
				<cfset MapData(qryGetInvoiceItems) />
				
				<cfreturn True />
			
			<cfelse>
			
				<cfreturn False />
				
			</cfif>
			
			<cfcatch><cfreturn False /></cfcatch>
			
		</cftry>
			
		
	</cffunction>
	
	<!---
			SerializeXML
					Serializes the InvoiceItem collection into an XML document for transmission to FreshBooks.
	--->
	<cffunction name="SerializeXML" access="public" returntype="string" hint="Serializes the InvoiceItem collection into an XML document for transmission to FreshBooks.">
	
		<!--- Create the line items element. --->
		<cfset retVal = "<lines>" />
	
		<!--- Loop through the collection and serialize each item. --->
		<cfloop from="1" to="#THIS.Count#" index="i">
		
			<cfset InvoiceItem = THIS.GetAt(i) />
			
			<cfset retVal = retVal & InvoiceItem.SerializeXML() />
		
		</cfloop>
		
		<cfset retVal = retVal & "</lines>" />
		
		<cfreturn retVal />
	
	</cffunction>

</cfcomponent>