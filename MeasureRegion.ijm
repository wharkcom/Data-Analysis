//This script is written in ImageJ macro language. It will analyze polymerized microtubules based on a selected region rather than the entire image.

var dir, imList, saveName, saveFile, suffix, suffix2, fileList, imList;

dir = File.directory;
imList = newArray(1000);
suffix = " Area.tif";
suffix2 = " Tubes filtered area.tif";


run("Bio-Formats Macro Extensions");

Dialog.create("Analyze Region");
Dialog.addString("Directory: ", dir, 100);
Dialog.addString("Save as: ", "Analysis", 15);
Dialog.show();

dir = Dialog.getString();
saveImages = Dialog.getCheckbox();
saveName = Dialog.getString();
saveFile = dir + saveName + ".txt";

run("Clear Results");

fileList = getFileList(dir);

numImages = 0;
for ( i = 0; i < fileList.length; i++ ) {
	fileName = fileList[i];
	if ( endsWith(fileName, suffix) ) {
		imList[numImages] = substring(fileName, 0, lengthOf(fileName)-lengthOf(suffix));
		numImages += 1;
	}

}

if ( !File.exists(saveFile) ) {
	File.saveString("", saveFile);
}

File.append("\r\nImage\tArea\tTotal\tTubes\r\n", saveFile);

for ( i = 0; i < numImages; i++ ) {
	imageName = imList[i];
	if ( File.exists(dir + imageName + suffix2) ) {
		print("Measuring " + imageName + ". (" + (i+1) + " of " + numImages + ")");
		open(dir + imageName + suffix2);
		run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
		open(dir + imageName + suffix);
		run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");

		waitForUser("Select region to measure or close images to abort macro.");

		if ( nImages < 2 ) {
			print("Aborting!");
			exit();
		}
		
		run("Set Measurements...", "area mean display redirect=[" + imageName + suffix + "] decimal=5");
		run("Measure");
		total = getResult("Mean");
		area = getResult("Area");
		run("Set Measurements...", "area mean display redirect=[" + imageName + suffix2 + "] decimal=5");
		run("Measure");
		tubes = getResult("Mean");
	
		run("Close All");
		File.append("" + imageName + "\t" + area + "\t" + total + "\t" + tubes, saveFile);
		
	} else {
		print("Skipping " + imageName + " because an image is missing. (" + i + " of " + numImages + ")");
	}
}
