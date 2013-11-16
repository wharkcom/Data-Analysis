//This ImageJ script will analyze the levels of Acetylated vs Tyrosinated tubulin
//Ac-Tubulin files have 3 channels: DAPI, Tyr, Ac

//setBatchMode(true);
imgArray = newArray(nImages);

for(i=0; i<nImages; i++){
	selectImage(i+1);
	imgArray[i] = getImageID();
}

tyr = newArray(imgArray.length);
ac =  newArray(imgArray.length);
areas = newArray(imgArray.length);

for(j=0; j<imgArray.length; j++){
	selectImage(imgArray[j]);
	name = getTitle();
	run("Split Channels");

	//close DAPI
	selectWindow("C1-"+name);
	close();

	//Make Mask
	selectWindow("C2-"+name);
	run("Z Project...", "start=1 stop=25 projection=[Average Intensity]");
	setAutoThreshold("Triangle dark");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Create Selection");
	roiManager("Add");
	close();


	//Measure Tyr Tubulin
	selectWindow("C2-"+name);
	roiManager("Select", 0);
	for (i = 1; i < nSlices; i++) {
		setSlice(i);
		getStatistics(area, mean);
		tyr[j] = tyr[j] + (mean);
		areas[j] = areas[j] + area;
	}
	selectWindow("C2-"+name);
	close();
	
	//Measure Ac Tubulin
	selectWindow("C3-"+name);
	roiManager("Select", 0);
	for (i = 1; i < nSlices; i++) {
		setSlice(i);
		getStatistics(area, mean);
		ac[j] = ac[j] + (mean);
	}
	selectWindow("C3-"+name);
	close();

	
	roiManager("Delete");

	print(name+"\t"+areas[j]+"\t"+tyr[j]+"\t"+ac[j]+"\t"+ac[j]/tyr[j]);
}


