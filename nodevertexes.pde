class Nodevertexes {
  /* The Nodevertexes class does the following:
  *  1) Creates a set of initial vertex values for all the nodes in a network
  *  2) Stores the values as an array of integers independently of the network object so they can be reused in successive networks
  *  3) The integers are pulled out of the array sequentially as the network is populated in the constructor
  */

  // VARIABLES
  int[] vertexes;  // 'vertexes' is an array of integers used for storing the initial number of vertexes of all the nodes in network.nodes
  int vertexMin, vertexMax;
  
  // Constructor (makes a Sizes object)
  Nodevertexes() {
    vertexes = new int[nodecount];  // Array size matches the size of the population
    vertexMin = 1;
    vertexMax = 4;
    
    // To set equal values for all nodes:
    for(int element = 0; element<nodecount; element++) {
      vertexes[element] = vertexMin; // Quick hack to set equal values for all elements in the constructor
    }
  }
  
  // Populates the vertexes array with random values
  void randomvMax() {
    for(int element = 0; element<nodecount; element++) {
      float vMaxRandom = random(vertexMin, vertexMax);
      //println("Writing to vertexes[" + element + "]  with value vMax=" + vMaxRandom);
      vertexes[element] = vMaxRandom;
    }
  }
  
  // Populates the vMax array with random values
  void elementvMax() {
    for(int element = 0; element<nodecount; element++) {
      float vMaxValue = map(element, 0, nodecount-1, vertexMax, vertexMin);
      //println("Writing to vertexes[" + element + "]  with value vMax=" + vMaxValue);
      vertexes[element] = vMaxValue;
    }
  }
  
  
  // Populates the seedsize array with values calculated using Perlin noise.
  void noisevMax() {
    float seed = noiseSeed;
    for(int element = 0; element<nodecount; element++) {
      float noiseValue = noise(seed);
      //println("Writing to vertexes[" + element + "]  with value vMax=" + vMaxRandom + " calculated with noiseSeed= " + seed + " incremented by " + noise1Scale + " on each iteration" );
      vertexes[element] = noiseValue;
      seed += 0.005; // Should perhaps be a function of the number of nodecount?
    }
  }
  
  // Populates the seedsize array with values calculated by mapping distance from Center to a predefined range
  void fromDistancevMax() {
    for(int element = 0; element<nodecount; element++) {
      PVector pos = positions.seedpos[element]; // Get the position of the element for which we are to calculate a value
      float distFrom = dist(pos.x, pos.y, width*0.5, height*0.5); // Calculate this element's distance from the reference coordinate
      float vMaxDist = map(distFrom, 0, width*sqrt(2)*0.5, vertexMin, vertexMax);
      //println("Writing to vertexes[" + element + "]  with values vMax=" + vMaxDist );
      vertexes[element] = vMaxDist;
    }
  }
  
  // Populates the seedsize array with values calculated by mapping distance from Center to a predefined range
  void fromDistancevMaxREV() {
    for(int element = 0; element<nodecount; element++) {
      PVector pos = positions.seedpos[element]; // Get the position of the element for which we are to calculate a value
      float distFrom = dist(pos.x, pos.y, width*0.5, height*0.5); // Calculate this element's distance from the reference coordinate
      float vMaxDist = map(distFrom, 0, width*sqrt(2)*0.5, vertexMax, vertexMin);
      //println("Writing to vertexes[" + element + "]  with values vMax=" + vMaxDist );
      vertexes[element] = vMaxDist;
    }
  }
  
  // Populates the seedsize array with values calculated by mapping distance from Center to a predefined range
  void fromDistanceHalfvMax() {
    for(int element = 0; element<nodecount; element++) {
      PVector pos = positions.seedpos[element]; // Get the position of the element for which we are to calculate a value
      float distFrom = dist(pos.x, pos.y, width*0.5, height*0.5); // Calculate this element's distance from the reference coordinate
      float distScale = map(distFrom, 0, width*sqrt(2)*0.5, 1, 8);
      float value = vertexMax * 1/distScale;
      //println("Writing to vertexes[" + element + "]  with values vMax=" + vMaxDist );
      vertexes[element] = value;
    }
  }
  
  
}
