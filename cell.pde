class Cell {
  
  // MOVEMENT
  PVector position; // cell's current position
  PVector velocity;
  
  // COLOR
  float fill_Hue, fill_Sat, fill_Bri, fill_Trans;
  float stroke_Hue, stroke_Sat, stroke_Bri, stroke_Trans;
  
  







  // **************************************************CONSTRUCTOR********************************************************
  // CONSTRUCTOR: create a 'cell' object
  Cell (PVector pos, PVector vel) {
    
    //Variables in the object:
    

    
    
    
    
    void run() {
      //What happens when we run the cell?
      //Call the functions which will be executed for each cell for each drawcycle:
      updateNoise();
      updateVelocity();
      updatePosition();
      updateSize();
      updateColors();
      display();
    }
    
    void updateNoise() {
      // Put the code for updating noise here
    }
    
    void updateVelocity() {
      // Put the code for updating velocity here  
    }
    
    void updatePosition() {
      // Put the code for updating position here
      position.add(velocity);
    }
    
    void updateSize() {
      // Put the code for updating position here
    }
    
    void updateColors() {
      // Put the code for updating fill & stroke colors here
      float fill_Hue = map(generation, 1, generations, 240, 240);
      //float fill_Sat = map(noise3, 0, 1, 128,255);
      //float fill_Sat = 0;
      float fill_Sat = map(generation, 1, generations, 255, 128);
      //float fill_Bri = map(noise2, 0, 1, 128,255);
      float fill_Bri = map(generation, 1, generations, 0, 255);
      //bkg_Bri = map(generation, 0, generations, 255, 128);
      //bkg_Sat = map(generation, 0, generations, 160, 255);
      float fill_Trans = map(generation, 1, generations, 8, 48);
      
      //fill(fill_Hue, fill_Sat, fill_Bri, fill_Trans); // Set the fill color
      //fill(fill_Hue, 0, fill_Bri); // Set the fill color B+W
      //fill(fill_Hue, fill_Sat, fill_Bri); // Set the fill color
      //fill(fill_Bri);
      //if (noise1 >= 0.5) {fill(360);} else {fill(0);}
      //noFill();
      
      //stroke(fill_Hue, fill_Sat, fill_Bri, fill_Trans); // Set the stroke color
      //stroke(360,fill_Trans);
      //stroke(255,32);
    }
    
    void updateStripes() {
      // Put the code for updating stripes here
      //if (stripeCounter >= stripeWidth * stripeFactor) {fill(360);} else {fill(0);} // Monochrome
      //if (stripeCounter >= stripeWidth * stripeFactor) {fill(360);} else {fill(240, 255, 255);}
      if (stripeCounter >= stripeWidth * stripeFactor) {fill(0,0,fill_Bri);} else {fill(0);}
      //if (stripeCounter >= stripeWidth * stripeFactor) {fill(240,fill_Sat,fill_Bri);} else {fill(fill_Hue,255,255);}
      //if (stripeCounter >= stripeWidth * stripeFactor) {fill(240,fill_Sat,fill_Bri);} else {fill(bkg_Hue, bkg_Sat, bkg_Bri);}
    }
    
    void display() {
      // Put the code for displaying the cell here
      //draw the thing
      pushMatrix();
      translate(position.x, position.y); // Go to the grid location
      rotate(map(noise1,0,1,0,TWO_PI)); // Rotate to the current angle
      
      // These shapes require that ry is a value in a similar range to rx
      //ellipse(0,0,rx,ry); // Draw an ellipse
      //triangle(0, -ry, (rx*0.866), (ry*0.5) ,-(rx*0.866), (ry*0.5)); // Draw a triangle
      //rect(0,0,rx,ry); // Draw a rectangle
      
      // These shapes requires that ry is a scaling factor (e.g. in range 0.5 - 1.0)
      ellipse(0,0,rx,rx*ry); // Draw an ellipse
      //triangle(0, -rx*ry, (rx*0.866), (rx*ry*0.5) ,-(rx*0.866), (rx*ry*0.5)); // Draw a triangle
      //rect(0,0,rx,rx*ry); // Draw a rectangle  
      //if (debugMode) {debugFile.println("Drawing a thing at x:" + gridx + " y:" + gridy + " with rx=" + rx + " ry=" + ry + " & noise1=" + noise1 + " noise2=" + noise2 + " noise3=" + noise3);}
      //println("Drawing a thing at x:" + gridx + " y:" + gridy + " with rx=" + rx + " ry=" + ry + " & noise1=" + noise1 + " noise2=" + noise2 + " noise3=" + noise3);
      
      popMatrix();
    }
    
    // Death
    boolean dead() {
      //if (condition) {return true;} // Death by old age (regardless of size, which may remain constant)
      //else { return false; }
    }
    
  }
  
  
  
}