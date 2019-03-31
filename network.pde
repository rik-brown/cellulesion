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
    exit();
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
      println("Node : " + n.nodeID);
      int neighbours = 0; // To start with, no neighbours have been discovered
      for (int searchRadius =1; neighbours <= n.vertexes && searchRadius <= (nodepositions.nodecolWidth*2)+2; searchRadius++) {
        println("Searching inside a radius of " + searchRadius + " around node " + n.nodeID);
        // searchRadius will increase until either we have found enough nodes or the max size is reached
        // BUG: This method does not prevent adding too many neighbours, it just stops increasing the radius larger than needed
        // There needs to be a way of stopping the Node other loop before overcounting (if more than one node found at a givem distance)
        // Maybe it could stop adding to the arraylist once the limit is reached
        for(Node other: nodepopulation) { // Loop through each node in the arraylist in turn
          if (other.nodeID != n.nodeID) {
            // Don't include myself
            println("Other node: " + other.nodeID);
            if (n.findNearestNeighbours(other, searchRadius)) { // Test to see if there is a c
              println("Node " + other.nodeID + " was found inside the search radius");
              neighbours ++;
              println(neighbours + " neighbours found");
              
            }
          }
        }  
      }
    }
  }
  
  // Run the network (e.g. to display nodes)
  void run() {
    for (int nodeID = nodepopulation.size()-1; nodeID>=0; nodeID--) {
      Node n = nodepopulation.get(nodeID);  // Get the nodes, one by one
      n.display(); // Display the node
    }
  }
  
}
