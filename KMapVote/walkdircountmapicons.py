from os import *
import re

iconCounts = dict( )
for( dirpath, dirnames, filenames ) in walk( "D:\\steamapps\\kamshak1337\\garrysmod\\garrysmod\\downloads\\materials\\mapicons" ):
    for filename in filenames:
        filename = re.sub( r'(.*?)(\(\d\))?\.png', r'\1', filename )
        iconCounts[filename] = iconCounts[filename] + 1 if filename in iconCounts else 1
        
print( "{" )
for( mapname, count )in iconCounts.items():
    print( "\t['%s'] = %i," % ( mapname, count ) )
print( "}" )
print( "Total: %i" % len( iconCounts ) + " maps" )