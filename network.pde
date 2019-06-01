class Network {
  /* The Network class does the following:
  *  1) Creates a network by spawning a given number of nodes in a predetermined spawn-pattern
  *  2) Runs the network
  */
  
  // VARIABLES
  ArrayList<Node> nodepopulation;    // An arraylist for all the cells
  IntList nodeList;         // A list of integers used to pick node content when populating the network (to permit shuffling the order)
  PVector nodepos, nodedir; // Used when pulling pos & vel Vectors from their respective seed-arrays
  int noderows, nodecols;   // The number of rows and columns in the network
  int vertexes;             // The number of vertexes a node will have
  Boolean nodestate;        // The inital activation state of the node
  
  // CONSTRUCTOR: Create a 'Network' object containing an set of nodes
  Network() {
    nodepopulation = new ArrayList<Node>();
    nodeList = new IntList();
    nodeListSequential();
    //nodeList.shuffle();
    populate();
    findNearestNeighbours();
    updateSelectedNeighbours();
    updateNodeRedirectors(); // To set the redirector PVector by selecting from the available Neighbours
    //trimNodeVertices();
    //trimNodeNeighbours();
    //exit();
    if (verboseMode) {println("Network has created a nodepopulation array");}
  }
  
  // Creates a list of integers used for picking the elements of a new Cell (can be shuffled if needed)
  void nodeListSequential() {
    for(int element = 0; element<nodecount; element++) {
      nodeList.append(element);
    }
  }
  
  
  // Populates the network with nodes
  void populate() {
    for(int element = 0; element<nodecount; element++) {
      int nodeID = nodeList.get(element);
      nodepos = nodepositions.nodeseedpos[nodeID];
      nodedir = nodevelocities.nodeseedvel[nodeID];
      nodestate = nodestates.nodeseedstates[nodeID];
      vertexes = nodevertexes.vertexes[nodeID];
      nodepopulation.add(new Node(nodepos, nodedir, vertexes, nodestate, element));
      //if (verboseMode) {println("Node added to the network with ID = " + element);}
    }
  }
  
  // Updates each node object with a list of nearest neighbours
  void findNearestNeighbours() {
    for(Node n: nodepopulation) {
      // Loop through each node in the arraylist in turn
      //println("Node : " + n.nodeID + " with " + n.vertexes + " vertexes");
      int neighbours = 0; // To start with, no neighbours have been discovered
      //for (int searchRadius =1; neighbours < n.vertexes && searchRadius <= (nodepositions.nodecolWidth*2)+2; searchRadius++) {
      for (int searchRadius =1; neighbours < n.vertexes && searchRadius <= w; searchRadius++) {
        //println("Searching inside a radius of " + searchRadius + " around node " + n.nodeID);
        // searchRadius will increase until either we have found enough nodes or the max size is reached
        for(int otherID = 0; otherID<nodepopulation.size() && neighbours < n.vertexes; otherID++) { // Loop through each node in the arraylist in turn
          if (otherID != n.nodeID) {
            Node other = nodepopulation.get(otherID);
            // Don't include myself
            //println("Other node: " + other.nodeID + ",  " + neighbours + " neighbours found");
            if (n.findNearestNeighbours(other, searchRadius)) {
              // Test to see if there is a c
              neighbours ++;            
              //println("Node " + other.nodeID + " was found inside the search radius. Neighbours = " + neighbours);
            }
          }
        }  
      }
    }
  }
  
  // To set the redirector PVector with a vector selected from the vertices arraylist 
  void updateNodeRedirectors() {
    for(Node n: nodepopulation) {
      //n.updateRedirector();
      n.updateRedirectorToSelectedNeighbour();
    }
  }
  
  // To set the redirector PVector with a vector selected from the vertices arraylist 
  void updateSelectedNeighbours() {
    for(Node n: nodepopulation) {
      n.selectNeighbour();
    }
  }
  
  // To set the redirector PVector with a vector selected from the vertices arraylist 
  void trimNodeVertices() {
    for(Node n: nodepopulation) {
      n.trimVertices();
    }
  }
  
  // To set the redirector PVector with a vector selected from the vertices arraylist 
  void trimNodeNeighbours() {
    for(Node n: nodepopulation) {
      n.trimNeighbours();
    }
  }
  
  void removeNodeFromNodelist(int nodeID) {
    if (nodeList.hasValue(nodeID)) {
      int index = nodeList.index(nodeID);
      network.nodeList.remove(index);
      println("Node " + nodeID + " has been removed from the network nodeList");
    }   
  }
  
  // Run the network (e.g. to display nodes)
  void run() {
    for (Node n : nodepopulation) {
      n.display(); // Display the node
    }
  }
  
}
