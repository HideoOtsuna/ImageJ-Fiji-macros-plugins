//Hideo Otsuna (HHMI Janelia Research Campus), May 21, 2015import ij.*;import ij.plugin.filter.*;import ij.plugin.PlugIn;import ij.process.*;import ij.gui.*;import java.awt.*;import ij.macro.*;import ij.gui.GenericDialog.*;import javax.swing.*;import javax.swing.event.ChangeEvent;import javax.swing.event.ChangeListener;import java.awt.event.ActionEvent;import java.awt.event.ActionListener; public class Histogram_thresholding implements PlugInFilter{	ImagePlus imp;	//	String origi;	//	String origi = imp.getTitle();	int nslice=0;	int sumpre=0;	int maxvalue=0;	int measuregap=0;	int startval=0;	double sd=0;	double avesd=0;	double insideSD=0;	int histo=0;	double sqinside=0;	int attenuationN=0;	String attenuationMe;	int realstart=0;	double minff=10000;	double ffmin=0;	double thresval=0;	int end0 = 0;	double attenvalue=0;	boolean logon;		public int setup(String arg, ImagePlus imp){		IJ.register (Histogram_thresholding.class);		if (IJ.versionLessThan("1.32c")){			IJ.showMessage("Error", "Please Update ImageJ.");			return 0;		}				startval = (int)Prefs.get("Thresholding.int", 10);		measuregap = (int)Prefs.get("measuregap.int", 5);	//	attenuationN = (int)Prefs.get("attenuation.int", 0);		String [] attenuation = {"Yes", "No"};				GenericDialog gd = new GenericDialog("Background thresholding");		gd.addSlider("Z-attenuation collection strength X ", 1.0, 2.0, 2);				gd.addNumericField("Min value for black background", startval, 2);		gd.addNumericField("thresholding measurement gap, 5 for 8bit, 50 for 16bit", measuregap, 2);		gd.addCheckbox("Show log",false);		gd.showDialog();		if(gd.wasCanceled()){			return 0;		}				attenvalue=(double)gd.getNextNumber();		attenvalue=1/attenvalue;				//	if(threnum==0){		startval = (int)gd.getNextNumber();		measuregap = (int)gd.getNextNumber();		logon = gd.getNextBoolean();				Prefs.set("Thresholding.int", startval);		Prefs.set("measuregap.int", measuregap);	//	Prefs.set("attenuation.int", attenuationN);				int[] wList = WindowManager.getIDList();		if (wList==null) {			IJ.error("No images are open.");			return 0;		}		//	IJ.log(" wList;"+String.valueOf(wList));		imp = WindowManager.getCurrentImage();		this.imp = imp;		if(imp.getType()!=imp.GRAY8 && imp.getType()!=imp.GRAY16){			IJ.showMessage("Error", "Plugin requires 8- or 16-bit image");			return 0;		}		//if(imp.getType()==imp.GRAY8)		//new ImageConverter(imp).convertToGray16();				return DOES_8G+DOES_16;	}		public void run(ImageProcessor ip){		//	String ff = ip.getTitle();				if(imp.getType()==imp.GRAY8)			maxvalue=255;				if(imp.getType()==imp.GRAY16)			maxvalue=4095;				int[] histogram = new int[maxvalue];		nslice = imp.getNSlices();		int pix = 0;		int ww = ip.getWidth() ;		int hh = ip.getHeight();		int sumpx = ip.getPixelCount();		ImageStack stack = imp.getStack();				//		ImageProcessor ip2 = ip.duplicate();				for(int sliceposi=1; sliceposi<=nslice; sliceposi++){			ip = stack.getProcessor(sliceposi);						histogram = ip.getHistogram();			int ff=startval;				/////// Thresholding value decision	////////////////////////							if(attenvalue<1){				double sliceposi1=sliceposi;				double nslice1=nslice;								double changeval=sliceposi1/nslice1;								double ff2=ff;				ff2=ff2-(ff2*attenvalue*changeval);				ff2=Math.round(ff2);				ff = (int) ff2;				realstart=ff;				//	IJ.log("Attenuation"+changeval);			}			int step=1;						while(step<=2){				end0 = 0;				minff=10000;								while(end0<maxvalue){										if(ff>=maxvalue)					end0=maxvalue;										sumpre=0;					for(int pre=ff; pre<=ff+measuregap; pre++){						histo=histogram[pre];						sumpre=sumpre+histo;					}					avesd=0;					avesd=sumpre/measuregap;//standard deviation					insideSD=0;										for(int pre1=ff; pre1<=ff+measuregap; pre1++){						histo=histogram[pre1];						insideSD=((histo-avesd)*(histo-avesd))+insideSD;					}					sqinside=0;					sqinside=insideSD/measuregap;										sd = Math.sqrt(sqinside);										if(minff>sd){						minff=sd;						thresval=ff+(measuregap/2);						ffmin=Math.round(thresval);//threshold value					}					if(ffmin>1){						if(minff<sd){								end0=maxvalue;						}					}					ff=ff+1;				}//while(ff<maxvalue){				step=step+1;			}			if(ffmin>maxvalue)			ffmin=maxvalue;						IJ.showProgress (sliceposi, nslice);//thresholding////////////////////////////		for(int i=0; i<sumpx; i++){				pix = ip.get (i);								if(pix>ffmin)				ip.set (i, maxvalue);				else				ip.set (i, 0);							}			if(logon==true)			IJ.log("start value;	"+realstart+"	,Threshold val;	"+ffmin+"	,slice;	"+sliceposi);		}				imp.show();	}	}