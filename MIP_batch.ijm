//Hideo Otsuna (HHMI Janelia Research Campus), June 4, 2015


setBatchMode(true);
compCC=0;// 1 is compressed nrrd, 0 is not compressed nrrd

dir = getDirectory("Choose a directory for aligned confocal files");

filepath0=getDirectory("temp");//C:\Users\??\AppData\Local\Temp\...C:\DOCUME~1\ADMINI~1\LOCALS~1\Temp\
filepath=filepath0+"MIP_batch.txt";

LF=10; TAB=9; swi=0; swi2=0; 
exi=File.exists(filepath);
List.clear();

if(exi==1){
	s1 = File.openAsRawString(filepath);
	swin=0;
	swi2n=-1;
	
	n = lengthOf(s1);
	String.resetBuffer;
	for (si=0; si<n; si++) {
		c = charCodeAt(s1, si);
		
		if(c==10){
			swi=swi+1;
			swin=swin+1;
			swi2n=swi-1;
		}
		
		if(swi==swin){
			if(swi2==swi2n){
				String.resetBuffer;
				swi2=swi;
			}
			if (c>=32 && c<=127)
			String.append(fromCharCode(c));
		}
		if(swi==0){
			exporttype = String.buffer;
		}else if(swi==1){
			subfolderS = String.buffer;
		}else if(swi==2){
			colorcodingS = String.buffer;
		}else if(swi==3){
			CLAHES = String.buffer;
		}else if(swi==4){
			AutoBR = String.buffer;
		} //swi==0
	}
	File.saveString(exporttype+"\n"+subfolderS+"\n"+colorcodingS+"\n"+CLAHES+"\n"+AutoBR, filepath);
}
if(exi==0){
	exporttype="1ch MIP";
	subfolderS=false;
	colorcodingS=false;
	CLAHES=false;
	AutoBR=false;
}


Dialog.create("Batch processing of 3D files conversion");
item0=newArray("1ch MIP", "2ch MIP", "3D tiff", "Both-MIP & 3Dtif");
Dialog.addRadioButtonGroup("Export type", item0, 1, 4, exporttype); 
Dialog.addCheckbox("Include sub-folder", subfolderS);
Dialog.addCheckbox("Depth Color coding MIP", colorcodingS);
Dialog.addCheckbox("Automatic Brightness adjustment", AutoBR);
Dialog.addCheckbox("Enhance contrast CLAHE", CLAHES);

Dialog.show();
exporttype = Dialog.getRadioButton();
subfolder=Dialog.getCheckbox();
colorcoding=Dialog.getCheckbox();
AutoBRV=Dialog.getCheckbox();
CLAHE=Dialog.getCheckbox();

if(subfolder==1)
subfolderS=true;

if(colorcoding==1)
colorcodingS=true;

if(CLAHE==1)
CLAHES=true;

if(AutoBRV==1)
AutoBR=true;

if(AutoBRV==0)
AutoBR=false;

if(subfolder==0)
subfolderS=false;

if(colorcoding==0)
colorcodingS=false;

if(CLAHE==0)
CLAHES=false;

if(AutoBRV==1){
	Dialog.create("Desired mean value for Auto-Brightness");
	Dialog.addNumber("Desired mean value for Auto-Brightness /255", 100);
	Dialog.show();
	desiredmean=Dialog.getNumber();
	print("Desired mean; "+desiredmean);
}

File.saveString(exporttype+"\n"+subfolderS+"\n"+colorcodingS+"\n"+CLAHES+"\n"+AutoBR, filepath);

myDir = 0; myDirT = 0; myDirCLAHE = 0; myDir2Co = 0;

if(exporttype=="1ch MIP" || exporttype=="Both-MIP & 3Dtif"){
	myDir = dir+File.separator+"MIP_Files"+File.separator;
	File.makeDirectory(myDir);
}

if(exporttype=="3D tiff" || exporttype=="Both-MIP & 3Dtif"){
	myDirT = dir+File.separator+"TIFF_Files"+File.separator;
	File.makeDirectory(myDirT);
}

if(exporttype=="2ch MIP" && CLAHE==0){
	myDir2 = dir+File.separator+"2ch_MIP_Files"+File.separator;
	File.makeDirectory(myDir2);
}

if(exporttype=="2ch MIP" && CLAHE==1){
	
	if(AutoBRV==1)
	myDirCLAHE = dir+File.separator+"2ch_CLAHE_MIP_"+desiredmean+"_mean_adjusted"+File.separator;
	if(AutoBRV==0)
	myDirCLAHE = dir+File.separator+"2ch_CLAHE_MIP"+File.separator;
	File.makeDirectory(myDirCLAHE);
}

if(exporttype=="2ch MIP" && colorcoding==1){
	
	if(AutoBRV==1)
	myDir2Co = dir+File.separator+"Color_Depth_MIP_"+desiredmean+"_mean_adjusted"+File.separator;
	
	if(AutoBRV==0)
	myDir2Co = dir+File.separator+"Color_Depth_MIP"+File.separator;
	
	File.makeDirectory(myDir2Co);
}

list = getFileList(dir);
for (i=0; i<list.length; i++){
	progress=i/list.length;
	showProgress(progress);
	path = dir+list[i];
	print(list[i]);
	
	mipbatch=newArray(list[i], path, exporttype, myDir, myDirT, myDirCLAHE, myDir2Co);
	
	if (endsWith(list[i], "/")){
		print(subfolder);
		if(subfolder==1){
			if(list[i]!="MIP_Files"+File.separator){
				listsub = getFileList(dir+list[i]);
				for (ii=0; ii<listsub.length; ii++){
					
					path2 = path+listsub[ii];
					mipbatch=newArray(listsub[ii], path2, exporttype, myDir myDirT, myDirCLAHE, myDir2Co);
					mipfunction(mipbatch);
				}
			}
		}
	}else{
	mipfunction(mipbatch);
	}
}

function mipfunction(mipbatch) { 
	listP=mipbatch[0];
	path=mipbatch[1];
	exporttype=mipbatch[2];
	myDir=mipbatch[3];
	myDirT=mipbatch[4];
	myDirCLAHE=mipbatch[5];
	myDir2Co=mipbatch[6];
	
	dotIndex = -1;
	dotIndexAM = -1;
	dotIndextif = -1;
	dotIndexTIFF = -1;
	dotIndexLSM = -1;
	dotIndexV3 = -1;
	dotIndexMha= -1;
	
	files=files+1;
	
	dotIndexMha = lastIndexOf(listP, "mha");
	dotIndexV3 = lastIndexOf(listP, "v3dpbd");
	dotIndexLSM = lastIndexOf(listP, "lsm");
	dotIndex = lastIndexOf(listP, "nrrd");
	dotIndexAM = lastIndexOf(listP, "am");
	dotIndextif = lastIndexOf(listP, "tif");
	dotIndexTIFF = lastIndexOf(listP, "TIFF");
	
	
	if(dotIndextif==-1 && dotIndexTIFF==-1 && dotIndex==-1 && dotIndexAM==-1 && dotIndexLSM==-1 && dotIndexMha==-1){
	}else{
		
		if(compCC==0){// if not compressed
			if(dotIndex>-1 || dotIndexAM>-1){
				run("Bio-Formats Importer", "open="+path+" autoscale color_mode=Default view=[Standard ImageJ] stack_order=Default");
			}
		}
		if(dotIndextif>-1 || dotIndexTIFF>-1 || compCC==1 || dotIndexLSM>-1 || dotIndexV3>-1 || dotIndexMha>-1){
			open(path);// for tif, comp nrrd, lsm", am, v3dpbd, mha
		}
		
		setFont("Arial", 18, " antialiased");
		setColor("white");
		//		run("Close", "Exception");
		bitd=bitDepth();
		totalslice=nSlices();
		origi=getTitle();
		getDimensions(width, height, channels, slices, frames);
		
		dotIndex = lastIndexOf(origi, ".");
		if (dotIndex!=-1);
		origiMIP = substring(origi, 0, dotIndex); // remove extension
		
		if(channels==2){
			run("Split Channels");
			
			selectWindow("C2-"+origi);//Red
			setMinAndMax(0, 4095);
			run("Z Project...", "projection=[Max Intensity]");
			setMinAndMax(0, 4095);
			
			selectWindow("C1-"+origi);//Green
			setMinAndMax(0, 4095);
			run("Mean Thresholding", "-=30 thresholding=Subtraction");//new plugins
			run("Z Project...", "projection=[Max Intensity]");
			setMinAndMax(0, 4095);
			
			
			if(AutoBRV==1){
				selectWindow("MAX_C1-"+origi);
				briadj=newArray(desiredmean, 0, 0);
				autobradjustment(briadj);
				applyV=briadj[2];
				
				if(applyV<50)
				applyV=80;
			}
			selectWindow("MAX_C1-"+origi);
			if(CLAHE==1){//&& colorcoding==0
				if(AutoBRV==1){
					brinum=0;
					run("8-bit");
					run("Brightness/Contrast...");
					setMinAndMax(0, applyV);
					run("Apply LUT");
				}//	if(AutoBRV==1){
				
				run("Enhance Local Contrast (CLAHE)", "blocksize=127 histogram=256 maximum=1.5 mask=*None*");
				run("Merge Channels...", "c1=MAX_C2-"+origi+" c2=MAX_C1-"+origi+" c3=MAX_C2-"+origi+"");
				save(myDirCLAHE+origiMIP+".tif");
				close();
			}

			if(CLAHE==0){
				if(AutoBRV==1){
					brinum=0;
					run("8-bit");
					run("Brightness/Contrast...");
					setMinAndMax(0, applyV);
					run("Apply LUT");
				}//	if(AutoBRV==1){
				run("Merge Channels...", "c1=MAX_C2-"+origi+" c2=MAX_C1-"+origi+" c3=MAX_C2-"+origi+"");
				save(myDir2+origiMIP+".tif");
				close();
			}
			
			if(CLAHE==1 && colorcoding==1){
				setBatchMode(true);
	//			setBatchMode("hide");
	//			selectWindow("C2-"+origi);
	//			close();
				
				selectWindow("C1-"+origi);
				run("Mean Thresholding", "-=35 thresholding=Subtraction");//new plugins
				
				if(AutoBRV==1){
					brinum=0;
					run("8-bit");
					run("Brightness/Contrast...");
					setMinAndMax(0, applyV);
					run("Apply LUT", "stack");
				}//	if(AutoBRV==1){
				selectWindow("C1-"+origi);
				run("Temporal-Color Code", "lut=[royal] start=1 end="+nSlices+" create");
				setBatchMode(true);
	//			setBatchMode("hide");
				selectWindow("color time scale");
				run("Select All");
				run("Copy");
				close();

				makeRectangle(width-257, 1, 256, 48);
				run("Paste");
				
				if(AutoBRV==1){
					if(applyV>99)
					drawString("Max: "+applyV+" /255", width-150, 88);
					
					else if(applyV<100)
					drawString("Max: 0"+applyV+" /255", width-150, 88);
				}
				
				run("Select All");
				
				if(CLAHE==1){
					run("Enhance Local Contrast (CLAHE)", "blocksize=127 histogram=256 maximum=1.5 mask=*None*");
					save(myDir2Co+origiMIP+"_CLAHE.tif");
				}
				if(CLAHE==0)
				save(myDir2Co+origiMIP+".tif");
				
			}//if(colorcoding==1){
			run("Close All");
		}//if(channels==2){
		
		if(exporttype=="1ch MIP" || exporttype=="Both-MIP & 3Dtif"){
			
			if(bitd==16){
				setMinAndMax(0, 4095);
				run("8-bit");
			}else if(bitd==8){
				setMinAndMax(0, 255);
			}
			
			if(colorcoding==1){
				
				run("Mean Thresholding", "-=30 thresholding=Subtraction");//new plugins
				
				run("Temporal-Color Code", "lut=[royal] start=1 end="+nSlices+"");
				run("Properties...", "channels=1 slices=1 frames=1 unit=pixel pixel_width=1.0000 pixel_height=1.0000 voxel_depth=0 global");
			}else{
				run("Z Project...", "projection=[Max Intensity]");
				run("Properties...", "channels=1 slices=1 frames=1 unit=pixel pixel_width=1.0000 pixel_height=1.0000 voxel_depth=0 global");
			}
			save(myDir+origiMIP+".tif");
			close();
			
				if(exporttype=="1ch MIP")
			close();
		}
		
		if(exporttype=="3D tiff" || exporttype=="Both-MIP & 3Dtif"){
			save(myDirT+origiMIP+".tif");
			close();
		}
	}
}
///////////////////////////////////////////////////////////////
function autobradjustment(briadj){
	run("Duplicate...", "title=test.tif");
	run("Properties...", "channels=1 slices=1 frames=1 unit=px pixel_width=1 pixel_height=1 voxel_depth=1");
	getDimensions(width2, height2, channels, slices, frames);
	totalpix=width2*height2;
	
	desiredmean=briadj[0];
	setMinAndMax(0, 4095);
	run("Select All");
	run("Copy");
	
	setAutoThreshold("Triangle dark");
	getThreshold(lower, upper);
	setThreshold(lower, upper);
	
	//setOption("BlackBackground", true);
	run("Convert to Mask", "method=Triangle background=Dark black");
	run("8-bit");
	
	makeRectangle(11, height2-100, 69, 43);
	getStatistics(area, mean, min, max, std, histogram);
	
	if(mean>200){
		run("Invert LUT");
		run("RGB Color");
		run("8-bit");
	}
	
	run("Add Slice");
	
	setSlice(1);
	run("Create Selection");
	getStatistics(area, mean, min, max, std, histogram);
	if(mean<200){
		selectWindow("test.tif");
		run("Make Inverse");
	}
	getStatistics(area2, mean, min, max, std, histogram);
	print(area2/totalpix);
//////////////////////
	if(area2/totalpix>0.4){
		setSlice(1);
		run("Select All");
		run("Paste");
		setMinAndMax(0, 255);
		
		setAutoThreshold("Moments dark");
		getThreshold(lower, upper);
		setThreshold(lower, 255);
		
		run("Convert to Mask", "method=Moments background=Dark black");
//		setBatchMode(false);
//		updateDisplay();
//				a
		
		makeRectangle(11, height2-100, 69, 43);
		getStatistics(area, mean, min, max, std, histogram);
		
		if(mean>200){
			run("Invert LUT");
			run("RGB Color");
			run("8-bit");
		}
	
		run("Create Selection");
		getStatistics(area, mean, min, max, std, histogram);
		if(mean<200){
			selectWindow("test.tif");
			run("Make Inverse");
		}
	}//if(area/totalpix>0.3){
	

	mean=0; applyV=254; i=0;
//////roop	
	while(mean<=desiredmean){
		selectWindow("test.tif");
		setSlice(2);
		run("Paste");
		setMinAndMax(0, 4095);
		run("8-bit");
		
		setSlice(1);
		run("Create Selection");
		getStatistics(area, mean3, min, max, std, histogram);
		if(mean3<200){
			run("Make Inverse");
		}

		setSlice(2);
		
		if(applyV==254)
		getStatistics(area, mean, min, max, std, histogram);
		
		gap=desiredmean-mean;
		
		if(gap>6){
			applyV=applyV-6;
			
			if(gap>10)
			applyV=applyV-10;
			if(gap>30)
			applyV=applyV-30;
		}
		
		if(mean<=desiredmean){
			run("Brightness/Contrast...");
			setMinAndMax(0, applyV);
	//		print(applyV);
			run("Apply LUT", "slice");
			applyV=applyV-1;
		}
		getStatistics(area, mean, min, max, std, histogram);
		if(applyV<40)
		mean=desiredmean+1;
			
	//	print(mean+"gap; "+gap+"applyV; "+applyV);
		
	}//	while(mean<=desiredmean){
	
	selectWindow("test.tif");
	close();
	briadj[2]=applyV;
	
}

"done"
