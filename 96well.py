#This script generates an XML file of X-Y coordinates to be used when reading multi-well plates
#on our microscope.
#Spacing = 9000 (mm) for 96-well plate


f = open('multipoints.xml','w')

#Change these values to adjust the plate size and well spacing (96well = 9 mm)
row_range = 2
col_range = 4
spacing = 9000

#Create an array of x,y coordinates in the plate and their corresponding distance from 0,0
well = []
well = [[[i*spacing,j*spacing] for j in range(col_range)] for i in range(row_range)]

#For counting overall well numbers
c = 0

#XML file header
f.write('<?xml version="1.0" encoding="UTF-16"?><variant version="1.0">'\
        '<no_name runtype="CLxListVariant"><bIncludeZ runtype="bool" value="true"/><bPFSEnabled runtype="bool" value="false"/>')

#Loop to generate XML file based on entry #, X, and Y values
for i in range(row_range):
    for j in range(col_range):
        f.write('<Point'+str("%05d" % (c))+' runtype="NDSetupMultipointListItem">' \
        '<bChecked runtype="bool" value="true"/>' \
        '<strName runtype="CLxStringW" value="#'+str(c+1)+'"/>' \
        '<dXPosition runtype="double" value="'+str("%.15f" % well[i][j][0])+'"/>' \
        '<dYPosition runtype="double" value="'+str("%.15f" % well[i][j][1])+'"/>' \
        '<dZPosition runtype="double" value="0.000000000000000"/>' \
        '<dPFSOffset runtype="double" value="-1.000000000000000"/>' \
        '</Point'+str("%05d" % (c))+'>' \
        )
        c += 1  #increment total well count
        
#XML file end
f.write('</no_name></variant>')
