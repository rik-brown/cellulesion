class MaxAges {
  /* The Offsets class does the following:
  *  1) Creates a set of initial maxAges for all the elements in a population
  *  2) Stores the maxAges as an array of floats independently of the colony object so they can be reused in successive colonies
  *  3) The floats are pulled out of the array sequentially as the Colony is populated in the constructor
  */

  // VARIABLES
  float[] seedMaxAge;  // 'maxage' is an array of floats used for storing the initial sizes of all the elements in colony.population
  float maxAgeMin, maxAgeMax;
  
  // Constructor (makes a Sizes object)
  MaxAges() {
    seedMaxAge = new float[elements];  // Array size matches the size of the population
    maxAgeMin = 0.0;
    maxAgeMax = 1.0;
    
    // To set equal values for all elements:
    for(int element = 0; element<elements; element++) {
      seedMaxAge[element] = maxAgeMin; // Quick hack to set equal values for all elements in the constructor
    }
    if (verboseMode) {println("MaxAges has created a seedMaxAge array");}
  }
  
  // Populates the maxAge array with random values
  void randomMaxAges() {
    for(int element = 0; element<elements; element++) {
      float maxAge = random(maxAgeMin, maxAgeMax);
      seedMaxAge[element] = maxAge;
    }
    if (verboseMode) {println("randomMaxAges");}
  }
  
  // Populates the maxAge array with random values
  void elementMaxAges() {
    for(int element = 0; element<elements; element++) {
      float maxAge = map(element, 0, elements-1, maxAgeMin, maxAgeMax);
      seedMaxAge[element] = maxAge;
    }
    if (verboseMode) {println("elementMaxAges");}
  }
  
  // Populates the maxAge array with values calculated by incrementing a Perlin noise seed value.
  void noiseMaxAges() {
    float seed = noiseSeed;
    for(int element = 0; element<elements; element++) {
      float noiseValue = noise(seed);
      seedMaxAge[element] = noiseValue;
      seed += 0.005; // Should perhaps be a function of the number of elements?
    }
    if (verboseMode) {println("noiseMaxAges");}
  }
  
  // Populates the maxAge array with values calculated by linking a Perlin noise seed value to distance from a position on the canvas (e.g. center).
  void noiseFromDistanceMaxAges() {
    for(int element = 0; element<elements; element++) {
      PVector pos = positions.seedpos[element]; // Get the position of the element for which we are to calculate a value
      float distFrom = dist(pos.x, pos.y, width*0.5, height*0.5); // Calculate this element's distance from the reference coordinate
      float seed = map(distFrom, 0, width*sqrt(2)*0.5, noiseSeed, noiseSeed + 1);
      float noiseValue = noise(seed);
      seedMaxAge[element] = noiseValue;
      seed += 0.01; // Should perhaps be a function of the number of elements?
    }
    if (verboseMode) {println("noiseFromDistanceMaxAges");}
  }
  
  // Populates the maxAge array with values calculated by mapping distance from Center to a predefined range
  void fromDistanceMaxAges() {
    for(int element = 0; element<elements; element++) {
      PVector pos = positions.seedpos[element]; // Get the position of the element for which we are to calculate a value
      float distFrom = dist(pos.x, pos.y, width*0.5, height*0.5); // Calculate this element's distance from the reference coordinate
      float maxAge = map(distFrom, 0, width*sqrt(2)*0.5, maxAgeMin, maxAgeMax);
      seedMaxAge[element] = maxAge;
    }
    if (verboseMode) {println("fromDistanceMaxAges");}
  }

  // Populates the maxAge array with values calculated by mapping distance from Center to a predefined range
  void fromDistanceMaxAgesREV() {
    for(int element = 0; element<elements; element++) {
      PVector pos = positions.seedpos[element]; // Get the position of the element for which we are to calculate a value
      float distFrom = dist(pos.x, pos.y, width*0.5, height*0.5); // Calculate this element's distance from the reference coordinate
      float maxAge = map(distFrom, 0, width*sqrt(2)*0.5, maxAgeMax, maxAgeMin);
      seedMaxAge[element] = maxAge;
    }
    if (verboseMode) {println("fromDistanceMaxAgesREV");}
  }
  
  // Populates the maxAge array with values calculated by mapping distance from Center to a predefined range
  void fromDistanceHalfMaxAges() {
    for(int element = 0; element<elements; element++) {
      PVector pos = positions.seedpos[element]; // Get the position of the element for which we are to calculate a value
      float distFrom = dist(pos.x, pos.y, width*0.5, height*0.5); // Calculate this element's distance from the reference coordinate
      float distScale = map(distFrom, 0, width*sqrt(2)*0.5, 1, 4);
      float maxAge = maxAgeMax * 1/distScale;
      seedMaxAge[element] = maxAge;
    }
    if (verboseMode) {println("fromDistanceHalfMaxAges");}
  }
  
  // Populates the maxAge array with values calculated by mapping distance from Center to a predefined range
  void fromDistanceMaxAgesPower() {
    for(int element = 0; element<elements; element++) {
      PVector pos = positions.seedpos[element]; // Get the position of the element for which we are to calculate a value
      float distFrom = dist(pos.x, pos.y, width*0.5, height*0.5); // Calculate this element's distance from the reference coordinate
      float distScale = map(distFrom, 0, width*sqrt(2)*0.5, 2, 0);
      float maxAge = maxAgeMax * 1/pow(1.75, distScale);
      seedMaxAge[element] = maxAge;
    }
    if (verboseMode) {println("fromDistanceMaxAgesPower");}
  }


}
