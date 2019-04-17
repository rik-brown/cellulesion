class Offsets {
  /* The Offsets class does the following:
  *  1) Creates a set of initial offsets for all the elements in a population
  *  2) Stores the offsets as an array of floats independently of the colony object so they can be reused in successive colonies
  *  3) The floats are pulled out of the array sequentially as the Colony is populated in the constructor
  */

  // VARIABLES
  float[] seedoffset;  // 'seedoffset' is an array of floats used for storing the initial sizes of all the elements in colony.population
  float offsetMin, offsetMax;
  
  // Constructor (makes a Sizes object)
  Offsets() {
    seedoffset = new float[elements];  // Array size matches the size of the population
    offsetMin = 0.0;
    offsetMax = 1.0;
    
    // To set equal values for all elements:
    for(int element = 0; element<elements; element++) {
      seedoffset[element] = offsetMin; // Quick hack to set equal values for all elements in the constructor
    }
    if (verboseMode) {println("Offsets has created a seedoffset array");}
  }
  
  // Populates the seedoffset array with random values
  void randomOffset() {
    for(int element = 0; element<elements; element++) {
      float offset = random(offsetMin, offsetMax);
      seedoffset[element] = offset;
    }
    if (verboseMode) {println("randomOffset");}
  }
  
  // Populates the seedoffset array with random values
  void elementOffset() {
    if (elements==1) {seedoffset[0] = offsetMin;}
    else {
      for(int element = 0; element<elements; element++) {
        float offset = map(element, 0, elements-1, offsetMin, offsetMax);
        seedoffset[element] = offset;
      }
    }
    if (verboseMode) {println("elementOffset");}
  }
  
  // Populates the seedoffset array with values calculated by incrementing a Perlin noise seed value.
  void noiseOffset() {
    float seed = noiseSeed;
    for(int element = 0; element<elements; element++) {
      float noiseValue = noise(seed);
      seedoffset[element] = noiseValue;
      seed += 0.005; // Should perhaps be a function of the number of elements?
    }
    if (verboseMode) {println("noiseOffset");}
  }
  
  // Populates the seedoffset array with values calculated by linking a Perlin noise seed value to distance from a position on the canvas (e.g. center).
  void noiseFromDistanceOffset() {
    for(int element = 0; element<elements; element++) {
      PVector pos = positions.seedpos[element]; // Get the position of the element for which we are to calculate a value
      float distFrom = dist(pos.x, pos.y, width*0.5, height*0.5); // Calculate this element's distance from the reference coordinate
      float seed = map(distFrom, 0, width*sqrt(2)*0.5, noiseSeed, noiseSeed + 1);
      float noiseValue = noise(seed);
      seedoffset[element] = noiseValue;
      seed += 0.01; // Should perhaps be a function of the number of elements?
    }
    if (verboseMode) {println("noiseFromDistanceOffset");}
  }
  
  // Populates the seedoffset array with values calculated by mapping distance from Center to a predefined range
  void fromDistanceOffset() {
    for(int element = 0; element<elements; element++) {
      PVector pos = positions.seedpos[element]; // Get the position of the element for which we are to calculate a value
      float distFrom = dist(pos.x, pos.y, width*0.5, height*0.5); // Calculate this element's distance from the reference coordinate
      float offset = map(distFrom, 0, width*sqrt(2)*0.5, offsetMin, offsetMax);
      seedoffset[element] = offset;
    }
    if (verboseMode) {println("fromDistanceOffset");}
  }
  
  // Populates the seedoffset array with values calculated by mapping distance from Center to a predefined range
  void fromDistanceHalfOffset() {
    for(int element = 0; element<elements; element++) {
      PVector pos = positions.seedpos[element]; // Get the position of the element for which we are to calculate a value
      float distFrom = dist(pos.x, pos.y, width*0.5, height*0.5); // Calculate this element's distance from the reference coordinate
      float distScale = map(distFrom, 0, width*sqrt(2)*0.5, 1, 4);
      float offset = offsetMax * 1/distScale;
      seedoffset[element] = offset;
    }
    if (verboseMode) {println("fromDistanceHalfOffset");}
  }
  
  // Populates the seedoffset array with values calculated by mapping distance from Center to a predefined range
  void fromDistanceOffsetPower() {
    for(int element = 0; element<elements; element++) {
      PVector pos = positions.seedpos[element]; // Get the position of the element for which we are to calculate a value
      float distFrom = dist(pos.x, pos.y, width*0.5, height*0.5); // Calculate this element's distance from the reference coordinate
      float distScale = map(distFrom, 0, width*sqrt(2)*0.5, 2, 0);
      float offset = offsetMax * 1/pow(1.75, distScale);
      seedoffset[element] = offset;
    }
    if (verboseMode) {println("fromDistanceOffsetPower");}
  }


}
