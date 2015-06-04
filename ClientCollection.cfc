<!---
	Title:		FreshBooks ClientCollection CFC
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
<cfcomponent displayname="Client Collection" hint="Collection of Client Objects" extends="BaseCollection">

	<!---
			Init
					Initializes the object with all clients that have a FreshBooks Client ID.
	--->
	<cffunction name="Init" access="public" returntype="boolean" hint="Initializes the object with all clients that have a FreshBooks Client ID.">
	
		<cftry>
	
			<!--- Get the clients that have a FreshBooks Client ID and map them to the collection. --->
			<cfset GetAllClientsInFreshBooks() />
			
			<cfreturn True />
			
			<cfcatch><cfreturn False /></cfcatch>
		
		</cftry>
		
	</cffunction>

	<!---
			MapObjects
					Maps the data from a query to a collection of clients.
	--->
	<cffunction name="MapObjects" access="private" returntype="void" hint="Maps the data from a query to a collection of clients.">
		<cfargument name="qryData" type="query" required="true" />
		
		<!--- Make sure this is a query and it has records. --->
		<cfif isQuery(Arguments.qryData) AND Arguments.qryData.RecordCount>
		
			<!--- Loop through it. --->
			<cfloop query="Arguments.qryData">
		
				<cfscript>
				
					ClientInfo = CreateObject('component', 'Client');
					
					ClientInfo.ClientID = GetInt(Arguments.qryData, 'client_id');
					ClientInfo.FreshBooksClientID = GetInt(Arguments.qryData, 'freshBooksClientID');
					ClientInfo.RecurringID = GetInt(Arguments.qryData, 'freshBooksRecurringID');
					ClientInfo.FirstName = GetString(Arguments.qryData, 'first_name');
					ClientInfo.LastName = GetString(Arguments.qryData, 'last_name');
					ClientInfo.Organization = GetString(Arguments.qryData, 'organization');
					ClientInfo.PrimaryStreet1 = GetString(Arguments.qryData, 'address1');
					ClientInfo.PrimaryStreet2 = GetString(Arguments.qryData, 'address2');
					ClientInfo.PrimaryCity = GetString(Arguments.qryData, 'city');
					ClientInfo.PrimaryState = GetString(Arguments.qryData, 'state');
					ClientInfo.PrimaryPostalCode = GetString(Arguments.qryData, 'postal_code');
					ClientInfo.PrimaryCountry = GetString(Arguments.qryData, 'country');
					ClientInfo.WorkPhone = GetString(Arguments.qryData, 'workPhone');
					ClientInfo.Email = GetString(Arguments.qryData, 'email');
					ClientInfo.HomePhone = GetString(Arguments.qryData, 'homePhone');
					ClientInfo.Mobile = GetString(Arguments.qryData, 'mobile');
					ClientInfo.Fax = GetString(Arguments.qryData, 'fax');
					ClientInfo.Language = GetString(Arguments.qryData, 'language');
					ClientInfo.CurrencyCode = GetString(Arguments.qryData, 'currencyCode');
					ClientInfo.Notes = GetString(Arguments.qryData, 'notes');
					ClientInfo.UserName = GetString(Arguments.qryData, 'userName');
					
					// Add the client to the collection.
					Add(ClientInfo);
				
				</cfscript>
			
			</cfloop>
		
		</cfif>
		
	</cffunction>

	<!---
			MapObjectsXML
					Maps the data from an XML documents to a collection of clients.
	--->
	<cffunction name="MapObjectsXML" access="private" returntype="void" hint="Maps the data from an XML documents to a collection of clients.">
		<cfargument name="xmlResponse" type="xml" required="true" />
		<cfargument name="MergeData" type="boolean" required="false" default="false" />
		
		<!--- Make sure this is an XML document. --->
		<cfif isXMLDoc(Arguments.xmlResponse)>
		
			<!--- Parse it into an object. --->
			<cfset Arguments.xmlResponse = XmlParse(Arguments.xmlResponse) />
			
			<!--- Get a node list of clients. --->
			<cfset xmlNode = XmlSearch(Arguments.xmlResponse, '//*[local-name()="client"]') />
			
			<!--- If there are nodes in the list... --->
			<cfif ArrayLen(xmlNode)>
			
				<!--- Loop through the node list. --->
				<cfloop from="1" to="#ArrayLen(xmlNode)#" index="i">
				
					<!--- Create a single node for the client. --->
					<cfset clientObject = xmlNode[i] />
				
					<!--- Pass the values to the merge method so they can be assigned to the properties. --->
					<cfscript>
					
						ClientInfo = CreateObject('component', 'Client');
						
						ClientInfo.FreshBooksClientID = clientObject['client_id'].xmlText;
						ClientInfo.Merge('FirstName', clientObject['first_name'].xmlText, Arguments.MergeData);
						ClientInfo.Merge('LastName', clientObject['last_name'].xmlText, Arguments.MergeData);
						ClientInfo.Merge('Organization', clientObject['organization'].xmlText, Arguments.MergeData);
						ClientInfo.Merge('Email', clientObject['email'].xmlText, Arguments.MergeData);
						ClientInfo.Merge('UserName', clientObject['username'].xmlText, Arguments.MergeData);
						ClientInfo.Merge('WorkPhone', clientObject['work_phone'].xmlText, Arguments.MergeData);
						ClientInfo.HomePhone = clientObject['home_phone'].xmlText;
						ClientInfo.Mobile = clientObject['mobile'].xmlText;
						ClientInfo.Fax = clientObject['fax'].xmlText;
						ClientInfo.Language = clientObject['language'].xmlText;
						ClientInfo.CurrencyCode = clientObject['currency_code'].xmlText;
						ClientInfo.Notes = clientObject['notes'].xmlText;
						ClientInfo.Merge('PrimaryStreet1', clientObject['p_street1'].xmlText, Arguments.MergeData);
						ClientInfo.Merge('PrimaryStreet2', clientObject['p_street2'].xmlText, Arguments.MergeData);
						ClientInfo.Merge('PrimaryCity',clientObject['p_city'].xmlText, Arguments.MergeData);
						ClientInfo.Merge('PrimaryState', clientObject['p_state'].xmlText, Arguments.MergeData);
						ClientInfo.Merge('PrimaryCountry', clientObject['p_country'].xmlText, Arguments.MergeData);
						ClientInfo.Merge('PrimaryPostalCode', clientObject['p_code'].xmlText, Arguments.MergeData);
						ClientInfo.Merge('SecondaryStreet1', clientObject['s_street1'].xmlText, Arguments.MergeData);
						ClientInfo.Merge('SecondaryStreet2',clientObject['s_street2'].xmlText, Arguments.MergeData);
						ClientInfo.Merge('SecondaryCity', clientObject['s_city'].xmlText, Arguments.MergeData);
						ClientInfo.Merge('SecondaryState', clientObject['s_state'].xmlText, Arguments.MergeData);
						ClientInfo.Merge('SecondaryCountry', clientObject['s_country'].xmlText, Arguments.MergeData);
						ClientInfo.Merge('SecondaryPostalCode', clientObject['s_code'].xmlText, Arguments.MergeData);
						ClientInfo.ClientViewLink = clientObject['links']['client_view'].xmlText;
						ClientInfo.ViewLink = clientObject['links']['view'].xmlText;
						
						// Add the client to the collection.
						Add(ClientInfo);
		
					</cfscript>
					
				</cfloop>
				
			</cfif>
		
		</cfif>
		
	</cffunction>

	<!---
			GetAllClientsInFreshBooks
					Gets all clients with a FreshBooks Client ID.
	--->
	<cffunction name="GetAllClientsInFreshBooks" access="public" returntype="boolean" hint="Gets all clients with a FreshBooks Client ID.">
		
		<cftry>
		
			<!--- Only do this if FreshBooks is enabled. --->
			<cfif Application.FreshBooksEnabled>

				<!--- Get a list of clients from the database. --->
				<cfstoredproc datasource="#Application.DSN#" procedure="FB_GetAllFreshBooksClients" result="qryGetAllClientsInFreshBooks" />
		
				<!--- If nothing was found, throw an error. --->
				<cfif qryGetAllClientsInFreshBooks.RecordCount eq 0>
					<cfthrow message="No records found." />
				</cfif>
				
				<!--- Map the data to the collection. --->
				<cfset MapObjects(qryGetAllClientsInFreshBooks) />
		
				<cfreturn True />
			
			<cfelse>
			
				<cfreturn False />
			
			</cfif>
			
			<cfcatch><cfreturn False /></cfcatch>
			
		</cftry>

	</cffunction>

	<!---
			GetAllClientsNotInFreshBooks
					Gets all clients without a FreshBooks Client ID.
	--->
	<cffunction name="GetAllClientsNotInFreshBooks" access="public" returntype="boolean" hint="Gets all clients without a FreshBooks Client ID.">
		
		<cftry>
		
			<!--- Only do this if FreshBooks is enabled. --->
			<cfif Application.FreshBooksEnabled>

				<!--- Get a list of clients from the database. --->
				<cfstoredproc datasource="#Application.DSN#" procedure="FB_GetAllNonFreshBooksClients" result="qryGetAllClientsNotInFreshBooks" />
				
				<!--- If nothing was found, throw an error. --->
				<cfif qryGetAllClientsNotInFreshBooks.RecordCount eq 0>
					<cfthrow message="No records found." />
				</cfif>
				
				<!--- Map the data to the collection. --->
				<cfset MapObjects(qryGetAllClientsNotInFreshBooks) />

				<cfreturn True />
			
			<cfelse>
			
				<cfreturn False />
			
			</cfif>
			
			<cfcatch><cfreturn False /></cfcatch>
			
		</cftry>

	</cffunction>

	<!---
			GetClientsFromFreshBooks
					Gets a collection of clients from FreshBooks.
	--->
	<cffunction name="GetClientsFromFreshBooks" access="public" returntype="boolean" hint="Gets a collection of clients from FreshBooks.">

		<cftry>
		
			<!--- Only do this if FreshBooks is enabled. --->
			<cfif Application.FreshBooksEnabled>

				<!--- Create the XML document to transmit. --->
				<cfsavecontent variable="xmlData">
					<cfoutput>
						#XMLencoding#
						<request method="client.list">
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

</cfcomponent>