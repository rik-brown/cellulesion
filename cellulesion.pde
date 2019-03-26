// Cellulesion
// Origin story: 'Circulesion' refactored into object-oriented code to lay foundation for vectors & movement
// Summary: Exploration of spatial & temporal modulation of velocity, shape & colour using Perlin Noise as primary source of 'environmental variation'
// 2018-01-31 22:56

import com.hamoid.*;                          // For converting frames to a .mp4 video file 
import processing.pdf.*;                      // For exporting output as a .pdf file

Positions positions;                          // A Positions object called 'positions'
Directions directions;
Sizes sizes;                                  // A Sizes object called 'sizes'
Velocities velocities;                        // A Velocities object called 'velocities'
Vel_Mags velMags;                             // A Vel_Mags object called 'velMags'
Colours colours;
Offsets offsets;
MaxAges maxAges;
Colony colony;                                // A Colony object called 'colony'
Nodepositions nodepositions;                  // A Nodepositions object called 'nodepositions'
Nodevelocities nodevelocities;                // A Nodevelocities object called 'nodevelocities'
Nodevertexes nodevertexes;
Nodestates nodestates;
Network network;                              // A Network object called 'network'
VideoExport videoExport;                      // A VideoExport object called 'videoExport'
PImage img;                                   // A PImage object called 'img' (used when importing a source image)
PShape cell;                                  // A PShape object called 'cell'

// Output configuration toggles:
boolean makeGenerationPNG = false;            // Enable .png output of each generation. (CAUTION! Will save one image per draw() frame!)
boolean makeEpochPNG = false;                 // Enable .png 'timelapse' output of each epoch (CAUTION! Will save one image for every epoch in the series)
boolean makeEraPNG = false;                   // Enable .png 'timelapse' output of each era (CAUTION! Will save one image for every era in the series)
boolean makeFinalPNG = true;                 // Enable .png 'timelapse' output of the last generation of the last epoch in the last era

boolean makeFinalPDF = false;                 // Enable .pdf 'timelapse' output of all the generations in a single epoch/era (forces epochs =1 & eras =1)

boolean makeGenerationMPEG = false;           // Enable video output for animation of a single generation cycle (one frame per draw cycle, one video per generations sequence)
boolean makeEpochMPEG = false;                // Enable video output for animation of a series of generation cycles (one frame per generations cycle, one video per epoch sequence)
boolean makeEraMPEG = false;

// Logging toggles:
boolean debugMode = false;                    // Enable logging to debug file
boolean verboseMode = false;                  // Enable printing to console (progress info)

// Background refresh toggles:
boolean updateEpochBkg = false;               // Enable refresh of background at start of a new era
boolean updateEraBkg = true;                 // Enable refresh of background at start of a new era

// Operating mode toggles:
boolean colourFromImage = false;
boolean bkgFromImage = false;
boolean collisionMode = true;                 // Enable detection of collisions between cells
boolean relativeGenerations = true;           // True: Calculate generations as fraction of canvas size False: Use absolute values
boolean networkMode = true;
boolean displayNetwork = false;

// File Management variables:
String batchName = "014";                     // Simple version number for design batches (updated manually when the mood takes me)
String pathName;                              // Path the root folder for all output
//String timestamp;                             // Holds the formatted time & date when timestamp() is called
String applicationName = "cellulesion";       // Used as the root folder for all output
String logFileName;                           // Name & location of logfile (.log)
String debugFileName;                         // Name & location of logfile (.log)
String pngFile;                               // Name & location of saved output (.png final image)
String pdfFile;                               // Name & location of saved output (.pdf file)
String mp4File;                               // Name & location of video output (.mp4 file)
//String inputFile = "Blue_red_green_2_blobs.png";               // First run will use /data/input.png, which will not be overwritten
String inputFile = "wild-planet.jpg";               // First run will use /data/input.png, which will not be overwritten
PrintWriter logFile;                          // Object for writing to the settings logfile
PrintWriter debugFile;                        // Object for writing to the debug logfile

// Video export variables:
int videoQuality = 85;                        // 100 = highest quality (lossless), 70 = default 
int videoFPS = 30;                            // Framerate for video playback

// Loop Control variables:
float generationsScaleMin = 800;            // Minimum value for modulated generationsScale
float generationsScaleMax = 800;              // Maximum value for modulated generationsScale
float generationsScale = 0.8;                // Static value for modulated generationsScale (fallback, used if no modulation)
int generation, epoch, era;
int generations;                            // Total number of drawcycles (frames) in a generation (timelapse loop) (% of width)
int epochs = 8;                           // The number of epoch frames in the video (Divide by 60 for duration (sec) @60fps, or 30 @30fps)
int eras = 1;

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
float noiseFactorMin = 1.0;                   // Minimum value for modulated noiseFactor
float noiseFactorMax = 1.25;                   // Maximum value for modulated noiseFactor
float noise1Factor = 2;                       // Value for constant noiseFactor, noise1 (numerator in noiseScale calculation)
float noise2Factor = 4;                       // Value for constant noiseFactor, noise2 (numerator in noiseScale calculation)
float noise3Factor = 8;                       // Value for constant noiseFactor, noise3 (numerator in noiseScale calculation)

//float noise1Offset =rndom(1000);             // Offset for the noisespace x&y coords (noise1) 
//float noise2Offset =random(1000);             // Offset for the noisespace x&y coords (noise2)
//float noise3Offset =random(1000);             // Offset for the noisespace x&y coords (noise3)
float noise1Offset =100;                        // Offset for the noisespace x&y coords (noise1)
float noise2Offset =2000;                     // Offset for the noisespace x&y coords (noise2)
float noise3Offset =4000;                     // Offset for the noisespace x&y coords (noise3)

// Noise initialisation variables:
//int noiseSeed = 1000;                       // To fix all noise values to a repeatable pattern
int noiseSeed = int(random(10000));
int noiseOctaves = 7;                         // Integer in the range 3-8? Default: 7
int noiseOctavesMin = 7;                      // Minimum value for modulated noiseOctaves
int noiseOctavesMax = 7;                      // Maximum value for modulated noiseOctaves
float noiseFalloff = 0.5;                     // Float in the range 0.0 - 1.0 Default: 0.5 NOTE: Values >0.5 may give noise() value >1.0
float noiseFalloffMin = 0.5;                  // Minimum value for modulated noiseFalloff
float noiseFalloffMax = 0.5;                  // Maximum value for modulated noiseFalloff

// Generator variables:
float eonCompleteness, eraCompleteness, epochCompleteness;
float eraAngle;                               //Angle turns full circle in one era cycle
float epochAngle, epochCosWave, epochSineWave;//Angle turns full circle in one epoch cycle giving Cos & Sin values in range -1/+1
float generationAngle, generationSineWave, generationCosWave, generationWiggleWave; //Angle turns full circle in one Generation cycle giving Cos & Sin values in range -1/+1

// Cartesian Grid variables: 
int  h, w, hwRatio;                           // Height & Width of the canvas & ratio h/w
int cols = 7;                              // Number of columns in the cartesian grid
int rows = 4;                                     // Number of rows in the cartesian grid. Value is calculated in setup();
int elements;                                 // Total number of elements in the initial spawn (=cols*rows)
float colWidth, rowHeight;                   // col- & rowHeight give correct spacing between rows & columns & canvas edges

// Network variables:
int noderows = 20;
int nodecols = 20;
int nodecount = noderows * nodecols;
int collisionRange, globalTransitionAge;

// Element Size variables (ellipse, triangle, rectangle):
float  cellSizeGlobal;                            // Scaling factor for drawn elements
float  cellSizeEpochGlobalMin = 0.5;                 // Minimum value for epoch-modulated  cellSizeGlobal (1.0 = 100% = no gap/overlap between adjacent elements in cartesian grid) 
float  cellSizeEpochGlobalMax = 40.0;                   // Maximum value for epoch-modulated  cellSizeGlobal (1.0 = 100% = no gap/overlap between adjacent elements in cartesian grid)
float  cellSizeGenerationGlobalMin = 1.0;                 // Minimum value for epoch-modulated  cellSizeGlobal (1.0 = 100% = no gap/overlap between adjacent elements in cartesian grid) 
float  cellSizeGenerationGlobalMax = 1.0;                   // Maximum value for epoch-modulated  cellSizeGlobal (1.0 = 100% = no gap/overlap between adjacent elements in cartesian grid)
float  cellSizePowerScalar = 1.0;

// Global velocity variables:
float vMaxGlobal;
float vMaxGlobalMin = 1.0;
float vMaxGlobalMax = 1.0;

// Global offsetAngle variable:
float offsetAngleGlobal;
float curveAngleMin, curveAngleMax; // Will be used in cell() by rotateVelocityByBroodFactor() (modulated by Epoch)

// Stripe variables:
float stripeWidthFactorMin = 0.05;            // Minimum value for modulated stripeWidthFactor
float stripeWidthFactorMax = 0.25;             // Maximum value for modulated stripeWidthFactor
float stripeFactor = 0.5;                     // Ratio between the pair of stripes in stripeWidth. 0.5 = 50/50 = equal distribution
int stripeWidth, stripeCounter;              // Counter marking the progress through the stripe (increments -1 each drawcycle)

//The lines below are moved to initiateStripes():
//int stripeWidth = int(generations * stripeWidthFactor); // stripeWidth is a % of # generations in an epoch
//int stripeWidth = ceil(map(generation, 1, generations, generations*stripeWidthFactorMax, generations*stripeWidthFactorMin));

// Colour variables:
float bkg_Hue;                                // Background Hue
float bkg_Sat;                                // Background Saturation
float bkg_Bri;                                // Background Brightness

// Colour-from-image variables:
int imgWidthLow, imgWidthHigh;
int imgHeightLow, imgHeightHigh;
float imgWidthScale = 1.0;
float imgHeightScale = 1.0;


void setup() {
  //frameRate(1);
  
  //fullScreen();
  //size(4960, 7016); // A4 @ 600dpi
  //size(10000, 10000);
  //size(6000, 6000);
  size(4000, 4000);
  //size(2000, 2000);
  //size(1280, 1280);
  //size(1080, 1080);
  //size(1000, 1000);
  //size(640, 1136); // iphone5
  //size(800, 800);
  //size(600,600);
  //size(400,400);
  
  colorMode(HSB, 360, 255, 255, 255);
  //colorMode(RGB, 360, 255, 255, 255);
  
  bkg_Hue = 360*0.66; // Red in RGB mode
  bkg_Sat = 255*0.0; // Green in RGB mode
  bkg_Bri = 255*0.6; // Blue in RGB mode
  
  
  noiseSeed(noiseSeed); //To make the noisespace identical each time (for repeatability) 
  ellipseMode(RADIUS);
  rectMode(RADIUS);
  getReady();
  updateBackground();  
}

void draw() {
  // Modulate by position:
  updateFeedback();          // Update feedback values
  modulateByFeedback();
  
  // Calculate new output values:
  manageStripes();           // Manage stripeCounter
  updateNoise();             // Update noise values
  updateImgScale();
  
  // Debug tools
  debugLog();                // DEBUG ONLY
  if (verboseMode) {debugPrint();}              // DEBUG ONLY
  pushMatrix();
  translate(width*0.5, height*0.5);
  //rotate(-epochAngle); // Rotate to the current epoch angle
  //rotate(-eraAngle); // Rotate to the current era angle
  //rotate(PI);          // Rotate to a fixed angle (e.g. PI)
  translate(-width*0.5, -height*0.5);
  if (displayNetwork) {network.run();}
  colony.runREV();              // BACKWARDS 1 iteration through all cells in the colony = 1 generation)
  //colony.runFWD();              // FORWARDS 1 iteration through all cells in the colony = 1 generation)
  popMatrix();
  if (colony.extinct()) {println("Oh no! The colony went extinct");generation = generations-1;}
  storeGenerationOutput();   // Save output images (once every generation = once every drawcycle)
  
  updateGeneration();
  
  // Old function - to animate every frame in the drawCycle:
  //background(bkg_Hue, bkg_Sat, bkg_Bri);

} //Closes draw() loop

void startEon() {
  // Called every time a new Eon is started
  era=0;              // A new Eon starts at era 0
  updateEraDrivers(); // When era value is reset to 0, the drivers need recalculating
  modulateByEra();    // When the drivers are updated, the values modulated by them need recalculating
  startEra();         // When you start an Eon, you always start a new Era too
}

void startEra() {
  // Called every time a new Era is started
  epoch=0;              // A new Era starts at epoch 0
  updateEpochDrivers(); // When epoch value is reset to 0, the drivers need recalculating
  modulateByEpoch();    // When the drivers are updated, the values modulated by them need recalculating
  if (updateEraBkg) {updateBackground();}
  startEpoch();         // When you start an Era, you always start a new Epoch too
}

void startEpoch() {
  // Called every time a new Epoch is started
  generation=0;              // A new Epoch starts at generation 0
  updateGenerations();       // Update the generations variable (if it is dynamically scaled)
  updateGenerationDrivers(); // When generation value is reset to 0, the drivers need recalculating
  modulateByGeneration();    // When the drivers are updated, the values modulated by them need recalculating
  initStripes();       // Reset the stripes for the new epoch
  if (colourFromImage) {colours.from_image();}
  if (updateEpochBkg) {updateBackground();}
  network = new Network();     // Create a new network (by making a new Network object)
  colony = new Colony();     // Create a new colony (by making a new Colony object)
  // There is nothing more to start because after starting a new Epoch, the new draw() cycle begins
}

void getReady() {
  img = loadImage(inputFile);
  updateImgScale();
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
  //rows = int(hwRatio * cols);
  elements = rows * cols;
  colWidth = w/cols;
  rowHeight = h/rows;
  collisionRange = int(w * 0.002); // For detecting collision between a cell and a node (gives 2 pixels when width = 1000)
  globalTransitionAge = int(w * 0.008);
  directions = new Directions();                     // Create a new directions array
  initNodepositions(); 
  initNodevertexes();
  initNodevelocities();
  initNodeStates();
  initPositions();
  initSizes();
  initVelocities();
  initVelMags();
  initColours();
  initOffsets();
  initMaxAges();
  randomChosenOnes();
  //predefinedChosenOnes();
  
  logSettings();
  if (debugMode) {debugFile = createWriter(debugFileName);}    //Open a new debug logfile
  if (makeFinalPDF) {epochs = 1; eras = 1; beginRecord(PDF, pdfFile);}
  if (makeGenerationMPEG) {makeEpochMPEG = false; epochs = 1;} // When making a generation video, stop after one epoch
  if (makeEpochMPEG) {makeGenerationMPEG = false;}             // Only one type of video file is possible at a time
  if (makeGenerationMPEG || makeEpochMPEG || makeEraMPEG) {
    videoExport = new VideoExport(this, mp4File);
    videoExport.setQuality(videoQuality, 128);
    videoExport.setFrameRate(videoFPS); // fps setting for output video (should not be lower than 30)
    videoExport.setDebugging(false);
    videoExport.startMovie();
  }
  //image(img,(width-img.width)*0.5, (height-img.height)*0.5); // Displays the image file DEBUG!
  startEon();
} 

void initPositions() {
  // Create positions object with initial positions
  positions = new Positions();                        // Create a new positions array (default layout: randomPos)
  //positions.centerPos();                              // Create a set of positions with a cartesian grid layout
  //positions.gridPos();  // Create a set of positions with a cartesian grid layout
  //positions.scaledGridPos();
  //positions.isoGridPos();
  //positions.offsetGridPos();                          // Create a set of positions with a cartesian grid layout
  //positions.phyllotaxicPos();                         // Create a set of positions with a phyllotaxic spiral layout
  //positions.phyllotaxicPos2();                        // Create a set of positions with a phyllotaxic spiral layout
  positions.posFromRandomNode();                        // Create a set of positions selected from the nodepositions array
  //positions.posFromSameRandomNode();                    // Create a set of positions selected from the nodepositions array
  //positions.posFromMiddleNode();                    // Create a set of positions selected from the nodepositions array
}

void initVelocities() {
  // Create velocities object with initial velocities
  velocities = new Velocities();                        // Create a new velocities array (default layout: randomVel)
  //velocities.fixedVel();
  velocities.toCenter();
  //velocities.fromCenter();
}

void initNodepositions() {
  // Create nodepositions object with initial nodepositions
  nodepositions = new Nodepositions();                      // Create a new nodepositions array (default layout: randomPos)
  //nodepositions.centerPos();                              // Create a set of nodepositions with a cartesian grid layout
  //nodepositions.gridPos();  // Create a set of nodepositions with a cartesian grid layout
  nodepositions.scaledGridPos();
  //nodepositions.isoGridPos();
  //nodepositions.offsetGridPos();                          // Create a set of nodepositions with a cartesian grid layout
  //nodepositions.phyllotaxicPos();                         // Create a set of nodepositions with a phyllotaxic spiral layout
  //nodepositions.phyllotaxicPos2();                        // Create a set of nodepositions with a phyllotaxic spiral layout
}

void initNodevertexes() {
  // Create nodevertexes object with initial vertex values
  nodevertexes = new Nodevertexes();                      // Create a new sizes array
  nodevertexes.randomVertex();                            // Create a set of random vMax values within a given range
  //nodevertexes.elementVertex();                          // Create a set of vMax values within a given range mapped to element ID
  //nodevertexes.noiseVertex();                            // Create a set of vMax values using Perlin noise.
  //nodevertexes.fromDistanceVertex();
  //nodevertexes.fromDistancevVertexREV();
  //nodevertexes.fromDistanceHalfVertex();
}

void initNodeStates() {
  // Create nodestates object with initial state values
  nodestates = new Nodestates();                      // Create a new nodestates array
  //nodestates.randomState();
}

void initNodevelocities() {
  // Create velocities object with initial velocities
  nodevelocities = new Nodevelocities();                 // Create a new nodevelocities array (default layout: randomVel)
  //nodevelocities.fixedVel();
  //nodevelocities.toCenter();
  //nodevelocities.fromCenter();
  nodevelocities.randomFromVertexes();
  //nodevelocities.sequentialFromVertexes();
}

void initVelMags() {
  // Create Vel_Mags object with initial vMax values
  velMags = new Vel_Mags();                      // Create a new sizes array
  velMags.randomvMax();                            // Create a set of random vMax values within a given range
  //velMags.elementvMax();                            // Create a set of vMax values within a given range mapped to element ID
  //velMags.noisevMax();                            // Create a set of vMax values using Perlin noise.
  //velMags.fromDistancevMax();
  //velMags.fromDistancevMaxREV();
  //velMags.fromDistanceHalfvMax();
}

void initSizes() {
  // Create sizes object with initial sizes
  sizes = new Sizes();                                // Create a new sizes array
  //sizes.randomSize();                                 // Create a set of random sizes within a given range
  sizes.elementSize();                                 // Create a set of sizes within a given range mapped to element ID
  //sizes.noiseSize();                                 // Create a set of sizes using Perlin noise.
  //sizes.noiseFromDistanceSize();                     // Create a set of sizes using Perlin noise & distance from center.
  //sizes.fromDistanceSize();                           // Create a set of sizes using ....
  //sizes.fromDistanceHalfSize();                           // Create a set of sizes using ....
  //sizes.fromDistanceSizePower();                           // Create a set of sizes using ....
}

void initColours() {
  // Create colours object with initial hStart values
  colours = new Colours();                            // Create a new set of colours arrays
  //colours.randomHue();                              // Create a set of random hStart & hEnd values within a given range
  //colours.noiseHue();                               // Create a set of Hue values using 1D Perlin noise.
  //colours.noise2D_Hue();                           // Create a set of Hue values using 2D Perlin noise.
  //colours.fromDistanceHue();
  //colours.fromDistanceHueStart();
  //colours.fromDistanceHueEnd();
  //colours.fromDistanceSat();
  
  //colours.noiseBEnd();                              // Create a set of bEnd values using 1D Perlin noise.
  //colours.noise2D_BStart();                         // Create a set of Brightness Start values using 2D Perlin noise.
  //colours.noise2D_BEnd();                           // Create a set of Brightness End values using 2D Perlin noise.
  
  //colours.noise2D_SStart();                         // Create a set of Saturation Start values using 2D Perlin noise.
  //colours.noise2D_SEnd();                           // Create a set of Saturation End values using 2D Perlin noise.
  //if (colourFromImage) {colours.from_image();} // MOVED to startEpoch()
  //colours.fromGrid();
  //colours.from2DSpace();
  //colours.fromPolarPosition();
  //colours.fromPolarPosition2();
}

void initOffsets() {
  // Create offsets object with initial sizes
  offsets = new Offsets();                                // Create a new offsets array
  //offsets.randomOffset();                                 // Create a set of random offsets within a given range
  offsets.elementOffset();                                // Create a set of offsets within a given range mapped to element ID
  //offsets.noiseOffset();                                  // Create a set of offsets using Perlin noise.
  //offsets.noiseFromDistanceOffset();                      // Create a set of offsets using Perlin noise & distance from center.
  //offsets.fromDistanceOffset();                           // Create a set of offsets using ....
  //offsets.fromDistanceHalfOffset();                       // Create a set of offsets using ....
  //offsets.fromDistanceOffsetPower();                      // Create a set of offsets using ....
}

void initMaxAges() {
  // Create sizes object with initial sizes
  maxAges = new MaxAges();                                // Create a new maxAges array
  //maxAges.randomMaxAges();                                 // Create a set of random maxAges within a given range
  //maxAges.elementMaxAges();                                // Create a set of maxAges within a given range mapped to element ID
  //maxAges.noiseMaxAges();                                  // Create a set of maxAges using Perlin noise.
  //maxAges.noiseFromDistanceMaxAges();                      // Create a set of maxAges using Perlin noise & distance from center.
  //maxAges.fromDistanceMaxAges();                           // Create a set of maxAges using ....
  //maxAges.fromDistanceMaxAgesREV();                           // Create a set of maxAges using ....
  //maxAges.fromDistanceHalfMaxAges();                       // Create a set of maxAges using ....
  //maxAges.fromDistanceMaxAgesPower();                      // Create a set of maxAges using ....
}

void updateBackground() {
  if (colourFromImage || bkgFromImage) {bkgFromImage();}
  else {
    background(bkg_Hue, bkg_Sat, bkg_Bri);
    //background(255,0.17*255, 0.95*255);
  }
}

void bkgFromImage() {
  //Purpose is to set background colour using the colour sampled from a source image at pixel(0,0);
  PVector samplePos = new PVector (1,1);
  color pixelColor = pixelColour(samplePos);
  bkg_Hue = hue(pixelColor);
  bkg_Sat = saturation(pixelColor);
  bkg_Bri = brightness(pixelColor);
  background(bkg_Hue, bkg_Sat, bkg_Bri);
  
}

void randomChosenOnes() {
  chosenOne = int(random(elements));  // Select the cell whose position is used to give x-y feedback to noise_1.
  chosenTwo = int(random(elements));  // Select the cell whose position is used to give x-y feedback to noise_2.
  chosenThree = int(random(elements));  // Select the cell whose position is used to give x-y feedback to noise_3.
  if (verboseMode) {println("The chosen one is: " + chosenOne + " The chosen two is: " + chosenTwo + " The chosen three is: " + chosenThree);}
}

void predefinedChosenOnes() {
  chosenOne = 30;  // Select the cell whose position is used to give x-y feedback to noise_1.
  chosenTwo = 15;  // Select the cell whose position is used to give x-y feedback to noise_2.
  chosenThree = 25;  // Select the cell whose position is used to give x-y feedback to noise_3.
  //println("The chosen one is: " + chosenOne + " The chosen two is: " + chosenTwo + " The chosen three is: " + chosenThree);
}

void updatePngFilename() {
  pngFile = pathName + "png/" + applicationName + "-" + batchName + "-" + timestamp() + ".png";
}

void updateGeneration() {
  generation++;
  stripeCounter++;
  updateGenerationDrivers();
  modulateByGeneration();
  checkGeneration();
}

void checkGeneration() {
  if (generation>=generations) {
    updateEpoch();
    startEpoch();
  }
}

void updateEpoch() {
  // Is called when if-statement in checkGeneration() returns TRUE (an epoch is over)
  storeEpochOutput();
  epoch++;
  updateEpochDrivers();
  modulateByEpoch();
  checkEpoch();
}

void checkEpoch() {
  if (epoch==epochs) {
    updateEra();
    startEra();
  }
}

void updateEra() {
  storeEraOutput();
  era++;
  updateEraDrivers();
  modulateByEra();
  checkEra();
}

void checkEra() {
  if (era == eras) {
    lastEra();
  }
}

void updateGenerations() {  
  if (relativeGenerations) {generations = ceil(generationsScale * w) + 1;} // ceil() used to give minimum value =1, +1 to give minimum value =2.
  else {generations = ceil(generationsScale);}
  //generations = 50;
}

void updateGenerationDrivers() {
  // 'GENERATION DRIVERS' in range -1/+1 for modulating variables through the course of a generation (ie. during one epoch):
  epochCompleteness = map(generation, 1, generations, 0, 1);
  //generationAngle = map(epochCompleteness, 0, 1, 0, TWO_PI); // The angle for various cyclic calculations increases from zero to 2PI as the minor loop runs
  generationAngle = map(epochCompleteness, 0, 1, PI, PI*1.5); // The angle for various cyclic calculations increases from zero to 2PI as the minor loop runs
  generationSineWave = sin(generationAngle);
  generationCosWave = cos(generationAngle);
  generationWiggleWave = cos(generationAngle*4);
}

void updateEpochDrivers() {
  // Floats in range -1/+1 for modulating variable over a sequence of epochs:
  // NOTE: Can't use map() as sometimes both epoch & epochs = 1 (when making a still image)
  
  //println("epoch=" + epoch + " epochs=" + epochs + "(epoch/epochs * TWO_PI)=" + (epoch/epochs * TWO_PI) );
  //eraCompleteness = epoch/epochs; // Will always start at a value >0 (= 1/epochs) and increase to 1.0
  if (epochs>0) {eraCompleteness = map(epoch, 0, epochs, 0, 1);} else {eraCompleteness=1;}
  //eraCompleteness = 1;
  //epochAngle = (eraCompleteness * TWO_PI); // Angle will turn through a full circle throughout one era
  epochAngle = PI + (eraCompleteness * TWO_PI); // Angle will turn through a full circle throughout one era
  epochSineWave = sin(epochAngle); // Range: -1 to +1. Starts at 0.
  epochCosWave = cos(epochAngle); // Range: -1 to +1. Starts at -1.
}

void updateEraDrivers() {
  // Put Era driver code here 
  if (eras>0) {eonCompleteness = map(era, 0, eras, 0, 1);} else {eonCompleteness=1;}
  eraAngle = (eonCompleteness * TWO_PI); // Angle will turn through a full circle throughout one age of eras
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

//>>>>>>>>>>>>>>>>>>>>>>>>>>MODULATORS GO BENEATH HERE<<<<<<<<<<<<<<<<<<<<<<<<<<<<

void modulateByGeneration() {
  //cellSizeGlobal *= map(epochCompleteness, 0, 1,  cellSizeGenerationGlobalMax,  cellSizeGenerationGlobalMin); // The scaling factor for  cellSizeGlobal  from max to zero as the minor loop runs
  //cellSizeGlobal = map(generationCosWave, -1, 0,  cellSizeGenerationGlobalMax,  cellSizeGenerationGlobalMin);
  //cellSizeGlobal = map(generationCosWave, -1, 0,  cellSizeGenerationGlobalMin,  cellSizeGenerationGlobalMax);
  //stripeFactor = map(generation, 1, generations, 0.5, 0.5);
  //stripeWidth = map(generation, 1, generations, generations*0.25, generations*0.1);
  //noiseFactor = sq(map(generationCosWave, -1, 1, noiseFactorMax, noiseFactorMin));
  
  //noiseLoopX = width*0.5 + noiseLoopRadius * generationCosWave;   // px is in 'canvas space'
  //noiseLoopY = height*0.5 + noiseLoopRadius * generationSineWave; // py is in 'canvas space'
  //noiseLoopZ = width*0.5 + noiseLoopRadius * generationCosWave;   // Offset is arbitrary but must stay positive (???)
  //noiseLoopZ = map(generation, 1, generations, 0, width);         // pz is in 'canvas space'
}

void modulateByEra() {
  // Values that are modulated by era go here
}

void modulateByEpoch() {
  // Values that are modulated by epoch go here
  //generationsScale = map(epochCosWave, -1, 1, generationsScaleMin, generationsScaleMax);
  //generationsScale = map(eraCompleteness, 0, 1, generationsScaleMin, generationsScaleMax);
  //generationsScale = eraCompleteness * generationsScaleMax; // WIll START AT ZERO! (gives empty first image)
  //generationsScale = 1/pow(cellSizePowerScalar, epoch) * generationsScaleMax;
  //generationsScale = (1-eraCompleteness) *  generationsScaleMax;
  //generationsScale = generationsScaleMax; //STATIC!
  cellSizeGlobal = (1-eraCompleteness) *  cellSizeEpochGlobalMax;
  //cellSizeGlobal = eraCompleteness *  cellSizeEpochGlobalMax;
  //cellSizeGlobal = cellSizeEpochGlobalMax; // STATIC
  //cellSizeGlobal = ((epochs+1)-epoch)/epochs *  cellSizeEpochGlobalMax;
  //cellSizeGlobal = 1/pow(cellSizePowerScalar, epoch) * cellSizeEpochGlobalMax;
  //cellSizeGlobal = 1/pow(cellSizePowerScalar, epoch-1) * cellSizeEpochGlobalMax;
  //cellSizeGlobal = cellSizeEpochGlobalMax/(epoch+1);
  vMaxGlobal = map(epochCosWave, -1, 1, vMaxGlobalMin, vMaxGlobalMax);
  imgWidthScale = 1-(eraCompleteness*0.1);
  imgHeightScale = 1-(eraCompleteness*0.1);
  
  //noiseOctaves = int(map(epochCosWave, -1, 1, noiseOctavesMin, noiseOctavesMax));
  //noiseFalloff = map(epochCosWave, -1, 1, noiseFalloffMin, noiseFalloffMax);
  //noiseFactor = sq(map(epochCosWave, -1, 1, noiseFactorMax, noiseFactorMin));
  noiseFactor = (map(eraCompleteness, 0, 1, noiseFactorMin, noiseFactorMax));
  //curveAngleMin = (map(eraCompleteness, 0, 1, 0, 2));
  //curveAngleMax = (map(eraCompleteness, 0, 1, 0, 6));
  curveAngleMin = (map(epochCosWave, -1, 1, 0, 1));
  curveAngleMax = (map(epochCosWave, -1, 1, 0, 4));
  
  // NOISE SEEDS WILL REMAIN GLOBAL, SINCE ALL CELLS EXIST IN THE SAME NOISESPACE(S)
  //noise1Offset = map(epochCosWave, -1, 1, 0, 100);
  //noise2Offset = map(epochCosWave, -1, 1, 0, 200);
  //noise3Offset = map(epochCosWave, -1, 1, 0, 300);
  
  //noiseLoopRadius = noiseLoopRadiusMedian * map(epochSineWave, -1, 1, 1-noiseLoopRadiusFactor, 1+noiseLoopRadiusFactor); //noiseLoopRadius is scaled by epoch
  //noiseLoopX = width*0.5 + noiseLoopRadius * epochCosWave;   // px is in 'canvas space'
  //noiseLoopY = height*0.5 + noiseLoopRadius * epochSineWave; // py is in 'canvas space'
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
//>>>>>>>>>>>>>>>>>>>>>>>>>>MODULATORS GO ABOVE HERE<<<<<<<<<<<<<<<<<<<<<<<<<<<<

void debugLog() {
  if (debugMode) {
    debugFile.println("Era: " + era + " of " + eras);
    debugFile.println("Epoch: " + int(epoch) + " of " + int(epochs));
    debugFile.println("Generation: " + generation + " of " + generations);
    debugFile.println("Frame: " + frameCount + " Generation: " + generation + " Epoch: " + epoch + " noiseFactor: " + noiseFactor + " noiseOctaves: " + noiseOctaves + " noiseFalloff: " + noiseFalloff);
  }
}

void debugPrint() {
  println("Era " + era + " of " + eras + ", Epoch " + epoch + " of " + epochs + ", Generation " + generation + " of " + generations + " stripeCount " + stripeCounter + " of " + stripeWidth);
  //println("noiseScale: " + noiseScale + " noise1Scale: " + noise1Scale + " noise2Scale: " + noise2Scale + " noise3Scale: " + noise3Scale);
  //println("seedScale: " + seedScale + " noise1Offset: " + noise1Offset + " noise2Offset: " + noise2Offset + " noise3Offset: " + noise3Offset);
  //println("Epoch " + epoch + " of " + epochs + " epochAngle=" + epochAngle + " epochCosWave=" + epochCosWave + " noise1Offset=" + noise1Offset + " noise2Offset=" + noise2Offset + " noise3Offset=" + noise3Offset);

}

void initStripes() {
  // stripeWidth is the width of a PAIR of stripes (e.g. background colour/foregroundcolour)
  //int stripeWidth = ceil(generations * stripeWidthFactor); // stripeWidth is a % of # generations in an epoch
  stripeWidth = ceil(generations * (map(epochCompleteness, 0, 1, stripeWidthFactorMax, stripeWidthFactorMin))); //stripeWidth varies linearly with generations
  // HOW DO I USE constrain() here to prevent stripeWidth from falling below the value 2?
  stripeCounter = 0;
  //println("Initialising Stripes. stripeCounter = " + stripeCounter);
} 

void manageStripes() {
  //float remainingSteps = generations - generation; //For stripes that are a % of remainingSteps in the loop
  //stripeWidth = (remainingSteps * 0.3) + 10;
  
  //If a stripe has been completed. Update stripeWidth value & reset the stripeCounter to start the next one
  if (stripeCounter == stripeWidth) {
    initStripes();
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
  if (debugMode) {debugFile.println("Generation " + generation + " of " + generations + " has ended.");}
    
  // Save an image of the generation frame to the archive folder:
  if (makeGenerationPNG) {updatePngFilename();saveFrame(pngFile); println("Saved Generation frame to .png file: " + pngFile);}
  
  // Add an image of the generation frame to the generation video file:
  if (makeGenerationMPEG) {videoExport.saveFrame();}  // What to do when an epoch is over? (when all the generations in the epoch have been completed)
}

void storeEpochOutput() {
  if (debugMode) {debugFile.println("Epoch " + epoch + " of " + epochs + " has ended.");}
  if (verboseMode) {println("Epoch " + epoch + " of " + epochs + " has ended.");}
  if (makeEpochPNG) {updatePngFilename();saveFrame(pngFile); println("Saved Epoch frame to .png file: " + pngFile);}
  //if (makeEpochMPEG) {videoExport.saveFrame(); println("Saved Epoch frame to .mp4 file: " + mp4File);} // Add an image of the epoch frame to the epoch video file:  
  if (makeEpochMPEG) {videoExport.saveFrame();} // Add an image of the generation frame to the generation video file:

}

void storeEraOutput() {
  if (debugMode) {debugFile.println("Era " + era + " of " + eras + " has ended.");}
  if (verboseMode) {println("Era " + era + " of " + eras + " has ended.");}
  if (makeEraPNG) {updatePngFilename();saveFrame(pngFile); println("Saved Era frame to .png file: " + pngFile);}
  //if (makeEraMPEG) {videoExport.saveFrame(); println("Saved Era frame to .mp4 file: " + mp4File);} // Add an image of the era frame to the era video file:  
  if (makeEraMPEG) {videoExport.saveFrame();} // Add an image of the generation frame to the generation video file:

}

// Saves an image of the final frame, closes any pdf & mpeg files and exits tidily
void lastEra() {
  if (verboseMode) {println("The final era has ended. Goodbye!");}
  if (debugMode) {debugEnd();}
  
  // Save an image of the final frame to the archive folder:
  if (makeFinalPNG) {updatePngFilename();saveFrame(pngFile); println("Saved Final frame to .png file: " + pngFile);}
  
  // If I'm in PDF-mode, complete & close the file
  if (makeFinalPDF) {
    println("Saving completed .pdf file: " + pdfFile);
    endRecord();
  }
  
  // If I'm in any kind of MPEG mode, complete & close the file
  if (makeGenerationMPEG || makeEpochMPEG || makeEraMPEG) {
    println("Saving completed .mp4 file: " + mp4File);
    videoExport.endMovie();
  }
    
  exit();
}

// Returns a color object matching the color of the equivalent pixel at the position 'pos' in the source image /data/input.png
color pixelColour(PVector pos) {
  int pixelX = constrain(int(map(pos.x, -1, width+1, imgWidthLow, imgWidthHigh)), 0, img.width-1); 
  int pixelY = constrain(int(map(pos.y, -1, height+1, imgWidthLow, imgHeightHigh)), 0, img.height-1);
  int pixelPos = pixelX + pixelY * img.width; // Position of pixel to be used for colour-sample
  img.loadPixels(); // Load the pixel array for the input image
  //println("pos.X: " + pos.x + " pos.Y:" + pos.y + "img.width:" + img.width + " img.Height:" + img.height + " PixelX: " + pixelX + " PixelY: " + pixelY + " pixelPos: " + pixelPos +" pixels.length: " + img.pixels.length); // DEBUG
  return color (hue(img.pixels[pixelPos]), saturation(img.pixels[pixelPos]), brightness(img.pixels[pixelPos]), alpha(img.pixels[pixelPos]));
}

// Update the scale of the source image from which colours are picked (to allow dynamic scaling)
void updateImgScale() {
  imgWidthLow = int(0.0 * img.width);
  imgWidthHigh = int(1.0 * imgWidthScale * img.width)-1;
  imgHeightLow = int(0.0 * img.height);
  imgHeightHigh = int(1.0 * imgHeightScale * img.height)-1;
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
  logFile.println("makeFinalPDF = " + makeFinalPDF);
  logFile.println("makeGenerationPNG = " + makeGenerationPNG);
  logFile.println("makeEpochPNG = " + makeEpochPNG);
  logFile.println("makeEraPNG = " + makeEraPNG);
  logFile.println("makeFinalPNG = " + makeFinalPNG);
  logFile.println("makeGenerationMPEG = " + makeGenerationMPEG);
  logFile.println("makeEpochMPEG = " + makeEpochMPEG);
  logFile.println("makeEraMPEG = " + makeEraMPEG);
  logFile.println("updateEpochBkg = " + updateEpochBkg);
  logFile.println("updateEraBkg = " + updateEraBkg);
  logFile.println("debugMode = " + debugMode);
  logFile.println();
  
  logFile.println("Loop Control variables:");
  logFile.println("-----------------------");
  logFile.println("generationsScaleMin = " + generationsScaleMin + " generationsMin = " + (ceil(generationsScaleMin*w)+1));
  logFile.println("generationsScaleMax = " + generationsScaleMax + " generationsMax = " + (ceil(generationsScaleMax*w)+1));
  logFile.println("generations (static value, if used) = " + generations);
  logFile.println("epochs = " + epochs);
  logFile.println("eras = " + eras);
  logFile.println();
  
  logFile.println("Cartesian Grid variables:");
  logFile.println("-------------------------");
  logFile.println("cols = " + cols);
  logFile.println("rows = " + rows);
  logFile.println("elements = " + elements);
  logFile.println();

  
  logFile.println("Element Size variables:");
  logFile.println("-----------------------");
  logFile.println("cellSizeEpochGlobalMin = " +  cellSizeEpochGlobalMin);
  logFile.println("cellSizeEpochGlobalMax = " +  cellSizeEpochGlobalMax);
  logFile.println("cellSizePowerScalar = " +  cellSizePowerScalar);
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
  if (key == 'q') {lastEra();}
  if (key == 'p') {updatePngFilename();saveFrame(pngFile); println("Saved a keypress frame to .png file: " + pngFile);}
  if (key == 'c') {randomChosenOnes(); println("New Chosen Ones selected!");}
  if (key == 't') {makeEpochPNG = !makeEpochPNG; println("Toggled makeEpochPNG");}
}
