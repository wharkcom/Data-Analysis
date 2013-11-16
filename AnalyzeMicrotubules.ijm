//This script is written in ImageJ marcro language. It will analzye a folder of images and calculate the mass of polymerized microtubules.

var choice, dir, saveImages, saveName, saveFile, saveDir, suffix, sigma, fileList, imList;
var imageWidth, imageHeight, numChannels, numSlices, numFrames;

dir = File.directory;
imList = newArray(1000);
suffix = ".nd2";

Dialog.create("Analyze Microtubules");
//Dialog.addChoice("Analyze", newArray("Entire image", "Select region"));
Dialog.addString("Directory: ", dir, 100);
Dialog.addCheckbox("Save images", true);
Dialog.addString("Save as", "Analysis", 15);
Dialog.show();

//choice = Dialog.getChoice();
dir = Dialog.getString();
saveImages = Dialog.getCheckbox();
saveName = Dialog.getString();
saveFile = dir + saveName + ".txt";
saveDir = dir + saveName + File.separator;

if ( saveImages && ! File.isDirectory(saveDir) ) {
	File.makeDirectory( saveDir );
}

// Set measurements to only what we need & clear them
run("Set Measurements...", "mean min display redirect=None decimal=5");
run("Clear Results");

// Run plug-in for opening nd2 files
run("Bio-Formats Macro Extensions");

// Look at all of the files in the directory
fileList = getFileList(dir);
setBatchMode(true);
j = 0;
for ( i = 0; i < fileList.length; i++ ) {
	fileName = fileList[i];
	if ( endsWith(fileName, suffix) ) {
		imList[j] = fileName;
		j += 1;
	}

}

File.append("------ Analysis started at " + getTime + " ------", saveFile);
File.append("Image\tTotal\tTotal Area\tTubes\tTubes Area\tFilter Tubes Area", saveFile);

i = 0;
for ( i = 0; i < j; i++ ) {
	imageName = imList[i];


	shortName = substring(imageName, 0, lengthOf(imageName)-4);

	IJ.redirectErrorMessages();
	Ext.openImagePlus(dir + imageName);

	if ( nImages<1 ) {
		
		print("Skipping " + shortName + " because there was an error opening the file (" + (i+1) + " of " + j + " images)");
	} else {

		getDimensions(imageWidth, imageHeight, numChannels, numSlices, numFrames);
	
		if ( numChannels > 1 ) {
			print("Skipping " + shortName + " because it has multiple channels (" + (i+1) + " of " + j + " images)");
			run("Close All");
		} else if ( numSlices <= 1 ) {
			print("Skipping " + shortName + " because it is not a stack (" + (i+1) + " of " + j + " images)");
			run("Close All");
		} else {
			print("Processing " + shortName + " (" + (i+1) + " of " + j + " images)");
		
			// Measure Total
			run("Z Project...", "projection=[Average Intensity]");
			selectWindow("AVG_" + imageName);
			
			run("Measure");
			
			setResult("Label", nResults-1, "Overall intensity of " + imageName);
			total = getResult("Mean", nResults-1);
		
			if ( saveImages ) {
				save( saveDir + substring(imageName, 0, lengthOf(imageName)-4) + " Total.tif");
			}
			
			selectWindow("AVG_" + imageName);
			setAutoThreshold("Triangle dark");
			run("Convert to Mask");
			run("Measure");
			setResult("Label", nResults-1, "Area of " + imageName);
			area = getResult("Mean", nResults-1);
		
			if ( saveImages ) {
				save( saveDir + substring(imageName, 0, lengthOf(imageName)-4) + " Area.tif");
			}
		
			// Measure Tubes
			selectWindow(imageName);
			run("Tubeness","sigma=1");
	
			if ( getTitle() == "tubeness of " + imageName ) {
				
				run("Z Project...", "projection=[Average Intensity]");
				selectWindow("AVG_tubeness of " + imageName);	
				
				run("Measure");
				setResult("Label", nResults-1, "Tubeness of " + imageName);
				tubes = getResult("Mean", nResults-1);
				
				if ( saveImages ) {
					save( saveDir + substring(imageName, 0, lengthOf(imageName)-4) + " Tubes.tif");
				}
				
				selectWindow("AVG_tubeness of " + imageName);	
				setAutoThreshold("Triangle dark");
				run("Convert to Mask");
		
				selectWindow("AVG_tubeness of " + imageName);	
				run("Measure");
				setResult("Label", nResults-1, "Tubes area of " + imageName);
				tubesarea = getResult("Mean", nResults-1);
			
				if ( saveImages ) {
					save( saveDir + substring(imageName, 0, lengthOf(imageName)-4) + " Tubes area.tif");
				}
				
				selectWindow("AVG_tubeness of " + imageName);	
				run("Set Measurements...", "mean min redirect=None decimal=5");
				run("Analyze Particles...", "size=50-Infinity pixel circularity=0.0-0.5 show=Masks");
			
				if ( saveImages ) {
					save( saveDir + substring(imageName, 0, lengthOf(imageName)-4) + " Tubes filtered area.tif");
				}
			
				selectWindow("Mask of AVG_tubeness of " + imageName);
				run("Set Measurements...", "mean min display redirect=None decimal=5");	
				run("Measure");
				setResult("Label", nResults-1, "Tubes area of " + imageName);
				filtertubesarea = getResult("Mean", nResults-1);
			
				run("Close All");
			
				File.append(shortName + "\t" + total + "\t" + area + "\t" + tubes + "\t" + tubesarea + "\t" + filtertubesarea, saveFile);
			} else {
				print("Tubeness seems to have failed for " + imageName);
				run("Close All");
			}
		}
	}
	
}
File.append("------ Analysis finished at " + getTime + " ------", saveFile);
print("All done!");
exit();
