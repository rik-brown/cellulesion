class Colours {
  /* The Colours class does the following:
  *  1) Creates a set of initial & final Colour values for all the elements in a population
  *  2) Stores the values as an array of floats independently of the colony object so they can be reused in successive colonies
  *  3) The floats are pulled out of the array sequentially as the Colony is populated in the constructor
  */

  // VARIABLES
  float[] hStart;  // 'hStart' is an array of floats used for storing the initial Hue values of all the elements in colony.population
  float[] sStart;  // 'sStart' is an array of floats used for storing the initial Saturation values of all the elements in colony.population
  float[] bStart;  // 'bStart' is an array of floats used for storing the initial Brightness values of all the elements in colony.population
  float[] hEnd;  // 'hEnd' is an array of floats used for storing the final Hue values of all the elements in colony.population
  float[] sEnd;  // 'sEnd' is an array of floats used for storing the final Saturation values of all the elements in colony.population
  float[] bEnd;  // 'bEnd' is an array of floats used for storing the final Brightness values of all the elements in colony.population
  
  float hMin, hMax;
  float sMin, sMax;
  float bMin, bMax;
  
  int imgWidthLow = int(0.0 * img.width);
  int imgWidthHigh = int(1.0 * img.width)-1;
  int imgHeightLow = int(0.0 * img.height);
  int imgHeightHigh = int(1.0 * img.height)-1;
  
  // Constructor (makes a Sizes object)
  Colours() {
    hStart = new float[elements];  // Array size matches the size of the population
    sStart = new float[elements];  // Array size matches the size of the population
    bStart = new float[elements];  // Array size matches the size of the population
    
    hEnd = new float[elements];  // Array size matches the size of the population
    sEnd = new float[elements];  // Array size matches the size of the population
    bEnd = new float[elements];  // Array size matches the size of the population
    
    //hMin = map(bkg_Hue,0,360,0,1);
    hMin = 0.25;
    hMax = 0.75;
    ///sMin = map(bkg_Sat,0,255,0,1);
    sMin = 0.2;
    sMax = 0.4;
    //bMin = map(bkg_Bri,0,255,0,1);
    bMin = 0.6;
    bMax = 1.0;
    
    // To set equal values for all elements:
    for(int element = 0; element<elements; element++) {
      hStart[element] = hMin; // Quick hack to set equal values for all elements in the constructor
      hEnd[element] = hMax;   // Quick hack to set equal values for all elements in the constructor
      sStart[element] = sMin; // Quick hack to set equal values for all elements in the constructor
      sEnd[element] = sMax;   // Quick hack to set equal values for all elements in the constructor
      bStart[element] = bMin; // Quick hack to set equal values for all elements in the constructor
      bEnd[element] = bMax;   // Quick hack to set equal values for all elements in the constructor
    }
 
  }
  
  // Populates the array with random values
  void randomHue() {
    for(int element = 0; element<elements; element++) {
      float RandomHue = random(hMin, hMax);
      //println("Writing to hStart[" + element + "]  with value vMax=" + vMaxRandom);
      hStart[element] = RandomHue;
      hEnd[element] = RandomHue;
    }
  }
  
  // Populates the array with values calculated using Perlin noise.
  void noiseHue() {
    float seed = noiseSeed;
    for(int element = 0; element<elements; element++) {
      float noiseValue = noise(seed);
      hStart[element] = noiseValue;
      hEnd[element] = noiseValue;
      seed += 0.005; // Should perhaps be a function of the number of elements?
    }
  }
  
  void noise2D_Hue() {
    float xseed = noiseSeed;
    float yseed = noiseSeed;
    float scale = 0.008;
    for(int element = 0; element<elements; element++) {
      PVector pos = positions.seedpos[element]; // Get the position of the element for which we are to calculate a value
      float noiseValue = noise(scale*(pos.x + xseed), scale*(pos.y + yseed));
      float value = map(noiseValue, 0, 1, 0.6, 0.65);
      hStart[element] = value;
      hEnd[element] = value;
    }
  }
  
  // Populates the array with values calculated by mapping distance from Center to a predefined range
  void fromDistanceHue() {
    for(int element = 0; element<elements; element++) {
      PVector pos = positions.seedpos[element]; // Get the position of the element for which we are to calculate a value
      float distFrom = dist(pos.x, pos.y, width*0.5, height*0.5); // Calculate this element's distance from the reference coordinate
      float value = map(distFrom, 0, width*sqrt(2)*0.5, hMin, hMax);
      hStart[element] = value;
      hEnd[element] = value;
    }
  }
  
  // Populates the array with values calculated by mapping distance from Center to a predefined range
  void fromDistanceHueStart() {
    for(int element = 0; element<elements; element++) {
      PVector pos = positions.seedpos[element]; // Get the position of the element for which we are to calculate a value
      float distFrom = dist(pos.x, pos.y, width*0.5, height*0.5); // Calculate this element's distance from the reference coordinate
      float value = map(distFrom, 0, width*sqrt(2)*0.5, hMin, hMax);
      hStart[element] = value;
    }
  }
  
  // Populates the array with values calculated by mapping distance from Center to a predefined range
  void fromDistanceHueEnd() {
    for(int element = 0; element<elements; element++) {
      PVector pos = positions.seedpos[element]; // Get the position of the element for which we are to calculate a value
      float distFrom = dist(pos.x, pos.y, random(width), random(height)); // Calculate this element's distance from the reference coordinate
      float value = map(distFrom, 0, width*sqrt(2)*0.5, hMax, hMin);
      hEnd[element] = value;
    }
  }
  
  // Populates the array with values calculated by mapping distance from Center to a predefined range
  void fromPolarPosition() {
    for(int element = 0; element<elements; element++) {
      PVector pos = positions.seedpos[element]; // Get the position of the element for which we are to calculate a value
      PVector target = new PVector(width*0.5, height*0.5);
      PVector colourVector = PVector.sub(pos, target); // Static vector pointing from cell position AWAY FROM the target
      float heading = map(colourVector.heading(), -PI, PI, hMin, hMax);
      float magnitude = map(colourVector.mag(), 0, width, sMax, sMin);
      hStart[element] = heading;
      hEnd[element] = heading;
      sStart[element] = magnitude;
      sEnd[element] = magnitude;
    }
  }
  
  // Populates the array with values calculated by mapping distance from Center to a predefined range
  void fromPolarPosition2() {
    for(int element = 0; element<elements; element++) {
      PVector pos = positions.seedpos[element]; // Get the position of the element for which we are to calculate a value
      PVector target = new PVector(width*0.5, height*0.5);
      PVector colourVector = PVector.sub(pos, target); // Static vector pointing from cell position AWAY FROM the target
      float heading = map(colourVector.heading(), -PI, PI, sMax, sMax*0.7);
      float magnitude = map(colourVector.mag(), 0, width*sqrt(2)*0.5, hMin, hMax);
      float saturation = map(colourVector.mag(), 0, width*sqrt(2)*0.5, sMax, sMin);
      hStart[element] = magnitude;
      hEnd[element] = magnitude;
      sStart[element] = saturation;
      sEnd[element] = saturation;
    }
  }
  
  void fromGrid() {
    for(int row = 0; row<rows; row++) {
      for(int col = 0; col<columns; col++) {
        int element = (columns*row) + col;
        float xFactor = map (col, 0, columns, 0, 1); // xpos is in 'canvas space'
        float yFactor = map (row, 0, rows, 1, 0.1);   // ypos is in 'canvas space'
        //Hattifnatt rainbow wanderers goal:
        //Hue will increase across columns in range 0-1
        //Saturation will increase across rows in range 1-0
        hStart[element] = xFactor;
        hEnd[element] = xFactor;
        sStart[element] = yFactor;
        sEnd[element] = yFactor;
        //bStart[element] = bMin;
        //bEnd[element] = bMax;
      }
    }
  }
  
  void from2DSpace() {
    for(int element = 0; element<elements; element++) {
      PVector pos = positions.seedpos[element]; // Get the position of the element for which we are to calculate a value
      float xFactor = map (pos.x, 0, width, hMin, hMax); // xpos is in 'canvas space'
      float yFactor = map (pos.y, 0, height, sMin, sMax);   // ypos is in 'canvas space'
      hStart[element] = xFactor;
      hEnd[element] = xFactor;
      sStart[element] = yFactor;
      sEnd[element] = yFactor;
      //bStart[element] = bMin;
      //bEnd[element] = bMax;
    }
  }
  
  void noise2D_SStart() {
    float xseed = noiseSeed;
    float yseed = noiseSeed;
    float scale = 0.0008;
    for(int element = 0; element<elements; element++) {
      PVector pos = positions.seedpos[element]; // Get the position of the element for which we are to calculate a value
      float noiseValue = noise(scale*(pos.x + xseed), scale*(pos.y + yseed));
      float colourValue = map(noiseValue, 0.2, 0.8, 0.0, 0.05); 
      sStart[element] = colourValue;
    }
  }
  
  void noise2D_SEnd() {
    float xseed = noiseSeed;
    float yseed = noiseSeed;
    float scale = 0.0008;
    for(int element = 0; element<elements; element++) {
      PVector pos = positions.seedpos[element]; // Get the position of the element for which we are to calculate a value
      float noiseValue = noise(scale*(pos.x + xseed), scale*(pos.y + yseed));
      float colourValue = map(noiseValue, 0.2, 0.8, 0.08, 0.15); 
      sEnd[element] = colourValue;
    }
  }
  
  // Populates the array with values calculated using Perlin noise.
  void noiseBEnd() {
    float seed = noiseSeed;
    for(int element = 0; element<elements; element++) {
      float noiseValue = noise(seed);
      //bEnd[element] = noiseValue;
      bEnd[element] = map (noiseValue, 0, 1, 0.8, 1.0);
      seed += 0.005; // Should perhaps be a function of the number of elements?
    }
  }
  
  void noise2D_BStart() {
    float xseed = noiseSeed;
    float yseed = noiseSeed;
    float scale = 0.0012;
    for(int element = 0; element<elements; element++) {
      PVector pos = positions.seedpos[element]; // Get the position of the element for which we are to calculate a value
      float noiseValue = noise(scale*(pos.x + xseed), scale*(pos.y + yseed));
      float colourValue = map(noiseValue, 0.2, 0.8, 0.0, 0.05); 
      bStart[element] = colourValue;
    }
  }
  
  void noise2D_BEnd() {
    float xseed = noiseSeed;
    float yseed = noiseSeed;
    float scale = 0.0010;
    for(int element = 0; element<elements; element++) {
      PVector pos = positions.seedpos[element]; // Get the position of the element for which we are to calculate a value
      float noiseValue = noise(scale*(pos.x + xseed), scale*(pos.y + yseed));
      float colourValue = map(noiseValue, 0.2, 0.8, 0.85, 1.0); 
      bEnd[element] = colourValue;
    }
  }
  
  void from_image(){
    for(int element = 0; element<elements; element++) {
      PVector pos = positions.seedpos[element]; // Get the position of the element for which we are to calculate a value
      //println("Elements=" + elements+ "  Have position vector for element: " + element);
      color colorFromPixel = pixelColour(pos);
      float hue = hue(colorFromPixel)/360;
      float sat = saturation(colorFromPixel)/255;
      float bri = brightness(colorFromPixel)/255;
      hStart[element] = hue;
      hEnd[element] = hue;
      sStart[element] = sMin;
      sEnd[element] = sMax;
      //bStart[element] = bri;
      bStart[element] = bMin;
      bEnd[element] = bMax;
    }
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
}
