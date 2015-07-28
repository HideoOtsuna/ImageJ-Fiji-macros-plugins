
setBatchMode(true);

savechannel=0;
blockmode=0;

dir = getDirectory("Choose a directory for aligned confocal files");
dir2 = getDirectory("Choose a directory for VVD save");

if(savechannel==1)
dir3 = getDirectory("Choose a directory for 1ch save");

list = getFileList(dir);

filepath0=getDirectory("temp");//C:\Users\??\AppData\Local\Temp\...C:\DOCUME~1\ADMINI~1\LOCALS~1\Temp\
filepath=filepath0+"tempVVT.txt";

LF=10; TAB=9; swi=0; swi2=0; 
exi=File.exists(filepath);
List.clear();

blockposition=1;
totalblock=10;
subfolderstrinjg=false;
compnrrd = false;
channel = "C1-";
subststring=false;
startn= 0;
testline=0;
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
			blockposition = String.buffer;
		}else if(swi==1 && swi<=testline){
			totalblock = String.buffer;
		}else if(swi==2 && swi<=testline){
			subfolderstrinjg = String.buffer;
		}else if(swi==3 && swi<=testline){
			compnrrd = String.buffer;// 1 is compressed nrrd, 0 is not compressed nrrd
		}else if(swi==4 && swi<=testline){
			channel= String.buffer;
		}else if(swi==5 && swi<=testline){
			subststring= String.buffer;
		}else if(swi==6 && swi<=testline){
			startn= String.buffer;
		} //swi==0
	}
	File.saveString(blockposition+"\n"+totalblock+"\n"+subfolderstrinjg+"\n"+compnrrd+"\n"+channel+"\n"+subststring+"\n"+startn, filepath);
}

Dialog.create("Batch processing of VVD conversion, Total number of files; "+list.length+"");
if(blockmode==0){
	Dialog.addNumber("Start file number", startn, 0, 0, " /"+list.length+""); //0
	Dialog.addNumber("End file", list.length-1, 0, 0, ""); //0
}

if(blockmode==1){
	Dialog.addNumber("Handling block", blockposition, 0, 0, " /"+totalblock+""); //0
	Dialog.addNumber("Total block number 1-10", totalblock, 0, 0, ""); //0
}
Dialog.addCheckbox("Include sub-folder", subfolderstrinjg);
Dialog.addCheckbox("Keep sub-folder structure", subststring);
Dialog.addCheckbox("Compressed nrrd?", 	compnrrd);
Dialog.show();

if(blockmode==1){
	blockposition=Dialog.getNumber();
	totalblock=Dialog.getNumber();
}
if(blockmode==0){
	startn=Dialog.getNumber();
	endn=Dialog.getNumber();
}
subfolder=Dialog.getCheckbox();
keepsubst=Dialog.getCheckbox();
compCC=Dialog.getCheckbox();

if(blockmode==1){
	blocksize=(list.length/totalblock);
	blocksize=round(blocksize);
	startn=blocksize*(blockposition-1);
	endn=startn+blocksize;
	
	if(blockposition==totalblock)
	endn=list.length;
}


if (subfolder==1)
subfolderstrinjg=true;

if (subfolder==0)
subfolderstrinjg=false;

if (keepsubst==1)
subststring=true;

if (keepsubst==0)
subststring=false;

if (compCC==0)
compnrrd=false;

if (compCC==1)
compnrrd=true;
File.saveString(blockposition+"\n"+totalblock+"\n"+subfolderstrinjg+"\n"+compnrrd+"\n"+channel+"\n"+subststring+"\n"+startn, filepath);
firsttime=0;
CC1="C1-";
/////////////////////////////////////////////////////////////////////////////////
for (i=startn; i<=endn; i++){

	progress=(i-startn+1)/(endn-startn+1);
	showProgress(progress);
	
	path = dir+list[i];
	
	if (endsWith(list[i], "/")){
		if(subfolder==1){
			
			if(keepsubst==1){
				myDir0 = dir2+File.separator+list[i];
				File.makeDirectory(myDir0);
				dir5=myDir0;
			}
			if(list[i]!="MIP_Files"+File.separator){
				listsub = getFileList(dir+list[i]);
				for (ii=0; ii<listsub.length; ii++){
					
					path2 = path+listsub[ii];
					
					if(keepsubst==0)
					mipbatch=newArray(listsub[ii], path2, dir2, firsttime, startn, CC1, i, list[i], endn, ii, listsub[ii]);
					
					if(keepsubst==1)
					mipbatch=newArray(listsub[ii], path2, dir5, firsttime, startn, CC1, i, list[i], endn, ii, listsub[ii]);
					
					mipfunction(mipbatch);
					CC1=mipbatch[5];
					firsttime=mipbatch[3];
				}
			}
		}
	}else{
		mipbatch=newArray(list[i], path, dir2, firsttime,  startn, CC1, i, list[i], endn, 0, 0);
		mipfunction(mipbatch);
		CC1=mipbatch[5];
		firsttime=mipbatch[3];
	}
}
////////////////////function/////////////////////////
function mipfunction(mipbatch) { 
	listP=mipbatch[0];
	path=mipbatch[1];
	dir2=mipbatch[2];
	number=mipbatch[3];
	startn=mipbatch[4];
	CC=mipbatch[5];
	i=mipbatch[6];
	list=mipbatch[7];
	endn=mipbatch[8];
	ii=mipbatch[9];
	listsub=mipbatch[9];
	
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
	
	
	if(dotIndextif==-1 && dotIndexTIFF==-1 && dotIndex==-1 && dotIndexAM==-1 && dotIndexLSM==-1 && dotIndexV3==-1 && dotIndexMha==-1){
	}else{
		
		print("No. "+i+",	Parent; 	"+list+"	/ "+endn+"	, No. "+ii+"	, Sub folder;  "+listsub);
		
		if(dotIndexAM>-1 || compCC==0 && dotIndex>-1){// not compressed nrrd
			run("Bio-Formats Importer", "open="+path+" autoscale color_mode=Default view=[Standard ImageJ] stack_order=Default");
			origi=getTitle();
			n = lengthOf(origi);
			
			dotIndex1 = lastIndexOf(origi, "/");
			if (dotIndex1!=-1);
			origi = substring(origi, dotIndex1+1, n); // remove extension
			rename(origi);
		}
	
		if(dotIndextif>-1 || dotIndexTIFF>-1 || dotIndexLSM>-1 || dotIndexV3>-1 || dotIndexMha>-1){
			open(path);// for tif, TIFF, lsm, v3dpbd, mha
			origi=getTitle();
		}
		if(compCC==1 && dotIndex>-1){// compressed nrrd
			open(path);// for comp nrrd
			origi=getTitle();
		}
		
		bitd=bitDepth();
		getDimensions(width, height, channels, slices, frames);
		
		if(bitd==24 || channels==3){///Need red channel only
			
			if(number>0)
			run("Split Channels");
			
			if(number==0){
				setBatchMode(false);
				run("Split Channels");
				
				waitForUser("Select the channel on Top that is necessary!");
				needthis=getTitle();
				CC = substring(needthis, 0, 3);
				setBatchMode(true);
				number=1;
			}
			
			selectWindow(CC+origi);
			close("\\Others");
			
			rename(origi);
		}//	if(bitd==24 || channels==3){///Need red channel only
		
		dotIndex = lastIndexOf(origi, ".");
		if (dotIndex!=-1);
		origiMIP = substring(origi, 0, dotIndex); // remove extension
		
		if(savechannel==1)
		run("MHD/MHA compressed ...", "save="+dir3+origiMIP+".mha");

		run("Scale...", "x=0.25 y=0.25 z=1.0 width="+width/4+" height="+height/4+" depth="+slices+" interpolation=Bicubic average process create title=quart.tif");

		selectWindow(origi);
		run("Scale...", "x=0.5 y=0.5 z=1.0 width="+width/2+" height="+height/2+" depth="+slices+" interpolation=Bicubic average process create title=half.tif");

		myDir = dir2+File.separator+origiMIP+File.separator;
		File.makeDirectory(myDir);
		
		run("mytest6 branch2 v3", "brickwidth=256 brickhight=256 brickdepth=64 levels=3 filetype=JPEG jpeg=60 image_0="+origi+" bricksize_0=[256 256 64] image_1=half.tif bricksize_1=[256 256 64] image_2=quart.tif bricksize_2=[128 128 64] save="+myDir+origiMIP+"");
		run("Close All");
		
	}
	mipbatch[5]=CC;
	mipbatch[3]=number;
}

"done"
