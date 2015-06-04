<!---
	Title:		FreshBooks Client CFC
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
<cfcomponent displayname="FreshBooks Client" hint="Client Object" extends="Common">

	<!--- Declare properties and private variables. --->
	<cfparam name="THIS.ClientID" default="#NullInt#" type="numeric" />
	<cfparam name="THIS.ClientViewLink" default="#NullString#" type="string" />
	<cfparam name="THIS.CurrencyCode" default="USD" type="string" />
	<cfparam name="THIS.Email" default="#NullString#" type="string" />
	<cfparam name="THIS.Fax" default="#NullString#" type="string" />
	<cfparam name="THIS.FirstName" default="#NullString#" type="string" />
	<cfparam name="THIS.FreshBooksClientID" default="#NullInt#" type="numeric" />
	<cfparam name="THIS.HomePhone" default="#NullString#" type="string" />
	<cfparam name="THIS.IsProphecyClient" default="False" type="boolean" />
	<cfparam name="THIS.Language" default="en" type="string" />
	<cfparam name="THIS.LastName" default="#NullString#" type="string" />
	<cfparam name="THIS.Mobile" default="#NullString#" type="string" />
	<cfparam name="THIS.Notes" default="#NullString#" type="string" />
	<cfparam name="THIS.OnInvoice" default="False" type="boolean" />
	<cfparam name="THIS.Organization" default="#NullString#" type="string" />
	<cfparam name="THIS.Password" default="#NullString#" type="string" />
	<cfparam name="THIS.PrimaryCity" default="#NullString#" type="string" />
	<cfparam name="THIS.PrimaryPostalCode" default="#NullString#" type="string" />
	<cfparam name="THIS.PrimaryCountry" default="#NullString#" type="string" />
	<cfparam name="THIS.PrimaryState" default="#NullString#" type="string" />
	<cfparam name="THIS.PrimaryStreet1" default="#NullString#" type="string" />
	<cfparam name="THIS.PrimaryStreet2" default="#NullString#" type="string" />
	<cfparam name="THIS.SecondaryCity" default="#NullString#" type="string" />
	<cfparam name="THIS.SecondaryPostalCode" default="#NullString#" type="string" />
	<cfparam name="THIS.SecondaryCountry" default="#NullString#" type="string" />
	<cfparam name="THIS.SecondaryState" default="#NullString#" type="string" />
	<cfparam name="THIS.SecondaryStreet1" default="#NullString#" type="string" />
	<cfparam name="THIS.SecondaryStreet2" default="#NullString#" type="string" />
	<cfparam name="THIS.UserName" default="#NullString#" type="string" />
	<cfparam name="THIS.ViewLink" default="#NullString#" type="string" />
	<cfparam name="THIS.WorkPhone" default="#NullString#" type="string" />

	<!---
			Init
					Initializes the object by its client ID.
	--->
	<cffunction name="Init" access="public" returntype="boolean" hint="Initializes the object by its client ID.">
		<cfargument name="ClientID" type="numeric" required="true" default="#NullInt#" />
		
		<cftry>
		
			<!--- Get a recordset of data and map it. --->
			<cfset GetClientByID(Arguments.ClientID) />
			
			<cfreturn True />
			
			<cfcatch><cfreturn False /></cfcatch>
		
		</cftry>
		
	</cffunction>
	
	<!---
			InitByFreshBooksClientID
					Initializes the object by its FreshBooks client ID.
	--->
	<cffunction name="InitByFreshBooksClientID" access="public" returntype="void" hint="Initializes the object by its FreshBooks client ID.">
		<cfargument name="FreshBooksClientID" type="numeric" required="true" />
		
		<!--- Set the FreshBooksClientID Property to the supplied value. --->
		<cfset THIS.FreshBooksClientID = Arguments.FreshBooksClientID />
		
		<!--- Get the data from FreshBooks and map it. --->
		<cfset GetClient() />
		
	</cffunction>
	
	<!---
			MapData
					Maps the data from a query to the properties of this object.
	--->
	<cffunction name="MapData" access="private" returntype="void" hint="Maps the data from a query to the properties of this object.">
		<cfargument name="qryData" type="query" required="true" />
		<cfargument name="MergeData" type="boolean" required="false" default="false" />
		
		<!--- Make sure this is a query and it has records. --->
		<cfif isQuery(Arguments.qryData) AND Arguments.qryData.RecordCount>
		
			<!--- Pass the values to the merge method so they can be assigned to the properties. --->
			<cfscript>
			
				THIS.ClientID = GetInt(Arguments.qryData, 'client_id');
				THIS.FreshBooksClientID = GetInt(Arguments.qryData, 'freshBooksClientID');
				THIS.OnInvoice = GetBool(Arguments.qryData, 'on_invoice');
				THIS.IsProphecyClient = GetBool(Arguments.qryData, 'Is_Prophecy_Client');
				Merge('FirstName', GetString(Arguments.qryData, 'first_name'), Arguments.MergeData);
				Merge('LastName', GetString(Arguments.qryData, 'last_name'), Arguments.MergeData);
				Merge('Organization', GetString(Arguments.qryData, 'organization'), Arguments.MergeData);
				Merge('PrimaryStreet1', GetString(Arguments.qryData, 'address1'), Arguments.MergeData);
				Merge('PrimaryStreet2', GetString(Arguments.qryData, 'address2'), Arguments.MergeData);
				Merge('PrimaryCity', GetString(Arguments.qryData, 'city'), Arguments.MergeData);
				Merge('PrimaryState', GetString(Arguments.qryData, 'state'), Arguments.MergeData);
				Merge('PrimaryPostalCode', GetString(Arguments.qryData, 'postal_code'), Arguments.MergeData);
				Merge('PrimaryCountry', GetString(Arguments.qryData, 'country'), Arguments.MergeData);
				Merge('WorkPhone', GetString(Arguments.qryData, 'workPhone'), Arguments.MergeData);
				Merge('Email', GetString(Arguments.qryData, 'email'), Arguments.MergeData);
				Merge('HomePhone', GetString(Arguments.qryData, 'homePhone'), Arguments.MergeData);
				Merge('Mobile', GetString(Arguments.qryData, 'mobile'), Arguments.MergeData);
				Merge('Fax', GetString(Arguments.qryData, 'fax'), Arguments.MergeData);
				Merge('Language', GetString(Arguments.qryData, 'language'), Arguments.MergeData);
				Merge('CurrencyCode', GetString(Arguments.qryData, 'currencyCode'), Arguments.MergeData);
				Merge('Notes', GetString(Arguments.qryData, 'notes'), Arguments.MergeData);
				Merge('UserName', GetString(Arguments.qryData, 'userName'), Arguments.MergeData);
				
			</cfscript>
		
		</cfif>
	
	</cffunction>
	
	<!---
			MapDataXML
					Maps the data from an XML document to the properties of this object.
	--->
	<cffunction name="MapDataXML" access="private" returntype="void" hint="Maps the data from an XML document to the properties of this object.">
		<cfargument name="xmlResponse" type="xml" required="true" />
		<cfargument name="MergeData" type="boolean" required="false" default="false" />
		
		<!--- Make sure this is an XML document. --->
		<cfif isXMLDoc(Arguments.xmlResponse)>
		
			<!--- Parse it into an object. --->
			<cfset Arguments.xmlResponse = XmlParse(Arguments.xmlResponse) />
		
			<!--- Pass the values to the merge method so they can be assigned to the properties. --->
			<cfscript>
			
				THIS.FreshBooksClientID = Arguments.xmlResponse['response']['client']['client_id'].xmlText;
				Merge('FirstName', Arguments.xmlResponse['response']['client']['first_name'].xmlText, Arguments.MergeData);
				Merge('LastName', Arguments.xmlResponse['response']['client']['last_name'].xmlText, Arguments.MergeData);
				Merge('Organization', Arguments.xmlResponse['response']['client']['organization'].xmlText, Arguments.MergeData);
				Merge('Email', Arguments.xmlResponse['response']['client']['email'].xmlText, Arguments.MergeData);
				Merge('UserName', Arguments.xmlResponse['response']['client']['username'].xmlText, Arguments.MergeData);
				Merge('WorkPhone', Arguments.xmlResponse['response']['client']['work_phone'].xmlText, Arguments.MergeData);
				THIS.HomePhone = Arguments.xmlResponse['response']['client']['home_phone'].xmlText;
				THIS.Mobile = Arguments.xmlResponse['response']['client']['mobile'].xmlText;
				THIS.Fax = Arguments.xmlResponse['response']['client']['fax'].xmlText;
				THIS.Language = Arguments.xmlResponse['response']['client']['language'].xmlText;
				THIS.CurrencyCode = Arguments.xmlResponse['response']['client']['currency_code'].xmlText;
				THIS.Notes = Arguments.xmlResponse['response']['client']['notes'].xmlText;
				Merge('PrimaryStreet1', Arguments.xmlResponse['response']['client']['p_street1'].xmlText, Arguments.MergeData);
				Merge('PrimaryStreet2', Arguments.xmlResponse['response']['client']['p_street2'].xmlText, Arguments.MergeData);
				Merge('PrimaryCity', Arguments.xmlResponse['response']['client']['p_city'].xmlText, Arguments.MergeData);
				Merge('PrimaryState', Arguments.xmlResponse['response']['client']['p_state'].xmlText, Arguments.MergeData);
				Merge('PrimaryCountry', Arguments.xmlResponse['response']['client']['p_country'].xmlText, Arguments.MergeData);
				Merge('PrimaryPostalCode', Arguments.xmlResponse['response']['client']['p_code'].xmlText, Arguments.MergeData);
				Merge('SecondaryStreet1', Arguments.xmlResponse['response']['client']['s_street1'].xmlText, Arguments.MergeData);
				Merge('SecondaryStreet2', Arguments.xmlResponse['response']['client']['s_street2'].xmlText, Arguments.MergeData);
				Merge('SecondaryCity', Arguments.xmlResponse['response']['client']['s_city'].xmlText, Arguments.MergeData);
				Merge('SecondaryState', Arguments.xmlResponse['response']['client']['s_state'].xmlText, Arguments.MergeData);
				Merge('SecondaryCountry', Arguments.xmlResponse['response']['client']['s_country'].xmlText, Arguments.MergeData);
				Merge('SecondaryPostalCode', Arguments.xmlResponse['response']['client']['s_code'].xmlText, Arguments.MergeData);
				THIS.ClientViewLink = Arguments.xmlResponse['response']['client']['links']['client_view'].xmlText;
				THIS.ViewLink = Arguments.xmlResponse['response']['client']['links']['view'].xmlText;

			</cfscript>
		
		</cfif>
		
	</cffunction>

	<!---
			GetClientByID
					Gets a recordset of data by client ID.
	--->
	<cffunction name="GetClientByID" access="public" returntype="void" hint="Gets a recordset of data by client ID.">
		<cfargument name="ClientID" type="numeric" required="true" default="#NullInt#" />
		
		<!--- Get the client's data from the database. --->
		<cfstoredproc datasource="#Application.DSN#" procedure="FB_GetClientByID">
			<cfprocparam dbvarname="@ClientID" value="#Arguments.ClientID#" cfsqltype="cf_sql_integer" />
			<cfprocresult name="qryGetClientByID" />
		</cfstoredproc>
		
		<!--- If nothing was found, throw an error. --->
		<cfif qryGetClientByID.RecordCount eq 0>
			<cfthrow message="No records found." />
		</cfif>
		
		<!--- Map the data to the object. --->
		<cfset MapData(qryGetClientByID) />
		
	</cffunction>
	
	<!---
			CreateClient
					Adds a client to FreshBooks.
	--->
	<cffunction name="CreateClient" access="public" returntype="boolean" hint="Adds a client to FreshBooks.">
	
		<cftry>
		
			<!--- Only do this if FreshBooks is enabled. --->
			<cfif Application.FreshBooksEnabled>
			
				<!--- Create the XML document to transmit. --->
				<cfsavecontent variable="xmlData">
					<cfoutput>
						#XMLencoding#
						<request method="client.create">
							#SerializeXML()#
						</request>
					</cfoutput>
				</cfsavecontent>
				
				<!--- Pass the XML document to the FreshBooks API and parse the response. --->
				<cfset xmlResponse = XmlParse(Post(xmlData)) />
	
				<!--- Set the FreshBooksClientID property to the value received from the API. --->
				<cfset THIS.FreshBooksClientID = xmlResponse['response']['client_id'].xmlText />
				
				<!--- Update the client's record with the FreshBooksClientID value. --->
				<cfstoredproc datasource="#Application.DSN#" procedure="FB_AddFreshBooksClientID">
					<cfprocparam dbvarname="@ClientID" value="#THIS.ClientID#" cfsqltype="cf_sql_integer" />
					<cfprocparam dbvarname="@FreshBooksClientID" value="#THIS.FreshBooksClientID#" cfsqltype="cf_sql_integer" />
					<cfprocresult name="qryUpdateClientID" />
				</cfstoredproc>
			
				<cfreturn True />
			
			<cfelse>
			
				<cfreturn False />
				
			</cfif>
			
			<cfcatch><cfreturn False /></cfcatch>
		
		</cftry>
		
	
	</cffunction>
	
	<!---
			UpdateClient
					Updates a client in FreshBooks.
	--->
	<cffunction name="UpdateClient" access="public" returntype="boolean" hint="Updates a client in FreshBooks.">
	
		<cftry>
		
			<!--- Only do this if FreshBooks is enabled. --->
			<cfif Application.FreshBooksEnabled>
			
				<!--- Make sure the client is already in FreshBooks. --->
				<cfif THIS.FreshBooksClientID gt NullInt>
		
					<!--- Get serialized data for this object. --->	
					<cfset xmlData = SerializeXML() />

					<!--- Create the XML document to transmit. --->
					<cfsavecontent variable="xmlDoc">
						<cfoutput>
							#XMLencoding#
							<request method="client.update">
								#xmlData#
							</request>
						</cfoutput>
					</cfsavecontent>

					<!--- Pass the XML document to the FreshBooks API. --->
					<cfset Post(xmlData) />					
				
				<!--- If not, create them. --->
				<cfelse>
				
					<cfset CreateClient() />
				
				</cfif>
			
				<cfreturn True />
			
			<cfelse>
			
				<cfreturn False />
			
			</cfif>
			
			<cfcatch><cfreturn False /></cfcatch>
		
		</cftry>
		
	</cffunction>

	<!---
			GetClient
					Gets a client from FreshBooks.
	--->
	<cffunction name="GetClient" access="public" returntype="boolean" hint="Gets a client from FreshBooks.">
	
		<cftry>
		
			<!--- Only do this if FreshBooks is enabled. --->
			<cfif Application.FreshBooksEnabled>
		
				<!--- Create the XML document to transmit. --->
				<cfsavecontent variable="xmlData">
					<cfoutput>
						#XMLencoding#
						<request method="client.get">
						  <client_id>#THIS.FreshBooksClientID#</client_id>
						</request>
					</cfoutput>
				</cfsavecontent>
				
				<!--- Pass the XML document to the FreshBooks API and map the response. --->
				<cfset MapDataXML(XmlParse(Post(xmlData))) />
				
				<cfreturn True />
			
			<cfelse>
			
				<cfreturn False />
				
			</cfif>
			
			<cfcatch><cfreturn False /></cfcatch>
		
		</cftry>
	
	</cffunction>
	
	<!---
			DeleteClient
					Deletes a client from FreshBooks. Currently does nothing.
	--->
	<cffunction name="DeleteClient" access="public" returntype="boolean" hint="Deletes a client from FreshBooks. Currently does nothing.">
	
		<cftry>
		
			<cfreturn True />
			
			<cfcatch><cfreturn False /></cfcatch>
		
		</cftry>
		
	
	</cffunction>
	
	<!---
			UpdateObjectWithLocalData
					Gets the client's data from the database and updates FreshBooks in one method.
	--->
	<cffunction name="UpdateObjectWithLocalData" access="public" returntype="boolean" hint="Gets the client's data from the database and updates FreshBooks in one method.">
		
		<cftry>
		
			<cfscript> 
				
				// Get the client's info.
				GetClientByID(THIS.ClientID);
				
				// Update the client.
				UpdateClient();
				
			</cfscript>
			
			<cfreturn True />
			
			<cfcatch><cfreturn False /></cfcatch>
		
		</cftry>
		
	</cffunction>
	
	<!---
			SerializeXML
					Serializes the object for transmission to FreshBooks.
	--->
	<cffunction name="SerializeXML" access="public" returntype="String" hint="Serializes the object for transmission to FreshBooks.">
	
		<cfset retVal = "<client>" />
		<cfif THIS.FreshBooksClientID gt 0>
			<cfset retVal = retVal & "<client_id>#THIS.FreshBooksClientID#</client_id>" />
		</cfif>
		<cfset retVal = retVal & "<first_name>#THIS.FirstName#</first_name>" />
		<cfset retVal = retVal & "<last_name>#THIS.LastName#</last_name>" />
		<cfset retVal = retVal & "<organization><![CDATA[#THIS.Organization#]]></organization>" />
		<cfset retVal = retVal & "<email>#THIS.Email#</email>" />
		<cfset retVal = retVal & "<username>#THIS.UserName#</username>" />
		<cfset retVal = retVal & "<password>#THIS.Password#</password>" />
		<cfset retVal = retVal & "<work_phone>#THIS.WorkPhone#</work_phone>" />
		<cfset retVal = retVal & "<home_phone>#THIS.HomePhone#</home_phone>" />
		<cfset retVal = retVal & "<mobile>#THIS.Mobile#</mobile>" />
		<cfset retVal = retVal & "<fax>#THIS.Fax#</fax>" />
		<cfset retVal = retVal & "<language>#THIS.Language#</language>" />
		<cfset retVal = retVal & "<currency_code>#THIS.CurrencyCode#</currency_code>" />
		<cfset retVal = retVal & "<notes>#THIS.Notes#</notes>" />
		<cfset retVal = retVal & "<p_street1>#THIS.PrimaryStreet1#</p_street1>" />
		<cfset retVal = retVal & "<p_street2>#THIS.PrimaryStreet2#</p_street2>" />
		<cfset retVal = retVal & "<p_city>#THIS.PrimaryCity#</p_city>" />
		<cfset retVal = retVal & "<p_state>#THIS.PrimaryState#</p_state>" />
		<cfset retVal = retVal & "<p_country>#THIS.PrimaryCountry#</p_country>" />
		<cfset retVal = retVal & "<p_code>#THIS.PrimaryPostalCode#</p_code>" />
		<cfset retVal = retVal & "<s_street1>#THIS.SecondaryStreet1#</s_street1>" />
		<cfset retVal = retVal & "<s_street2>#THIS.SecondaryStreet2#</s_street2>" />
		<cfset retVal = retVal & "<s_city>#THIS.SecondaryCity#</s_city>" />
		<cfset retVal = retVal & "<s_state>#THIS.SecondaryState#</s_state>" />
		<cfset retVal = retVal & "<s_country>#THIS.SecondaryCountry#</s_country>" />
		<cfset retVal = retVal & "<s_code>#THIS.SecondaryPostalCode#</s_code>" />
		<cfset retVal = retVal & "</client>" />
		
		<cfreturn retVal />
	
	</cffunction>

	<!---
			SerializeXMLForInvoice
					Serializes the client's basic info needed for an invoice.
	--->
	<cffunction name="SerializeXMLForInvoice" access="public" returntype="String" hint="Serializes the client's basic info needed for an invoice.">
	
		<cfset retVal = "<first_name>#THIS.FirstName#</first_name>" />
		<cfset retVal = retVal & "<last_name>#THIS.LastName#</last_name>" />
		<cfset retVal = retVal & "<organization><![CDATA[#THIS.Organization#]]></organization>" />
		<cfset retVal = retVal & "<p_street1>#THIS.PrimaryStreet1#</p_street1>" />
		<cfset retVal = retVal & "<p_street2>#THIS.PrimaryStreet2#</p_street2>" />
		<cfset retVal = retVal & "<p_city>#THIS.PrimaryCity#</p_city>" />
		<cfset retVal = retVal & "<p_state>#THIS.PrimaryState#</p_state>" />
		<cfset retVal = retVal & "<p_country>#THIS.PrimaryCountry#</p_country>" />
		<cfset retVal = retVal & "<p_code>#THIS.PrimaryPostalCode#</p_code>" />
		
		<cfreturn retVal />
	
	</cffunction>
	
	<!---
			MergeData
					Checks to see if the property has a value, then overwrites it if MergeData is True. Otherwise, it sets the properties value to the specified data.
	--->
	<cffunction name="Merge" access="public" returntype="void" hint="Checks to see if the property has a value, then overwrites it if MergeData is True. Otherwise, it sets the properties value to the specified data.">
		<cfargument name="Key" type="string" required="true" />
		<cfargument name="Value" type="string" required="true" />
		<cfargument name="MergeData" type="boolean" required="true" default="false" />
		
		<!--- Get the current value of the property. --->
		<cfset currentValue = Evaluate("THIS." & Arguments.Key) />
		
		<!--- If the property has a value... --->
		<cfif Len(Trim(currentValue))>
			
			<!--- ...overwrite the current value if requested.  Otherwise, leave it alone. --->
			<cfif Arguments.MergeData>
				<cfset StructUpdate(THIS, Arguments.Key, Arguments.Value) />
			</cfif>
		
		<!--- If the property is empty, set it's value. --->
		<cfelse>
			<cfset StructUpdate(THIS, Arguments.Key, Arguments.Value) />
		</cfif>
		
	</cffunction>

</cfcomponent>