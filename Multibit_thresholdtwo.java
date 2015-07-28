import ij.*;
import ij.process.*;
import ij.gui.*;
import java.awt.*;
//import ij.plugin.*;
import ij.plugin.PlugIn;
import ij.plugin.frame.*; 
import ij.plugin.filter.*;
//import ij.plugin.Macro_Runner.*;
import ij.gui.GenericDialog.*;
import ij.macro.*;
import javax.swing.*;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener; 
//import Multibit_thresholdtwo.;

public class Multibit_thresholdtwo extends JFrame implements PlugIn {
	//int wList [] = WindowManager.getIDList();
	private JTextField textFieldR;
	private JTextField textFieldL;
	private JFrame sliderFrame;
	ImagePlus imp;
	ImagePlus newimp;
	ImageProcessor ip1;
	ImageProcessor ip2;
	int bittype=0;
	int threnum=0;
	int sourceRR=0;
	int sourceLL=0;
	int countsource;
	int count;
	int Minthre;
	int Maxthre;
	int macro=0;
	int maxvalue=0;
	int sliceposition=0;
	int iii=1;
	int nslice=1;
	
//	public void run(String arg) {
//	}
	
	public void run(String arg) {
		imp = WindowManager.getCurrentImage();
	//	this.imp = imp;
		
		IJ.register (Multibit_thresholdtwo.class);
		if (IJ.versionLessThan("1.32c")){
			IJ.showMessage("Error", "Please Update ImageJ.");
			return;
		}
		int[] wList = WindowManager.getIDList();
		if (wList==null) {
			IJ.error("No images are open.");
			return;
		}
		if(imp.getType()!=imp.GRAY8 && imp.getType()!=imp.GRAY16){
				IJ.showMessage("Error", "Plugin requires 8- or 16-bit image");
			return;
		}
		
		if(imp.getType()==imp.GRAY8){
			maxvalue=255;
			bittype=0;
		}else if(imp.getType()==imp.GRAY16 ){
			maxvalue=4095;
			bittype=1;
		}
		
		int curslice=imp.getSlice();
		nslice = imp.getNSlices();
		int bdepth = imp.getBitDepth();
		threnum = (int)Prefs.get("threnum.int", 0);
		macro = (int)Prefs.get("macro.int", 0);
		
		if(threnum==0){
			Maxthre = (int)Prefs.get("Max thresholding.int", maxvalue);
		}
		if(threnum==1){
		Maxthre = (int)Prefs.get("Min thresholding.int", 0);
		}
		String [] thresholds = {"Set_black", "Set_white"};
		String [] macroor = {"In macro", "Not in macro"};
		
		GenericDialog gd = new GenericDialog("Background thresholding");
		gd.addRadioButtonGroup("W/B for selected region", thresholds, 2, 2, thresholds[threnum]);
		
		gd.addNumericField("Min value for white background", Maxthre, 2);
		
		gd.addRadioButtonGroup("in macro or not", macroor, 2, 2, macroor[macro]);
		gd.showDialog();
		if(gd.wasCanceled()){
			return;
		}
		
		String thremethod=(String)gd.getNextRadioButton();
		
		//	if(threnum==0){
		sourceRR = (int)gd.getNextNumber();
		
		String macroornot=(String)gd.getNextRadioButton();
		threnum=1;
		if(thremethod=="Set_black")
		threnum=0;
		

		if(threnum==1)
		sourceLL = sourceRR;
		
		macro=1;
		if(macroornot=="In macro")
		macro=0;//in macro
		
		Prefs.set("threnum.int", threnum);
		Prefs.set("macro.int", macro);
		
		newimp = imp.duplicate();
		ImageStack stack2 = newimp.getStack(); 
		newimp.setSlice(curslice);
		newimp.show();
		final ImagePlus oriimp= imp;
		
		if(macro==1){//not in macro
			sliderFrame = new JFrame("Slider");
			setDefaultCloseOperation(sliderFrame.DISPOSE_ON_CLOSE);
			Container cont = sliderFrame.getContentPane();
			cont.setLayout(new FlowLayout());
		
			if(threnum==0){//set black
				JSlider sliderR = new JSlider(0,maxvalue,sourceRR);// (min, max, default value)
				sliderR.setPaintTicks(true);
				sliderR.setPaintLabels(true);
				sliderR.setMajorTickSpacing(40);
				sliderR.setMinorTickSpacing(20);

				textFieldR = new JTextField(""+maxvalue+"", 5); // ("defaoult value")
	
				sliderR.addChangeListener(new ChangeListener() { // real time slider
						public void stateChanged(ChangeEvent e) {
							JSlider sourceR = (JSlider) e.getSource();
							textFieldR.setText(""+sourceR.getValue());
							
							sliceposition=newimp.getCurrentSlice();
							threshold(ip1, ip2, oriimp, newimp, 0, sourceR.getValue(), threnum, bittype, sliceposition);
						
							newimp.show();
							newimp.getProcessor().resetMinAndMax();
							newimp.updateAndRepaintWindow();
							sourceRR=sourceR.getValue();
						}
			//		Prefs.set("Max thresholding.int", sourceRR);
			//		IJ.log("Max  " + sourceRR);
				});
				cont.add(sliderR);
				cont.add(textFieldR);
			}//set black
			
			if(threnum==1){//set white//sliderL
				JSlider sliderL = new JSlider(0,maxvalue,0);// (min, max, default value)
				sliderL.setPaintTicks(true);
				sliderL.setPaintLabels(true);
				sliderL.setMajorTickSpacing(40);
				sliderL.setMinorTickSpacing(20);
	
				textFieldL = new JTextField("0", 5); // ("defaoult value")
	
				sliderL.addChangeListener(new ChangeListener() { // real time slider
						public void stateChanged(ChangeEvent e) {
					JSlider sourceL = (JSlider) e.getSource();
					textFieldL.setText(""+sourceL.getValue());
							
							sliceposition=newimp.getCurrentSlice();
							
							threshold(ip1, ip2, oriimp, newimp, sourceL.getValue(), maxvalue, threnum, bittype, sliceposition);
						
							newimp.show();
							newimp.getProcessor().resetMinAndMax();
							newimp.updateAndRepaintWindow();
							sourceLL=sourceL.getValue();
						}
				});
				cont.add(sliderL);
				cont.add(textFieldL);
			}//set white
			JButton button = new JButton("Apply");
			button.addActionListener(new ActionListener() { //real time button
					public void  actionPerformed(ActionEvent e) { // if clicked button
							
					newimp.getProcessor().resetMinAndMax();
					newimp.updateAndRepaintWindow();
					newimp.unlock();
					
					if(threnum==0){
						Prefs.set("Max thresholding.int", sourceRR);
							//	IJ.log("Max  " + sourceRR);
							
							for(iii=1; iii<=nslice; iii++){
								sliceposition=iii;
								threshold(ip1, ip2, oriimp, newimp, 0, sourceRR, threnum, bittype, sliceposition);
							}
					}
					if(threnum==1){
						Prefs.set("Min thresholding.int", sourceLL);
							//	IJ.log("Min  " + sourceLL);
							
							for(iii=1; iii<=nslice; iii++){
								sliceposition=iii;
								threshold(ip1, ip2, oriimp, newimp, sourceLL, maxvalue, threnum, bittype, sliceposition);
							}
					}
					newimp.updateImage();
					sliderFrame.setVisible(false); //you can't see me!
					sliderFrame.dispose();
					
				}
		});
		

		cont.add(button); 
		sliderFrame.setBounds(250,250,300,200);
			sliderFrame.setVisible(true);
		} // if(macro==1){
		
		if (macro==0){
			sliceposition=newimp.getCurrentSlice();
			threshold(ip1, ip2, imp, newimp, 0, sourceRR, threnum, bittype, sliceposition);
			
			newimp.show();
			newimp.getProcessor().resetMinAndMax();
			newimp.updateAndRepaintWindow();
			newimp.unlock();
			newimp.updateImage();
			
		}
		
	} //public void run(String arg) {
	////function////
	public void threshold(ImageProcessor tip1, ImageProcessor tip2, ImagePlus oriimp, ImagePlus timp, int sourceL, int sourceR, int tthrenum, int tbittype, int sliceposition) {
		ImageStack stack1 = oriimp.getStack();
		
		//	int d1 = stack1.getStackSize();
		int d1 = timp.getNSlices();
		
		tip1 = stack1.getProcessor(1);
		int sumpx = tip1.getPixelCount();
		int width = tip1.getWidth();
		int height = tip1.getHeight();
		
		int oripix = 0; int oripix1=0;  int oripix2=0;  int oripix3=0;  int oripix4=0; int oripix5=0;
		int oripix6=0;  int oripix7=0;  int oripix8=0; int sum=0;
		int setvalue = 0;
		
		int[] dims = timp.getDimensions();
		int imageW = dims[0];
		int imageH = dims[1];
		int nCh    = dims[2];
		int imageD = dims[3];
		int nFrame = dims[4];
		int bdepth = timp.getBitDepth();
		
		
		//ImagePlus newimp2 = IJ.createHyperStack("result.tif", width, height, nCh, imageD, nFrame, bdepth);
		ImageStack stack22 = timp.getStack(); //creating new blank stack
		
		if(tthrenum==0){ //black value setting
			setvalue = 0;
			countsource=sourceR;
		}
		if(tthrenum==1){//white value setting
			countsource=sourceL;
			if(tbittype==0){
				setvalue = 255;//set white
			}
			if(tbittype==1){
				setvalue = 4095;//set white
			}
		}
		
		//		for (int slicen=1; slicen<=d1; slicen++){
		tip1 = stack1.getProcessor(sliceposition);
		tip2 = stack22.getProcessor(sliceposition);
		
		for (int hh=width+1; hh <= sumpx-width-1; hh+=width){// hh, 1-383
			for (int threpx=hh; threpx < hh+width-2; threpx++){ //endbranch delection
				count=8;
				
				oripix = tip1.get (threpx);
				oripix1 = tip1.get (threpx-1);
				if(oripix1>countsource){
					count=count-1;
				oripix1 = 0;}
				
				oripix2 = tip1.get (threpx+1);
				if(oripix2>countsource){
					count=count-1;
				oripix2 = 0;}
				
				oripix3 = tip1.get (threpx-width);
				if(oripix3>countsource){
					count=count-1;
				oripix3 = 0;}
				
				oripix4 = tip1.get (threpx+width);
				if(oripix4>countsource){
					count=count-1;
				oripix4 = 0;}
				
				oripix5 = tip1.get (threpx-width-1);
				if(oripix5>countsource){
					count=count-1;
				oripix5 = 0;}
				
				oripix6 = tip1.get (threpx-width+1);
				if(oripix6>countsource){
					count=count-1;
				oripix6 = 0;}
				
				oripix7 = tip1.get (threpx+width-1);
				if(oripix7>countsource){
					count=count-1;
				oripix7 = 0;}
				
				oripix8 = tip1.get (threpx+width+1);
				if(oripix8>countsource){
					count=count-1;
				oripix8 = 0;}
				
				sum = oripix1+oripix2+oripix3+oripix4+oripix5+oripix6+oripix7+oripix8;
				
				if(tthrenum==1){ //set white
					if (oripix<=sourceL){
						if(count>=2){
							tip2.set (threpx, setvalue);//set value
						}
					}//(oripix<=maxthre){
					else if (oripix>sourceL){
						tip2.set (threpx, oripix);//set value
					}//
				}//tthrenum==1 set white
				
				if(tthrenum==0){ //set black
					if (oripix>=sourceR){
						if(count<=7){
							tip2.set (threpx, setvalue);//set value
						}
					}//(oripix<=maxthre, sourceR){
					
					if (oripix<sourceR){
						tip2.set (threpx, oripix);//set value
						
						if(count<=4){
							tip2.set (threpx, setvalue);//set value
						}
						if(count==8){
							tip2.set (threpx, oripix);//set value
						}
						
					}//
				}//tthrenum==1 set black
				
			} //for (int threpx=0; threpx < sumpx; threpx++){
		}
		//		} //slice n
		
		
		//	IJ.log(" noisemethod;"+String.valueOf(noisemethod));
		//	ImagePlus dd = new ImagePlus("Max thre;"+String.valueOf(maxthre)+" Min thre;"+String.valueOf(minthre)+" thresholding fill;"+thremethod, ip2);
		timp.show();
		
	}//threshold
} 
	


