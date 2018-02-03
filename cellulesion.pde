// Attempting to convert Circulesion into object-oriented code to lay foundation for vectors & movement
// 2018-01-31 22:56

// 2018-01-27 GOAL: Generation is linear, epoch is circular

// TO DO: Try using RGB mode to make gradients from one hue to another, instead of light/dark etc. (2018-01-04)
// TO DO: Make a variable for selecting render type (primitive: rect, ellipse or triangle) (2018-01-16)
// TO DO: Instead of 2D noisefield use an image and pick out the colour values from the pxels!!! Vary radius of circular path for each cycle :D
// TO DO: Consider moving epoch-modulated values so they are only recalculated when epoch nr. changes (behind (if generation>generations){})

// TO DO: Make a list of rendering methdods (gradients, stripes, transparent strokes etc.)
//      1) Brightness from dark to light
//      2) Saturation from high to low (colour to white)
//      3) Hue from warm to cold

// TO DO: Make a list of variables that can be modulated through the Epoch, noting which ones I have tried & result
//      1) noiseRadius  1/6  Just seemed to modulate size, not very exciting 
//      2) noiseFactor  4/6  Best when increasing as sq() from very high value to a low-end/high variation
//      3) noiseOctaves 1/6  Is an integer, so changes in steps rather than smooth transition
//      4) noiseFallOff
//      5) noiseSeed
//      6) ellipseMaxSize
//      7) generations


// TO TRY: Add a higher level pop/push matrix & rotate the entire grid through TWO_PI for each timelapse cycle

// OBSERVATION: If seed1, 2 & 3 are equal, noise1, 2 & 3 will also be the same when x = y

import com.hamoid.*;     // For converting frames to a .mp4 video file 
import processing.pdf.*; // For exporting output as a .pdf file

Colony colony;           // A Colony object called 'colony'
VideoExport videoExport;

// File Management variables:
int batch = 1;
String applicationName = "cellulesion";
String logFileName;   // Name & location of logfile (.log)
String debugFileName; // Name & location of logfile (.log)
String pngFile;       // Name & location of saved output (.png final image)
String pdfFile;       // Name & location of saved output (.pdf file)
String framedumpPath; // Name & location of saved output (individual frames) NOT IN USE
String mp4File;       // Name & location of video output (.mp4 file)

// Video export variables
int videoQuality = 75; // 100 = highest quality (lossless), 70 = default 
int videoFPS = 30;     // Framerate for video playback

// Loop Control variables
int generation = 1;    // Generation counter starts at 1
int generations = 2000; // Total number of drawcycles (frames) in a generation (timelapse loop)
float epoch = 1;         // Epoch counter starts at 1
float epochs = 1;      // The number of epoch frames in the video (Divide by 60 for duration (sec) @60fps, or 30 @30fps)

// Noise variables:
float noiseLoopX, noiseLoopY, noiseLoopZ;
float noise1Scale, noise2Scale, noise3Scale, noiseFactor;
float noiseFactorMin = 2.5; 
float noiseFactorMax = 5;
float noise1Factor = 5;
float noise2Factor = 5;
float noise3Factor = 5;
float radiusMedian;
float radiusMedianFactor = 0.2; // Percentage of the width for calculating radiusMedian
float radiusFactor = 0;         // By how much (+/- %) should the radius vary throughout the timelapse cycle?
float radius;
//float seed1 =random(1000);  // To give random variation between the 3D noisespaces
//float seed2 =random(1000);  // One seed per noisespace
//float seed3 =random(1000);
float seed1 =0;  // To give random variation between the 3D noisespaces
float seed2 =100;  // One seed per noisespace
float seed3 =200;
int noiseSeed = 1000;

int noiseOctaves; // Integer in the range 3-8? Default: 7
int noiseOctavesMin = 4;
int noiseOctavesMax = 4;
float noiseFalloff; // Float in the range 0.0 - 1.0 Default: 0.5 NOTE: Values >0.5 may give noise() value >1.0
float noiseFalloffMin = 0.5;
float noiseFalloffMax = 0.5;

// Generator variables
float epochAngle, epochCosWave, epochSineWave;
float generationAngle, generationSineWave, generationCosWave;

// Cartesian Grid variables: 
int columns = 8;
int rows, h, w;
float colOffset, rowOffset, hwRatio;

// Size variables
float ellipseSize;
float ellipseMaxSize = 2.5;

// Stripe variables
float stripeWidthFactorMin = 0.005;
float stripeWidthFactorMax = 0.05;
float stripeFactor = 0.5;
//int stripeWidth = int(generations * stripeWidthFactor); // stripeWidth is a % of # generations in an epoch
int stripeWidth = int(map(generation, 1, generations, generations*stripeWidthFactorMax, generations*stripeWidthFactorMin));;
int stripeCounter = stripeWidth;

// Colour variables:
float bkg_Hue;
float bkg_Sat;
float bkg_Bri;

// Output configuration toggles:
boolean makeGenerationPNG = false;  // Use with care! Will save one image per draw() frame!
boolean makePDF = false;            // Enable .pdf 'timelapse' output of all the generations in a single epoch
boolean makeEpochPNG = true;       // Enable .png 'timelapse' output of all the generations in a single epoch
boolean makeGenerationMPEG = false; // Enable video output for animation of a single generation cycle (one frame per draw cycle, one video per generations sequence)
boolean makeEpochMPEG = false;       // Enable video output for animation of a series of generation cycles (one frame per generations cycle, one video per epoch sequence)
boolean debugMode = false;          // Enable logging to debug file

PrintWriter logFile;   // Object for writing to the settings logfile
PrintWriter debugFile; // Object for writing to the debug logfile

void setup() {
  //fullScreen();
  //size(10000, 10000);
  //size(6000, 6000);
  size(4000, 4000);
  //size(2000, 2000);
  //size(1024, 1024);
  //size(1000, 1000);
  //size(800, 800);
  //size(400,400);
  colorMode(HSB, 360, 255, 255, 255);
  bkg_Hue = 240;
  bkg_Sat = 255;
  bkg_Bri = 0;
  //background(bkg_Bri);
  background(bkg_Hue, bkg_Sat, bkg_Bri);
  noiseSeed(noiseSeed); //To make the noisespace identical each time (for repeatability) 
  noStroke();
  //stroke(0);
  ellipseMode(RADIUS);
  rectMode(RADIUS);
  h = height;
  w = width;
  radiusMedian = w * radiusMedianFactor; // Better to scale radiusMedian to the current canvas size than use a static value
  hwRatio = h/w;
  println("Width: " + w + " Height: " + h + " h/w ratio: " + hwRatio);
  //columns = int(random(3, 7));
  //columns = 3;
  rows = int(hwRatio * columns);
  //rows = columns;
  //rows=5;
  colOffset = w/(columns*2);
  rowOffset = h/(rows*2);
  getReady();
  if (makeGenerationMPEG) {makeEpochMPEG = false; epochs = 1;} // When making a generation video, stop after one epoch
  if (makeEpochMPEG) {makeGenerationMPEG = false;}             // Only one type of video file is possible at a time
  if (makeGenerationMPEG || makeEpochMPEG) {
    videoExport = new VideoExport(this, mp4File);
    videoExport.setQuality(videoQuality, 128);
    videoExport.setFrameRate(videoFPS); // fps setting for output video (should not be lower than 30)
    videoExport.setDebugging(false);
    videoExport.startMovie();
  }
}


void draw() {

  // What to do when an epoch is over? (when all the generations in the epoch have been completed)
  if (generation == generations) {
    if (debugMode) {debugFile.println("Epoch " + epoch + " has ended.");}
    println("Epoch " + epoch + " has ended.");
    generation = 1; // Reset the generation counter for the next epoch
    stripeCounter = stripeWidth; // Reset the stripeCounter for the next epoch 
    if (makeEpochMPEG) {
        videoExport.saveFrame(); // Add an image of the generation frame to the generation video file:
        background(bkg_Hue, bkg_Sat, bkg_Bri); //Refresh the background
        //background(bkg_Bri);
      }
    if (epoch == epochs) {
      // The sketch has reached the end of it's intended lifecycle
      // Time to close up shop...
      println("The last epoch has ended. Goodbye!");
      shutdown();
    }
    epoch++; // An epoch has ended, increase the counter
  }
  
  if (debugMode) {
    debugFile.println("Epoch: " + epoch + " of " + epochs);
    debugFile.println("Generation: " + generation + " of " + generations);
  }
  
  if (stripeCounter <= 0) {
    // The stripe has been completed so reset the counter & start the next one
    stripeWidth = int(map(generation, 1, generations, generations*stripeWidthFactorMax, generations*stripeWidthFactorMin));
    stripeCounter = stripeWidth;

  }
  
  // 'Driver' variables modulated over a succession of epochs:
  //println("epoch=" + epoch + " epochs=" + epochs + "(epoch/epochs * TWO_PI)=" + (epoch/epochs * TWO_PI) );
  epochAngle = PI + (epoch/epochs * TWO_PI); // Angle will turn through a full circle throughout one epoch
  // NOTE: Can't use map() as both epoch & epochs will sometimes = 1
  epochSineWave = sin(epochAngle); // Range: -1 to +1
  epochCosWave = cos(epochAngle); // Range: -1 to +1
  radius = radiusMedian * map(epochSineWave, -1, 1, 1-radiusFactor, 1+radiusFactor); //radius is scaled by epoch
    
  // 'Driver' variables modulated over a succession of generations (ie. during an epoch):
  generationAngle = map(generation, 1, generations, 0, TWO_PI); // The angle for various cyclic calculations increases from zero to 2PI as the minor loop runs
  generationSineWave = sin(generationAngle);
  generationCosWave = cos(generationAngle);
  
  ellipseSize = map(generation, 1, generations, ellipseMaxSize, 0); // The scaling factor for ellipseSize  from max to zero as the minor loop runs
  
  //stripeFactor = map(generation, 1, generations, 0.5, 0.5);
  //float remainingSteps = generations - generation; //For stripes that are a % of remainingSteps in the loop
  //stripeWidth = (remainingSteps * 0.3) + 10;
  //stripeWidth = map(generation, 1, generations, generations*0.25, generations*0.1);
    
  noiseOctaves = int(map(epochCosWave, -1, 1, noiseOctavesMin, noiseOctavesMax));
  noiseFalloff = map(epochCosWave, -1, 1, noiseFalloffMin, noiseFalloffMax);
  noiseDetail(noiseOctaves, noiseFalloff);
  
  //noiseFactor = sq(map(epochCosWave, -1, 1, noiseFactorMax, noiseFactorMin));
  noiseFactor = sq(map(generationCosWave, -1, 1, noiseFactorMax, noiseFactorMin));
  noise1Scale = noise1Factor/(noiseFactor*w);
  noise2Scale = noise2Factor/(noiseFactor*w);
  noise3Scale = noise3Factor/(noiseFactor*w);
   
  //noiseLoopX = width*0.5 + radius * cos(generationAngle); 
  //noiseLoopY= height*0.5 + radius * sin(generationAngle);
  //float generationAngleZ = generationAngle; // This angle will be used to move through the z axis
  //noiseLoopZ = width*0.5 + radius * cos(generationAngleZ); // Offset is arbitrary but must stay positive
  
  if (debugMode) {debugFile.println("Frame: " + frameCount + " Generation: " + generation + " Epoch: " + epoch + " noiseFactor: " + noiseFactor + " noiseOctaves: " + noiseOctaves + " noiseFalloff: " + noiseFalloff);}
  
  //Run the colony (1 iteration through all cells)
  colony.run();
  
  // EACH CELL'S NOISE PATH CAN LATER BE CALCULATED IN THE CELL USING A ROTATED VECTOR (ROTATE BY EPOCH OR GENERATION ANGLE)
  //noiseLoopX = width*0.5 + radius * generationCosWave;   // px is in 'canvas space'
  //noiseLoopY = height*0.5 + radius * generationSineWave; // py is in 'canvas space'
  noiseLoopX = width*0.5 + radius * epochCosWave;   // px is in 'canvas space'
  noiseLoopY = height*0.5 + radius * epochSineWave; // py is in 'canvas space'
  noiseLoopZ = map(generation, 1, generations, 0, width); //pz is in 'canvas space'
    
  // NOISE SEEDS WILL REMAIN GLOBAL, SINCE ALL CELLS EXIST IN THE SAME NOISESPACE(S)
  seed1 = map(epochCosWave, -1, 1, 0, 100);
  seed2 = map(epochCosWave, -1, 1, 0, 200);
  seed3 = map(epochCosWave, -1, 1, 0, 300);
  //println("Epoch " + epoch + " of " + epochs + " epochAngle=" + epochAngle + " epochCosWave=" + epochCosWave + " seed1=" + seed1 + " seed2=" + seed2 + " seed3=" + seed3);
  
  // After you have drawn all the elements in the colony:
  
  if (debugMode) {debugFile.println("Generation " + generation + " has ended.");}
    
  // Save an image of the generation frame to the archive folder:
  if (makeGenerationPNG) {saveFrame( "save/"+ nf(generation, 3)+ ".jpg");}
  
  // Add an image of the generation frame to the generation video file:
  if (makeGenerationMPEG) {videoExport.saveFrame();}
  
  generation++; // A generation has ended, Increase the generation counter by +1 (for each iteration of draw() - a frame)
  stripeCounter--;

  // Old function - to animate every frame in the drawCycle:
  //background(bkg_Hue, bkg_Sat, bkg_Bri);

} //Closes draw() loop


void keyPressed() {
  if (key == 'q') {
    shutdown();
  }
}

// Prepares pathnames for various file outputs
void getReady() {
  String batchName = String.valueOf(nf(batch,3));
  String timestamp = timeStamp();
  String pathName = "../../output/" + applicationName + "/" + batchName + "/" + String.valueOf(width) + "x" + String.valueOf(height) + "/"; //local
  pngFile = pathName + "png/" + applicationName + "-" + batchName + "-" + timestamp + ".png";
  //screendumpPath = "../output.png"; // For use when running from local bot
  pdfFile = pathName + "pdf/" + applicationName + "-" + batchName + "-" + timestamp + ".pdf";
  mp4File = pathName + applicationName + "-" + batchName + "-" + timestamp + ".mp4";
  logFileName = pathName + "settings/" + applicationName + "-" + batchName + "-" + timestamp + ".log";
  logFile = createWriter(logFileName); //Open a new settings logfile
  logSettings();
  if (debugMode) {
    debugFileName = pathName + "debug/" + applicationName + "-" + batchName + "-" + timestamp + "debug.log";
    debugFile = createWriter(debugFileName); //Open a new debug logfile
  }
  if (makePDF) {
    epochs = 1;
    beginRecord(PDF, pdfFile);
  }
  colony = new Colony();
}


// Saves an image of the final frame, closes any pdf & mpeg files and exits tidily
void shutdown() {
  if (debugMode) {debugEnd();}
  
  // Save an image of the generation or epoch final frame to the archive folder:
  if (makeEpochPNG) {
    saveFrame(pngFile);
    println("Saving .png file: " + pngFile);
  }
  
  // If I'm in PDF-mode, complete & close the file
  if (makePDF) {
    println("Saving .pdf file: " + pdfFile);
    endRecord();
  }
  
  // If I'm in MPEG mode, complete & close the file
  if (makeGenerationMPEG || makeEpochMPEG) {
    println("Saving .mp4 file: " + mp4File);
    videoExport.endMovie();}
  exit();
}


// Returns a string with the date & time in the format 'yyyymmdd-hhmmss'
String timeStamp() {
  String s = String.valueOf(nf(second(),2));
  String m = String.valueOf(nf(minute(),2));
  String h = String.valueOf(nf(hour(),2));
  String d = String.valueOf(nf(day(),2));
  String mo = String.valueOf(nf(month(),2));
  String y = String.valueOf(nf(year(),4));
  String timestamp = y + mo + d + "-" + h + m + s;
  return timestamp;
}

// Could rename?
void logSettings() {
  logFile.println(pngFile);
  logFile.println("width = " + w);
  logFile.println("height = " + h);
  logFile.println("videoQuality = " + videoQuality);
  logFile.println("videoFPS = " + videoFPS);
  logFile.println("generations = " + generations);
  logFile.println("epochs = " + epochs);
  logFile.println("columns = " + columns);
  logFile.println("rows = " + rows);
  logFile.println("makePDF = " + makePDF);
  logFile.println("makeGenerationPNG = " + makeGenerationPNG);
  logFile.println("makeEpochPNG = " + makeEpochPNG);
  logFile.println("makeGenerationMPEG = " + makeGenerationMPEG);
  logFile.println("makeEpochMPEG = " + makeEpochMPEG);
  logFile.println("debugMode = " + debugMode);
  logFile.println("ellipseMaxSize = " + ellipseMaxSize);
  logFile.println("noiseSeed = " + noiseSeed);
  logFile.println("seed1 = " + seed1);
  logFile.println("seed2 = " + seed2);
  logFile.println("seed3 = " + seed3);
  logFile.println("noiseFactorMin = " + noiseFactorMin);
  logFile.println("noiseFactorMax = " + noiseFactorMax);
  logFile.println("noiseOctavesMin = " + noiseOctavesMin);
  logFile.println("noiseOctavesMax = " + noiseOctavesMax);
  logFile.println("noiseFalloffMin = " + noiseFalloffMin);
  logFile.println("noiseFalloffMax = " + noiseFalloffMax);
  logFile.println("noise1Factor = " + noise1Factor);
  logFile.println("noise2Factor = " + noise2Factor);
  logFile.println("noise3Factor = " + noise3Factor);
  logFile.println("radiusMedianFactor = " + radiusMedianFactor);
  logFile.println("radiusMedian = " + radiusMedian);
  logFile.println("stripeWidthFactorMin = " + stripeWidthFactorMin);
  logFile.println("stripeWidthFactorMax = " + stripeWidthFactorMax);
  logFile.println("stripeWidth = " + stripeWidth);
  logFile.println("radiusFactor = " + radiusFactor);
  logEnd();
}

void logEnd() {
  logFile.flush();
  logFile.close(); //Flush and close the settings file
  println("Saved .log file: " + logFileName);
}

void debugEnd() {
  debugFile.flush();
  debugFile.close(); //Flush and close the settings file
  println("Saved debug.log file: " + debugFileName);
}