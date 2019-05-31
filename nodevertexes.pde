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
    vertexMin = 4;
    vertexMax = 8;
    
    // To set equal vertexes values for all nodes:
    for(int element = 0; element<nodecount; element++) {
      equalVertex(); // Default is all equal (apart from edges & corners)
    }
    if (verboseMode) {println("Nodevertexes has created a vertexes array");}
  }

  // Populates the vertexes array with fixed values
  void equalVertex() {
    for(int element = 0; element<nodecount; element++) {
      int value = vertexMax;
      int constrainedValue = value;
      //println("Writing to vertexes[" + element + "]  with value vertex=" + value);
      int nodePosType = nodepositions.nodeseedposType[element]; // Get the positionType for this element
      if (nodePosType==1) {constrainedValue=constrain(value,0,3);} // An edge can have max. 3 connections
      if (nodePosType==2) {constrainedValue=constrain(value,0,2);} // A corner can have max. 2 connections
      vertexes[element] = constrainedValue; // If neither edge or corner, the original unconstrained value is used.
    }
  }

  
  // Populates the vertexes array with random values
  void randomVertex() {
    for(int element = 0; element<nodecount; element++) {
      int value = ceil(random(vertexMin, vertexMax));
      int constrainedValue = value;
      //println("Writing to vertexes[" + element + "]  with value vertex=" + value);
      int nodePosType = nodepositions.nodeseedposType[element]; // Get the positionType for this element
      if (nodePosType==1) {constrainedValue=constrain(value,0,3);} // An edge can have max. 3 connections
      if (nodePosType==2) {constrainedValue=constrain(value,0,2);} // A corner can have max. 2 connections
      vertexes[element] = constrainedValue; // If neither edge or corner, the original unconstrained value is used.
    }
  }
  
  // Populates the vertexes array with random values
  void randomVertex2() {
    for(int element = 0; element<nodecount; element++) {
      int numValues = 2;
      int randomValue = int(random(numValues)); // Should give either 0 or 1
      int value = randomValue * (vertexMax - vertexMin) + vertexMin;
      //println("Writing to vertexes[" + element + "]  with value vertex=" + value);
      vertexes[element] = value;
    }
  }
  
  // Populates the vertexes array with random values
  void elementVertex() {
    for(int element = 0; element<nodecount; element++) {
      int value = int(map(element, 0, nodecount-1, vertexMax, vertexMin));
      //println("Writing to vertexes[" + element + "]  with value vertexes=" + value);
      vertexes[element] = value;
    }
  }
  
  
  // Populates the vertexes array with values calculated using Perlin noise.
  void noiseVertex() {
    float seed = noiseSeed;
    for(int element = 0; element<nodecount; element++) {
      int value = int(noise(seed)*vertexMax);
      vertexes[element] = value;
      seed += 0.005; // Should perhaps be a function of the number of nodecount?
    }
  }
  
  // Populates the vertexes array with values calculated by mapping distance from Center to a predefined range
  void fromDistanceVertex() {
    for(int element = 0; element<nodecount; element++) {
      PVector pos = nodepositions.nodeseedpos[element]; // Get the position of the element for which we are to calculate a value
      float distFrom = dist(pos.x, pos.y, width*0.5, height*0.5); // Calculate this element's distance from the reference coordinate
      int value = int(map(distFrom, 0, width*sqrt(2)*0.5, vertexMin, vertexMax));
      //println("Writing to vertexes[" + element + "]  with value=" + value );
      vertexes[element] = value;
    }
  }
  
  // Populates the vertexes array with values calculated by mapping distance from Center to a predefined range
  void fromDistanceVertexREV() {
    for(int element = 0; element<nodecount; element++) {
      PVector pos = positions.seedpos[element]; // Get the position of the element for which we are to calculate a value
      float distFrom = dist(pos.x, pos.y, width*0.5, height*0.5); // Calculate this element's distance from the reference coordinate
      int value = int(map(distFrom, 0, width*sqrt(2)*0.5, vertexMax, vertexMin));
      //println("Writing to vertexes[" + element + "]  with value =" + value );
      vertexes[element] = value;
    }
  }
  
  // Populates the vertexes array with values calculated by mapping distance from Center to a predefined range
  void fromDistanceHalfVertex() {
    for(int element = 0; element<nodecount; element++) {
      PVector pos = positions.seedpos[element]; // Get the position of the element for which we are to calculate a value
      float distFrom = dist(pos.x, pos.y, width*0.5, height*0.5); // Calculate this element's distance from the reference coordinate
      float distScale = map(distFrom, 0, width*sqrt(2)*0.5, 1, 8);
      int value = int(vertexMax * 1/distScale);
      //println("Writing to vertexes[" + element + "]  with value =" + value );
      vertexes[element] = value;
    }
  }
  
  
}
