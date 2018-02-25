class Colours {
  /* The Colours class does the following:
  *  1) Creates a set of initial Colour values for all the elements in a population
  *  2) Stores the values as an array of floats independently of the colony object so they can be reused in successive colonies
  *  3) The floats are pulled out of the array sequentially as the Colony is populated in the constructor
  */

  // VARIABLES
  float[] hStart;  // 'hStart' is an array of floats used for storing the initial Hues of all the elements in colony.population
  float[] bStart;  // 'bStart' is an array of floats used for storing the initial Hues of all the elements in colony.population
  float[] sStart;  // 'sStart' is an array of floats used for storing the initial Hues of all the elements in colony.population
  
  float vMaxMin, vMaxMax;
  
  // Constructor (makes a Sizes object)
  Colours() {
    // Work in progress!
 
  }
  
  // Populates the vMax array with random values
  void randomvMax() {
    for(int element = 0; element<elements; element++) {
      float vMaxRandom = random(vMaxMin, vMaxMax);
      //println("Writing to vMax[" + element + "]  with value vMax=" + vMaxRandom);
      //vMax[element] = vMaxRandom;
    }
  }
  
  
  // Populates the seedsize array with values calculated using Perlin noise.
  void noisevMax() {
    float seed = noiseSeed;
    for(int element = 0; element<elements; element++) {
      float vMaxNoise = noise(seed);
      //println("Writing to vMax[" + element + "]  with value vMax=" + vMaxRandom + " calculated with noiseSeed= " + seed + " incremented by " + noise1Scale + " on each iteration" );
      //vMax[element] = vMaxNoise;
      seed += 0.005; // Should perhaps be a function of the number of elements?
    }
  }
  
  
}