class Cell {
  
  // MOVEMENT
  PVector position;     // position on the canvas
  PVector velocity;     // velocity
  float vMax;           // Half of maximum size of each x-y component in the velocity vector (velocity.x in the range -vMax/+vMax)
                        // Alternatively: the scalar length of the velocity vector
  float angleOffset;
  float angle;          // Heading of the velocity vector
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
  Cell (PVector pos, float cellSize_, float vMax_, float hs, float he, float ss, float se, float bs, float be) {
    //Variables in the object:
    position = pos.copy();
    //velocity = vel.copy();
    cellSize = cellSize_;
    vMax = vMax_;
    //vMax = generations * 0.0003;
    //vMax = w * 0.0001;
    noiseRangeLow = 0.2;
    noiseRangeHigh = 0.8;
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
    updateNoise();
    updateSize();
    updateColors();
    //updateFillColorByPosition();
    //updateFill_HueByPosition();
    //updateFill_SatByPosition();
    //updateFill_BriByPosition();
    //updateFill_HueByEpoch();
    //updateFill_HueByEpochAngle();
    //updateStripes();
    //updateVelocityByNoise();
    //updateVelocityLinear();
    //updateVelocityLinearHueSway();
    //updateVelocityAwayFromFocalPoint();
    //updateVelocityAwayFromFocalPoint2();
    //updateVelocityAwayFromFocalPointWiggly();
    //if (generation == 1) {initialVelocityFromColour();}
    //if (generation == 1) {initialVelocityFromNoise();}
    //updateVelocityByColour();
    //updateVelocityByLerpColour();
    updateVelocityByCycle();
    //rotateVelocityByHue();
    updateRotation();
    //display();
    //move();
    updateOldFillColor();
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
    //rx = map(noise2, noiseRangeLow, noiseRangeHigh, 0, colOffset* cellSizeGlobal);
    rx = map(1, 0, 1, 0, colOffset * cellSizeGlobal * cellSize);   // rx is controlled by GLOBAL changes, not local to the cell
    //ry = map(noise3, noiseRangeLow, noiseRangeHigh, 0, rowOffset* cellSizeGlobal);      //ry is a value in same range as rx
    ry = map(1, 0, 1, 0, rowOffset * cellSizeGlobal * cellSize);   // ry is controlled by GLOBAL changes, not local to the cell
    //ry = map(noise3, noiseRangeLow, noiseRangeHigh, 0.5, 1.0);                    //ry is a scaling factor of rx in range 50-100% REALLY? THIS IS A BIT SAFE!!!
  }
  
  void updateColors() {
    // Put the code for updating fill & stroke colors here
    //fill_Hue = map(generation, 1, generationsScaleMax*w, fill_H_start, fill_H_end);
    fill_Hue = map(generation, 1, generations, fill_H_start, fill_H_end);
    //fill_Sat = map(noise3, 0, 1, fill_S_start, fill_S_end);
    //fill_Sat = 0;
    //fill_Sat = map(generation, 1, generations, fill_S_start, fill_S_end);
    fill_Sat = map(generation, 1, generations, fill_S_start, fill_S_end);
    //fill_Bri = map(noise2, 0, 1, fill_B_start, fill_B_end);
    //fill_Bri = map(generation, 1, generations, fill_B_start, fill_B_end);
    //fill_Bri = map(generation, 1, generations, fill_B_start, fill_B_end);
    fill_Bri = map(generationCosWave, -1, 0, fill_B_start, fill_B_end);
    fill_Trans = map(generation, 1, generations, fill_T_start, fill_T_end);
    //bkg_Bri = map(generation, 0, generations, 255, 128);
    //bkg_Sat = map(generation, 0, generations, 160, 255);
    
    fill(fill_Hue, fill_Sat, fill_Bri, fill_Trans); // Set the fill color
    //fill(fill_Hue, 0, fill_Bri); // Set the fill color B+W
    //fill(fill_Hue, fill_Sat, fill_Bri); // Set the fill color
    //fill(fill_Bri);
    //if (noise1 >= 0.5) {fill(360);} else {fill(0);}
    //fill(240,10,fill_Bri*3);
    //noFill();
    strokeWeight(map(generationCosWave, -1, 0, 2, 0.5));
    //stroke(fill_Hue, fill_Sat, 0, fill_Trans); // Set the stroke color
    //stroke(240,255,255,fill_Trans);
    //strokeWeight(2);
    //stroke(360,255);
    noStroke();
  }
  
  void updateFillColorByPosition() {
    color pixelColor = colours.pixelColour(position);
    fill_Hue = hue(pixelColor);
    fill_Sat = saturation(pixelColor);
    fill_Bri = brightness(pixelColor);
    fill(fill_Hue, fill_Sat, fill_Bri); // Set the fill color
    noStroke();
  }
  
  void updateFill_HueByPosition() {
    color pixelColor = colours.pixelColour(position);
    fill_Hue = hue(pixelColor);
    fill(fill_Hue, fill_Sat, fill_Bri); // Set the fill color
    noStroke();
  }
  
  void updateFill_SatByPosition() {
    color pixelColor = colours.pixelColour(position);
    fill_Sat = saturation(pixelColor);
    fill(fill_Hue, fill_Sat, fill_Bri); // Set the fill color
    noStroke();
  }
  
  void updateFill_BriByPosition() {
    color pixelColor = colours.pixelColour(position);
    fill_Bri = brightness(pixelColor);
    fill(fill_Hue, fill_Sat, fill_Bri); // Set the fill color
    noStroke();
  }
  
  void updateFill_HueByEpoch() {
    fill_Hue = map(epoch, 1, epochs, fill_H_start, fill_H_end); // NB! Will not work when epochs=1
    fill(fill_Hue, fill_Sat, fill_Bri); // Set the fill color
  }
  
  void updateFill_HueByEpochAngle() {
    fill_Hue = map(epochCosWave, -1, 1, fill_H_start, fill_H_end);
    fill(fill_Hue, fill_Sat, fill_Bri); // Set the fill color
  }
  
  void updateOldFillColor() {
    //Need to set the initial value for fill_Hue_Old on first run (to have a value to use in first lerp)
    fill_Old = color(fill_Hue, fill_Sat, fill_Bri);
  }
  
  void updateStripes() {
    // Put the code for updating stripes here
    //if (stripeCounter >= stripeWidth * stripeFactor) {fill(360);} else {fill(0);} // Monochrome
    //if (stripeCounter >= stripeWidth * stripeFactor) {fill(360);} else {fill(240, 255, 255);}
    //if (stripeCounter >= stripeWidth * stripeFactor) {fill(0,0,fill_Bri);} else {fill(0);}
    //if (stripeCounter >= stripeWidth * stripeFactor) {fill(240,fill_Sat,fill_Bri);} else {fill(fill_Hue,255,255);}
    //if (stripeCounter >= stripeWidth * stripeFactor) {fill(240,fill_Sat,fill_Bri);} else {fill(bkg_Hue, bkg_Sat, bkg_Bri);}
    //if (stripeCounter >= stripeWidth * stripeFactor) {fill(fill_Hue, fill_Sat, fill_Bri);} else {fill(bkg_Hue, bkg_Sat, bkg_Bri);}
    if (stripeCounter >= stripeWidth * stripeFactor) {fill(fill_Hue, fill_Sat, fill_Bri);} else {fill(colours.pixelColour(position));}
  }
  
  void initialVelocityFromNoise() {
    // When updateVelocity is replaced by rotateVelocity (and vector is not renewed on each cycle, just rotated & rescaled) it must be INITIATED on first run
    velocity = PVector.fromAngle(map(noise1, noiseRangeLow, noiseRangeHigh, 0, TWO_PI)).mult(map(noise2, noiseRangeLow, noiseRangeHigh, 0, vMaxGlobal * vMax));
    //velocity.rotate(epochAngle);
  }
  
  void updateVelocityByCycle() {
    // Goal here is that Vmax will vary according to an epoch cycle to vary the 'range' of the cell sinusoidally
    // Where each cell will have it's own personal phase angle offset (e.g. from local noise value)
    if (generation ==1) {angleOffset = map(noise1, 0.25, 0.75, 0, TWO_PI);}
    //if (generation ==1) {angleOffset = map(position.x, 0, width, 0, TWO_PI);}
    float vScalar = map(sin(epochAngle + angleOffset),-1,1,-1,1);
    velocity = PVector.fromAngle(PI*1.5).mult(vMaxGlobal * vMax * vScalar);   
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
    velocity.rotate(epochAngle);
  }
  
  void updateVelocityLinear() {
    velocity = PVector.fromAngle(PI*1.5).mult(vMaxGlobal * vMax);
    velocity.rotate(epochAngle);
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
    float scalar = map(brightness(colours.pixelColour(position)), 0, 255, 1, vMaxGlobal * vMax);
    //println("Scalar value = " + scalar);
    velocity = PVector.fromAngle(map(fill_Hue, 0, 360, 0, TWO_PI)).mult(scalar);
    velocity.rotate(epochAngle);
  }
  
  void updateVelocityByLerpColour() {
    //New heading is given by the 'colourAngle' of the hue value gained by lerping between old & new colours
    if (generation == 1) {fill_Old = color(fill_Hue, fill_Sat, fill_Bri);}
    color fill_Now = color(fill_Hue, fill_Sat, fill_Bri);
    color lerpCol = lerpColor(fill_Old, fill_Now, 0.1);
    //float delta = (cellSizeGlobalMax - cellSizeGlobalMin)/generations; // Incremental size scaling factor (not actual value)
    //float scalar = (rx*2) - (colOffset * cellSize * delta);
    float scalar = rx*1.5;
    velocity = PVector.fromAngle(map(hue(lerpCol), 0, 360, 0, TWO_PI)).mult(scalar); //Unit vector, needs scaling
     println("Old hue: " + hue(fill_Old) + " Current hue: " + hue(fill_Now) + " Lerp hue: " + hue(lerpCol) + " Heading: " + degrees(velocity.heading()) );
    velocity.rotate(epochAngle);
    fill_Old = lerpCol;
  }
  
  void initialVelocityFromColour() {
    // When updateVelocity is replaced by rotateVelocity (and vector is not renewed on each cycle, just rotated & rescaled) it must be INITIATED on first run
    float scalar = map(brightness(colours.pixelColour(position)), 0, 255, 1, vMaxGlobal * vMax);
    velocity = PVector.fromAngle(map(fill_Hue, 0, 360, 0, TWO_PI)).mult(scalar); // Minimum velocity must be 1.0 to avoid deadlock
    //println("Scalar value = " + scalar + " Vel.x = " + velocity.x + " Vel.y = " + velocity.y);
    //velocity.rotate(epochAngle);
  }
  
  void rotateVelocityByHue() {
    float scalar = map(brightness(colours.pixelColour(position)), 0, 255, 1, vMaxGlobal * vMax);
    velocity.rotate(map(fill_Hue, 0, 360, radians(-1), radians(1)));
    //println("Scalar value = " + scalar + " Vel.x = " + velocity.x + " Vel.y = " + velocity.y);
    //velocity.rotate(epochAngle);
  }
  
  void updateRotation() {
    // Put the code for updating angle of rotation here
    //angle = map(noise1,0,1,0,TWO_PI);
    angle = velocity.heading();
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
    
    //float size = colOffset*ellipseSize;
    ////stroke(0,128);
    //fill(map(noise1, 0.3, 0.7, 0, 360), 255, 255, 255);
    //ellipse(0,0,size, size);
    //fill(map(noise2, 0.3, 0.7, 0, 360), 255, 255, 255);
    //ellipse(0,0,size*0.66, size*0.66);
    //fill(map(noise3, 0.3, 0.7, 0, 360), 255, 255, 255);
    //ellipse(0,0,size*0.33, size*0.33);
    
    popMatrix();
  }
  
  void first(int id) {
    // The idea is to draw a shape at the seed position
    // and a shape at the final position
    // and a line joining the two (the line should be drawn first)
    // Calculate size of shape:
    //float radius = width*0.012;
    float radiusMin = colOffset * cellSizeGlobalMax;
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
    float radiusMin = colOffset * cellSizeGlobalMax;
    float radiusMax = radiusMin * 1.1;
    float radius = radiusMin;
    // Draw shape at 'end' position:
    //fill(0);
    //fill(fill_Hue, fill_Sat, fill_Bri); // Set the fill color
    fill(bkg_Hue, bkg_Sat, bkg_Bri); // Set the fill color
    //radius = width * 0.016;
    //radius = colOffset*0.3;
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
  
  void move() {
    // Put the code for updating position here
    position.add(velocity);
  }
  
   void updateStartPosition(int element) {
    // To update the start position used in the next epoch  
    positions.seedpos[element] = new PVector(position.x, position.y);
  }
  
  // Death
  boolean dead() {
    //if (rx <= 0 | ry <= 0) {return true;} // Death by zero size
    if (position.x>width+rx |position.x<-rx|position.y>height+rx |position.y<-rx) {return true;} // Death by fallen off canvas
    else { return false; }
  }
  
  // Debug
  void debug() {
    debugFile.println("Cell X-size: " + rx + " colOffset: " + colOffset + " cellSizeGlobal:" +  cellSizeGlobal + " cellSize:" + cellSize);
    debugFile.println("Cell Y-size: " + ry + " rowOffset: " + rowOffset + " cellSizeGlobal:" +  cellSizeGlobal + " cellSize:" + cellSize);
  }
 
}
