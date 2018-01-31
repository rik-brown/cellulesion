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

// OBSERVATION: When making video timelapse, the pathway to construct each each frame need not be circular!
// OBSERVATION: If seed1, 2 & 3 are equal, noise1, 2 & 3 will also be the same when x = y

import com.hamoid.*;     // For converting frames to a .mp4 video file 
import processing.pdf.*; // For exporting output as a .pdf file

VideoExport videoExport;

// File Management variables:
int batch = 4;
String applicationName = "circulesion";
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
float noise1Scale, noise2Scale, noise3Scale, noiseFactor;
float noiseFactorMin = 2.5; 
float noiseFactorMax = 5;
float noise1Factor = 5;
float noise2Factor = 5;
float noise3Factor = 5;
float radiusMedian;
float radiusMedianFactor = 0.2; // Percentage of the width for calculating radiusMedian
float radiusFactor = 0;         // By how much (+/- %) should the radius vary throughout the timelapse cycle?

//float seed1 =random(1000);  // To give random variation between the 3D noisespaces
//float seed2 =random(1000);  // One seed per noisespace
//float seed3 =random(1000);
float seed1 =0;  // To give random variation between the 3D noisespaces
float seed2 =0;  // One seed per noisespace
float seed3 =0;
int noiseSeed = 0;

int noiseOctaves; // Integer in the range 3-8? Default: 7
int noiseOctavesMin = 4;
int noiseOctavesMax = 4;
float noiseFalloff; // Float in the range 0.0 - 1.0 Default: 0.5 NOTE: Values >0.5 may give noise() value >1.0
float noiseFalloffMin = 0.5;
float noiseFalloffMax = 0.5;

// Generator variables
float epochCosWave, epochSineWave;

// Cartesian Grid variables: 
int columns = 8;
int rows, h, w;
float colOffset, rowOffset, hwRatio;

// Size variables
float ellipseMaxSize = 2.5;

// Stripe variables
float stripeWidthFactorMin = 0.01;
float stripeWidthFactorMax = 0.1;
//int stripeWidth = int(generations * stripeWidthFactor); // stripeWidth is a % of # generations in an epoch
int stripeWidth = 20;
int stripeCounter = 0;

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
    epoch++; // An epoch has ended, increase the counter
    generation = 1; // Reset the generation counter for the next epoch
    stripeCounter = stripeWidth; // Reset the stripeCounter for the next epoch 
    if (makeEpochMPEG) {
        videoExport.saveFrame(); // Add an image of the generation frame to the generation video file:
        background(bkg_Hue, bkg_Sat, bkg_Bri); //Refresh the background
        //background(bkg_Bri);
      }
    if (epoch >= epochs) {
      // The sketch has reached the end of it's intended lifecycle
      // Time to close up shop...
      println("The last epoch has ended. Goodbye!");
      shutdown();
    }
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
  float epochAngle = PI + (epoch/epochs * TWO_PI); // Angle will turn through a full circle throughout one epoch
  // NOTE: Can't use map() as both epoch & epochs will sometimes = 1
  epochSineWave = sin(epochAngle); // Range: -1 to +1
  epochCosWave = cos(epochAngle); // Range: -1 to +1
  float radius = radiusMedian * map(epochSineWave, -1, 1, 1-radiusFactor, 1+radiusFactor); //radius is scaled by epoch
    
  // 'Driver' variables modulated over a succession of generations (ie. during an epoch):
  float t = map(generation, 1, generations, 0, TWO_PI); // The angle for various cyclic calculations increases from zero to 2PI as the minor loop runs
  float sineWave = sin(t);
  float cosWave = cos(t);
  
  float ellipseSize = map(generation, 1, generations, ellipseMaxSize, 0); // The scaling factor for ellipseSize  from max to zero as the minor loop runs
  
  float stripeFactor = map(generation, 1, generations, 0.5, 0.5);
  //float remainingSteps = generations - generation; //For stripes that are a % of remainingSteps in the loop
  //stripeWidth = (remainingSteps * 0.3) + 10;
  //stripeWidth = map(generation, 1, generations, generations*0.25, generations*0.1);
    
  noiseOctaves = int(map(epochCosWave, -1, 1, noiseOctavesMin, noiseOctavesMax));
  noiseFalloff = map(epochCosWave, -1, 1, noiseFalloffMin, noiseFalloffMax);
  noiseDetail(noiseOctaves, noiseFalloff);
  
  //noiseFactor = sq(map(epochCosWave, -1, 1, noiseFactorMax, noiseFactorMin));
  noiseFactor = sq(map(cosWave, -1, 1, noiseFactorMax, noiseFactorMin));
  noise1Scale = noise1Factor/(noiseFactor*w);
  noise2Scale = noise2Factor/(noiseFactor*w);
  noise3Scale = noise3Factor/(noiseFactor*w);
   
  //float px = width*0.5 + radius * cos(t); 
  //float py = height*0.5 + radius * sin(t);
  //float tz = t; // This angle will be used to move through the z axis
  //float pz = width*0.5 + radius * cos(tz); // Offset is arbitrary but must stay positive
  
  if (debugMode) {debugFile.println("Frame: " + frameCount + " Generation: " + generation + " Epoch: " + epoch + " noiseFactor: " + noiseFactor + " noiseOctaves: " + noiseOctaves + " noiseFalloff: " + noiseFalloff);}
  
  //loop through all the elements in the cartesian grid
  for(int col = 0; col<columns; col++) {
    if (debugMode) {debugFile.println("Col: " + (col+1) + " of " + columns);}
    for(int row = 0; row<rows; row++) {
      if (debugMode) {debugFile.println("Row: " + (row+1) + " of " + rows);}
      // This is where the code for each element in the grid goes
      // All the calculations which are specific to the individual element
      
      // 1) Map the grid coords (row/col) to the x/y coords in the canvas space 
      float gridx = map (col, 0, columns, 0, width) + colOffset; // gridx is in 'canvas space'
      float gridy = map (row, 0, rows, 0, height) + rowOffset;   // gridy is in 'canvas space'
      
      // 2) A useful value for modulating other parameters can be calculated: 
      float distToCenter = dist(gridx, gridy, width*0.5, height*0.5);  // distToCenter is in 'canvas space'
      
      // 3) The radius for the x-y(z) noise loop can now be calculated (if not already done so):
      //radius = radiusMedian * map(distToCenter, 0, width*0.7, 0.5, 1.0); // In this case, radius is influenced by the distToCenter value
      
      // 4) The x-y co-ordinates (in canvas space) of the circular path can now be calculated:
      //float px = width*0.5 + radius * cosWave;   // px is in 'canvas space'
      //float py = height*0.5 + radius * sineWave; // py is in 'canvas space'
      float px = width*0.5 + radius * epochCosWave;   // px is in 'canvas space'
      float py = height*0.5 + radius * epochSineWave; // py is in 'canvas space'
      float pz = map(generation, 1, generations, 0, width); //pz is in 'canvas space'
      
      //noise1Scale = map(distToCenter, 0, width*0.7, 0.0005, 0.05); // If Scale factor is to be influenced by dist2C: 
      
      //noiseN is a 3D noise value comprised of these 3 components:
      // X co-ordinate:
      // gridx (cartesian grid position on the 2D canvas)
      // +
      // px (x co-ordinate of the current point of the circular noisepath on the 2D canvas)
      // +
      // seedN (arbitrary noise seed number offsetting the canvas along the x-axis)
      //
      // The sum of these values is multiplied by the constant scaling factor 'noise1Scale' (whose values does not change relative to window size)
      
      // Y co-ordinate:
      // gridy (cartesian grid position on the 2D canvas)
      // +
      // py (y co-ordinate of the current point of the circular noisepath on the 2D canvas)
      // +
      // seedN (arbitrary noise seed number offsetting the canvas along the x-axis)
      //
      // The sum of these values is multiplied by the constant scaling factor 'noise1Scale' (whose values does not change relative to window size)
      
      // Z co-ordinate:
      // Z is different from X & Y as it only needs to follow a one-dimensional cyclic path (returning to where it starts)
      // It could keep a constant rate of change up & down (like an elevator) but I thought a sinewave might be more interesting
      // It occurred to me that I could just as well re-use either px or py (and not even bother offsetting the angle to start at a max or min)
      // I haven't really experimented with any other strategies, so I could be missing something here.
      // I have a nagging feeling that the 3D pathway should be more sophisticated (e.g. mapping the surface of a sphere)
      // but I'm not certain enough to invest the time learning the more advanced math required. (TO DO...)
      //
      // px (x co-ordinate of the current point of the circular noisepath on the 2D canvas)
      // +
      // seedN (arbitrary noise seed number offsetting the canvas along the x-axis)
      //
      // The sum of these values is multiplied by the constant scaling factor 'noise1Scale' (whose values does not change relative to window size)
      
      //noise1, 2 & 3 are basically 3 identical 'grid systems' offset at 3 arbitrary locations in the 3D noisespace.
      
      seed1 = map(epochCosWave, -1, 1, 0, 100);
      seed2 = map(epochCosWave, -1, 1, 0, 200);
      seed3 = map(epochCosWave, -1, 1, 0, 300);
      //println("Epoch " + epoch + " of " + epochs + " epochAngle=" + epochAngle + " epochCosWave=" + epochCosWave + " seed1=" + seed1 + " seed2=" + seed2 + " seed3=" + seed3);
      
      float noise1 = noise(noise1Scale*(gridx + px + seed1), noise1Scale*(gridy + py + seed1), noise1Scale*(pz + seed1));
      float noise2 = noise(noise2Scale*(gridx + px + seed2), noise2Scale*(gridy + py + seed2), noise2Scale*(pz + seed2));
      float noise3 = noise(noise3Scale*(gridx + px + seed3), noise3Scale*(gridy + py + seed3), noise3Scale*(pz + seed3));
      
      float rx = map(noise2,0,1,0,colOffset*ellipseSize);
      //float ry = map(noise3,0,1,0,rowOffset*ellipseSize);
      float ry = map(noise3,0,1,0.5,1.0);
      //float fill_Hue = map(noise1, 0, 1, 0, 20);
      
      

    } //Closes 'rows' loop
  } //Closes 'columns' loop
  
  // After you have drawn all the elements in the cartesian grid:
  
  if (debugMode) {debugFile.println("Generation " + generation + " has ended.");}
    
  // Save an image of the generation frame to the archive folder:
  if (makeGenerationPNG) {saveFrame( "save/"+ nf(generation, 3)+ ".jpg");}
  
  // Add an image of the generation frame to the generation video file:
  if (makeGenerationMPEG) {videoExport.saveFrame();}
  
  generation++; // A generation has ended, Increase the generation counter by +1 (for each iteration of draw() - a frame)
  stripeCounter--;

  // Old function - to animate every frame in the drawCycle:
  //bkg_Hue = map(sineWave, -1, 1, 240, 200);
  //bkg_Bri = map(sineWave, -1, 1, 100, 255);
  //background(bkg_Hue, bkg_Sat, bkg_Bri);
  //background(bkg_Bri);
  //background(bkg_Hue, 0, bkg_Bri);

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