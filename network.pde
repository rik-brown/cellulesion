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
  
  // Run the network (e.g. to display nodes)
  void run() {
    for (int nodeID = nodepopulation.size()-1; nodeID>=0; nodeID--) {
      Node n = nodepopulation.get(nodeID);  // Get the nodes, one by one
      n.display(); // Display the node
    }
  }
  
}
