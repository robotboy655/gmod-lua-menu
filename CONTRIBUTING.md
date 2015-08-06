Contributing to Lua Main Menu
=============

Here's what you need to know if you wish to submit Pull Requests to this repository.

Code Formatting
=============

Your code formatting must be consistent with the rest of the code:
* Use tabulation to indent your code - TAB size = 4 spaces
* Use all of the C style Lua in Garry's Mod
* Use UpperCamelCase for function names
* Use lowerCamelCase for variable names
* Do not include variable type in variable names

Examples
=============

These examples are of CODE FORMATTING, not examples of GOOD CODE.

Good:
```
local myTable = {
	meem = "no",
	test = true,
	foo = 1,
	bar = "yes"
}

if ( type( myTable ) != "table" ) then error( "bad" ) end

function Test( myVariable1, myVariable2 )
	if ( !myVariable2 ) then return "hax" end

	if ( myTable[ myVariable1 ] ) then
		return myTable[ myVariable1 ]
	end

	return myVariable2
end
```

Bad:
```
local myTable =
{
 meem =			"no",
  test =true,
   foo= 1,
    bar				= "yes"
}

if type(myTable) ~= "table" then error "bad" end

function Test( myVariable1, myVariable2 )
 if not myVariable2 then return "hax" end

 if myTable[myVariable1] then         
  return myTable[myVariable1]
		end

 return myVariable2			
end
```