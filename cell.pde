class Cell {
  
  // MOVEMENT
  PVector position;     // position on the canvas
  PVector velocity;     // velocity
  float vMax;           // Half of maximum size of each x-y component in the velocity vector (velocity.x in the range -vMax/+vMax)
  //                    // Could consider making it a % of generations?
  float angle;          // Heading of the velocity vector
  float noiseRangeLow;  // When mapping noise to <something>, this is the lower value of the noise range (e.g. in range 0-0.3)
  float noiseRangeHigh; // When mapping noise to <something>, this is the upper value of the noise range (e.g. in range .7-1.0)
  
  // COLOR
  float fill_Hue, fill_Sat, fill_Bri, fill_Trans;          // Fill colour components
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
  float rx;             // Radius size x-component (absolute value used when drawing an element) 
  float ry;             // Radius size y-component (scaling value in range 0-1, 0-100%, multiplied by rx)
  //                       Alternative calculation: (absolute value used when drawing an element) 
  
  // **************************************************CONSTRUCTOR********************************************************
  // CONSTRUCTOR: create a 'cell' object
  Cell (PVector pos) {
    //Variables in the object:
    position = pos.copy();
    //velocity = vel.copy();
    vMax = 1.3;
    //vMax = generations * 0.0003;
    //vMax = w * 0.0001;
    noiseRangeLow = 0.2;
    noiseRangeHigh = 0.8;
    fill_H_start = 230;
    fill_H_end = 0;
    fill_S_start = 0;
    fill_S_end = 0;
    fill_B_start = 255;
    fill_B_end = 0;
    fill_T_start = 8;
    fill_T_end = 48;
  
  
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
    //updateStripes();
    updateVelocity();
    updateRotation();
    //display();
    //move();
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
    rx = map(noise2, noiseRangeLow, noiseRangeHigh, 0, colOffset*elementSize);
    ry = map(noise3, noiseRangeLow, noiseRangeHigh, 0, rowOffset*elementSize);      //ry is a value in same range as rx
    //ry = map(noise3, noiseRangeLow, noiseRangeHigh, 0.5, 1.0);                    //ry is a scaling factor of rx in range 50-100% REALLY? THIS IS A BIT SAFE!!!
  }
  
  void updateColors() {
    // Put the code for updating fill & stroke colors here
    //fill_Hue = map(generation, 1, generationsScaleMax*w, fill_H_start, fill_H_end);
    fill_Hue = map(generation, 1, generations, fill_H_start, fill_H_end);
    //fill_Sat = map(noise3, 0, 1, fill_S_start, fill_S_end);
    //fill_Sat = 0;
    //fill_Sat = map(generation, 1, generationsScaleMax*w, fill_S_start, fill_S_end);
    fill_Sat = map(generation, 1, generations, fill_S_start, fill_S_end);
    //fill_Bri = map(noise2, 0, 1, fill_B_start, fill_B_end);
    //fill_Bri = map(generation, 1, generationsScaleMax*w, fill_B_start, fill_B_end);
    //fill_Bri = map(generation, 1, generations, fill_B_start, fill_B_end);
    fill_Bri = map(generationCosWave, -1, 1, fill_B_start, fill_B_end);
    fill_Trans = map(generation, 1, generationsScaleMax*w, fill_T_start, fill_T_end);
    //bkg_Bri = map(generation, 0, generations, 255, 128);
    //bkg_Sat = map(generation, 0, generations, 160, 255);
    
    //fill(fill_Hue, fill_Sat, fill_Bri, fill_Trans); // Set the fill color
    //fill(fill_Hue, 0, fill_Bri); // Set the fill color B+W
    fill(fill_Hue, fill_Sat, fill_Bri); // Set the fill color
    //fill(fill_Bri);
    //if (noise1 >= 0.5) {fill(360);} else {fill(0);}
    //fill(360, 10);
    //noFill();
    
    //stroke(fill_Hue, fill_Sat, fill_Bri, fill_Trans); // Set the stroke color
    //stroke(240,255,255,fill_Trans);
    //strokeWeight(2);
    //stroke(360,10);
    noStroke();
  }
  
  void updateStripes() {
    // Put the code for updating stripes here
    //if (stripeCounter >= stripeWidth * stripeFactor) {fill(360);} else {fill(0);} // Monochrome
    //if (stripeCounter >= stripeWidth * stripeFactor) {fill(360);} else {fill(240, 255, 255);}
    //if (stripeCounter >= stripeWidth * stripeFactor) {fill(0,0,fill_Bri);} else {fill(0);}
    if (stripeCounter >= stripeWidth * stripeFactor) {fill(240,fill_Sat,fill_Bri);} else {fill(fill_Hue,255,255);}
    //if (stripeCounter >= stripeWidth * stripeFactor) {fill(240,fill_Sat,fill_Bri);} else {fill(bkg_Hue, bkg_Sat, bkg_Bri);}
  }

  
  void updateVelocity() {
    // Put the code for updating velocity here
    //velocity = new PVector(map(noise1, 0, 1, -vMax, vMax), map(noise2, 0, 1, -vMax, vMax));
    //velocity = new PVector(map(noise1, noiseRangeLow, noiseRangeHigh, -vMax, vMax), map(noise2, noiseRangeLow, noiseRangeHigh, -vMax, vMax));
    //velocity = PVector.fromAngle(map(noise1, noiseRangeLow, noiseRangeHigh, 0, TWO_PI)).mult(map(noise2, noiseRangeLow, noiseRangeHigh, 0, vMax));
    velocity = PVector.fromAngle(map(noise1, noiseRangeLow, noiseRangeHigh, 0, TWO_PI)).mult(map(noise2, noiseRangeLow, noiseRangeHigh, 0, vMaxGlobal));
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
    rotate(angle); // Rotate to the current angle
    
    // These shapes require that ry is a value in a similar range to rx
    ellipse(0,0,rx,ry); // Draw an ellipse
    //triangle(0, -ry, (rx*0.866), (ry*0.5) ,-(rx*0.866), (ry*0.5)); // Draw a triangle
    //rect(0,0,rx,ry); // Draw a rectangle
    
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
  
  void move() {
    // Put the code for updating position here
    position.add(velocity);
  }
  
  // Death
  boolean dead() {
    //if (rx <= 0 | ry <= 0) {return true;} // Death by zero size
    if (position.x>width+rx |position.x<-rx|position.y>height+rx |position.y<-rx) {return true;} // Death by fallen off canvas
    else { return false; }
  }
 
}