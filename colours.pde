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
  
  // Constructor (makes a Sizes object)
  Colours() {
    hStart = new float[elements];  // Array size matches the size of the population
    sStart = new float[elements];  // Array size matches the size of the population
    bStart = new float[elements];  // Array size matches the size of the population
    
    hEnd = new float[elements];  // Array size matches the size of the population
    sEnd = new float[elements];  // Array size matches the size of the population
    bEnd = new float[elements];  // Array size matches the size of the population
    
    hMin = random (0.45, 0.55);
    hMax = random(0.45, 0.55);
    sMin = 0.0;
    sMax = 0.1;
    bMin = 0.2;
    bMax = 1.0;
    
    // To set equal values for all elements:
    for(int element = 0; element<elements; element++) {
      sStart[element] = sMin; // Quick hack to set equal values for all elements in the constructor
      sEnd[element] = sMax;   // Quick hack to set equal values for all elements in the constructor
      //bStart[element] = bMin; // Quick hack to set equal values for all elements in the constructor
      //bEnd[element] = bMax;   // Quick hack to set equal values for all elements in the constructor
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
    float scale = 0.0008;
    for(int element = 0; element<elements; element++) {
      PVector pos = positions.seedpos[element]; // Get the position of the element for which we are to calculate a value
      float noiseValue = noise(scale*(pos.x + xseed), scale*(pos.y + yseed));
      hStart[element] = noiseValue;
      hEnd[element] = noiseValue;
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
  
  // Populates the seedsize array with values calculated using Perlin noise.
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
    float scale = 0.0008;
    for(int element = 0; element<elements; element++) {
      PVector pos = positions.seedpos[element]; // Get the position of the element for which we are to calculate a value
      float noiseValue = noise(scale*(pos.x + xseed), scale*(pos.y + yseed));
      float colourValue = map(noiseValue, 0, 1, 0.5, 0.7); 
      bStart[element] = colourValue;
    }
  }
  
  void noise2D_BEnd() {
    float xseed = noiseSeed;
    float yseed = noiseSeed;
    float scale = 0.0008;
    for(int element = 0; element<elements; element++) {
      PVector pos = positions.seedpos[element]; // Get the position of the element for which we are to calculate a value
      float noiseValue = noise(scale*(pos.x + xseed), scale*(pos.y + yseed));
      float colourValue = map(noiseValue, 0, 1, 0.8, 1.0); 
      bEnd[element] = colourValue;
    }
  }
  
  
}