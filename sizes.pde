class Sizes {
  /* The Sizes class does the following:
  *  1) Creates a set of initial sizes for all the elements in a population
  *  2) Stores the sizes as an array of floats independently of the colony object so they can be reused in successive colonies
  *  3) The floats are pulled out of the array sequentially as the Colony is populated in the constructor
  */

  // VARIABLES
  float[] seedsize;  // 'seedsize' is an array of floats used for storing the initial sizes of all the elements in colony.population
  float sizeMin, sizeMax;
  
  // Constructor (makes a Sizes object)
  Sizes() {
    seedsize = new float[elements];  // Array size matches the size of the population
    sizeMin = 1.0;
    sizeMax = 2.5;
    
    // To set equal values for all elements:
    for(int element = 0; element<elements; element++) {
      seedsize[element] = sizeMin; // Quick hack to set equal values for all elements in the constructor
    }
  }
  
  // Populates the seedsize array with random values
  void randomSize() {
    for(int element = 0; element<elements; element++) {
      float size = random(sizeMin, sizeMax);
      //println("Writing to seedsize[" + element + "]  with values size=" + size);
      seedsize[element] = size;
    }
  }
  
  // Populates the seedsize array with values calculated by incrementing a Perlin noise seed value.
  void noiseSize() {
    float seed = noiseSeed;
    for(int element = 0; element<elements; element++) {
      float noiseValue = noise(seed);
      //println("Writing to seedsize[" + element + "]  with values size=" + noiseValue + " calculated with noiseSeed= " + seed + " incremented by " + noise1Scale + " on each iteration" );
      seedsize[element] = noiseValue;
      seed += 0.005; // Should perhaps be a function of the number of elements?
    }
  }
  
  // Populates the seedsize array with values calculated by linking a Perlin noise seed value to distance from a position on the canvas (e.g. center).
  void noiseFromDistanceSize() {
    for(int element = 0; element<elements; element++) {
      PVector pos = positions.seedpos[element]; // Get the position of the element for which we are to calculate a value
      float distFrom = dist(pos.x, pos.y, width*0.5, height*0.5); // Calculate this element's distance from the reference coordinate
      float seed = map(distFrom, 0, width*sqrt(2)*0.5, noiseSeed, noiseSeed + 1);
      float noiseValue = noise(seed);
      //println("Writing to seedsize[" + element + "]  with values size=" + noiseValue + " calculated with noiseSeed= " + seed + " incremented by " + noise1Scale + " on each iteration" );
      seedsize[element] = noiseValue;
      seed += 0.01; // Should perhaps be a function of the number of elements?
    }
  }
  
  // Populates the seedsize array with values calculated by mapping distance from Center to a predefined range
  void fromDistanceSize() {
    for(int element = 0; element<elements; element++) {
      PVector pos = positions.seedpos[element]; // Get the position of the element for which we are to calculate a value
      float distFrom = dist(pos.x, pos.y, width*0.5, height*0.5); // Calculate this element's distance from the reference coordinate
      float size = map(distFrom, 0, width*sqrt(2)*0.5, sizeMax, sizeMin);
      println("Writing to seedsize[" + element + "]  with values size=" + size );
      seedsize[element] = size;
    }
  }




}
