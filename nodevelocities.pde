class Nodevelocities {
  /* The Nodevelocities class does the following:
  *  1) Creates a set of initial velocity PVectors for all the nodes in a network
  *  2) Stores the values as an array of PVectors independently of the network object so they can be reused in successive networks
  *  3) The PVectors are pulled out of the array sequentially as the network is populated in the constructor
  */

  // VARIABLES
  PVector[] nodeseedvel;  // 'vMax' is an array of floats used for storing the initial sizes of all the elements in colony.population
    
  // Constructor (makes a Sizes object)
  Nodevelocities() {
    nodeseedvel = new PVector[nodecount];  // Array size matches the size of the population
    randomVel(); // Default mode if no other alternative is selected
  }

  // Populates the seedpos array with random values
  void randomVel() {
    for(int element = 0; element<nodecount; element++) {
      PVector v = PVector.random2D();
      nodeseedvel[element] = v;
    }
    if (verboseMode) {println("Nodevelocities has created a nodeseedvel array");}
  }  
  
  // Populates the seedpos array with all velocities identical
  void fixedVel() {
    for(int element = 0; element<nodecount; element++) {
      float angle = radians(0);
      PVector v = PVector.fromAngle(angle);
      nodeseedvel[element] = v;
    }
  }
  
  void fromCenter() {
    for(int element = 0; element<nodecount; element++) {
      PVector center = new PVector(width*0.5, height*0.5);
      PVector pos = nodepositions.nodeseedpos[element]; // Get the position of the element for which we are to calculate a value
      PVector v = PVector.sub(pos, center).normalize();
      nodeseedvel[element] = v;
    }
  }
  
  void toCenter() {
    for(int element = 0; element<nodecount; element++) {
      PVector center = new PVector(width*0.5, height*0.5);
      PVector pos = nodepositions.nodeseedpos[element]; // Get the position of the element for which we are to calculate a value
      PVector v = PVector.sub(center, pos).normalize();
      nodeseedvel[element] = v;
    }
  }
  
  // Selects from one of the 'available directions' designated by the node's vertexes value
  void randomFromVertexes() {
    for(int element = 0; element<nodecount; element++) {
      int vertexes = nodevertexes.vertexes[element]; // Get the number of vertexes for the node
      float sectorAngle = TWO_PI/vertexes;
      float randomAngle = sectorAngle * int(random(vertexes));
      PVector v = PVector.fromAngle(0).rotate(randomAngle);
      nodeseedvel[element] = v;
    }
  }
  
  // Selects from one of the 'available directions' designated by the node's vertexes value
  void sequentialFromVertexes() {
    for(int element = 0; element<nodecount; element++) {
      int vertexes = nodevertexes.vertexes[element]; // Get the number of vertexes for the node
      float sectorAngle = TWO_PI/vertexes;
      int rotations = element%vertexes;
      float Angle = sectorAngle * rotations;
      println("ElementID: " + element + " Rotating the sectorAngle " + rotations + " times. Total angular rotation = " + degrees(Angle));
      PVector v = PVector.fromAngle(0).rotate(Angle);
      nodeseedvel[element] = v;
    }
  }

}
