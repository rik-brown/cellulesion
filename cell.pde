class Cell {
  
  // IDENTITY
  int id;
  int brood; // 0 is the first brood
  float broodFactor;
  int age;
  int maxAge; // The greatest possible value age can have (equal to generations for brood 0 cells, to generations-generation for later broods)
  int transitionAge; // The age (in generations) at which a cell becomes 'adult' and can collide/conceive (applies only to brood 1 and higher)
  float maturity; // The % of life lived (rang 0-1.0)
  boolean hasCollided;
  boolean fertile;
  boolean hatchling;
  
  // MOVEMENT
  PVector position;     // current position on the canvas
  PVector origin;       // starting position on the canvas
  PVector velocity;     // velocity
  
  ArrayList<PVector> positionHistory;    // An arraylist to store all the positions the cell has occupied
  ArrayList<Float> sizeHistory;    // An arraylist to store all the positions the cell has occupied
  
  float vMax;           // Half of maximum size of each x-y component in the velocity vector (velocity.x in the range -vMax/+vMax)
                        // Alternatively: the scalar length of the velocity vector
  float angleOffset;
  float angle;          // Heading of the velocity vector
  int myDirection;      // Integer which can be mapped to a heading for velocity
  int stepCount;        // Simple counter used for stepping through changes of direction
  float noiseRangeLow;  // When mapping noise to <something>, this is the lower value of the noise range (e.g. in range 0-0.3)
  float noiseRangeHigh; // When mapping noise to <something>, this is the upper value of the noise range (e.g. in range .7-1.0)
  
  // COLOR
  float fill_Hue, fill_Sat, fill_Bri, fill_Trans;          // Fill colour components
  color fill_Old;                                          // Fill colour from the previous cycle
  int fill_H_start, fill_H_end;
  int fill_S_start, fill_S_end;
  int fill_B_start, fill_B_end;
  int fill_T_start, fill_T_end;
  float stroke_Hue, stroke_Sat, stroke_Bri, stroke_Trans;  // Stroke colour components
  
  // NOISE
  float noise1, noise2, noise3;                      // Noise values
  PVector noiseLoop1, noiseLoop2, noiseLoop3;        // NOT CURRENTLY IN USE !
  PVector noiseVector1, noiseVector2, noiseVector3;  // NOT CURRENTLY IN USE !
  
  // SIZE
  float cellSize;       // Size scaling factor unique to each cell
  float rx;             // Radius size x-component (absolute value used when drawing an element) 
  float ry;             // Radius size y-component (scaling value in range 0-1, 0-100%, multiplied by rx)
  //                       Alternative calculation: (absolute value used when drawing an element) 
  
  // **************************************************CONSTRUCTOR********************************************************
  // CONSTRUCTOR: create a 'cell' object
  Cell (int id_, int brood_, PVector pos, PVector vel, float cellSize_, float vMax_, float hs, float he, float ss, float se, float bs, float be) {
    //Variables in the object:
    id = id_;
    brood = brood_;
    broodFactor = pow(brood+1,-1);
    age = 0;
    maxAge = generations - generation;
    updateMaturity();
    hasCollided = false;
    fertile = true;
    origin = pos.copy();
    position = pos.copy();
    velocity = vel.copy();
    positionHistory = new ArrayList<PVector>(); // Initialise the arraylist
    sizeHistory = new ArrayList<Float>(); // Initialise the arraylist
    //updatePositionHistory(); // Add the first position in the constructor
    cellSize = cellSize_;
    if (brood==0) {hatchling = false; transitionAge = 0;} else {hatchling = true; transitionAge = int(maxAge * 0.3);} // For all other broods than first, transitionAge is >0
    // This might get tricky in later broods when size is greatly reduced. Need to come back to this when I have figured out how brood will affect size.
    // For the time being - leaving cellSize out of the equation since this will normally be <1 so size will never be greater than cellSizeGlobal
    
    vMax = vMax_;
    stepCount = 0;
    //vMax = generations * 0.0003;
    //vMax = w * 0.0001;
    noiseRangeLow = 0.25;
    noiseRangeHigh = 0.75;
    fill_H_start = int(hs*360);
    fill_H_end = int(he*360);
    fill_S_start = int(ss*255);
    fill_S_end = int(se*255);
    fill_B_start = int(bs*255);
    fill_B_end = int(be*255);
    fill_T_start = int(255*1.0);
    fill_T_end = int(255*1.0);
  }
    
  void update() {
    //Call the update functions which will be executed before displaying the cell:
    //Initial position is given by the constructor
    //Noise values are calculated from a combination of position & external factors
    //Size, Colors & Velocity are all calculated using current Noise values
    //Rotation angle could be replaced by Velocity heading or calculated directly from Noise values
    //Stripe is calculated from external factors (or maybe later from local ones, or noise values?)
    //radius();
    updateMaturity();
    if (!hasCollided) {updatePositionHistory();} // Add the current position to the ArrayList storing all positions
    updateNoise();
    if (!hasCollided) {updateSize(); updateSizeHistory();}
    updateFillColor();
    //updateStripes();
    updateStroke();
    setFillColor();
    updateVelocity();
    updateRotation();
    //display();
    //move();
    updateOldFillColor();
    //if (generation == 1) {shapeStart();}
    //shapeVertex();
    //if (generation == generations) {shapeStop(); shapeDisplay();}
    updateAge();
  }
  
  // Add position to ArrayList 'positionHistory'
  void updatePositionHistory() {
    positionHistory.add(new PVector(position.x, position.y));
    //println("Generation:" + generation + " Cell ID:" + id + " X=" + position.x + " Y=" + position.y + " positionHistory.size=" + positionHistory.size() );
    //for (int i = positionHistory.size()-1; i >= 0; i--) {
    //  PVector positionTest = positionHistory.get(i);
    //  println("Test... i=" + i + " x=" + positionTest.x + " y=" + positionTest.y);
    //}
  }
  
  void updateNoise() {
    // Put the code for updating noise here 
    //noise1 = noise(noise1Scale*(position.x + noiseLoopX + noise1Offset), noise1Scale*(position.y + noiseLoopY + noise1Offset), noise1Scale*(noiseLoopZ + noise1Offset));
    //noise2 = noise(noise2Scale*(position.x + noiseLoopX + noise2Offset), noise2Scale*(position.y + noiseLoopY + noise2Offset), noise2Scale*(noiseLoopZ + noise2Offset));
    //noise3 = noise(noise3Scale*(position.x + noiseLoopX + noise3Offset), noise3Scale*(position.y + noiseLoopY + noise3Offset), noise3Scale*(noiseLoopZ + noise3Offset));
    
    noise1 = noise(noise1Scale*(position.x + noise1Offset), noise1Scale*(position.y + noise1Offset));
    noise2 = noise(noise2Scale*(position.x + noise2Offset), noise2Scale*(position.y + noise2Offset));
    noise3 = noise(noise3Scale*(position.x + noise3Offset), noise3Scale*(position.y + noise3Offset));
    
    
    //WHAT I THINK I WILL AIM FOR IN A FUTURE VERSION:
    // noise1=(noiseVector1.x, noiseVector1.y, noiseVector1.z) OR
    // noise1 = noise(noise1Scale*noiseVector1.x, noise1Scale*noiseVector1.y, noise1Scale*noiseVector1.z);
    //ALLOWING ME TO USE VECTOR MATH TO MOVE THROUGH THE NOISE SPACE: SCALAR, ROTATE ETC.
    // Where noiseVector1 is 'local' (unique for each cell)
    //FOR NOW, START WITH A SIMPLE CONVERSION ATTEMPT:
    // noise1Scale, noise2Scale, noise3Scale
    // noiseLoopX, noiseLoopY, noiseLoopZ
    // noise1Offset, noise2Offset, noise3Offset
    // ARE ALL GLOBAL VARIABLES, AVAILABLE TO ALL CELLS, HAVING EQUAL VALUE
    
    // X co-ordinate:
    // position.x (cartesian grid position on the 2D canvas)
    // +
    // noiseLoopX (x co-ordinate of the current point of the circular noisepath on the 2D canvas)
    // +
    // seedN (arbitrary noise seed number offsetting the canvas along the x-axis)
    //
    // The sum of these values is multiplied by the constant scaling factor 'noise1Scale' (whose values does not change relative to window size)
    
    // Y co-ordinate:
    // position.y (cartesian grid position on the 2D canvas)
    // +
    // noiseLoopY (y co-ordinate of the current point of the circular noisepath on the 2D canvas)
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
  }
  
  void updateSize() {
    // Put the code for updating size (radii) here
    //rx = map(noise2, noiseRangeLow, noiseRangeHigh, 0, colWidth* cellSizeGlobal);
    //rx = map(1, 0, 1, 0, colWidth * 0.5 * cellSizeGlobal * cellSize);   // rx is controlled by GLOBAL changes, not local to the cell
    rx = colWidth * 0.5 * cellSizeGlobal * cellSize * broodFactor;
    //ry = map(noise3, noiseRangeLow, noiseRangeHigh, 0, rowHeight* cellSizeGlobal);      //ry is a value in same range as rx
    //ry = map(1, 0, 1, 0, rowHeight * 0.5 * cellSizeGlobal * cellSize);   // ry is controlled by GLOBAL changes, not local to the cell
    ry = rx; // HACK UNTIL rowHeight is fixed for isoGrid HACK! HACK! HACK!
    //ry = map(noise3, noiseRangeLow, noiseRangeHigh, 0.5, 1.0);                    //ry is a scaling factor of rx in range 50-100% REALLY? THIS IS A BIT SAFE!!!
  }
  
  // Add size to ArrayList 'sizeHistory'
  void updateSizeHistory() {
    float currentSize = rx;
    sizeHistory.add(currentSize);
    //println("Generation:" + generation + " Cell ID:" + id + " currentSize=" + currentSize);
    //for (int i = sizeHistory.size()-1; i >= 0; i--) {
    //  float sizeTest = sizeHistory.get(i);
    //  println("Test... i=" + i + " sizeTest=" + sizeTest);
    //}
  }
  
  void updateFillColor() {
    // Put the code for updating fill & stroke colors here:
    
    //updateFillColorByPosition();
    //updateFill_ByEpoch();
    //if (age == 0) {updateFillColorByPosition();}
    
    //updateFill_HueByPosition();
    //updateFill_HueByEpochAngle();
    //updateFill_HueByEpoch();
    //updateFill_HueByOddBrood();
    //updateFill_HueByMaturity();
    updateFill_HueByBroodFactor();
    
    //updateFill_SatByPosition();
    //updateFill_SatByEpoch();
    updateFill_SatByMaturity();
    //updateFill_SatByBroodFactor();
    
    //updateFill_BriByPosition();
    //updateFill_BriByEpoch();
    //updateFill_BriByMaturity();
    updateFill_BriByBroodFactor();
    
    //updateFill_TransByEpoch();
    
    //updateFillColorByOdd();
    //updateFillColorByOdd_BW();
    //updateFillColorByOddBrood();
    
    // Random old stuff that I  can't be bothered to move...
    //fill_Hue = map(generation, 1, generationsScaleMax*w, fill_H_start, fill_H_end);
    
    //fill_Sat = map(noise3, 0, 1, fill_S_start, fill_S_end);
    //fill_Sat = 0;
    //fill_Sat = map(generation, 1, generations, fill_S_start, fill_S_end);
    
    //fill_Bri = map(noise2, 0, 1, fill_B_start, fill_B_end);
    //fill_Bri = map(generation, 1, generations, fill_B_start, fill_B_end);
    
    //fill_Bri = map(generationCosWave, -1, 0, fill_B_start, fill_B_end);      
  }
  
  void updateStroke() {
    //strokeWeight(map(generationCosWave, -1, 0, 2, 0.5));
    //stroke(fill_Hue, fill_Sat, 0, fill_Trans); // Set the stroke color
    //stroke(240,255,255,fill_Trans);
    //strokeWeight(2);
    //stroke(360,255);
    //stroke(0,8);
    noStroke();
  }
  
    void updateBkgColorByGeneration() {
      //bkg_Bri = map(generation, 0, generations, 255, 128);
      //bkg_Sat = map(generation, 0, generations, 160, 255);
  }
  
  void updateFillColorByGeneration() {
    fill_Hue = map(generation, 1, generations, fill_H_start, fill_H_end);
    fill_Sat = map(generation, 1, generations, fill_S_start, fill_S_end);
    fill_Bri = map(generation, 1, generations, fill_B_start, fill_B_end);
    fill_Trans = map(generation, 1, generations, fill_T_start, fill_T_end);
  }
  
  
  void updateFillColorByOdd() {
    noStroke();
    if (isOdd(int(epoch))) {
      fill(fill_Hue, fill_Sat, fill_Bri, fill_Trans);
    }
    else {
      fill(0,255,255);
    }
  }
  
  void updateFillColorByOdd_BW() {
    noStroke();
    //NOTE: First Epoch = 1 = ODD
    if (isOdd(int(epoch))) {
      fill(360);
      //fill(map(fill_Bri,0,255,0,360));
      //if (hasCollided) {fill(0,255,255);} else {fill(360);}
    }
    else {
      //fill(360);
      fill(0);
    }
  }
  
  void updateFillColorByBrood() {
    // This will modulate colours according to brood number development from 0 >>
    //updateFill_HueByBroodFactor();
    updateFill_SatByBroodFactor();
    //updateFill_BriByBroodFactor();
  }
  
  void updateFillColorByOddBrood() {
    noStroke();
    //NOTE: First Brood = 0 = EVEN
    if (isOdd(int(epoch))) {
      if (isOdd(brood)) {
        //fill_Bri = 0; // Black
        fill_Bri = 255; // White
        fill_Sat = 0;   // White
      }
      else {
        //fill_Hue = 200;
        updateFill_HueByMaturity();
        //fill_Sat = 255; // Sky Blue
        updateFill_SatByBroodFactor();
        //fill_Bri = 255;
        updateFill_BriByEpoch();
        }
    }
    else {
      if (isOdd(brood)) {
        fill_Sat = 0;
        fill_Bri = 255; // White
        //fill_Bri = 0; // Black
      }
      else {
        //fill_Hue = 200;  // Sky Blue
        updateFill_HueByMaturity();
        //fill_Sat = 255;
        updateFill_SatByBroodFactor();
        //fill_Bri = 255;
        updateFill_BriByEpoch();
      }
    }
  }
  
  void updateFill_HueByOddBrood() {
    noStroke();
    //NOTE: First Brood = 0 = EVEN
    if (isOdd(int(epoch))) {
      if (isOdd(brood)) {fill_Hue = 0;} else {fill_Hue = 240;}
    }
    else {
      if (isOdd(brood)) {fill_Hue = 0;} else {fill_Hue = 240;}
    }
  }
  
  void updateFill_HueByBroodFactor() {
    fill_Hue = map(broodFactor, 1 , 0, fill_H_start, fill_H_end);
  }
  
  void updateFill_SatByBroodFactor() {
    fill_Sat = map(broodFactor, 1 , 0, fill_S_start, fill_S_end);
  }
  
  void updateFill_BriByBroodFactor() {
    fill_Bri = map(broodFactor, 1 , 0, fill_B_start, fill_B_end);
  }
  
  void updateFillColorByPosition() {
    color pixelColor = pixelColour(position);
    fill_Hue = hue(pixelColor);
    fill_Sat = saturation(pixelColor);
    fill_Bri = brightness(pixelColor);
  }
  
  void updateFill_HueByPosition() {
    color pixelColor = pixelColour(position);
    fill_Hue = hue(pixelColor);
  }
  
  void updateFill_SatByPosition() {
    color pixelColor = pixelColour(position);
    fill_Sat = saturation(pixelColor);
  }
  
  void updateFill_BriByPosition() {
    color pixelColor = pixelColour(position);
    fill_Bri = brightness(pixelColor);
  }
  
  void updateFill_ByEpoch() {
    fill_Hue = map(epochsProgress, 0, 1, fill_H_start, fill_H_end);
    fill_Sat = map(epochsProgress, 0, 1, fill_S_start, fill_S_end);
    fill_Bri = map(epochsProgress, 0, 1, fill_B_start, fill_B_end);
    fill_Trans = map(epochsProgress, 0, 1, fill_T_start, fill_T_end);
  }
  
  void updateFill_HueByEpoch() {
    fill_Hue = map(epoch, 1, epochs, fill_H_start, fill_H_end); // NB! Will not work when epochs=1
  }
  
  void updateFill_BriByEpoch() {
    fill_Bri = map(epoch, 1, epochs, fill_B_start, fill_B_end); // NB! Will not work when epochs=1
  }
  
  void updateFill_SatByEpoch() {
    fill_Sat = map(epoch, 1, epochs, fill_S_start, fill_S_end); // NB! Will not work when epochs=1
  }
  
  void updateFill_HueByMaturity() {
    fill_Hue = map(maturity, 0, 1, fill_H_start, fill_H_end);
  }
  
  void updateFill_HueByMaturityREV() {
    fill_Hue = map(maturity, 1, 0, fill_H_start, fill_H_end);
  }
  
  void updateFill_SatByMaturity() {
    fill_Sat = map(maturity, 0, 1, fill_S_start, fill_S_end);
    //println("ID:" + id + " age:" + age + " fill_S_start:" + fill_S_start + " fill_S_end:" + fill_S_end +  " fill_Sat:" + fill_Sat);
  }
  
  void updateFill_BriByMaturity() {
    fill_Bri = map(maturity, 0, 1, fill_B_start, fill_B_end);
    //println("ID:" + id + " age:" + age + " fill_B_start:" + fill_B_start + " fill_B_end:" + fill_B_end +  " fill_Bri:" + fill_Bri);
  }
  
  void updateFill_HueByEpochAngle() {
    fill_Hue = map(epochCosWave, -1, 1, fill_H_start, fill_H_end);
  }
  
  void updateFill_TransByEpoch() {
    fill_Trans = map(epochsProgress, 0, 1, fill_T_start, fill_T_end); // NB! Will not work when epochs=1
  }
  
  void updateOldFillColor() {
    //Need to set the initial value for fill_Hue_Old on first run (to have a value to use in first lerp)
    fill_Old = color(fill_Hue, fill_Sat, fill_Bri);
  }
  
  void setFillColor() {
    //noFill();
    fill(fill_Hue, fill_Sat, fill_Bri);           // Set the fill color (default transparency)
    //fill(fill_Hue, fill_Sat, fill_Bri, fill_Trans); // Set the fill color (modulated transparency)
    //fill(fill_Hue, 0, fill_Bri);                  // Set the fill color B+W
    //fill(fill_Bri);                               // Set the fill color monochrome greyscale (from Brightness)
    //if (noise1>=0.5) {fill(360);} else {fill(0);} // Primitive noise boundary fill
  }
  
  void updateStripes() {
    // Put the code for updating stripes here
    //if (stripeCounter >= stripeWidth * stripeFactor) {fill(360);} else {fill(0);} // Monochrome
    //if (stripeCounter >= stripeWidth * stripeFactor) {fill(360);} else {fill(240, 255, 255);}
    //if (stripeCounter >= stripeWidth * stripeFactor) {fill(0,0,fill_Bri);} else {fill(0);}
    //if (stripeCounter >= stripeWidth * stripeFactor) {fill(240,fill_Sat,fill_Bri);} else {fill(fill_Hue,255,255);}
    //if (stripeCounter >= stripeWidth * stripeFactor) {fill(240,fill_Sat,fill_Bri);} else {fill(bkg_Hue, bkg_Sat, bkg_Bri);}
    //if (stripeCounter >= stripeWidth * stripeFactor) {fill(fill_Hue, fill_Sat, fill_Bri);} else {fill(bkg_Hue, bkg_Sat, bkg_Bri);}
    if (stripeCounter >= stripeWidth * stripeFactor) {fill(fill_Hue, fill_Sat, fill_Bri);} else {fill(pixelColour(position));}
  }
  
  void initialVelocityFromNoise() {
    // When updateVelocity is replaced by rotateVelocity (and vector is not renewed on each cycle, just rotated & rescaled) it must be INITIATED on first run
    velocity = PVector.fromAngle(map(noise1, noiseRangeLow, noiseRangeHigh, 0, TWO_PI)).mult(map(noise2, noiseRangeLow, noiseRangeHigh, 0, vMaxGlobal * vMax));
    //velocity.rotate(epochAngle);
  }
  
  void updateVelocity() {
    updateVelocityByNoise();
    //updateVelocityLinear();
    //updateVelocityLinearIso();
    //updateVelocityLinearHueSway();
    //updateVelocityAwayFromFocalPoint();
    //updateVelocityAwayFromFocalPoint2();
    //updateVelocityAwayFromFocalPointWiggly();
    //if (generation == 1) {initialVelocityFromColour();}
    //if (generation == 1) {initialVelocityFromNoise();}
    //if (generation == 1) {rotateVelocityByEonAngle();}
    //updateVelocityByColour();
    //updateVelocityByLerpColour();
    //updateVelocityByCycle();
    //updateVelocityCircular();
    //rotateVelocityByHue();
  }
  
  void updateVelocityByCycle() {
    // Goal here is that Vmax will vary according to an epoch cycle to vary the 'range' of the cell sinusoidally
    // Where each cell will have it's own personal phase angle offset (e.g. from local noise value)
    if (generation ==1) {angleOffset = map(noise1, 0.25, 0.75, 0, TWO_PI);}
    //if (generation ==1) {angleOffset = map(position.x, 0, width, 0, TWO_PI);}
    float vScalar = map(sin(epochAngle + angleOffset),-1,1,0,1);
    velocity = PVector.fromAngle(PI*1.5).mult(vMaxGlobal * vMax * vScalar);
    if (generation ==2) {
      rx *= map(vScalar, -1, 1, 0.9, 1.1);
      ry *= map(vScalar, -1, 1, 0.9, 1.1);
      //fill_Bri *= map(vScalar, -1, 1, 0.8, 1.25);
      fill_Sat *= map(vScalar, -1, 1, 1.0, 0.9);
      fill(fill_Hue, fill_Sat, fill_Bri); 
    }
  }
  
  void updateVelocityCircular() {
    float segmentAngle = (TWO_PI/(generations-1)) * epochsProgress * 0.5;
    PVector center = new PVector(origin.x + colWidth, origin.y); //FLAW!!! This will move as position moves! Need a fixed reference
    PVector center2Pos = PVector.sub(position, center);
    line(center.x, center.y, center.x+center2Pos.x, center.y+center2Pos.y);
    PVector center2NewPos = center2Pos.copy();
    center2NewPos.rotate(segmentAngle);
    PVector newPos = new PVector(center.x+center2NewPos.x, center.y+center2NewPos.y);
    //line(center.x, center.y, newPos.x, newPos.y);
    velocity = PVector.sub(newPos, position);
  }

  
  void updateVelocityByNoise() {
    // Put the code for updating velocity here
    //velocity = new PVector(map(noise1, 0, 1, -vMax, vMax), map(noise2, 0, 1, -vMax, vMax));
    //velocity = new PVector(map(noise1, noiseRangeLow, noiseRangeHigh, -vMax, vMax), map(noise2, noiseRangeLow, noiseRangeHigh, -vMax, vMax));
    //velocity = PVector.fromAngle(map(noise1, noiseRangeLow, noiseRangeHigh, 0, TWO_PI)).mult(map(noise2, noiseRangeLow, noiseRangeHigh, 0, vMax));
    //if (epoch/epochs <= 0.5) {
    //  velocity = PVector.fromAngle(0).mult(vMaxGlobal * vMax);
    //}
    //else {
    //  velocity = PVector.fromAngle(map(noise1, noiseRangeLow, noiseRangeHigh, 0, TWO_PI)).mult(map(noise2, noiseRangeLow, noiseRangeHigh, 0, vMaxGlobal * vMax));
    //}
    velocity = PVector.fromAngle(map(noise1, noiseRangeLow, noiseRangeHigh, 0, TWO_PI)).mult(map(noise2, noiseRangeLow, noiseRangeHigh, 0, vMaxGlobal * vMax));
    //velocity.rotate(epochAngle);
  }
  
  void updateVelocityLinear() {
    velocity.setMag(vMaxGlobal * vMax); //Always update the magnitude of the velocity vector (in case vMaxGlobal or vMax have changed)
    //velocity = PVector.fromAngle(PI*1.5).mult(vMaxGlobal * vMax);
    //velocity.rotate(epochAngle);
  }
  
  void updateVelocityLinearIso() {
    // Will choose one of a set of predefined directions & follow it
    // Selection could be based on initial noise value   
    velocity.setMag(vMaxGlobal * vMax); //Always update the magnitude of the velocity vector (in case vMaxGlobal or vMax have changed)
    //velocity.setMag(rx); //Experimental
    //float changeDirectionDenominator = eonsProgress * 20; 
    float changeDirectionDenominator = 9;
    int changeDirection = int(generationsScaleMax*w/changeDirectionDenominator);
    if (generation%changeDirection==1) {
      //Put code here for 'what do I do in order to bring about a change in direction'
      //myDirection = int(map(noise1, noiseRangeLow, noiseRangeHigh, 1, directions)); // Earlier code to change direction based on noise value - keep!
      int stepLimit = directions.numSteps; // The max number of available 'direction changers' to be stepped through (= length of IntList in directions object)
      int step = stepCount%stepLimit;      // The current step value = the position in the IntList from which a 'direction changer' will be picked
      int directionValue = directions.dirArray[id].get(step);
      float headingAngle = TWO_PI/9; // How many headings (directions) are there in the 'compass' (360 degrees divided equally by this amount)
      velocity.rotate(headingAngle * directionValue);
      //velocity.rotate(eonAngle); //Rotates at every generation. Interesting (but unintended) effect - see cellulesion-010-20180615-210610 (example). 
      stepCount++; //<>//
    }    
  }
  
  void updateVelocityLinearIsoSIN() {
    // Will choose one of a set of predefined directions & follow it
    // Selection could be based on initial noise value   
    velocity.setMag(vMaxGlobal * vMax); //Always update the magnitude of the velocity vector (in case vMaxGlobal or vMax have changed)
    int changeDirection = int(generationsScaleMax*w/6);
    if (generation%changeDirection==1) {
      //Put code here for 'what do I do in order to bring about a change in direction'
      //myDirection = int(map(noise1, noiseRangeLow, noiseRangeHigh, 1, directions)); // Earlier code to change direction based on noise value - keep!
      int stepLimit = directions.numSteps; // The max number of available 'direction changers' to be stepped through (= length of IntList in directions object)
      int step = stepCount%stepLimit;      // The current step value = the position in the IntList from which a 'direction changer' will be picked
      //int directionValue = directions.dirArray[id].get(step);
      float directionValue = generationSineWave;
      println("id=" + id + " dirVal=" + directionValue);
      float headingAngle = TWO_PI/6; // How many headings (directions) are there in the 'compass' (360 degrees divided equally by this amount)
      velocity.rotate(headingAngle * directionValue);
      stepCount++;
    }    
  }
  
  void updateVelocityLinearHueSway(){
    velocity = PVector.fromAngle(PI*1.5).mult(vMaxGlobal * vMax);
    float swayFactor = cos(radians(fill_Hue));
    float swayAngle = PI * map(swayFactor, -1, 1, -0.05, 0.05);
    velocity.rotate(epochAngle + swayAngle);
  }
  
  void updateVelocityAwayFromFocalPoint(){
    float focusRadius = width*map(epochCosWave, -1, 1, 1.0, 1.75);
    float angleOffset = PI * map(epochSineWave, -1, 1, -0.0, 0.0);
    float focusX = sin(-epochAngle+angleOffset) * focusRadius;
    float focusY = cos(-epochAngle+angleOffset) * focusRadius;
    PVector focusPos = new PVector(width*0.5 + focusX, height*0.5 + focusY);
    //PVector center = new PVector(width*0.5, height*0.5);
    velocity = PVector.sub(position, focusPos).setMag(vMaxGlobal * vMax);
  }
  
  void updateVelocityAwayFromFocalPoint2(){
    float focusRadius = width*map(generationCosWave, -1, 1, 1.5, 0.5);
    float angleOffset = PI * map(epochSineWave, -1, 1, 0.0, 0.0);
    float focusX = sin(-epochAngle+angleOffset) * focusRadius;
    float focusY = cos(-epochAngle+angleOffset) * focusRadius;
    PVector focusPos = new PVector(width*0.5 + focusX, height*0.5 + focusY);
    //PVector center = new PVector(width*0.5, height*0.5);
    velocity = PVector.sub(position, focusPos).setMag(vMaxGlobal * vMax);
  }
  
  void updateVelocityAwayFromFocalPointWiggly(){
    float focusRadius = width*map(epochCosWave, -1, 1, 0.25, 2);
    float wiggleFactor = map(epochCosWave, -1, 1, 0, 2.0);
    //float angleOffset = PI * wiggleFactor * map(generationWiggleWave, -1, 1, -0.75, 0.75);
    float angleOffset = PI * wiggleFactor * map(generation, 1, generations, 0, 1.0);
    float focusX = sin(-epochAngle+angleOffset) * focusRadius;
    float focusY = cos(-epochAngle+angleOffset) * focusRadius;
    PVector focusPos = new PVector(width*0.5 + focusX, height*0.5 + focusY);
    //PVector center = new PVector(width*0.5, height*0.5);
    velocity = PVector.sub(position, focusPos).setMag(vMaxGlobal * vMax);
  }
  
  void updateVelocityByColour() {
    float scalar = map(brightness(pixelColour(position)), 0, 255, 1, vMaxGlobal * vMax);
    //println("Scalar value = " + scalar);
    velocity = PVector.fromAngle(map(fill_Hue, 0, 360, 0, TWO_PI)).mult(scalar);
    velocity.rotate(epochAngle);
  }
  
  void updateVelocityByLerpColour() {
    //New heading is given by the 'colourAngle' of the hue value gained by lerping between old & new colours
    if (generation == 1) {fill_Old = color(fill_Hue, fill_Sat, fill_Bri);}
    color fill_Now = color(fill_Hue, fill_Sat, fill_Bri);
    color lerpCol = lerpColor(fill_Old, fill_Now, 0.1);
    //float delta = (cellSizeEpochGlobalMax - cellSizeGlobalMin)/generations; // Incremental size scaling factor (not actual value)
    //float scalar = (rx*2) - (colWidth * cellSize * delta);
    float scalar = rx*1.5;
    velocity = PVector.fromAngle(map(hue(lerpCol), 0, 360, 0, TWO_PI)).mult(scalar); //Unit vector, needs scaling
     println("Old hue: " + hue(fill_Old) + " Current hue: " + hue(fill_Now) + " Lerp hue: " + hue(lerpCol) + " Heading: " + degrees(velocity.heading()) );
    velocity.rotate(epochAngle);
    fill_Old = lerpCol;
  }
  
  void initialVelocityFromColour() {
    // When updateVelocity is replaced by rotateVelocity (and vector is not renewed on each cycle, just rotated & rescaled) it must be INITIATED on first run
    float scalar = map(brightness(pixelColour(position)), 0, 255, 1, vMaxGlobal * vMax);
    velocity = PVector.fromAngle(map(fill_Hue, 0, 360, 0, TWO_PI)).mult(scalar); // Minimum velocity must be 1.0 to avoid deadlock
    //println("Scalar value = " + scalar + " Vel.x = " + velocity.x + " Vel.y = " + velocity.y);
    //velocity.rotate(epochAngle);
  }
  
  void rotateVelocityByHue() {
    float scalar = map(brightness(pixelColour(position)), 0, 255, 1, vMaxGlobal * vMax);
    velocity.rotate(map(fill_Hue, 0, 360, radians(-1), radians(1)));
    //println("Scalar value = " + scalar + " Vel.x = " + velocity.x + " Vel.y = " + velocity.y);
    //velocity.rotate(epochAngle);
  }
  
  void rotateVelocityByEonAngle() {
    velocity.rotate(eonAngle);
  }
  
  
  void updateRotation() {
    // Put the code for updating angle of rotation here
    //angle = map(noise1,0,1,0,TWO_PI);
    angle = velocity.heading();
  }
  
  void updateAge() {
    age ++;
    transitionAge --;
    if (transitionAge <= 0) {hatchling = false;}
  }
  
  void updateMaturity() {
    maturity = map(age, 0, maxAge, 0, 1);
    //println("ID:" + id + " age:" + age + " maxAge:" + maxAge + " maturity:" + maturity);
  }
  
  void shapeStart() {
    cell = createShape();
    cell.beginShape();
    cell.stroke(0);
    cell.noFill();
    println("Started shape");
  }
  
  void display() {
    // Put the code for displaying the cell here
    //draw the thing
    pushMatrix();
    translate(position.x, position.y); // Go to the grid location
    rotate(angle - (PI*0.5)); // Rotate to the current angle
    
    // These shapes require that ry is a value in a similar range to rx
    ellipse(0,0,rx,ry); // Draw an ellipse
    //triangle(0, -ry, (rx*0.866), (ry*0.5) ,-(rx*0.866), (ry*0.5)); // Draw a triangle
    //rect(0,0,rx,ry); // Draw a rectangle
    
    //blob();
    
    // These shapes requires that ry is a scaling factor (e.g. in range 0.5 - 1.0)
    //ellipse(0,0,rx,rx*ry); // Draw an ellipse
    //triangle(0, -rx*ry, (rx*0.866), (rx*ry*0.5) ,-(rx*0.866), (rx*ry*0.5)); // Draw a triangle
    //rect(0,0,rx,rx*ry); // Draw a rectangle  
    //if (debugMode) {debugFile.println("Drawing a thing at x:" + gridx + " y:" + gridy + " with rx=" + rx + " ry=" + ry + " & noise1=" + noise1 + " noise2=" + noise2 + " noise3=" + noise3);}
    //println("Drawing a thing at x:" + position.x + " y:" + position.y + " with rx=" + rx + " ry=" + ry + " & noise1=" + noise1 + " noise2=" + noise2 + " noise3=" + noise3);
    
    //float size = colWidth*ellipseSize;
    ////stroke(0,128);
    //fill(map(noise1, 0.3, 0.7, 0, 360), 255, 255, 255);
    //ellipse(0,0,size, size);
    //fill(map(noise2, 0.3, 0.7, 0, 360), 255, 255, 255);
    //ellipse(0,0,size*0.66, size*0.66);
    //fill(map(noise3, 0.3, 0.7, 0, 360), 255, 255, 255);
    //ellipse(0,0,size*0.33, size*0.33);
    
    popMatrix();
  }
  
  void shapeVertex() {
    cell.vertex(position.x, position.y);
    println("Vertex added to shape");
  }
  
  void shapeStop() {
    if (generation == generations) {cell.endShape();}
    println("Stopped shape");
  }
  
  void shapeDisplay() {
    shape(cell, 0, 0);
    println("Displayed shape");
  }
  
  void first(int id) {
    // The idea is to draw a shape at the seed position
    // and a shape at the final position
    // and a line joining the two (the line should be drawn first)
    // Calculate size of shape:
    //float radius = width*0.012;
    float radiusMin = colWidth * cellSizeEpochGlobalMax;
    float radiusMax = radiusMin * 1.1;
    float radius = radiusMin;
    // Draw shape at 'start' position:
    //fill(360);
    //fill(240,255,255);
    fill(fill_Hue, fill_Sat, fill_Bri); // Set the fill color
    pushMatrix();
    translate(positions.seedpos[id].x, positions.seedpos[id].y); // Go to the seed position (which will be the last position in the epoch)
    ellipse(0,0,radius,radius); // Draw an ellipse
    //triangle(0, -ry, (rx*0.866), (ry*0.5) ,-(rx*0.866), (ry*0.5)); // Draw a triangle
    //rect(0,0,rx,ry); // Draw a rectangle
    popMatrix();
  }
  
  void last(int id) {
    // The idea is to draw a shape at the seed position
    // and a shape at the final position
    // and a line joining the two (the line should be drawn first)
    // Calculate size of shape:
    //float radius = width*0.012;
    float radiusMin = colWidth * cellSizeEpochGlobalMax;
    float radiusMax = radiusMin * 1.1;
    float radius = radiusMin;
    // Draw shape at 'end' position:
    //fill(0);
    //fill(fill_Hue, fill_Sat, fill_Bri); // Set the fill color
    fill(bkg_Hue, bkg_Sat, bkg_Bri); // Set the fill color
    //radius = width * 0.016;
    //radius = colWidth*0.3;
    radius = map(epochCosWave, -1, 1, radiusMin, radiusMax);
    pushMatrix();
    translate(position.x, position.y); // Go to the current position (which will be the last position in the epoch)
    rotate(angle - (PI*0.5)); // Rotate to the current angle
    ellipse(0,0,radius,radius); // Draw an ellipse
    //triangle(0, -ry, (rx*0.866), (ry*0.5) ,-(rx*0.866), (ry*0.5)); // Draw a triangle
    //rect(0,0,rx,ry); // Draw a rectangle
    popMatrix();
  }
  
  //Draw some Hattifnatt'ish eyes:
  void eyes() {
    color eyeWhite = color(fill_Hue,fill_Sat,fill_Bri*0.75);
    color eyePupil = color(fill_Hue,fill_Sat,fill_Bri*0.65);
    pushMatrix();
    translate(position.x, position.y); // Go to the current cell position
    rotate(angle - (PI*0.5)); // Rotate to the current cell angle
    fill(eyeWhite);
    strokeWeight(1);
    stroke(0);
    noStroke();
    float eyeWidth = rx * map(noise1, 0.2, 0.8, 0.45, 0.55);
    float eyeHeight = -ry * map(noise2, 0.2, 0.8, 0.45, 0.65);
    float eyeSize = rx * map(noise3, 0.2, 0.8, 0.25, 0.35);
    ellipse(eyeWidth, eyeHeight, eyeSize, eyeSize*1.25);
    ellipse(-eyeWidth, eyeHeight, eyeSize, eyeSize*1.25);
    fill(eyePupil);
    float pupilSize = eyeSize * map(noise2, 0.2, 0.8, 0.5, 0.7);
    float pupilHeight = eyeHeight * map(noise3, 0.2, 0.8, 1.25, 0.75);
    ellipse(eyeWidth, pupilHeight, pupilSize, pupilSize);
    ellipse(-eyeWidth, pupilHeight, pupilSize, pupilSize);
    popMatrix();
  }
  
  //Draw some Studio Ahoj ghost eyes:
  void eyes_Ahoj() {
    color eyeWhite = color(fill_Hue,fill_Sat,fill_Bri);
    color eyePupil = color(0,0,0);
    float cellAngle = angle - (PI*0.5);
    PVector lookHere = new PVector (width*0.5, height*0.5); // Eyes will point towards this position
    pushMatrix();
    translate(position.x, position.y); // Go to the current cell position
    rotate(cellAngle); // Rotate to the current cell angle
    // Draw outer ellipse
    fill(eyeWhite);
    strokeWeight(1);
    stroke(0);
    float eyeWidth = rx * 0.55;
    float eyeHeight = -ry * 0.6;
    float eyeSize = rx * 0.35;
    ellipse(eyeWidth, eyeHeight, eyeSize, eyeSize);
    ellipse(-eyeWidth, eyeHeight, eyeSize, eyeSize);
    // Draw inner ellipse (pupil)
    fill(eyePupil);
    float pupilSize = eyeSize * 0.4;
    float distFrom = dist(position.x, position.y, width*0.5, height*0.5);
    float lookingScalar = map(distFrom, 0, width*sqrt(2)*0.5, 0, eyeSize - pupilSize);
    PVector lookingAt = PVector.sub(lookHere, position).setMag(lookingScalar).rotate(-cellAngle);
    ellipse(eyeWidth + lookingAt.x, eyeHeight + lookingAt.y, pupilSize, pupilSize);
    ellipse(-eyeWidth + lookingAt.x, eyeHeight + lookingAt.y, pupilSize, pupilSize);
    popMatrix();
  }
  
  //Draw some Hattifnatt'ish eyes:
  void hands() {
    float fingerXPos = rx*0.9;
    float fingerL = rx * 0.75;
    float fingerW = fingerL * 0.25;
    float angleFactor = PI*0.09;
    if (debugMode) {debugFile.println("Drawing hands!");}
    pushMatrix();
    translate(position.x, position.y); // Go to the current cell position
    rotate(angle - (PI*0.5)); // Rotate to the current cell angle
    for (int fingers = 0; fingers <5; fingers ++) {
      float fingerAngle = map(fingers, 0, 4, -angleFactor, angleFactor);
      pushMatrix();
      rotate(fingerAngle);
      ellipseMode(CORNER);
      ellipse( fingerXPos, -fingerW*0.5,  fingerL, fingerW);
      ellipse(-fingerXPos, -fingerW*0.5, -fingerL, fingerW);
      ellipseMode(RADIUS);
      popMatrix();
    }
    popMatrix();
  }
  
  void blob() {
    // Testing out an idea to make a spiral blob
    fill(360);
    noStroke();
    float blobAngle = map(generation, 1, generations, 0, TWO_PI*5);
    float blobSize = w * 0.003;
    rotate(blobAngle);
    ellipse(0, rx, blobSize, blobSize); 
  }
  
  void radius() {
    // Testing out an idea to make a spiral blob
    //noFill();
    fill(128);
    stroke(0);
    ellipse(origin.x, origin.y, colWidth, rowHeight); 
  }
  
  void move() {
    // Put the code for updating position here
    position.add(velocity);
  }
  
   void updateStartPosition(int element) {
    // To update the start position used in the next epoch  
    positions.seedpos[element] = new PVector(position.x, position.y);
  }
  
  // Test for a collision
  // Receives a Cell object 'other' to get the required info about the collidee
  void checkCollision(Cell other) {
    PVector distVect = PVector.sub(other.position, position); // Static vector to get distance between the cell & other
    float distMag = distVect.mag();       // calculate magnitude of the vector separating the balls
    if (distMag < (rx + other.rx)) {
      // What should happen when two cells collide?
      println("Cell " + id + " just collided with cell " + other.id);
      hasCollided = true;
      other.hasCollided = true;
      conception(other);
    }
  }
  
  // Test for a collision version 2
  // Receives a Cell object 'other' to get the required info about the collidee
  // Will check through the positions of all previous generations of the collidee (during the current epoch)
  void checkCollision2(Cell other) {
    for (int i = other.positionHistory.size()-1; i >= 0; i--) {
      PVector otherPosition = other.positionHistory.get(i);  // Get each of the other cell's historical positions, one at a time
      float otherSize = other.sizeHistory.get(i);            // Get each of the other cell's corresponding historical sizes, one at a time
      PVector distVect = PVector.sub(otherPosition, position); // Static vector to get distance between the cell & other
      float distMag = distVect.mag();       // calculate magnitude of the vector separating the balls 
      //println("Cell ID:" + id + " x:" + position.x + " y:" + position.y + " other ID:" + other.id + " i:" + i + " otherPosition.x:" + otherPosition.x + " otherPosition.y:" + otherPosition.y + " distMag:" + distMag + " collisionDist:" + (rx + other.rx));
      //stroke(0);
      //fill(0,255,255); //red
      //ellipse(position.x, position.y, rx, rx);
      //line(position.x, position.y, otherPosition.x, otherPosition.y);
      //fill(0,0,255); //white
      //ellipse(otherPosition.x, otherPosition.y, other.rx, other.rx);
      if (distMag < (rx + otherSize)) {
        // Cells have collided!
        fill(360);
        ellipse(position.x, position.y, rx*0.66, rx*0.66);
        fill(0);
        ellipse(position.x, position.y, rx*0.25, rx*0.25);
        //ellipse(otherPosition.x, otherPosition.y, other.rx*0.5, other.rx*0.5);
        //println("<<<<Cell " + id + " just collided with cell " + other.id + " >>>>");
        hasCollided = true;
        //other.hasCollided = true; //NOTE: I don't want to stop the other just because I collided with his tail, do I?
        //if (fertile && other.fertile) {conception(other);}
      }
    }
  }
  
  void conception(Cell other) {

    // Calculate velocity vector for spawn as being centered between parent cell & other
    PVector spawnVel = velocity.copy(); // Create spawnVel as a copy of parent cell's velocity vector
    spawnVel.add(other.velocity);       // Add dad's velocity
    spawnVel.normalize();               // Normalize to leave just the direction and magnitude of 1 (will be multiplied later)
    
    PVector spawnPosOffset = velocity.copy().setMag(rx * 2);
    PVector spawnPos = position.copy().add(spawnPosOffset);
    
    // Set fertile = false to avoid further conceptions in the two cells which have just conceived
    fertile = false;
    other.fertile = false;
    
    println("Spawning a new cell with Mother id = " + id + " & Father id = " + other.id);
    // Only Mother id is passed on into new cell (initial solution, for simplicity)
    colony.spawn(id, brood, spawnPos, spawnVel);
  }
  
  // Death
  boolean dead() {
    if (rx <= 0 | ry <= 0) {return true;} // Death by zero size
    if (position.x>width+rx |position.x<-rx|position.y>height+rx |position.y<-rx) {return true;} // Death by fallen off canvas
    if (hasCollided) {return true;} // Death by collision
    else { return false; }
  }
  
  // Debug
  void debug() {
    debugFile.println("Cell X-size: " + rx + " colWidth: " + colWidth + " cellSizeGlobal:" +  cellSizeGlobal + " cellSize:" + cellSize);
    debugFile.println("Cell Y-size: " + ry + " rowHeight: " + rowHeight + " cellSizeGlobal:" +  cellSizeGlobal + " cellSize:" + cellSize);
  }
  
  //Test if a number is even:
  boolean isEven(int n){
    return n % 2 == 0;
  }
  
  //Test if a number is odd:
  boolean isOdd(int n){
    return n % 2 != 0;
  }
 
}
