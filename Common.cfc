<!---
	Title:		FreshBooks Common CFC
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
<cfcomponent displayname="Common" hint="Common Object" output="false">

	<!--- Define contants --->
	<cfset NullInt = -2147483648 />
	<cfset NullGuid = '00000000-0000-0000-0000-000000000000' />
	<cfset NullDate = '01/01/1900' />
	<cfset NullTime = '00:00:00' />
	<cfset NullString = '' />
	<cfset NullBool = False />
	
	<!---
		TrueFalseFormat
				Takes either a bit value or a yes/no value and converts it to True or False.
	--->
	<cffunction name="TrueFalseFormat" access="public" returntype="boolean">
		<cfargument name="value" type="any" required="yes" />
		
		<cfset var retVal = NullBool />
		
		<cfif Arguments.value eq 1>
			<cfset retVal = True />
		<cfelseif Arguments.value eq 'yes'>
			<cfset retVal = True />
		</cfif>
		
		<cfreturn retVal />
		
	</cffunction>
	
	<!---
		BitFormat
				Takes either a True/False value or a yes/no value and converts it to 1 or 0.
	--->
	<cffunction name="BitFormat" access="public" returntype="binary">
		<cfargument name="value" type="any" required="yes" />

		<cfset var retVal = 0 />
		
		<cfif Arguments.value eq 'True'>
			<cfset retVal = 1 />
		<cfelseif Arguments.value eq 'yes'>
			<cfset retVal = 1 />
		</cfif>
					
		<cfreturn retVal />
		
	</cffunction>
	
	<!---
		YesNo
				Takes either a True/False value or a bit value and converts it to yes or no.
	--->
	<cffunction name="YesNo" access="public" returntype="string">
		<cfargument name="value" type="any" required="yes" />
	
		<cfset var retVal = 'No' />
		
		<cfif Arguments.value eq 1>
			<cfset retVal = 'Yes' />
		<cfelseif Arguments.value eq 'True'>
			<cfset retVal = 'Yes' />
		</cfif>
		
		<cfreturn retVal />
	
	</cffunction>
	
	<!---
		GetString
				Gets a string value from the specified field in a record.
				If the field does not exist, it returns the default value of the constant.
	--->
	<cffunction name="GetString" access="public" returntype="string">
		<cfargument name="Dataset" type="query" required="yes" />
		<cfargument name="Value" type="string" required="yes" />
		<cfargument name="DefaultValue" type="string" required="no" default="#NullString#" />

		<cfset var retVal = NullString />

		<cftry>

			<cfif Len(Trim(Arguments.value))>
				<cfset retVal = Trim(Arguments.dataset[Arguments.value][Arguments.dataset.CurrentRow]) />
			</cfif>

			<cfcatch><cfset retVal = '' /></cfcatch>
		
		</cftry>
		
		<cfreturn retVal />
		
	</cffunction>
	
	<!---
		GetInt
				Gets an integer value from the specified field in a record.
				If the field does not exist, it returns the default value of the constant.
	--->
	<cffunction name="GetInt" access="public" returntype="numeric">
		<cfargument name="Dataset" type="query" required="yes" />
		<cfargument name="Value" type="string" required="yes" />
		<cfargument name="DefaultValue" type="numeric" required="no" default="#NullInt#" />

		<cfset var retVal = Arguments.DefaultValue />
		
		<cftry>

			<cfif Len(Trim(Arguments.value))>
			
				<cfset tempValue = Trim(Arguments.dataset[Arguments.value][Arguments.dataset.CurrentRow]) />
			
				<cfif isNumeric(tempValue)>
					<cfset retVal = tempValue />
				</cfif>
			</cfif>
		
			<cfcatch></cfcatch>
		
		</cftry>
		
		<cfreturn retVal />
		
	</cffunction>
	
	<!---
		GetBool
				Gets a boolean value from the specified field in a record.
				If the field does not exist, it returns the default value of the constant.
	--->
	<cffunction name="GetBool" access="public" returntype="boolean">
		<cfargument name="Dataset" type="query" required="yes" />
		<cfargument name="Value" type="string" required="yes" />
		<cfargument name="DefaultValue" type="boolean" required="no" default="#NullBool#" />

		<cfset var retVal = Arguments.DefaultValue />
		
		<cftry>

			<cfif Len(Trim(Arguments.value))>
			
				<cfset tempValue = Trim(Arguments.dataset[Arguments.value][Arguments.dataset.CurrentRow]) />
			
				<cfset retVal = TrueFalseFormat(tempValue) />
				
			</cfif>

			<cfcatch></cfcatch>
			
		</cftry>
		
		<cfreturn retVal />
		
	</cffunction>
	
	<!---
		GetGuid
				Gets a guid value from the specified field in a record.
				If the field does not exist, it returns the default value of the constant.
	--->
	<cffunction name="GetGuid" access="public" returntype="string">
		<cfargument name="Dataset" type="query" required="yes" />
		<cfargument name="Value" type="string" required="yes" />
		<cfargument name="DefaultValue" type="string" required="no" default="#NullGuid#" />

		<cfset var retVal = Arguments.DefaultValue />
		
		<!--- Use regex to find out of the value is a guid. --->
		<cftry>

			<cfif Len(Trim(Arguments.value))>
			
				<cfset tempValue = Trim(Arguments.dataset[Arguments.value][Arguments.dataset.CurrentRow]) />
			
				<cfif IsGuid(tempValue)>
					<cfset retVal = tempValue />
				</cfif>
				
			</cfif>
		
			<cfcatch></cfcatch>
			
		</cftry>
		
		<cfreturn retVal />
		
	</cffunction>
	
	<!---
		GetDate
				Gets a date value from the specified field in a record.
				If the field does not exist, it returns the default value of the constant.
	--->
	<cffunction name="GetDate" access="public" returntype="date">
		<cfargument name="Dataset" type="query" required="yes" />
		<cfargument name="Value" type="string" required="yes" />
		<cfargument name="DefaultValue" type="date" required="no" default="#NullDate#" />

		<cfset var retVal = Arguments.DefaultValue />
		
		<cftry>

			<cfif Len(Trim(Arguments.value))>
			
				<cfset tempValue = Trim(Arguments.dataset[Arguments.value][Arguments.dataset.CurrentRow]) />
			
				<cfif IsDate(tempValue)>
					<cfset retVal = tempValue />
				</cfif>
			</cfif>
		
			<cfcatch></cfcatch>
		
		</cftry>
		
		<cfreturn retVal />
		
	</cffunction>
	
	<!---
			IsGuid
				Checks to see if a string is a guid.
	--->
	<cffunction name="IsGuid" access="public" returntype="boolean">
		<cfargument name="str" type="string" required="yes" />

		<cfreturn refindNoCase('^[{|\(]?[0-9a-fA-F]{8}[-]?([0-9a-fA-F]{4}[-]?){3}[0-9a-fA-F]{12}[\)|}]?$', Arguments.str) />
	
	</cffunction>
	
	<!---
			Post
					Takes an XML document, posts it to FreshBooks and returns the response.
					Special thanks to J.J. Merrick for providing this function.
	--->
	<cffunction name="Post" access="private" returntype="xml" hint="">
		<cfargument name="XmlDoc" type="xml" required="true" />
		
		<cfhttp url="#FreshBooksURL#" result="response" username="#Token#" password="#Password#" method="post" charset="utf-8">
			<cfhttpparam value="#XmlDoc#" type="xml" />
		</cfhttp>
		
		<cfreturn XmlParse(response.fileContent) />
		
	</cffunction>

</cfcomponent>