<!---
	Title:		FreshBooks InvoiceItem CFC
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
<cfcomponent displayname="Invoice Item" hint="Invoice Item Object" extends="Common">

	<!--- Declare properties and private variables. --->
	<cfparam name="THIS.Description" default="#NullString#" type="string" />
	<cfparam name="THIS.Name" default="#NullString#" type="string" />
	<cfparam name="THIS.Quantity" default="0" type="numeric" />
	<cfparam name="THIS.Tax1Name" default="#NullString#" type="string" />
	<cfparam name="THIS.Tax1Percent" default="0" type="numeric" />
	<cfparam name="THIS.Tax2Name" default="#NullString#" type="string" />
	<cfparam name="THIS.Tax2Percent" default="0" type="numeric" />
	<cfparam name="THIS.UnitCost" default="0" type="string" />

	<!---
			Init
					Constructor for the object.
	--->
	<cffunction name="Init" access="public" returntype="void" hint="Constructor for the object.">
	</cffunction>
	
	<!---
			MapData
					Maps the data from a query to the properties of this object.
	--->
	<cffunction name="MapData" access="private" returntype="void" hint="Maps the data from a query to the properties of this object.">
		<cfargument name="qryData" type="query" required="true" />
		
		<!--- Make sure this is a query and it has records. --->
		<cfif isQuery(Arguments.qryData) AND Arguments.qryData.RecordCount>
		
			<cfscript>
			
				THIS.Description = GetString(Arguments.qryData, 'description');
				THIS.Name = GetString(Arguments.qryData, 'name');
				THIS.Quantity = GetInt(Arguments.qryData, 'quantity', 0);
				THIS.Tax1Name = GetString(Arguments.qryData, 'tax1Name');
				THIS.Tax1Percent = GetInt(Arguments.qryData, 'tax1Percent', 0);
				THIS.Tax2Name = GetString(Arguments.qryData, 'tax2Name');
				THIS.Tax2Percent = GetInt(Arguments.qryData, 'tax2Percent', 0);
				THIS.UnitCost = GetInt(Arguments.qryData, 'unitCost', 0);
			
			</cfscript>
		
		</cfif>
	
	</cffunction>
	
	<!---
			MapDataXML
					Maps the data from an XML document to the properties of this object. Currently does nothing.
	--->
	<cffunction name="MapDataXML" access="private" returntype="void" hint="Maps the data from an XML document to the properties of this object. Currently does nothing.">
		<cfargument name="xmlData" type="xml" required="true" />
		
		<cfif isXMLDoc(Arguments.xmlData)>
		
			<cfscript>
			
			</cfscript>
		
		</cfif>
		
	</cffunction>
	
	<!---
			SerializeXML
					Serializes the object for transmission to FreshBooks.
	--->
	<cffunction name="SerializeXML" access="public" returntype="String" hint="Serializes the object for transmission to FreshBooks.">
		
		<cfset retVal = "<line>" />
		<cfset retVal = retVal & "<name>#THIS.Name#</name>" />
		<cfset retVal = retVal & "<description><![CDATA[#THIS.Description#]]></description>" />
		<cfset retVal = retVal & "<unit_cost>#THIS.UnitCost#</unit_cost>" />
		<cfset retVal = retVal & "<quantity>#THIS.Quantity#</quantity>" />
		<!--- Only include tax info if it has been specified in the invoice. --->
		<cfif Len(Trim(THIS.Tax1Name)) gt 0>
			<cfset retVal = retVal & "<tax1_name>#THIS.Tax1Name#</tax1_name>" />
			<cfset retVal = retVal & "<tax1_percent>#THIS.Tax1Percent#</tax1_percent>" />
		</cfif>
		<cfif Len(Trim(THIS.Tax2Name)) gt 0>
			<cfset retVal = retVal & "<tax2_name>#THIS.Tax2Name#</tax2_name>" />
			<cfset retVal = retVal & "<tax2_percent>#THIS.Tax2Percent#</tax2_percent>" />
		</cfif>
		<cfset retVal = retVal & "<type>Item</type>" />
		<cfset retVal = retVal & "</line>" />
		
		<cfreturn retVal />
		
	</cffunction>

</cfcomponent>