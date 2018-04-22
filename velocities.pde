class Velocities {
  /* The Velocities class does the following:
  *  1) Creates a set of initial Vmax values for all the elements in a population
  *  2) Stores the values as an array of floats independently of the colony object so they can be reused in successive colonies
  *  3) The floats are pulled out of the array sequentially as the Colony is populated in the constructor
  */

  // VARIABLES
  float[] vMax;  // 'vMax' is an array of floats used for storing the initial sizes of all the elements in colony.population
  float vMaxMin, vMaxMax;
  
  // Constructor (makes a Sizes object)
  Velocities() {
    vMax = new float[elements];  // Array size matches the size of the population
    vMaxMin = 0.66;
    vMaxMax = 1.33;
    
    // To set equal values for all elements:
    for(int element = 0; element<elements; element++) {
      vMax[element] = vMaxMin; // Quick hack to set equal values for all elements in the constructor
    }
  }
  
  // Populates the vMax array with random values
  void randomvMax() {
    for(int element = 0; element<elements; element++) {
      float vMaxRandom = random(vMaxMin, vMaxMax);
      //println("Writing to vMax[" + element + "]  with value vMax=" + vMaxRandom);
      vMax[element] = vMaxRandom;
    }
  }
  
  
  // Populates the seedsize array with values calculated using Perlin noise.
  void noisevMax() {
    float seed = noiseSeed;
    for(int element = 0; element<elements; element++) {
      float noiseValue = noise(seed);
      //println("Writing to vMax[" + element + "]  with value vMax=" + vMaxRandom + " calculated with noiseSeed= " + seed + " incremented by " + noise1Scale + " on each iteration" );
      vMax[element] = noiseValue;
      seed += 0.005; // Should perhaps be a function of the number of elements?
    }
  }
  
  // Populates the seedsize array with values calculated by mapping distance from Center to a predefined range
  void fromDistancevMax() {
    for(int element = 0; element<elements; element++) {
      PVector pos = positions.seedpos[element]; // Get the position of the element for which we are to calculate a value
      float distFrom = dist(pos.x, pos.y, width*0.5, height*0.5); // Calculate this element's distance from the reference coordinate
      float vMaxDist = map(distFrom, 0, width*sqrt(2)*0.5, vMaxMin, vMaxMax);
      //println("Writing to vMax[" + element + "]  with values vMax=" + vMaxDist );
      vMax[element] = vMaxDist;
    }
  }
  
  // Populates the seedsize array with values calculated by mapping distance from Center to a predefined range
  void fromDistanceHalfvMax() {
    for(int element = 0; element<elements; element++) {
      PVector pos = positions.seedpos[element]; // Get the position of the element for which we are to calculate a value
      float distFrom = dist(pos.x, pos.y, width*0.5, height*0.5); // Calculate this element's distance from the reference coordinate
      float distScale = map(distFrom, 0, width*sqrt(2)*0.5, 1, 8);
      float value = vMaxMax * 1/distScale;
      //println("Writing to vMax[" + element + "]  with values vMax=" + vMaxDist );
      vMax[element] = value;
    }
  }
  
  
}
