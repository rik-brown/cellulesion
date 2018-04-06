// Cellulesion
// Origin story: 'Circulesion' refactored into object-oriented code to lay foundation for vectors & movement
// Summary: Exploration of spatial & temporal modulation of velocity, shape & colour using Perlin Noise as primary source of 'environmental variation'
// 2018-01-31 22:56

/* BUGS:
  + PImage img seems to be rotated 90 degrees anticlockwise
  
*/

/* IMPROVEMENTS:
   * 04.04.18 Hitting a certain hue = death
   * 26.03.18 Make sure ALL relevant settings are logged by logSettings()
   * 23.03.18 Colourwalker: Sample colour at position. If hue is going clockwise in the colour circle, turn velocity clockwise. Scale by brightness (stop at black?)
   > The closer to successive hues are to one another, the lower the angular deflection should be. Configurable range (0-180 degrees is maximum).
   > Could use FromAngle - LerpColor??
   > Alternatively: lerp() between old velocity & new 'from colour angle' velocity? (can vary % of new angle vs % of old)
   > 01.04.18 Trying for velocity from lerped colour.
   * Is it time to start considering the noisefields with specific purposes in mind?
   * Colour array should also be able to 'move and warp' through the epochs in a similar way to start position 
   * Think about the requirements for passing values BACK into the array
      - they must be the (absolute) cell values which change during growth (like position?), not the multiplying factors
*/

/* REFACTORING:
  + Simplify the code - both size & vMax arrays (& there will be others) are populated with values in range 0-1 by a variety of algorithms. Synergies!
  + Consider moving epoch-modulated values so they are only recalculated ONCE at the start of an epoch (e.g. if(generation==1) {newEpoch()}
  + Make a variable for selecting render type (primitive: rect, ellipse or triangle) (2018-01-16)
  + NEED a way of logging the pattern configuration choices (need to be parameterized)
  + Option to export .png epoch frames with framenr. as filename & timestamp as folder for later conversion to video (more flexibility to optimise)
    * See http://hamelot.io/visualization/using-ffmpeg-to-convert-a-set-of-images-into-a-video/
  + Populate arrays with the ranges of required sin/cos values (e.g. equal to number of generations) instead of recalculating each time
*/

/* NEW FEATURES:
  + Consider ways in which new cells may be ADDED after the colony has started running
    > Seriously? How will this look in videos with new cells suddenly appearing?)
  + Introduce branching ?
  + Instead of 2D noisefield use an image and pick out the colour values from the pixels!!! Vary radius of circular path for each cycle :D
  + 'Chosen ones' get a different colour than all the others (& why not a different set of values in other ways too?)
  + Pick from a pallette of colours rather than always calculating each HSB value individually.
  + Phyllotaxis seed position
  + Seed position as grid but only add cell if noise value is above a given threshold
  + Alternative rendering patterns:
    > Triangle strips?
    > Lines
*/ 


/* RANDOM IDEAS:
  ? Try using RGB mode to make gradients from one hue to another, instead of light/dark etc. (2018-01-04)
*/

/* DOCUMENTATION TASKS:
  + Make a list of variables that can be modulated through the Epoch, noting which ones I have tried & result:
  1) noiseRadius  1/6  Just seemed to modulate size, not very exciting 
  2) noiseFactor  4/6  Best when increasing as sq() from very high value to a low-end/high variation
  3) noiseOctaves 1/6  Is an integer, so changes in steps rather than smooth transition
  4) noiseFallOff
  5) noiseSeed
  6) cellSizeGlobalMax
  7) generations
*/

import com.hamoid.*;                          // For converting frames to a .mp4 video file 
import processing.pdf.*;                      // For exporting output as a .pdf file

Positions positions;                          // A Positions object called 'positions'
Sizes sizes;                                  // A Sizes object called 'sizes'
Velocities velocities;                        // A Velocities object called 'velocities'
Colours colours;
Colony colony;                                // A Colony object called 'colony'
VideoExport videoExport;                      // A VideoExport object called 'videoExport'
PImage img;                                   // A PImage object called 'img' (used when importing a source image)

// Output configuration toggles:
boolean makeGenerationPNG = false;            // Enable .png output of each generation. (CAUTION! Will save one image per draw() frame!)
boolean makeEpochPNG = false;                 // Enable .png 'timelapse' output of each epoch (CAUTION! Will save one image for every epoch in the series)
boolean makeFinalPNG = false;                 // Enable .png 'timelapse' output of the last epoch in a series of epochs
boolean makeEpochPDF = false;                 // Enable .pdf 'timelapse' output of all the generations in a single epoch (forces epochs =1)
boolean makeGenerationMPEG = false;           // Enable video output for animation of a single generation cycle (one frame per draw cycle, one video per generations sequence)
boolean makeEpochMPEG = true;                 // Enable video output for animation of a series of generation cycles (one frame per generations cycle, one video per epoch sequence)
boolean debugMode = false;                    // Enable logging to debug file

// Operating mode toggles:
boolean colourFromImage = false;

// File Management variables:
String batchName = "007";                     // Simple version number for design batches (updated manually when the mood takes me)
String pathName;                              // Path the root folder for all output
//String timestamp;                             // Holds the formatted time & date when timestamp() is called
String applicationName = "cellulesion";       // Used as the root folder for all output
String logFileName;                           // Name & location of logfile (.log)
String debugFileName;                         // Name & location of logfile (.log)
String pngFile;                               // Name & location of saved output (.png final image)
String pdfFile;                               // Name & location of saved output (.pdf file)
String mp4File;                               // Name & location of video output (.mp4 file)
//String inputFile = "Blue_red_green_2_blobs.png";               // First run will use /data/input.png, which will not be overwritten
String inputFile = "IMG_9343.JPG";               // First run will use /data/input.png, which will not be overwritten
PrintWriter logFile;                          // Object for writing to the settings logfile
PrintWriter debugFile;                        // Object for writing to the debug logfile

// Video export variables:
int videoQuality = 85;                        // 100 = highest quality (lossless), 70 = default 
int videoFPS = 30;                            // Framerate for video playback

// Loop Control variables:
float generationsScaleMin = 0.25;            // Minimum value for modulated generationsScale
float generationsScaleMax = 0.25;              // Maximum value for modulated generationsScale
float generationsScale = 0.001;                // Static value for modulated generationsScale (fallback, used if no modulation)
int generations;                            // Total number of drawcycles (frames) in a generation (timelapse loop) (% of width)
float epochs = 360;                           // The number of epoch frames in the video (Divide by 60 for duration (sec) @60fps, or 30 @30fps)
int generation = 1;                           // Generation counter starts at 1
float epoch = 1;                              // Epoch counter starts at 1. Note: Epoch & Epochs are floats because they are used in a division formula.

// Feedback variables:
int chosenOne;                                // A random number in the range 0-population.size(). The cell whose position is used to give x-y feedback to noise_1.
int chosenTwo;                                // A random number in the range 0-population.size(). The cell whose position is used to give x-y feedback to noise_2.
int chosenThree;                              // A random number in the range 0-population.size(). The cell whose position is used to give x-y feedback to noise_3.
float feedbackPosX_1, feedbackPosY_1;         // The x-y coords of the cell used for feedback to noise_1
float feedbackPosX_2, feedbackPosY_2;         // The x-y coords of the cell used for feedback to noise_1
float feedbackPosX_3, feedbackPosY_3;         // The x-y coords of the cell used for feedback to noise_1

// NoiseLoop variables:
//float noiseLoopX, noiseLoopY, noiseLoopZ;     // The x-y-z coords of a looping path in canvas-space that can be used for cyclic animations
//float noiseLoopRadiusMedian;                  // Median value for noiseLoop noiseLoopRadius
//float noiseLoopRadiusMedianFactor = 0.2;      // Percentage of the width for calculating noiseLoopRadiusMedian
//float noiseLoopRadiusFactor = 0;              // By how much (+/- %) should the noiseLoopRadius vary throughout the timelapse cycle?
//float noiseLoopRadius;                        // The radius of the noiseLoop (in canvas space)

// NoiseScale & Offset variables:
float noise1Scale, noise2Scale, noise3Scale;  // Scaling factors for calculation of noise1,2&3 values
float noiseScale1, noiseScale2, noiseScale3;  // Scaling factors for calculation of noise1,2&3 values

float noiseFactor;                            // Scaling factor for calculation of noise values (denominator in noiseScale calculation)
float noiseFactorMin = 4.0;                   // Minimum value for modulated noiseFactor
float noiseFactorMax = 4.0;                   // Maximum value for modulated noiseFactor
float noise1Factor = 5;                       // Value for constant noiseFactor, noise1 (numerator in noiseScale calculation)
float noise2Factor = 5;                       // Value for constant noiseFactor, noise2 (numerator in noiseScale calculation)
float noise3Factor = 5;                       // Value for constant noiseFactor, noise3 (numerator in noiseScale calculation)

//float noise1Offset =random(1000);             // Offset for the noisespace x&y coords (noise1) 
//float noise2Offset =random(1000);             // Offset for the noisespace x&y coords (noise2)
//float noise3Offset =random(1000);             // Offset for the noisespace x&y coords (noise3)
float noise1Offset =0;                        // Offset for the noisespace x&y coords (noise1)
float noise2Offset =1000;                     // Offset for the noisespace x&y coords (noise2)
float noise3Offset =2000;                     // Offset for the noisespace x&y coords (noise3)

// Noise initialisation variables:
int noiseSeed = 0;                       // To fix all noise values to a repeatable pattern
//int noiseSeed = int(random(10000));
int noiseOctaves = 7;                         // Integer in the range 3-8? Default: 7
int noiseOctavesMin = 7;                      // Minimum value for modulated noiseOctaves
int noiseOctavesMax = 7;                      // Maximum value for modulated noiseOctaves
float noiseFalloff = 0.5;                     // Float in the range 0.0 - 1.0 Default: 0.5 NOTE: Values >0.5 may give noise() value >1.0
float noiseFalloffMin = 0.5;                  // Minimum value for modulated noiseFalloff
float noiseFalloffMax = 0.5;                  // Maximum value for modulated noiseFalloff

// Generator variables:
float epochAngle, epochCosWave, epochSineWave;                //Angle turns full circle in one Epoch cycle      giving Cos & Sin values in range -1/+1
float generationAngle, generationSineWave, generationCosWave; //Angle turns full circle in one Generation cycle giving Cos & Sin values in range -1/+1

// Cartesian Grid variables: 
int  h, w, hwRatio;                           // Height & Width of the canvas & ratio h/w
int columns = 17;                              // Number of columns in the cartesian grid
int rows;                                     // Number of rows in the cartesian grid. Value is calculated in setup();
int elements;                                 // Total number of elements in the initial spawn (=columns*rows)
float colOffset, rowOffset;                   // col- & rowOffset give correct spacing between rows & columns & canvas edges

// Element Size variables (ellipse, triangle, rectangle):
float  cellSizeGlobal;                            // Scaling factor for drawn elements
float  cellSizeGlobalMin = 0.6;                   // Minimum value for modulated  cellSizeGlobal (1.0 = 100% = no gap/overlap between adjacent elements in cartesian grid) 
float  cellSizeGlobalMax = 1.333;                   // Maximum value for modulated  cellSizeGlobal (1.0 = 100% = no gap/overlap between adjacent elements in cartesian grid)

// Global velocity variable:
float vMaxGlobal;
float vMaxGlobalMin = 1.0;
float vMaxGlobalMax = 1.75;

// Global offsetAngle variable:
float offsetAngleGlobal;

// Stripe variables:
float stripeWidthFactorMin = 0.15;            // Minimum value for modulated stripeWidthFactor
float stripeWidthFactorMax = 0.3;             // Maximum value for modulated stripeWidthFactor
// stripeWidth is the width of a PAIR of stripes (e.g. background colour/foregroundcolour)
//int stripeWidth = int(generations * stripeWidthFactor); // stripeWidth is a % of # generations in an epoch
int stripeWidth = int(map(generation, 1, generations, generations*stripeWidthFactorMax, generations*stripeWidthFactorMin));;
float stripeFactor = 0.5;                     // Ratio between the pair of stripes in stripeWidth. 0.5 = 50/50 = equal distribution
int stripeCounter = stripeWidth;              // Counter marking the progress through the stripe (increments -1 each drawcycle)

// Colour variables:
float bkg_Hue;                                // Background Hue
float bkg_Sat;                                // Background Saturation
float bkg_Bri;                                // Background Brightness

void setup() {
  //frameRate(5);
  
  //fullScreen();
  //size(4960, 7016); // A4 @ 600dpi
  //size(10000, 10000);
  //size(6000, 6000);
  //size(4000, 4000);
  //size(2000, 2000);
  //size(1280, 1280);
  size(1080, 1080);
  //size(1000, 1000);
  //size(640, 1136); // iphone5
  //size(800, 800);
  //size(600,600);
  //size(400,400);
  
  colorMode(HSB, 360, 255, 255, 255);
  //colorMode(RGB, 360, 255, 255, 255);
  
  bkg_Hue = 229; // Red in RGB mode
  bkg_Sat = 255*0.34; // Green in RGB mode
  bkg_Bri = 255*0.63; // Blue in RGB mode
  background(bkg_Hue, bkg_Sat, bkg_Bri);
  
  noiseSeed(noiseSeed); //To make the noisespace identical each time (for repeatability) 
  ellipseMode(RADIUS);
  rectMode(RADIUS);
  getReady();
}


void draw() {
  // Update input values:
  updateEpochDrivers();      // Update 'Epoch Drivers'
  updateFeedback();          // Update feedback values
  
  // Modulate:
  modulateByEpoch();         // Update values which are modulated by epoch
  updateGenerations();       // Update the generations variable (if it is dynamically scaled)  
  updateGenerationDrivers(); // Update 'Generation Drivers'
  modulateByGeneration();
  modulateByFeedback();
  
  // Calculate new output values:
  manageStripes();           // Manage stripeCounter
  updateNoise();             // Update noise values
  
  // Debug tools
  debugLog();                // DEBUG ONLY
  debugPrint();              // DEBUG ONLY
    
  colony.run();              // 1 iteration through all cells in the colony = 1 generation)
  
  storeGenerationOutput();   // Save output images
  
  if (generation == generations) {newEpoch();} else {generation++; stripeCounter--;}
  
  // Old function - to animate every frame in the drawCycle:
  //background(bkg_Hue, bkg_Sat, bkg_Bri);

} //Closes draw() loop

void getReady() {
  img = loadImage(inputFile);
  // Prepare path & filenames for various file outputs
  String startTime = timestamp();
  pathName = "../../output/" + applicationName + "/" + batchName + "/" + String.valueOf(width) + "x" + String.valueOf(height) + "/"; //local
  //screendumpPath = "../output.png"; // For use when running from local bot
  pdfFile = pathName + "pdf/" + applicationName + "-" + batchName + "-" + startTime + ".pdf";
  mp4File = pathName + applicationName + "-" + batchName + "-" + startTime + ".mp4";
  logFileName = pathName + "settings/" + applicationName + "-" + batchName + "-" + startTime + ".log";
  debugFileName = pathName + "debug/" + applicationName + "-" + batchName + "-" + startTime + "debug.log";
  
  // Initialise some variables
  h = height;
  w = width;
  //noiseLoopRadiusMedian = w * noiseLoopRadiusMedianFactor; // Better to scale noiseLoopRadiusMedian to the current canvas size than use a static value
  hwRatio = h/w;
  println("Width: " + w + " Height: " + h + " h/w ratio: " + hwRatio);
  rows = int(hwRatio * columns);
  elements = rows * columns;
  colOffset = w/(columns*2);
  rowOffset = h/(rows*2);
  generations = ceil(generationsScale * w) + 1; // ceil() used to give minimum value =1, +1 to give minimum value =2.
  
  // Create positions object with initial positions
  positions = new Positions();                        // Create a new positions array (default layout: randomPos)
  //positions.centerPos();                              // Create a set of positions with a cartesian grid layout
  //positions.gridPos();                                // Create a set of positions with a cartesian grid layout
  positions.phyllotaxicPos();                          // Create a set of positions with a phyllotaxic spiral layout
  
  // Create sizes object with initial sizes
  sizes = new Sizes();                                // Create a new sizes array
  //sizes.randomSize();                                 // Create a set of random sizes within a given range
  //sizes.noiseSize();                                 // Create a set of sizes using Perlin noise.
  //sizes.noiseFromDistanceSize();                     // Create a set of sizes using Perlin noise & distance from center.
  sizes.fromDistanceSize();                           // Create a set of sizes using ....
  
  // Create velocities object with initial vMax values
  velocities = new Velocities();                      // Create a new sizes array
  //velocities.randomvMax();                            // Create a set of random vMax values within a given range
  //velocities.noisevMax();                            // Create a set of vMax values using Perlin noise.
  velocities.fromDistancevMax();
  
  // Create colours object with initial hStart values
  colours = new Colours();                            // Create a new set of colours arrays
  //colours.randomHue();                              // Create a set of random hStart & hEnd values within a given range
  //colours.noiseHue();                               // Create a set of Hue values using 1D Perlin noise.
  //colours.noise2D_Hue();                           // Create a set of Hue values using 2D Perlin noise.
  //colours.fromDistanceHue();
  //colours.fromDistanceHueStart();
  //colours.fromDistanceHueEnd();
  
  //colours.noiseBEnd();                              // Create a set of bEnd values using 1D Perlin noise.
  //colours.noise2D_BStart();                         // Create a set of Brightness Start values using 2D Perlin noise.
  //colours.noise2D_BEnd();                           // Create a set of Brightness End values using 2D Perlin noise.
  
  //colours.noise2D_SStart();                         // Create a set of Saturation Start values using 2D Perlin noise.
  //colours.noise2D_SEnd();                           // Create a set of Saturation End values using 2D Perlin noise.
  if (colourFromImage) {colours.from_image();}
  //colours.fromGrid();
  //colours.from2DSpace();
  colours.fromPolarPosition();
  
  
  colony = new Colony();                              // Create a new colony
  //randomChosenOnes();
  predefinedChosenOnes();
  
  logSettings();
  if (debugMode) {debugFile = createWriter(debugFileName);}    //Open a new debug logfile
  if (makeEpochPDF) {epochs = 1; beginRecord(PDF, pdfFile);}
  if (makeGenerationMPEG) {makeEpochMPEG = false; epochs = 1;} // When making a generation video, stop after one epoch
  if (makeEpochMPEG) {makeGenerationMPEG = false;}             // Only one type of video file is possible at a time
  if (makeGenerationMPEG || makeEpochMPEG) {
    videoExport = new VideoExport(this, mp4File);
    videoExport.setQuality(videoQuality, 128);
    videoExport.setFrameRate(videoFPS); // fps setting for output video (should not be lower than 30)
    videoExport.setDebugging(false);
    videoExport.startMovie();
  }
  //image(img,(width-img.width)*0.5, (height-img.height)*0.5); // Displays the image file DEBUG!
} 

void randomChosenOnes() {
  chosenOne = int(random(colony.population.size()));  // Select the cell whose position is used to give x-y feedback to noise_1.
  chosenTwo = int(random(colony.population.size()));  // Select the cell whose position is used to give x-y feedback to noise_2.
  chosenThree = int(random(colony.population.size()));  // Select the cell whose position is used to give x-y feedback to noise_3.
  println("The chosen one is: " + chosenOne + " The chosen two is: " + chosenTwo + " The chosen three is: " + chosenThree);
}

void predefinedChosenOnes() {
  chosenOne = 21;  // Select the cell whose position is used to give x-y feedback to noise_1.
  chosenTwo = 3;  // Select the cell whose position is used to give x-y feedback to noise_2.
  chosenThree = 24;  // Select the cell whose position is used to give x-y feedback to noise_3.
  println("The chosen one is: " + chosenOne + " The chosen two is: " + chosenTwo + " The chosen three is: " + chosenThree);
}

void updatePngFilename() {
  pngFile = pathName + "png/" + applicationName + "-" + batchName + "-" + timestamp() + ".png";
}

void updateFeedback() {
  // Update feedback values from current chosenOne positions:
  feedbackPosX_1 = colony.population.get(chosenOne).position.x;
  feedbackPosY_1 = colony.population.get(chosenOne).position.y;
  feedbackPosX_2 = colony.population.get(chosenTwo).position.x;
  feedbackPosY_2 = colony.population.get(chosenTwo).position.y;
  feedbackPosX_3 = colony.population.get(chosenThree).position.x;
  feedbackPosY_3 = colony.population.get(chosenThree).position.y;
}

void updateEpochDrivers() {
  // Floats in range -1/+1 for modulating variable over a sequence of epochs:
  // NOTE: Can't use map() as sometimes both epoch & epochs = 1 (when making a still image)
  
  //println("epoch=" + epoch + " epochs=" + epochs + "(epoch/epochs * TWO_PI)=" + (epoch/epochs * TWO_PI) );
  epochAngle = PI + (epoch/epochs * TWO_PI); // Angle will turn through a full circle throughout one epoch
  //epochSineWave = sin(epochAngle); // Range: -1 to +1. Starts at 0.
  epochCosWave = cos(epochAngle); // Range: -1 to +1. Starts at -1.
}

void modulateByEpoch() {
  // Values that are modulated by epoch go here
  generationsScale = map(epochCosWave, -1, 1, generationsScaleMin, generationsScaleMax);
  vMaxGlobal = map(epochCosWave, -1, 1, vMaxGlobalMin, vMaxGlobalMax);
  
  //noiseOctaves = int(map(epochCosWave, -1, 1, noiseOctavesMin, noiseOctavesMax));
  //noiseFalloff = map(epochCosWave, -1, 1, noiseFalloffMin, noiseFalloffMax);
  noiseFactor = sq(map(epochCosWave, -1, 1, noiseFactorMax, noiseFactorMin));
  
  // NOISE SEEDS WILL REMAIN GLOBAL, SINCE ALL CELLS EXIST IN THE SAME NOISESPACE(S)
  //noise1Offset = map(epochCosWave, -1, 1, 0, 100);
  //noise2Offset = map(epochCosWave, -1, 1, 0, 200);
  //noise3Offset = map(epochCosWave, -1, 1, 0, 300);
  
  //noiseLoopRadius = noiseLoopRadiusMedian * map(epochSineWave, -1, 1, 1-noiseLoopRadiusFactor, 1+noiseLoopRadiusFactor); //noiseLoopRadius is scaled by epoch
  //noiseLoopX = width*0.5 + noiseLoopRadius * epochCosWave;   // px is in 'canvas space'
  //noiseLoopY = height*0.5 + noiseLoopRadius * epochSineWave; // py is in 'canvas space'

}

void updateGenerations() {  
  generations = ceil(generationsScale * w) + 1; // ceil() used to give minimum value =1, +1 to give minimum value =2.
}

void updateGenerationDrivers() {
  // 'GENERATION DRIVERS' in range -1/+1 for modulating variables through the course of a generation (ie. during one epoch):
  //generationAngle = map(generation, 1, generations, 0, TWO_PI); // The angle for various cyclic calculations increases from zero to 2PI as the minor loop runs
  generationAngle = map(generation, 1, generations, PI, PI*1.5); // The angle for various cyclic calculations increases from zero to 2PI as the minor loop runs
  generationSineWave = sin(generationAngle);
  generationCosWave = cos(generationAngle);
}

void modulateByGeneration() {
  // cellSizeGlobal = map(generation, 1, generations,  cellSizeGlobalMax,  cellSizeGlobalMin); // The scaling factor for  cellSizeGlobal  from max to zero as the minor loop runs
   cellSizeGlobal = map(generationCosWave, -1, 0,  cellSizeGlobalMax,  cellSizeGlobalMin);
  //stripeFactor = map(generation, 1, generations, 0.5, 0.5);
  //stripeWidth = map(generation, 1, generations, generations*0.25, generations*0.1);
  //noiseFactor = sq(map(generationCosWave, -1, 1, noiseFactorMax, noiseFactorMin));
  
  //noiseLoopX = width*0.5 + noiseLoopRadius * generationCosWave;   // px is in 'canvas space'
  //noiseLoopY = height*0.5 + noiseLoopRadius * generationSineWave; // py is in 'canvas space'
  //noiseLoopZ = width*0.5 + noiseLoopRadius * generationCosWave;   // Offset is arbitrary but must stay positive (???)
  //noiseLoopZ = map(generation, 1, generations, 0, width);         // pz is in 'canvas space'
}

void modulateByFeedback() {
  //float noiseScale = map (mouseY, 0, height, 1, 10);
  noiseScale1 = map (feedbackPosY_1, 0, height, 1, 10);
  noiseScale2 = map (feedbackPosY_2, 0, height, 1, 20);
  noiseScale3 = map (feedbackPosY_3, 0, height, 1, 30);
  
  //float seedScale = map(mouseX, 0, width, 0, 1000);
  noise1Offset = map(feedbackPosX_1, 0, width, 0, 1000);
  noise2Offset = map(feedbackPosX_2, 0, width, 0, 1000);
  noise3Offset = map(feedbackPosX_3, 0, width, 0, 1000);
}

void debugLog() {
  if (debugMode) {
    debugFile.println("Epoch: " + int(epoch) + " of " + int(epochs));
    debugFile.println("Generation: " + generation + " of " + generations);
    debugFile.println("Frame: " + frameCount + " Generation: " + generation + " Epoch: " + epoch + " noiseFactor: " + noiseFactor + " noiseOctaves: " + noiseOctaves + " noiseFalloff: " + noiseFalloff);
  }
}

void debugPrint() {
  println("Epoch " + epoch + " of " + epochs + " Generation " + generation + " of " + generations);
  //println("noiseScale: " + noiseScale + " noise1Scale: " + noise1Scale + " noise2Scale: " + noise2Scale + " noise3Scale: " + noise3Scale);
  //println("seedScale: " + seedScale + " noise1Offset: " + noise1Offset + " noise2Offset: " + noise2Offset + " noise3Offset: " + noise3Offset);
  //println("Epoch " + epoch + " of " + epochs + " epochAngle=" + epochAngle + " epochCosWave=" + epochCosWave + " noise1Offset=" + noise1Offset + " noise2Offset=" + noise2Offset + " noise3Offset=" + noise3Offset);

}

void manageStripes() {
  //float remainingSteps = generations - generation; //For stripes that are a % of remainingSteps in the loop
  //stripeWidth = (remainingSteps * 0.3) + 10;
  
  //If a stripe has been completed. Update stripeWidth value & reset the stripeCounter to start the next one
  if (stripeCounter <= 0) {
    stripeWidth = int(map(generation, 1, generations, generations*stripeWidthFactorMax, generations*stripeWidthFactorMin));
    stripeCounter = stripeWidth;
  }
}

void updateNoise() {
  noiseDetail(noiseOctaves, noiseFalloff);
  
  //noise1Scale = noise1Factor/(noiseFactor*w);
  //noise2Scale = noise2Factor/(noiseFactor*w);
  //noise3Scale = noise3Factor/(noiseFactor*w);
  noise1Scale = noiseScale1/(noiseFactor*w);
  noise2Scale = noiseScale2/(noiseFactor*w);
  noise3Scale = noiseScale3/(noiseFactor*w);
}

void storeGenerationOutput() {
  // After you have drawn all the elements in one generation of the colony:
  if (debugMode) {debugFile.println("Generation " + generation + " has ended.");}
    
  // Save an image of the generation frame to the archive folder:
  if (makeGenerationPNG) {updatePngFilename();saveFrame(pngFile); println("Saved Generation frame to .png file: " + pngFile);}
  
  // Add an image of the generation frame to the generation video file:
  if (makeGenerationMPEG) {videoExport.saveFrame();}  // What to do when an epoch is over? (when all the generations in the epoch have been completed)
}

void storeEpochOutput() {
  if (debugMode) {debugFile.println("Epoch " + epoch + " has ended.");}
  if (makeEpochPNG) {updatePngFilename();saveFrame(pngFile); println("Saved Epoch frame to .png file: " + pngFile);}
  if (makeEpochMPEG) {videoExport.saveFrame(); println("Saved Epoch frame to .mp4 file: " + mp4File);} // Add an image of the generation frame to the generation video file:

}

void newEpoch() {
  println("Epoch " + epoch + " has ended.");
  storeEpochOutput();
  
  if (epoch == epochs) {
    // The sketch has reached the end of it's intended lifecycle. Time to close up shop... 
    println("The final epoch has ended. Goodbye!");
    lastEpoch();
  }
  
  // If we are not at the end, reset to start a new epoch:
  generation = 1;              // Reset the generation counter for the next epoch
  stripeCounter = stripeWidth; // Reset the stripeCounter for the next epoch
  if (colourFromImage) {colours.from_image();}  // To update colours with new seed positions (they may have changed)
  colony = new Colony();       // Reset the colony (by making a new Colony object)
  background(bkg_Hue, bkg_Sat, bkg_Bri); //Refresh the background
  //background(bkg_Bri);
  epoch++; // An epoch has ended, increase the counter
}

// Saves an image of the final frame, closes any pdf & mpeg files and exits tidily
void lastEpoch() {
  if (debugMode) {debugEnd();}
  
  // Save an image of the final frame to the archive folder:
  if (makeFinalPNG) {updatePngFilename();saveFrame(pngFile); println("Saved Final frame to .png file: " + pngFile);}
  
  // If I'm in PDF-mode, complete & close the file
  if (makeEpochPDF) {
    println("Saving completed .pdf file: " + pdfFile);
    endRecord();
  }
  
  // If I'm in MPEG mode, complete & close the file
  if (makeGenerationMPEG || makeEpochMPEG) {
    println("Saving completed .mp4 file: " + mp4File);
    videoExport.endMovie();
  }
    
  exit();
}


// Returns a string with the date & time in the format 'yyyymmdd-hhmmss'
String timestamp() {
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
  logFile = createWriter(logFileName); //Open a new settings logfile
  logFile.println("Canvas size:");
  logFile.println("------------");
  logFile.println("width = " + w);
  logFile.println("height = " + h);
  logFile.println();
  
  logFile.println("Video export variables:");
  logFile.println("-----------------------");
  logFile.println("videoQuality = " + videoQuality);
  logFile.println("videoFPS = " + videoFPS);
  logFile.println();
  
    
  logFile.println("Output configuration toggles:");
  logFile.println("-----------------------------");
  logFile.println("makeEpochPDF = " + makeEpochPDF);
  logFile.println("makeGenerationPNG = " + makeGenerationPNG);
  logFile.println("makeEpochPNG = " + makeEpochPNG);
  logFile.println("makeFinalPNG = " + makeFinalPNG);
  logFile.println("makeGenerationMPEG = " + makeGenerationMPEG);
  logFile.println("makeEpochMPEG = " + makeEpochMPEG);
  logFile.println("debugMode = " + debugMode);
  logFile.println();
  
  logFile.println("Loop Control variables:");
  logFile.println("-----------------------");
  logFile.println("generationsScaleMin = " + generationsScaleMin + " generationsMin = " + (ceil(generationsScaleMin*w)+1));
  logFile.println("generationsScaleMax = " + generationsScaleMax + " generationsMax = " + (ceil(generationsScaleMax*w)+1));
  logFile.println("generations (static value, if used) = " + generations);
  logFile.println("epochs = " + epochs);
  logFile.println();
  
  logFile.println("Cartesian Grid variables:");
  logFile.println("-------------------------");
  logFile.println("columns = " + columns);
  logFile.println("rows = " + rows);
  logFile.println("elements = " + elements);
  logFile.println();

  
  logFile.println("Element Size variables:");
  logFile.println("-----------------------");
  logFile.println(" cellSizeGlobalMin = " +  cellSizeGlobalMin);
  logFile.println(" cellSizeGlobalMax = " +  cellSizeGlobalMax);
  logFile.println();
  
  logFile.println("Feedback variables:");
  logFile.println("-------------------");
  logFile.println("ChosenOne = " + chosenOne);
  logFile.println("ChosenTwo = " + chosenTwo);
  logFile.println("ChosenThree = " + chosenThree);
  logFile.println();
  
  logFile.println("Noise initialisation variables:");
  logFile.println("-------------------------------");
  logFile.println("noiseSeed = " + noiseSeed);
  logFile.println("noiseOctavesMin = " + noiseOctavesMin);
  logFile.println("noiseOctavesMax = " + noiseOctavesMax);
  logFile.println("noiseFalloffMin = " + noiseFalloffMin);
  logFile.println("noiseFalloffMax = " + noiseFalloffMax);
  logFile.println();
  
  logFile.println("NoiseLoop variables: (NOT IN USE)");
  logFile.println("---------------------------------");
  //logFile.println("noiseLoopRadiusMedianFactor = " + noiseLoopRadiusMedianFactor);
  //logFile.println("noiseLoopRadiusMedian = " + noiseLoopRadiusMedian);
  //logFile.println("noiseLoopRadiusFactor = " + noiseLoopRadiusFactor);
  logFile.println();
  
  logFile.println("NoiseScale & Offset variables:");
  logFile.println("------------------------------");
  logFile.println("noiseFactorMin = " + noiseFactorMin);
  logFile.println("noiseFactorMax = " + noiseFactorMax);
  logFile.println("noise1Factor = " + noise1Factor);
  logFile.println("noise2Factor = " + noise2Factor);
  logFile.println("noise3Factor = " + noise3Factor);
  logFile.println("noise1Offset = " + noise1Offset);
  logFile.println("noise2Offset = " + noise2Offset);
  logFile.println("noise3Offset = " + noise3Offset);
  logFile.println();
  
  logFile.println("Stripe variables:");
  logFile.println("-----------------");
  logFile.println("stripeWidthFactorMin = " + stripeWidthFactorMin);
  logFile.println("stripeWidthFactorMax = " + stripeWidthFactorMax);
  logFile.println("stripeWidth = " + stripeWidth);
  logFile.println();
  
  logFile.println("Colour variables:");
  logFile.println("-----------------");
  logFile.println("bkg_Hue = " + bkg_Hue);
  logFile.println("bkg_Sat = " + bkg_Sat);
  logFile.println("bkg_Bri = " + bkg_Bri);
  
   //Flush and close the settings file
  logFile.flush();
  logFile.close();
  println("Saved .log file: " + logFileName);
}

void debugEnd() {
  debugFile.flush();
  debugFile.close(); //Flush and close the settings file
  println("Saved debug.log file: " + debugFileName);
}

void keyPressed() {
  if (key == 'q') {lastEpoch();}
  if (key == 'p') {updatePngFilename();saveFrame(pngFile); println("Saved a keypress frame to .png file: " + pngFile);}
  if (key == 'c') {randomChosenOnes(); println("New Chosen Ones selected!");}
  if (key == 't') {makeEpochPNG = !makeEpochPNG; println("Toggled makeEpochPNG");}
}
