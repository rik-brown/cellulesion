class Nodestates {
  /* The NodeStates class does the following:
  *  1) Creates a set of initial activation states for all the nodes in a network
  *  2) Stores the states as an array of Boolean variables independently of the network object so they can be reused in successive networks
  *  3) The Booleans are pulled out of the array sequentially as the network is populated in the constructor
  */
 
 // VARIABLES
  Boolean[] nodeseedstates;  // 'nodeseedstates' is an array of Booleans used for storing the initial activation state of all the nodes in network.nodes
  
  
 // CONSTRUCTOR: create a 'nodestates' object
  Nodestates() {
    nodeseedstates = new Boolean[nodecount];  // Array size matches the size of the population
    
    // To set equal state values for all nodes:
    for(int element = 0; element<nodecount; element++) {
      nodeseedstates[element] = true; // Default mode where all nodes are active at the start
    }
    if (verboseMode) {println("NodeStates has created a nodeseedstates array");}
  }
  
  // Populates the nodeseedstates array with random values
  void randomState() {
    for(int element = 0; element<nodecount; element++) {
      float randomValue =random(1); // Value between 0 and 1
      if (randomValue >= 0.5) {
        nodeseedstates[element] = true;
      }
      else {
        nodeseedstates[element] = false;
      }
    }
  }
  
}
