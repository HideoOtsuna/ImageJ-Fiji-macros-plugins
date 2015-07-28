
keepsubst=0;
compCC=0;
setBatchMode(true);
dir = getDirectory("Choose a directory for confocal files");
dir2 = getDirectory("Choose a directory for Save");
blockmode=1;

list = getFileList(dir);
Array.sort(list);
startn=0;
endn=list.length;

startn=0;
endn=list.length;

if(blockmode==1){
	Dialog.create("Block separation for file number");
	Dialog.addNumber("Handling block", 1, 0, 0, " /Total block"); //0
	Dialog.addNumber("Total block number 1-10", 3, 0, 0, ""); //0
	Dialog.show();
	
	blockposition=Dialog.getNumber();
	totalblock=Dialog.getNumber();
	
	blocksize=(list.length/totalblock);
	blocksize=round(blocksize);
	startn=blocksize*(blockposition-1);
	endn=startn+blocksize;
	
	if(blockposition==totalblock)
	endn=list.length;
	
}

//myDir = dir+"OBJ_Files"+File.separator;
//File.makeDirectory(myDir);
sub=0;
for (i=startn; i<endn; i++){

	progress=i/endn;
	showProgress(progress);

	path=dir+list[i];
	
	if (endsWith(list[i], "/")){
			sub=1;
		if(keepsubst==1){
			myDir0 = dir2+list[i];
			File.makeDirectory(myDir0);
		}
		listsub = getFileList(dir+list[i]);
		for (ii=0; ii<listsub.length; ii++){
			path2 = path+listsub[ii];
			
			if (endsWith(listsub[ii], "/")){//if "/"
				listsub2 = getFileList(path2);
				Array.sort(listsub2);
				sub=2;
				for (iii=0; iii<listsub2.length; iii++){
					path3 = path2+listsub2[iii];
					
					conv=newArray(listsub2[iii], path3, dir2, i, list[i], iii, listsub2.length, path2, sub);
					convfunction(conv);
				}//	for (iii=0; iii<listsub2.length; iii++){
			}//if (endsWith(listsub[ii], "/")){//if "/"
			
			if(keepsubst==0)
			conv=newArray(listsub[ii], path2, dir2, i, list[i], ii, listsub.length, path, sub);
					
			if(keepsubst==1)
			conv=newArray(listsub[ii], path2, myDir0, i, list[i], ii, listsub.length, path, sub);
					
			convfunction(conv);
		}//			for (ii=0; ii<listsub.length; ii++){
	}else{
		conv=newArray(list[i], path, dir2, i, list[i], i, endn, dir, sub);
		convfunction(conv);
	}//	if (endsWith(list[i], "/")){
	
	if(nImages>0){
		for(ni=1; ni<=nImages; ni++){
			close();
		}
	}//if(nImages>0){
}//for (i=startn; i<endn; i++){

function convfunction(conv) {
	listP=conv[0];//FILES 
	path=conv[1];//full path
	dir5=conv[2];//save directory
	i=conv[3];//original i number
	parentfolder=conv[4];	//parentfolder
	ii=conv[5];//sub folder item number
	endn=conv[6];//
	dir2=conv[7];
	sub=conv[8];
	
	dotIndexXML =	-1;
	files=files+1;
	
	dotIndexXML = lastIndexOf(listP, "xml");
	
	if(dotIndexXML>-1){
	}else{
		dotIndex = -1;
		dotIndexAM = -1;
		dotIndextif = -1;
		dotIndexTIFF = -1;
		dotIndexLSM = -1;
		dotIndexV3 = -1;
		dotIndexMha= -1;
		dotIndexzip= -1;
		
		files=files+1;
		
		dotIndexMha = lastIndexOf(listP, "mha");
		dotIndexV3 = lastIndexOf(listP, "v3dpbd");
		dotIndexLSM = lastIndexOf(listP, "lsm");
		dotIndex = lastIndexOf(listP, "nrrd");
		dotIndexAM = lastIndexOf(listP, "am");
		dotIndextif = lastIndexOf(listP, "tif");
		dotIndexTIFF = lastIndexOf(listP, "TIFF");
		dotIndexzip = lastIndexOf(listP, "TIFF");
		
		if(dotIndextif==-1 && dotIndexTIFF==-1 && dotIndex==-1 && dotIndexAM==-1 && dotIndexLSM==-1 && dotIndexMha==-1 && dotIndexzip==-1){
		}else{
			
			dotIndex = lastIndexOf(listP, ".");
			if (dotIndex!=-1);
			origiMIP = substring(listP, 0, dotIndex); // remove extension
			
			filepathmhaG=dir5+origiMIP+"_G.zip";
			filepathmhaR=dir5+origiMIP+"_R.zip";
			eximhaG=File.exists(filepathmhaG);
			eximhaR=File.exists(filepathmhaR);
			
					//	print("eximha;"+eximha);
			if(eximhaR==0 || eximhaG==0 ){
				
				if(compCC==0){// if not compressed
					if(dotIndex>-1 || dotIndexAM>-1)
					run("Bio-Formats Importer", "open="+path+" autoscale color_mode=Default view=[Standard ImageJ] stack_order=Default");
				}//if(compCC==0){// if not compressed
				
				if(dotIndextif>-1 || dotIndexTIFF>-1 || compCC==1 || dotIndexLSM>-1 || dotIndexV3>-1 || dotIndexMha>-1 || dotIndexzip>-1)
					open(path);// for tif, comp nrrd, lsm", am, v3dpbd, mha
				
				if(sub==1)
				print(listP+"	 ;	 "+ii+" / "+endn+"	 parentfolder; 	"+parentfolder);
			
				if(sub==0)
				print(listP+"	 ;	 "+ii+" / "+endn);
			
				origi=getTitle();
				getDimensions(width, height, channels, slices, frames);
				
				if(channels==3){
					run("Split Channels");
					selectWindow("C3-"+origi);
					close();
				
					selectWindow("C2-"+origi);
					saveAs("ZIP", ""+dir5+origiMIP+"_G.zip");
					close();
				
					saveAs("ZIP", ""+dir5+origiMIP+"_R.zip");
					close();
				}	//if(channels>1){
				
				if(channels==2){
					run("Split Channels");
				
					selectWindow("C2-"+origi);
					saveAs("ZIP", ""+dir5+origiMIP+"_01.zip");
					close();
				
					saveAs("ZIP", ""+dir5+origiMIP+"_02.zip");
					close();
				}	//if(channels==2){
				
				if(channels==1){
					saveAs("ZIP", ""+dir5+origiMIP+".zip");
					close();
				}	//if(channels==1){
				if(nImages>0){
					for(ni=1; ni<=nImages; ni++){
						close();
					}
				}//	if(nImages>0){
			}//if(eximhaR==0 || eximhaG==0 ){
		}//if(dotIndextif==-1 && dotIndexTIFF==-1 && dotIndex=....
	}//if(dotIndexXML>-1){
}//function convfunction(conv) {

"Done"




