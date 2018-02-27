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
    
    hMin = 0;
    hMax = 0.33;
    sMin = 0.5;
    sMax = 1.0;
    bMin = 0.5;
    bMax = 1.0;
    
    // To set equal values for all elements:
    for(int element = 0; element<elements; element++) {
      sStart[element] = sMin; // Quick hack to set equal values for all elements in the constructor
      sEnd[element] = sMax;   // Quick hack to set equal values for all elements in the constructor
      bStart[element] = bMin; // Quick hack to set equal values for all elements in the constructor
      bEnd[element] = bMax;   // Quick hack to set equal values for all elements in the constructor
    }
 
  }
  
  // Populates an array with random values
  void randomHueStart() {
    for(int element = 0; element<elements; element++) {
      float RandomHue = random(hMin, hMax);
      //println("Writing to hStart[" + element + "]  with value vMax=" + vMaxRandom);
      hStart[element] = RandomHue;
      hEnd[element] = RandomHue;
    }
  }
  
  
  // Populates the seedsize array with values calculated using Perlin noise.
  void noiseBEnd() {
    float seed = noiseSeed;
    for(int element = 0; element<elements; element++) {
      float noiseValue = noise(seed);
      bEnd[element] = noiseValue;
      seed += 0.005; // Should perhaps be a function of the number of elements?
    }
  }
  
  
}