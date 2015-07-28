//Hideo Otsuna (HHMI Janelia Research Campus), June 4, 2015

autothre=0;//1 is FIJI'S threshold
multiDSLT=1;// multi step DSLT for better sensitivity

setBatchMode(true);
compCC=0;// 1 is compressed nrrd, 0 is not compressed nrrd
keepsubst=0; // 1 is keeoing sub folder structures

dir = getDirectory("Choose a directory for aligned confocal files");

filepath0=getDirectory("temp");//C:\Users\??\AppData\Local\Temp\...C:\DOCUME~1\ADMINI~1\LOCALS~1\Temp\
filepath=filepath0+"MIP_batch.txt";

LF=10; TAB=9; swi=0; swi2=0; testline=0;
exi=File.exists(filepath);
List.clear();

exporttype="1ch MIP";
subfolderS=false;
colorcodingS=false;
CLAHES=false;
AutoBR=false;
blockposition=1;
totalblock=3;
blockON=false;
desiredmean=130;
savestring="Save in same folder";
CscaleON=true;
reveseStr=false;
startMIP=0;
endMIP=1000;
usingLUT="PsychedelicRainBow2";
manualST="Manual setting 1st time only";
lowerweight=0.7;
lowthreM="Peak Histogram";

if(exi==1){
	s1 = File.openAsRawString(filepath);
	swin=0;
	swi2n=-1;
	
	n = lengthOf(s1);
	String.resetBuffer;
	for (testnum=0; testnum<n; testnum++) {
		enter = charCodeAt(s1, testnum);
		
		if(enter==10)
			testline=testline+1;//line number
	}
	
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
		}else if(swi==1 && swi<=testline){
			subfolderS = String.buffer;
		}else if(swi==2 && swi<=testline){
			colorcodingS = String.buffer;
		}else if(swi==3 && swi<=testline){
			CLAHES = String.buffer;
		}else if(swi==4 && swi<=testline){
			AutoBR = String.buffer;
		}else if(swi==5 && swi<=testline){
			totalblock = String.buffer;
		}else if(swi==6 && swi<=testline){
			blockposition = String.buffer;
		}else if(swi==7 && swi<=testline){
			blockON = String.buffer;
		}else if(swi==8 && swi<=testline){
			desiredmean = String.buffer;
		}else if(swi==9 && swi<=testline){
			savestring = String.buffer;
		}else if(swi==10 && swi<=testline){
			CscaleON = String.buffer;
		}else if(swi==11 && swi<=testline){
			reveseStr = String.buffer;
		}else if(swi==12 && swi<=testline){
			startMIP = String.buffer;
		}else if(swi==13 && swi<=testline){
			endMIP = String.buffer;
		}else if(swi==14 && swi<=testline){
			usingLUT = String.buffer;
		}else if(swi==15 && swi<=testline){
			manualST = String.buffer;
		}else if(swi==16 && swi<=testline){
			lowerweight = String.buffer;
		}else if(swi==17 && swi<=testline){
			lowthreM = String.buffer;
		} //swi==0
	}
	File.saveString(exporttype+"\n"+subfolderS+"\n"+colorcodingS+"\n"+CLAHES+"\n"+AutoBR+"\n"+totalblock+"\n"+blockposition+"\n"+blockON+"\n"+desiredmean+"\n"+savestring+"\n"+CscaleON+"\n"+reveseStr+"\n"+startMIP+"\n"+endMIP+"\n"+usingLUT+"\n"+manualST+"\n"+lowerweight+"\n"+lowthreM, filepath);
}

Dialog.create("Batch processing of 3D files conversion");
//item0=newArray("1ch MIP", "2ch MIP", "3D tiff", "Both-MIP & 3Dtif");
//Dialog.addRadioButtonGroup("Export type", item0, 1, 4, exporttype); 
Dialog.addCheckbox("Include sub-folder", subfolderS);
Dialog.addCheckbox("Depth Color coding MIP", colorcodingS);
Dialog.addCheckbox("Automatic Brightness adjustment", AutoBR);
Dialog.addCheckbox("Enhance contrast CLAHE", CLAHES);
Dialog.addCheckbox("Block Mode", blockON);
Dialog.addCheckbox("Add color scale", CscaleON);
Dialog.addCheckbox("Reversed color", reveseStr);

item4=newArray("Manual setting 1st time only", "Automatic");
Dialog.addRadioButtonGroup("Channel discrimination method", item4, 1, 2, manualST); 
//Dialog.addCheckbox("LZW compression", JPGon);

item2=newArray("Save in same folder", "Choose directory");
Dialog.addRadioButtonGroup("Export place", item2, 1, 2, savestring); 

item3=newArray("PsychedelicRainBow2", "royal");
Dialog.addRadioButtonGroup("LUT type", item3, 1, 2, usingLUT); 

item5=newArray("Peak Histogram", "Auto-threshold");
Dialog.addRadioButtonGroup("Lower thresholding method", item5, 1, 2, lowthreM); 

Dialog.addNumber("Starting MIP slice", startMIP);
Dialog.addNumber("Ending MIP slice, larger number will be the last slice", endMIP);

Dialog.show();
//exporttype = Dialog.getRadioButton();
subfolder=Dialog.getCheckbox();
colorcoding=Dialog.getCheckbox();
AutoBRV=Dialog.getCheckbox();
CLAHE=Dialog.getCheckbox();
blockmode=Dialog.getCheckbox();
colorscale=Dialog.getCheckbox();
reverse0=Dialog.getCheckbox();

manualST= Dialog.getRadioButton();
savestring = Dialog.getRadioButton();
usingLUT = Dialog.getRadioButton();
lowthreM = Dialog.getRadioButton();
startMIP=Dialog.getNumber();
endMIP=Dialog.getNumber();

blockON=false;
dirCOLOR=0;

savemethod=0;
if(savestring=="Choose directory"){
	dirCOLOR= getDirectory("Choose a directory for Color MIP SAVE");
	savemethod=1;
}

manual=0;
if(manualST=="Manual setting 1st time only")
manual=1;



if(AutoBRV==1){
	Dialog.create("Desired mean value for Auto-Brightness");
	Dialog.addNumber("Desired mean value for Auto-Brightness /255", desiredmean);
	Dialog.addNumber("weight for lower thresholding 0.5-1.5", lowerweight);
	Dialog.show();
	desiredmean=Dialog.getNumber();
	lowerweight=Dialog.getNumber();
}

if(blockmode==1){
	Dialog.create("Block separation for file number");
	Dialog.addNumber("Handling block", blockposition, 0, 0, " /Total block"); //0
	Dialog.addNumber("Total block number 1-10", totalblock, 0, 0, ""); //0
	Dialog.show();
	
	blockposition=Dialog.getNumber();
	totalblock=Dialog.getNumber();

	list = getFileList(dir);
	Array.sort(list);
	
	blocksize=(list.length/totalblock);
	blocksize=round(blocksize);
	startn=blocksize*(blockposition-1);
	endn=startn+blocksize;
	
	if(blockposition==totalblock)
	endn=list.length;
	
	blockON=true;
}

if(AutoBRV==1)
print("Desired mean; "+desiredmean);

reveseStr=false;
if(reverse0==1)
reveseStr=true;

CscaleON=false;
if(colorscale==1)
CscaleON=true;

subfolderS=false;
if(subfolder==1)
subfolderS=true;

colorcodingS=false;
if(colorcoding==1)
colorcodingS=true;

CLAHES=false;
if(CLAHE==1)
CLAHES=true;

AutoBR=false;
if(AutoBRV==1)
AutoBR=true;

if(blockmode==0){
	list = getFileList(dir);
	Array.sort(list);
	startn=0;
	endn=list.length;	
}

File.saveString(exporttype+"\n"+subfolderS+"\n"+colorcodingS+"\n"+CLAHES+"\n"+AutoBR+"\n"+totalblock+"\n"+blockposition+"\n"+blockON+"\n"+desiredmean+"\n"+savestring+"\n"+CscaleON+"\n"+reveseStr+"\n"+startMIP+"\n"+endMIP+"\n"+usingLUT+"\n"+manualST+"\n"+lowerweight+"\n"+lowthreM, filepath);

myDir = 0; myDirT = 0; myDirCLAHE = 0; myDir2Co = 0;
//if(exporttype=="3D tiff" || exporttype=="Both-MIP & 3Dtif"){
//	myDirT = dir+File.separator+"TIFF_Files"+File.separator;
//	File.makeDirectory(myDirT);
//}

firsttime=0;
firsttime1ch=0;
nc82=0;
neuronimg=0;
myDir2=0;
myDirCLAHE=0;
myDir2Co=0;
myDir=0;
numberGap=endn-startn+1;
Circulicity=newArray(numberGap);
Roundness=newArray(numberGap);
ratio=newArray(numberGap);
AR=newArray(numberGap);
areasizeM=newArray(numberGap);
perimLM=newArray(numberGap);
defaultNoCH=0;

for (i=startn; i<endn; i++){
	arrayi=i-startn;
	progress=i/endn;
	showProgress(progress);
	path = dir+list[i];
	
	mipbatch=newArray(list[i], path, 1, dirCOLOR, endn, i, dir, startn, firsttime, firsttime1ch,AutoBRV,colorcoding,desiredmean,savemethod,CLAHE,neuronimg,nc82,myDir2,myDirCLAHE,myDir2Co,myDir,usingLUT,Circulicity[arrayi],Roundness[arrayi],ratio[arrayi],AR[arrayi],lowerweight,lowthreM,manual,0,0,0,defaultNoCH);
	
	if (endsWith(list[i], "/")){//if "/"
		if(subfolder==1){
			
			if(keepsubst==1){
				myDir0 = dirCOLOR+File.separator+list[i];
				File.makeDirectory(myDir0);
				dirCOLOR=myDir0;
			}
			
			print(subfolder);
			listsub = getFileList(dir+list[i]);
			Array.sort(listsub);
			for (ii=0; ii<listsub.length; ii++){
				path2 = path+listsub[ii];
				
				if (endsWith(listsub[ii], "/")){//if "/"
					listsub2 = getFileList(path2);
					Array.sort(listsub2);
					
					for (iii=0; iii<listsub2.length; iii++){
						path3 = path2+listsub2[iii];
						
						if (endsWith(listsub2[iii], "/")){//if "/"
							listsub3 = getFileList(path3);
							Array.sort(listsub3);
							
							for (iiii=0; iiii<listsub3.length; iiii++){
								path4 = path3+listsub3[iiii];
								
								if (endsWith(listsub3[iiii], "/")){//if "/"
									listsub4 = getFileList(path4);
									Array.sort(listsub4);
									
									for (iiiii=0; iiiii<listsub4.length; iiiii++){
										path5 = path4+listsub4[iiiii];
										mipbatch=newArray(listsub4[iiiii], path5, 1, dirCOLOR, endn, i, dir, startn, firsttime,firsttime1ch,AutoBRV,colorcoding,desiredmean,savemethod,CLAHE,neuronimg,nc82,myDir2,myDirCLAHE,myDir2Co,myDir,usingLUT,Circulicity[arrayi],Roundness[arrayi],ratio[arrayi], AR[arrayi],lowerweight,lowthreM,manual,0,0,0,defaultNoCH);
										mipfunction(mipbatch);
										firsttime=mipbatch[8];
										firsttime1ch=mipbatch[9];
										neuronimg=mipbatch[15];
										nc82=mipbatch[16];
										myDir2=mipbatch[17];
										myDirCLAHE=mipbatch[18];
										myDir2Co=mipbatch[19];
										myDir=mipbatch[20];
										Circulicity[arrayi]=mipbatch[22];
										Roundness[arrayi]=mipbatch[23];
										ratio[arrayi]=mipbatch[24];
										AR[arrayi]=mipbatch[25];
										areasizeM[arrayi]=mipbatch[29];
										perimLM[arrayi]=mipbatch[30];
										defaultNoCH=mipbatch[31];
										
									}
								}//	if (endsWith(listsub3[iiii], "/"))
				
								mipbatch=newArray(listsub3[iiii], path4, 1, dirCOLOR, endn, i, dir, startn, firsttime, firsttime1ch,AutoBRV,colorcoding,desiredmean,savemethod,CLAHE,neuronimg,nc82,myDir2,myDirCLAHE,myDir2Co,myDir,usingLUT,Circulicity[arrayi],Roundness[arrayi],ratio[arrayi],AR[arrayi],lowerweight,lowthreM,manual,0,0,0,defaultNoCH);
								mipfunction(mipbatch);
								firsttime=mipbatch[8];
								firsttime1ch=mipbatch[9];
								neuronimg=mipbatch[15];
								nc82=mipbatch[16];
								myDir2=mipbatch[17];
								myDirCLAHE=mipbatch[18];
								myDir2Co=mipbatch[19];
								myDir=mipbatch[20];
								Circulicity[arrayi]=mipbatch[22];
								Roundness[arrayi]=mipbatch[23];
								ratio[arrayi]=mipbatch[24];
								AR[arrayi]=mipbatch[25];
								areasizeM[arrayi]=mipbatch[29];
								perimLM[arrayi]=mipbatch[30];
								defaultNoCH=mipbatch[31];
								
							}
						}//if (endsWith(listsub2[iii], "/")
				
						mipbatch=newArray(listsub2[iii], path3, 1, dirCOLOR, endn, i, dir, startn, firsttime, firsttime1ch, AutoBRV, colorcoding, desiredmean, savemethod, CLAHE, neuronimg, nc82,myDir2,myDirCLAHE,myDir2Co, myDir, usingLUT,Circulicity[arrayi],Roundness[arrayi],ratio[arrayi],AR[arrayi],lowerweight,lowthreM,manual,0,0,0,defaultNoCH);
						mipfunction(mipbatch);
						firsttime=mipbatch[8];
						firsttime1ch=mipbatch[9];
						neuronimg=mipbatch[15];
						nc82=mipbatch[16];
						myDir2=mipbatch[17];
						myDirCLAHE=mipbatch[18];
						myDir2Co=mipbatch[19];
						myDir=mipbatch[20];
						Circulicity[arrayi]=mipbatch[22];
						Roundness[arrayi]=mipbatch[23];
						ratio[arrayi]=mipbatch[24];
						AR[arrayi]=mipbatch[25];
						areasizeM[arrayi]=mipbatch[29];
						perimLM[arrayi]=mipbatch[30];
						defaultNoCH=mipbatch[31];
					}//for (iii=0; iii<listsub2.length; iii++)
				}//if (endsWith(listsub[ii], "/"))
				mipbatch=newArray(listsub[ii], path2, 1, dirCOLOR, endn, i, dir, startn, firsttime, firsttime1ch, AutoBRV, colorcoding, desiredmean, savemethod, CLAHE, neuronimg, nc82,myDir2,myDirCLAHE,myDir2Co, myDir, usingLUT,Circulicity,Roundness[arrayi],ratio[arrayi],AR[arrayi],lowerweight,lowthreM,manual,0,0,0,defaultNoCH);
				mipfunction(mipbatch);
				firsttime=mipbatch[8];
				firsttime1ch=mipbatch[9];
				neuronimg=mipbatch[15];
				nc82=mipbatch[16];
				myDir2=mipbatch[17];
				myDirCLAHE=mipbatch[18];
				myDir2Co=mipbatch[19];
				myDir=mipbatch[20];
				Circulicity[arrayi]=mipbatch[22];
				Roundness[arrayi]=mipbatch[23];
				ratio[arrayi]=mipbatch[24];
				AR[arrayi]=mipbatch[25];
				areasizeM[arrayi]=mipbatch[29];
				perimLM[arrayi]=mipbatch[30];
				defaultNoCH=mipbatch[31];
			}//for (ii=0; ii<listsub.length; ii++){
		
		}//if(subfolder==1){
	}else{//	if (endsWith(list[i], "/")){
		mipfunction(mipbatch);
		firsttime=mipbatch[8];
		firsttime1ch=mipbatch[9];
		neuronimg=mipbatch[15];
		nc82=mipbatch[16];
		myDir2=mipbatch[17];
		myDirCLAHE=mipbatch[18];
		myDir2Co=mipbatch[19];
		myDir=mipbatch[20];
		Circulicity[arrayi]=mipbatch[22];
		Roundness[arrayi]=mipbatch[23];
		ratio[arrayi]=mipbatch[24];
		AR[arrayi]=mipbatch[25];
		areasizeM[arrayi]=mipbatch[29];
		perimLM[arrayi]=mipbatch[30];
		defaultNoCH=mipbatch[31];

	//	print("AR"+AR[arrayi]+"arrayi; "+arrayi);
	}
	if(nImages>0){
	//	print("Image"+nImages);
		for(ni=1; ni<=nImages; ni++){
			close();
		}
	}
}//for (i=startn; i<endn; i++){

resultnum=nResults();
IJ.deleteRows(1, resultnum);

for(resultNum=0; resultNum<endn-startn; resultNum++){
	setResult("Circulicity", resultNum, Circulicity[resultNum]);
	setResult("Roundness", resultNum, Roundness[resultNum]);
	setResult("ratio(perim/size)", resultNum, ratio[resultNum]);
	setResult("AR", resultNum, AR[resultNum]);
	setResult("Size", resultNum, areasizeM[resultNum]);
	setResult("Perim", resultNum, perimLM[resultNum]);
}

/////////Function//////////////////////////////////////////////////////////////////
function mipfunction(mipbatch) { 
	listP=mipbatch[0];
	path=mipbatch[1];
	
	dirCOLOR=mipbatch[3];
	endn=mipbatch[4];
	i=mipbatch[5];
	dir=mipbatch[6];
	startn=mipbatch[7];
	firsttime=mipbatch[8];
	firsttime1ch=mipbatch[9];
	AutoBRV=mipbatch[10];
	colorcoding=mipbatch[11];
	desiredmean=mipbatch[12];
	savemethod=mipbatch[13];
	CLAHE=mipbatch[14];
	neuronimg=mipbatch[15];
	nc82=mipbatch[16];
	myDir2=mipbatch[17];
	myDirCLAHE=mipbatch[18];
	myDir2Co=mipbatch[19];
	myDir=mipbatch[20];
	usingLUT=mipbatch[21];
	Circulicity=mipbatch[22];
	Roundness=mipbatch[23];
	ratio=mipbatch[24];
	AR=mipbatch[25];
	lowerweight=mipbatch[26];
	lowthreM=mipbatch[27];
	manual=mipbatch[28];
	areasizeM=mipbatch[29];
	perimLM=mipbatch[30];
	defaultNoCH=mipbatch[31];
	dotIndex = -1;
	dotIndexAM = -1;
	dotIndextif = -1;
	dotIndexTIFF = -1;
	dotIndexLSM = -1;
	dotIndexV3 = -1;
	dotIndexMha= -1;
	dotIndexzip= -1;
	dotIndexVNC =-1;
	files=files+1;
	
	dotIndexMha = lastIndexOf(listP, "mha");
	dotIndexV3 = lastIndexOf(listP, "v3dpbd");
//	dotIndexLSM = lastIndexOf(listP, "lsm");
	dotIndex = lastIndexOf(listP, "nrrd");
	dotIndexAM = lastIndexOf(listP, "am");
	dotIndextif = lastIndexOf(listP, "tif");
	dotIndexTIFF = lastIndexOf(listP, "TIFF");
	dotIndexzip = lastIndexOf(listP, "zip");
	dotIndexVNC = lastIndexOf(listP, "v_");
	
	listsave=getFileList(dirCOLOR);
	filepathcolor=0;
	for(save0=0; save0<listsave.length; save0++){
		
		namelist=listsave[save0];
		nnamelist = lengthOf(namelist);
		
		dotposition=lastIndexOf(listP, ".");
		purenameOri=substring(listP, 0, dotposition);
		lengthNameOri = lengthOf(purenameOri);
		
		if(lengthNameOri<nnamelist)
		namelist = substring(namelist, 0, lengthNameOri); // remove extension
		
	//	print("purenameOri; "+purenameOri+"_namelist; "+namelist);
		
		if(namelist==purenameOri){
			filepathcolor=1;
			save0=listsave.length;
		}
	}
	
	if(filepathcolor==1 || dotIndextif==-1 && dotIndexzip== -1 && dotIndexTIFF==-1 && dotIndex==-1 && dotIndexAM==-1 && dotIndexLSM==-1 && dotIndexMha==-1 && dotIndexVNC==-1){
		print("Skipped; "+i+"; 	 "+listP);
	}else{
		
		if(compCC==0){// if not compressed
			if(dotIndex>-1 || dotIndexAM>-1){
				run("Bio-Formats Importer", "open="+path+" autoscale color_mode=Default view=[Standard ImageJ] stack_order=Default");
			}
		}
		if(dotIndexVNC>-1 || dotIndextif>-1 || dotIndexTIFF>-1 || compCC==1 || dotIndexLSM>-1 || dotIndexV3>-1 || dotIndexMha>-1 || dotIndexzip>-1){
			open(path);// for tif, comp nrrd, lsm", am, v3dpbd, mha
		}
		print(listP+"	 ;	 "+i+" / "+endn);
		//		run("Close", "Exception");
		bitd=bitDepth();
		totalslice=nSlices();
		origi=getTitle();
		getDimensions(width, height, channels, slices, frames);

		dotIndex = lastIndexOf(origi, ".");
		if (dotIndex!=-1);
		origiMIP = substring(origi, 0, dotIndex); // remove extension
		
		if(channels==2 || channels==3 ){
			if(defaultNoCH!=channels){
				channels=0;
				AutoBRV=0;
				colorcoding=0;
				close();
				print("Ch number different skipped; "+i+"; 	 "+listP);
			}
		}
		
		if(channels==2 || channels==3 ){
			if(firsttime==1 || firsttime==2 || firsttime==3){
				defaultNoCH=channels;
				run("Split Channels");
			}
		
			if(firsttime==0){//creating directory
				firsttime=1;
	//			if(CLAHE==0){
	//				if(savemethod==1)
	//				myDir2 = dirCOLOR;
					
	//				if(savemethod==1){
	//					myDir2 = dir+File.separator+"2ch_MIP_Files"+File.separator;
	//					File.makeDirectory(myDir2);
	//				}
	//			}//if(CLAHE==0){
				
//				if(CLAHE==1){
//					if(savemethod==1)
	//				myDirCLAHE = dirCOLOR;
					
	//				if(AutoBRV==1){
	//					if(savemethod==0)
	//					myDirCLAHE = dir+File.separator+"2ch_CLAHE_MIP_"+desiredmean+"_mean_adjusted"+File.separator;
	//				}//if(AutoBRV==1){
					
	//				if(AutoBRV==0){
	//					if(savemethod==0)
	//					myDirCLAHE = dir+File.separator+"2ch_CLAHE_MIP"+File.separator;
	//				}//if(AutoBRV==0){
	//				if(savemethod==0)
	//				File.makeDirectory(myDirCLAHE);
	//			}//if(CLAHE==1){
				
				if(colorcoding==1){
					if(savemethod==1)
					myDir2Co = dirCOLOR;
					
					if(AutoBRV==1){
						if(savemethod==0)
						myDir2Co = dir+File.separator+"Color_Depth_MIP_"+desiredmean+"_mean_adjusted"+File.separator;
					}//if(AutoBRV==1){
					
					if(AutoBRV==0){
						if(savemethod==0)
						myDir2Co = dir+File.separator+"Color_Depth_MIP"+File.separator;
					}//if(AutoBRV==0){
					
					if(savemethod==0)
					File.makeDirectory(myDir2Co);
				}//if(colorcoding==1){

				if(manual==1){
					setBatchMode(false);
					updateDisplay();
					run("Split Channels");
					if(channels==2)
					waitForUser("Choose neuron channel on Top, nc82 window for bottom");
				
					if(channels==3)
					waitForUser("Choose neuron channel on Top, nc82 window for 2nd, the other is bottom");
				
					neuronimg=getTitle();
				
					setBatchMode(true);
					if(channels==2){
						if(neuronimg=="C1-"+origi){
							neuronimg="C1-";
							nc82="C2-";
						}else if(neuronimg=="C2-"+origi){
							neuronimg="C2-";
							nc82="C1-";
						}//if(neuronimg=="C2-"+origi){
					}else if(channels==3){
						if(neuronimg=="C1-"+origi){
						neuronimg="C1-";
						run("Put Behind [tab]");
						notneed=getTitle();
						if(notneed=="C2-"+origi){
							notneedST="C2-";
							nc82="C3-";
						}else{
							notneedST="C3-";
							nc82="C2-";
						}
					}else if(neuronimg=="C2-"+origi){
						neuronimg="C2-";
						run("Put Behind [tab]");
						notneed=getTitle();
						if(notneed=="C1-"+origi){
							notneedST="C1-";
							nc82="C3-";
						}else{
							notneedST="C3-";
							nc82="C1-";
						}
					}else if(neuronimg=="C3-"+origi){
						neuronimg="C3-";
						run("Put Behind [tab]");
						notneed=getTitle();
						if(notneed=="C1-"+origi){
							notneedST="C1-";
							nc82="C2-";
						}else{
							notneedST="C2-";
							nc82="C1-";
						}
					}//if(neuronimg=="C1-"+origi){
					}//if(channels==2){
				}//if(manual==1){

			}//if(firsttime==0){//creating directory
			
			
////Automatic nc82 discrimination & close the nc82 /////////////////////////////////
			if(manual==0){
				if(firsttime==1){
					run("Split Channels");
					firsttime=2;
				}
				
				run("Set Measurements...", "area centroid perimeter shape redirect=None decimal=2");
				
				sumCh=newArray(channels);
				
		//		for(imageN=0; imageN<channels; imageN++){
		//			Ch[imageN]=getTitle();
		//			run("Put Behind [tab]");
		//			print(Ch[imageN]);
		//		}
				Ch=getList("image.titles");
	
				for(iamgen=0; iamgen<channels; iamgen++){
					
					selectWindow(Ch[iamgen]);
				//	print(Ch[iamgen]);
					
					run("Z Project...", "start=1 stop="+nSlices+" projection=[Max Intensity]");
					run("8-bit");
					maxP=getTitle();
					
					//run("Histogram thresholding", "z-attenuation=1 how=2");
					setAutoThreshold("Intermodes dark");
				//	setAutoThreshold("Huang dark");
					setThreshold(0, 255);
					//Histval=getTitle();
					//Histval=round(Histval);
					
					getThreshold(lower, upper);
					setThreshold(lower, upper);
					
					setOption("BlackBackground", true);
					run("Convert to Mask");
				
					run("Make Binary");
					run("Analyze Particles...", "size=100.00-Infinity circularity=0.00-1.00 show=Nothing display clear");
					maxsize=0; maxperim=0;
					
					for(getresult=0; getresult<nResults; getresult++){
						areasize=getResult("Area", getresult);
						perimL=getResult("Perim.", getresult);
						
						if(areasize>=maxsize){
							maxsize=areasize;
							maxperim=perimL;
							Circulicity=getResult("Circ.", getresult);
							Roundness=getResult("Round", getresult);
							AR=getResult("AR", getresult);
							areasizeM=getResult("Area", getresult);
							perimLM=getResult("Perim.", getresult);
						//	print("AR; "+AR);
						}
					}
					
					run("Analyze Particles...", "size="+maxsize-1+"-Infinity circularity=0.00-1.00 show=Masks display clear");
					
					masknc82=getImageID();// opened images are original stack, "sumCh"+iamgen, masknc82
					masknc82title=getTitle();
					run("RGB Color");
					run("8-bit");

					//creation of rectangle = background measure
					makeRectangle(0, 2, 100, 100);
					getStatistics(area, mean, min, max, std, histogram);
					
					if(mean>200){//convert to 16bit mask
						run("Invert LUT");
						run("RGB Color");
						run("8-bit");
						run("16-bit");
						run("Select All");
						run("Mask255 to 4095");
					}else{
						run("Select All");
						run("16-bit");
						run("Mask255 to 4095");
					}
					
					selectImage(maxP);
					close();
					
					selectWindow(Ch[iamgen]);
					run("Z Project...", "start=1 stop="+nSlices+" projection=[Sum Slices]");
					
					run("16-bit");
					sumP=getImageID();
					
					imageCalculator("AND create", "SUM_"+Ch[iamgen]+"", ""+masknc82title+"");//AND operation, then measure signal amount only mask region//////////////
					getStatistics(area, amount, min, max, std, histogram);//	Amount of signal, larger is nc82
					close();//
					
					ratio=maxperim/maxsize;// smaller is nc82
					
					List.set("ImageSize"+iamgen, maxsize);
					List.set("ratio"+iamgen, ratio);
					List.set("Amount"+iamgen, amount);	//counting only signal region, not count background
					List.set("Circulicity"+iamgen, Circulicity);
					
					selectImage(masknc82);
					close();
					
					selectImage(sumP);
					close();
					
					ChRest=getList("image.titles");
					restNo=0;
					while(nImages>channels){
						selectWindow(ChRest[restNo]);
						sampleslice=nSlices();
						if(sampleslice==1)
						close();
						
						restNo=restNo+1;
					}
					
					print(iamgen+";  maxsize; "+maxsize+"  ratio; "+ratio+"  amount; "+amount+"  Circulicity; "+Circulicity);
				}//for(iamgen=0; iamgen<channels; iamgen++){
				
				defaultM=100; defaultsize=0; defaultamout=0; defaultcirc=0; amountgap=0; sizegap=0;
				
				for(chnum0=0; chnum0<channels; chnum0++){
					ratiocomp=List.get("ratio"+chnum0);
					sizecomp=List.get("ImageSize"+chnum0);
					sizecomp=round(sizecomp);
					amountcomp=List.get("Amount"+chnum0);
					amountcomp=round(amountcomp);
					
					CirculicityComp=List.get("Circulicity"+chnum0);
					
					if(ratiocomp<defaultM){//smallest ratio is nc82
						defaultM=ratiocomp;
						nc82Ratio=chnum0;
					}
					if(sizecomp > defaultsize){//highest number= nc82
						if(defaultsize!=0)
						sizegap=sizecomp/defaultsize;
						
						defaultsize=sizecomp;
						nc82Size=chnum0;
					}
					if(amountcomp>defaultamout){//highest number= nc82
						if(defaultamout!=0)
						amountgap=amountcomp/defaultamout;
						
						defaultamout=amountcomp;
						nc82Amount=chnum0;
					}
					if(CirculicityComp>defaultcirc){//highest number= nc82
						defaultcirc=CirculicityComp;
						nc82Circu=chnum0;
					}
				}//for(chnum0=0; chnum0<channels; chnum0++){
				print("nc82Amount; "+nc82Amount+"  nc82Size; "+nc82Size+"  nc82Ratio; "+nc82Ratio+"	  nc82Circu; "+nc82Circu);
				
				nc82Real=1000;
				
				if(nc82Amount==nc82Size && nc82Ratio==nc82Size && nc82Amount==nc82Ratio && nc82Circu==nc82Ratio && nc82Circu==nc82Amount){
					nc82Real=nc82Amount;
				}else{
					
					if(nc82Circu==nc82Ratio)
					nc82Real=nc82Circu;
					
					else if(nc82Amount==nc82Size)
					nc82Real=nc82Amount;
				
					else if(nc82Ratio==nc82Size)
					nc82Real=nc82Ratio;
				
					else if(nc82Amount==nc82Ratio)
					nc82Real=nc82Amount;
				}
				if(defaultcirc<0.1){//Circulicity thresholding
					if(nc82Circu!=nc82Real)
					nc82Real=nc82Circu;
					
					if(nc82Amount==nc82Size && nc82Ratio==nc82Size && nc82Amount==nc82Ratio)
					nc82Real=nc82Amount;
					
					if(sizegap>10)//if size difference is more than 10 time, bigger is nc82
					nc82Real=nc82Size;
					
				}
				
				if(nc82Real==1000){
					print("Could not detect nc82, just will close 1 image")
					nc82Real=0;
				}
				
				selectWindow(Ch[nc82Real]);//nc82
				close();
				
				if(channels==2)
				neuronCH=getTitle();
				
			//	setBatchMode(false);
			//	updateDisplay();
			//	a
				if(channels==3){//if 3 channels, will MIP only 1 channel
					if(firsttime=1 || firsttime==2){
						firsttime==3;
						waitForUser("Choose neuron channel on Top, the other is to bottom");
					
						neuronimg=getTitle();
					
						if(neuronimg=="C1-"+origi){
							neuronimg="C1-";
							run("Put Behind [tab]");
							notneed=getTitle();
							if(notneed=="C2-"+origi){
								notneedST="C2-";
							}else{
								notneedST="C3-";
							}
						}else if(neuronimg=="C2-"+origi){
							neuronimg="C2-";
							run("Put Behind [tab]");
							notneed=getTitle();
							if(notneed=="C1-"+origi){
								notneedST="C1-";
							}else{
								notneedST="C3-";
							}
						}else if(neuronimg=="C3-"+origi){
							neuronimg="C3-";
							run("Put Behind [tab]");
							notneed=getTitle();
							if(notneed=="C1-"+origi){
								notneedST="C1-";
							}else{
								notneedST="C2-";
							}
						}//if(neuronimg=="C1-"+origi){
					}
					
					neuronCH=neuronimg+origi;
					
					selectWindow(notneedST+origi);//not need
					close();
				}//	if(channels==3){
			}//if(manual==0){
			
//////manual == 1, manual channel discrimination///////////////	
			if(manual==1){
				neuronCH=neuronimg+origi;
				
				selectWindow(nc82+origi);//Red nc82
				close();
				
				if(channels==3){
					selectWindow(notneedST+origi);//not need
					close();
				}
				
				run("Z Project...", "start=1 stop="+nSlices+" projection=[Average Intensity]");
				run("8-bit");
				maxP=getTitle();
				
				//setAutoThreshold("Huang dark");
				setAutoThreshold("Intermodes dark");
				
				getThreshold(lower, upper);
				setThreshold(lower, upper);
				
				setOption("BlackBackground", true);
				run("Convert to Mask");
				
				run("Make Binary");
				run("Analyze Particles...", "size=100.00-Infinity circularity=0.00-1.00 show=Nothing display clear");
				maxsize=0; maxperim=0;
				updateResults();
				for(getresult=0; getresult<nResults; getresult++){
					areasize=getResult("Area", getresult);
					perimL=getResult("Perim.", getresult);
	//				print("perimL; "+perimL);
					
					if(areasize>=maxsize){
						maxsize=areasize;
						maxperim=perimL;
						Circulicity=getResult("Circ.", getresult);
						Roundness=getResult("Round", getresult);
						AR=getResult("AR", getresult);
						areasizeM=getResult("Area", getresult);
						perimLM=getResult("Perim.", getresult);
				//		print("AR; "+AR);
					}
				}
			}//	if(manual==1){
			
		//	print("901AR; "+AR);
			
	//		run("Z Project...", "projection=[Max Intensity]");
	//		if(bitd==16)
	//		setMinAndMax(0, 4095);
			
	//		selectWindow(nc82+origi);
			
				selectWindow(neuronCH);//Green signal
		}//if(channels==2 || channels==3 ){
			
		if(channels==1){
			if(colorcoding==1){//create directory
				if(savemethod==1)
				myDir2Co = dirCOLOR;
					
				if(savemethod==0){
					myDir2Co = dir+File.separator+"1ch_Color_Depth_MIP"+desiredmean+"_mean_adjusted"+File.separator;
					if(firsttime1ch==0){
						File.makeDirectory(myDir2Co);
						firsttime1ch=1;
					}
				}
			}//if(colorcoding==1){
			selectWindow(origi);
		}//if(channels==1){
		
		if(channels!=0)
		basicoperation(bitd);//rename MIP.tif
			
		if(AutoBRV==1){//to get brightness value from MIP
				selectWindow("MIP.tif");
				briadj=newArray(desiredmean, 0, 0, 0,lowerweight,lowthreM);
				autobradjustment(briadj);
				applyV=briadj[2];
				sigsize=briadj[1];
				sigsizethre=briadj[3];
				sigsizethre=round(sigsizethre);
				sigsize=round(sigsize);
			

				
		//		if(bitd==8){
		//			if(applyV<255){
		//				setMinAndMax(0, applyV);
		//				run("Apply LUT");
		//			}
		//		}
		//		if(bitd==16){
		//			if(applyV<4095)
		//			setMinAndMax(0, applyV);
		//			run("8-bit");
	//			}//if(bitd==16){
			}//	if(AutoBRV==1){
			
	//		selectWindow("MAX_"+neuronCH);
			
	//		if(CLAHE==1){
	//			run("Enhance Local Contrast (CLAHE)", "blocksize=127 histogram=256 maximum=1.5 mask=*None*");
	//		}

	//		run("Merge Channels...", "c1=MAX_"+nc82+origi+" c2=MAX_"+neuronCH+" c3=MAX_"+nc82+origi+"");
	//		selectWindow("RGB");
	//		if(CLAHE==1)
	//		save(myDirCLAHE+origiMIP+"_"+applyV+"_s"+sigsize+".tif");
			
	//		if(CLAHE==0)
	//		save(myDir2+origiMIP+"_"+applyV+"_s"+sigsize+".tif");
			
	//		close();//RGB MIP
			
		if(colorcoding==1){
			
			if(channels==1)
			selectWindow(origi);
			
			if(channels==2 || channels==3 )
			selectWindow(neuronCH);
			
			if(AutoBRV==1)
			brightnessapply(applyV, bitd);
				
			if(reverse0==1)
			run("Reverse");
				
			if(usingLUT=="royal")
			stackconcatinate();
				
			TimeLapseColorCoder(slices, applyV, width, AutoBRV, bitd, CLAHE, colorscale, reverse0, colorcoding, usingLUT);
				
			save(myDir2Co+origiMIP+"_"+applyV+"_DSLT"+sigsize+"_thre"+sigsizethre+".tif");
				
			close();
			
			if(channels==1)
			selectWindow(origi);
			
			if(channels==2 || channels==3 )
			selectWindow(neuronCH);
			close();
		}//if(colorcoding==1){
		run("Close All");


		mipbatch[8]=firsttime;
		mipbatch[9]=firsttime1ch;
		mipbatch[15]=neuronimg;
		mipbatch[16]=nc82;
		
		mipbatch[17]=myDir2;
		mipbatch[18]=myDirCLAHE;
		mipbatch[19]=myDir2Co;
		mipbatch[20]=myDir;
		
		mipbatch[22]=Circulicity;
		mipbatch[23]=Roundness;
		mipbatch[24]=ratio;
		mipbatch[25]=AR;
		mipbatch[29]=areasizeM;
		mipbatch[30]=perimLM;
		mipbatch[31]=defaultNoCH;

	}//if(dotIndextif==-1 && dotI
} //function mipfunction(mipbatch) { 
///////////////////////////////////////////////////////////////
function autobradjustment(briadj){

	lowerweight=briadj[4];
	lowthreM=briadj[5];
	if(autothre==1)//Fiji Original thresholding
	run("Duplicate...", "title=test.tif");
	
	bitd=bitDepth();
	run("Properties...", "channels=1 slices=1 frames=1 unit=px pixel_width=1 pixel_height=1 voxel_depth=1");
	getDimensions(width2, height2, channels, slices, frames);
	totalpix=width2*height2;
	
	desiredmean=briadj[0];
	run("Select All");
	if(bitd==8){
		run("Copy");
	}
	
	if(bitd==16){
		setMinAndMax(0, 4095);
		run("Copy");
	}
	/////////////////////signal size measurement/////////////////////
	selectWindow("MIP.tif");
	
	run("Duplicate...", "title=test2.tif");
	setAutoThreshold("Triangle dark");
	getThreshold(lower, upper);
	setThreshold(lower, 255);
	
	run("Convert to Mask", "method=Triangle background=Dark black");
	
	selectWindow("test2.tif");
	
	if(bitd==16)
	run("8-bit");
	
	run("Create Selection");
	getStatistics(areathre, mean, min, max, std, histogram);
	if(areathre!=totalpix){
		if(mean<200){
		selectWindow("test2.tif");
		run("Make Inverse");
		}
	}
	getStatistics(areathre, mean, min, max, std, histogram);
	close();//test2.tif
	
	
	if(areathre/totalpix>0.4){

		selectWindow("MIP.tif");
		
		run("Duplicate...", "title=test2.tif");
		setAutoThreshold("Moments dark");
		getThreshold(lower, upper);
		setThreshold(lower, 255);
		
		run("Convert to Mask", "method=Moments background=Dark black");
		
		selectWindow("test2.tif");
		
		if(bitd==16)
		run("8-bit");
		
		run("Create Selection");
		getStatistics(areathre, mean, min, max, std, histogram);
		if(areathre!=totalpix){
			if(mean<200){
				selectWindow("test2.tif");
				run("Make Inverse");
			}
		}
		getStatistics(areathre, mean, min, max, std, histogram);
		close();//test2.tif
		
	}//if(area/totalpix>0.4){
	
	/////////////////////Fin signal size measurement/////////////////////
	
	selectWindow("MIP.tif");
	if(autothre==1){//Fiji Original thresholding
		setAutoThreshold("Triangle dark");
		getThreshold(lower, upper);
		setThreshold(lower, 255);
	
		run("Convert to Mask", "method=Triangle background=Dark black");
		run("16-bit");
		run("Mask255 to 4095");
		
		makeRectangle(11, height2-100, 69, 43);
		getStatistics(area, mean, min, max, std, histogram);
		
		if(mean>200){
			run("Invert LUT");
			run("RGB Color");
			run("16-bit");
			run("Mask255 to 4095");
		}
		rename("test.tif");
	}//if(autothre==1){//Fiji Original thresholding
	
	dsltarray=newArray(autothre, bitd, totalpix, desiredmean, 0);
	DSLTfun(dsltarray);
	desiredmean=dsltarray[3];
	area2=dsltarray[4];
	//////////////////////
	if(autothre==1){//Fiji Original thresholding
		if(area2/totalpix>0.4){
			selectWindow("test.tif");
			setSlice(1);
			run("Select All");
			run("Paste");
			
			if(bitd==16)
			setMinAndMax(0, 4095);
			
			setAutoThreshold("Moments dark");
			getThreshold(lower, upper);
			if(bitd==8)
			setThreshold(lower, 255);
			
			if(bitd==16)
			setThreshold(lower, 4095);
			
			run("Convert to Mask", "method=Moments background=Dark black");
	//		setBatchMode(false);
	//		updateDisplay();
			//				a
			if(bitd==16)
			run("8-bit");
			
			makeRectangle(11, height2-100, 69, 43);
			getStatistics(area, mean, min, max, std, histogram);
			
			if(mean>200){
				run("Invert LUT");
			}
		
			getStatistics(area, mean, min, max, std, histogram);
			if(area!=totalpix){
				if(mean<250)
				run("Make Inverse");
			}
		}//if(area/totalpix>0.3){
	}//	if(autothre==1){//Fiji Original thresholding
	
	selectWindow("MIP.tif");//MIP

	run("Mask Brightness Measure", "mask=test.tif data=MIP.tif desired="+desiredmean+"");

	
	applyvv=newArray(1);
	applyVcalculation(applyvv);
	applyV=applyvv[0];
	
	rename("MIP.tif");//MIP
	
	selectWindow("test.tif");//new window from DSLT
	close();
	/////////////////2nd time DSLT for picking up dimmer neurons/////////////////////

	
	if(applyV>50 && applyV<220 && bitd==8){
		applyVpre=applyV;
		selectWindow("MIP.tif");
		
		setMinAndMax(0, applyV);

			run("Duplicate...", "title=MIPtest.tif");
					
		setMinAndMax(0, applyV);
		run("Apply LUT");
		maxcounts=0;
		getHistogram(values, counts,  256);
		for(i=0; i<100; i++){
			Val=counts[i];
					
			if(Val>maxcounts){
					maxcounts=counts[i];
				maxi=i;
			}
		}
					
		changelower=maxi*lowerweight;
		if(changelower<1)
		changelower=1;
		
		selectWindow("MIPtest.tif");
		close();
					
		selectWindow("MIP.tif");
		setMinAndMax(0, applyV);
		run("Apply LUT");
					
		setMinAndMax(changelower, 255);
		run("Apply LUT");
		
		print("Double DSLT");
	//	run("Multibit thresholdtwo", "w/b=Set_black max=207 in=[In macro]");
		
		desiredmean=230;//230 for GMR
		
		dsltarray=newArray(autothre, bitd, totalpix, desiredmean, 0);
		DSLTfun(dsltarray);//will generate test.tif DSLT thresholded mask
		desiredmean=dsltarray[3];
		area2=dsltarray[4];
	
		selectWindow("MIP.tif");//MIP
	
		run("Mask Brightness Measure", "mask=test.tif data=MIP.tif desired="+desiredmean+"");
		
		applyvv=newArray(1);
		applyVcalculation(applyvv);
		applyV=applyvv[0];
		
		if(applyVpre<applyV){
			applyV=applyVpre;
			print("previous applyV is brighter");
		}
		
		rename("MIP.tif");//MIP
		close();
		
		selectWindow("test.tif");//new window from DSLT
		close();
	}//	if(applyV>25 && applyV<150 && bitd==8){
	
	
	sigsize=area2/totalpix;
	if(sigsize==1)
	sigsize=0;
	
	sigsizethre=areathre/totalpix;
	
	print("Signal brightness; 	"+applyV+"	 Signal Size DSLT; 	"+sigsize+"	 Sig size threshold; 	"+sigsizethre);
	briadj[1]=(sigsize)*100;
	briadj[2]=applyV;
	briadj[3]=sigsizethre*100;
}//function autobradjustment

function DSLTfun(dsltarray){
	
	autothre=dsltarray[0];
	bitd=dsltarray[1];
	totalpix=dsltarray[2];
	desiredmean=dsltarray[3];
	
	if(autothre==0){//DSLT
		
		if(bitd==8)
		//	run("DSLT ", "radius_r_max=4 radius_r_min=2 radius_r_step=2 rotation=6 weight=14 filter=GAUSSIAN close=None noise=5px");
		run("DSLT ", "radius_r_max=4 radius_r_min=2 radius_r_step=2 rotation=6 weight=5 filter=GAUSSIAN close=None noise=5px");
		
		if(bitd==16){
			run("DSLT ", "radius_r_max=4 radius_r_min=2 radius_r_step=2 rotation=6 weight=100 filter=GAUSSIAN close=None noise=5px");
			
			run("16-bit");
			run("Mask255 to 4095");
		}
		rename("test.tif");//new window from DSLT
	}//if(autothre==0){//DSLT
	
	selectWindow("test.tif");
	
	run("Duplicate...", "title=test2.tif");
	selectWindow("test2.tif");
	
	if(bitd==16)
	run("8-bit");
	
	run("Create Selection");
	getStatistics(area, mean, min, max, std, histogram);
	if(area!=totalpix){
		if(mean<200){
			selectWindow("test2.tif");
			run("Make Inverse");
		}
	}
	getStatistics(area2, mean, min, max, std, histogram);
	close();//test2.tif
	
	presize=area2/totalpix;
	
	if(multiDSLT==1){
		if(area2/totalpix<0.05){// set DSLT more sensitive, too dim images, less than 5%
			selectWindow("test.tif");//new window from DSLT
			close();
			selectWindow("MIP.tif");//MIP
			
			if(bitd==8){
				//run("DSLT ", "radius_r_max=4 radius_r_min=2 radius_r_step=2 rotation=6 weight=5 filter=GAUSSIAN close=None noise=5px");
				run("DSLT ", "radius_r_max=4 radius_r_min=2 radius_r_step=2 rotation=6 weight=2 filter=GAUSSIAN close=None noise=5px");
				getStatistics(area2, mean, min, max, std, histogram);
			}
			if(bitd==16){
				run("DSLT ", "radius_r_max=4 radius_r_min=2 radius_r_step=2 rotation=6 weight=50 filter=GAUSSIAN close=None noise=5px");
				
				run("Create Selection");
				getStatistics(area2, mean, min, max, std, histogram);
				if(area2!=totalpix){
					if(mean<200)
					run("Make Inverse");
				}
				getStatistics(area2, mean, min, max, std, histogram);
				run("16-bit");
				run("Mask255 to 4095");
			}//if(bitd==16){
			rename("test.tif");//new window from DSLT
			run("Select All");
			
			sizediff=(area2/totalpix)/presize;
			print("2nd_sizediff; 	"+sizediff);
			if(bitd==16){
				if(sizediff>2){
					repeatnum=(sizediff-1)*10;
					oriss=1;
					
					for(rep=1; rep<=repeatnum+1; rep++){
						oriss=oriss+oriss*0.11;
					}
					weight=oriss/4;
					desiredmean=desiredmean+(desiredmean/4)*weight;
					desiredmean=round(desiredmean);
					
					if(desiredmean>220)
					desiredmean=230;
					
					print("desiredmean; 	"+desiredmean+"	 sizediff; "+sizediff+"	 weight *25%;"+(desiredmean/4)*weight);
				}
			}else if(bitd==8){
				if(sizediff>2){
					repeatnum=(sizediff-1);//*10
					oriss=1;
					
					for(rep=1; rep<=repeatnum+1; rep++){
						oriss=oriss+oriss*0.08;
					}
					weight=oriss/7;
					desiredmean=desiredmean+(desiredmean/7)*weight;
					desiredmean=round(desiredmean);
					
					if(desiredmean>225)
					desiredmean=235;
					
					print("desiredmean; 	"+desiredmean+"	 sizediff; "+sizediff+"	 weight *25%;"+(desiredmean/4)*weight);
				}
			}
		}//if(area2/totalpix<0.01){
	}//	if(multiDSLT==1){
	dsltarray[3]=desiredmean;
	dsltarray[4]=area2;
}//function DSLTfun

function applyVcalculation(applyvv){
	applyV=getTitle();
	applyV=round(applyV);
	
	if(bitd==8){
		applyV=255-applyV;
		
		if(applyV==0)
		applyV=255;
		else if(applyV<15)
		applyV=20;
	}else if(bitd==16){
		applyV=4095-applyV;
		
		if(applyV==0)
		applyV=4095;
		else if(applyV<150)
		applyV=150;
	}
	applyvv[0]=applyV;
}
	
function stackconcatinate(){

	getDimensions(width2, height2, channels2, slices, frames);
	addingslices=slices/10;
	addingslices=round(addingslices);
	
	for(GG=1; GG<=addingslices; GG++){
		setSlice(nSlices);
		run("Add Slice");
	}
	
	for(GG=1; GG<=addingslices; GG++){
		setSlice(1);
		run("Add Slice");
	}
}

function brightnessapply(applyV, bitd){
stacktoApply=getTitle();
	if(bitd==8){
		
		
		if(applyV<255){
			setMinAndMax(0, applyV);
			
			if(applyV<220){
				run("Z Project...", "projection=[Max Intensity]");
				MIPapply=getTitle();
		
				setMinAndMax(0, applyV);
				run("Apply LUT");


item5=newArray("Peak Histogram", "Auto-threshold");
Dialog.addRadioButtonGroup("Lower thresholding method", item5, 1, 2, lowthreM); 


				if(lowthreM=="Peak Histogram"){
					maxcounts=0;
					getHistogram(values, counts,  256);
					for(i=0; i<100; i++){
						Val=counts[i];

						if(Val>maxcounts){
							maxcounts=counts[i];
							maxi=i;
						}
					}
					changelower=maxi*lowerweight;
					
				}else if(lowthreM=="Auto-threshold"){
					setAutoThreshold("Huang dark");
					getThreshold(lower, upper);
					resetThreshold();
					changelower=lower*lowerweight;
				}

				if(changelower>80)
				changelower=60;
				
				close();
				
				selectWindow(stacktoApply);
				setMinAndMax(0, applyV);
				run("Apply LUT", "stack");

				if(changelower<1)
				changelower=1;
				
				setMinAndMax(changelower, 255);
				print("lower threshold; 	"+changelower);
			}

		run("Apply LUT", "stack");
		}
	}
	if(bitd==16){
		if(applyV<4095)
		setMinAndMax(0, applyV);
		
		if(applyV<1500){
			run("Z Project...", "projection=[Max Intensity]");
			setAutoThreshold("Huang dark");
			getThreshold(lower, upper);
			resetThreshold();
			close();
			
			selectWindow(stacktoApply);
			changelower=lower-lower/4;
			setMinAndMax(changelower, applyV);
			print("lower threshold; 	"+changelower);
			
		}
		run("8-bit");
	}//if(bitd==16){
}//function brightnessapply(applyV, bitd){

function basicoperation(bitd){
	run("Mean Thresholding", "-=30 thresholding=Subtraction");//new plugins
	if(bitd==16)
	setMinAndMax(0, 4095);
	
	run("Z Project...", "projection=[Max Intensity]");
	rename("MIP.tif");
	if(bitd==16)
	setMinAndMax(0, 4095);
}


function TimeLapseColorCoder(slicesOri, applyV, width, AutoBRV, bitd, CLAHE, GFrameColorScaleCheck, reverse0, colorcoding, usingLUT) {//"Time-Lapse Color Coder" 
	
	if(usingLUT=="royal")
	var Glut = "royal";	//default LUT
	
	if(usingLUT=="PsychedelicRainBow2")
	var Glut = "PsychedelicRainBow2";	//default LUT
	
	var Gstartf = 1;var Gendf = 10;
	
	getDimensions(width, height, channels, slices, frames);
	origi=getTitle();
	
	if(frames>slices)
	slices=frames;
	
	newImage("lut_table.tif", "8-bit black", slices, 1, 1);
	for(xxx=0; xxx<slices; xxx++){
		per=xxx/slices;
		colv=255*per;
		colv=round(colv);
		setPixel(xxx, 0, colv);
	}
	
	run(Glut);
	run("RGB Color");
	
	selectWindow(origi);
	
	run("Z Code Stack HO", "data="+origi+" 1px=lut_table.tif");
	
	selectWindow("Depth_color_RGB.tif");
	
	if(endMIP>nSlices)
	endMIP=nSlices;
	
	if(usingLUT=="royal"){
		addingslices=slicesOri/10;
		addingslices=round(addingslices);
		startMIP=addingslices+startMIP;
		endMIP=addingslices+endMIP;
		
		if(endMIP>nSlices)
		endMIP=nSlices;
		
		run("Z Project...", "start="+startMIP+" stop="+endMIP+" projection=[Max Intensity] all");
	}
		
	if(usingLUT=="PsychedelicRainBow2")
		run("MIP right color", "start="+startMIP+" end="+endMIP+"");
	
	max=getTitle();
	
	selectWindow("Depth_color_RGB.tif");
	close();
	
	selectWindow("lut_table.tif");
	close();
	
	selectWindow(max);
	rename("color.tif");
	if (GFrameColorScaleCheck==1){
		CreateScale(Glut, Gstartf, slicesOri, reverse0);
	
		selectWindow("color time scale");
		run("Select All");
		run("Copy");
		close();
	}
	
	selectWindow("color.tif");
	run("Properties...", "channels=1 slices=1 frames=1 unit=pixel pixel_width=1.0000 pixel_height=1.0000 voxel_depth=0 global");
	if(CLAHE==1 && usingLUT=="royal" )
	run("Enhance Local Contrast (CLAHE)", "blocksize=127 histogram=256 maximum=1.5 mask=*None*");
	
	if (GFrameColorScaleCheck==1){
		makeRectangle(width-257, 1, 256, 48);
		run("Paste");
	
		if(AutoBRV==1){
			setFont("Arial", 20, " antialiased");
			setColor("white");
			if(applyV>99){
				if(bitd==8)
				drawString("Max: "+applyV+" /255", width-150, 78);
				
				if(bitd==16)
				drawString("Max: "+applyV+" /4095", width-150, 78);
			}
			if(applyV<100){
				if(bitd==8)
				drawString("Max: 0"+applyV+" /255", width-150, 78);
				if(bitd==16)
				drawString("Max: 0"+applyV+" /255", width-150, 78);
			}
		}//if(AutoBRV==1){
	}//if (GFrameColorScaleCheck==1){
	run("Select All");
	setMetadata("Label", applyV+"	 DSLT; 	"+sigsize+"	Thre; 	"+sigsizethre);
}//function TimeLapseColorCoder(slicesOri, applyV, width, AutoBRV, bitd) {//"Time-Lapse Color Coder" 
	
function CreateScale(lutstr, beginf, endf, reverse0){
	ww = 256;
	hh = 32;
	newImage("color time scale", "8-bit White", ww, hh, 1);
	if(reverse0==0){
		for (j = 0; j < hh; j++) {
			for (i = 0; i < ww; i++) {
				setPixel(i, j, i);
			}
		}
	}//	if(reverse0==0){
	
	if(reverse0==1){
		valw=ww;
		for (j = 0; j < hh; j++) {
			for (i = 0; i < ww; i++) {
				setPixel(i, j, valw);
				valw=ww-i;
			}
		}
	}//	if(reverse0==1){
	
	if(usingLUT=="royal"){
		makeRectangle(25, 0, 204, 32);
		run("Crop");
	}
	
	run(lutstr);
	run("RGB Color");
	op = "width=" + ww + " height=" + (hh + 16) + " position=Top-Center zero";
	run("Canvas Size...", op);
		setFont("SansSerif", 12, "antiliased");
	run("Colors...", "foreground=white background=black selection=yellow");
	drawString("Slices", round(ww / 2) - 12, hh + 16);
	
	if(usingLUT=="PsychedelicRainBow2"){
		drawString(leftPad(beginf, 3), 10, hh + 16);
		drawString(leftPad(endf, 3), ww - 30, hh + 16);
	}else{
		drawString(leftPad(beginf, 3), 24, hh + 16);
		drawString(leftPad(endf, 3), ww - 50, hh + 16);
	}
		}
	
function leftPad(n, width) {
	s = "" + n;
	while (lengthOf(s) < width)
	s = "0" + s;
	return s;
}

"done"
