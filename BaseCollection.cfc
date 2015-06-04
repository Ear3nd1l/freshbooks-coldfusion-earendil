<!---
	Title:		FreshBooks BaseCollection CFC
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
<cfcomponent displayname="Base Collection" hint="Inheritable Base Collection" extends="Common">

	<!--- Declare properties and private variables. --->
	<cfset VARIABLES.Container = ArrayNew(1) />
	<cfparam name="THIS.Count" default="0" type="numeric" />

	<!---
			Add
				Adds an object to the collection.
	--->
	<cffunction name="Add" access="public" returntype="void" hint="Adds an object to the collection.">
		<cfargument name="Object" type="any" required="yes" />

		<cfset ArrayAppend(VARIABLES.container, Arguments.Object) />
		<cfset THIS.count = ArrayLen(VARIABLES.Container) />
	</cffunction>
	
	<!---
			GetAt
					Gets an object in the collection by its index.
	--->
	<cffunction name="GetAt" access="public" returntype="any" hint="Gets an object in the collection by its index.">
		<cfargument name="Index" type="numeric" required="yes" default="#NullInt#" />
		
		<!--- If this is a valid item, get it.  Otherwise, return an empty string --->
		<cfif index GT 0 AND index LTE THIS.Count>
			<cfreturn VARIABLES.Container[Arguments.Index] />
		<cfelse>
			<cfreturn NullString />
		</cfif>
		
	</cffunction>
	
	<!---
			RemoveAt
					Removes an object from the collection by its index.
	--->
	<cffunction name="RemoveAt" access="public" returntype="boolean" hint="Removes an object from the collection by its index.">
		<cfargument name="Index" type="numeric" required="yes" default="#NullInt#" />
		
		<!--- If this is a valid item, remove it.  Otherwise, do nothing --->
		<cfif index GT 0 AND index LTE THIS.Count>
			<cfset ArrayDeleteAt(VARIABLES.Container, Arguments.Index) />
			<cfset THIS.Count = ArrayLen(VARIABLES.Container) />
			<cfreturn True />
		<cfelse>
			<cfreturn False />
		</cfif>
	</cffunction>
	
	<!---
			Clear
					Clears the collection.
	--->
	<cffunction name="Clear" access="public" returntype="void" hint="Clears the collection.">
		<cfset VARIABLES.Container = ArrayNew(1) />
		<cfset THIS.Count = 0 />
	</cffunction>

</cfcomponent>