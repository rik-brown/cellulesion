class Network {
  /* The Network class does the following:
  *  1) Creates a network by spawning a given number of nodes in a predetermined spawn-pattern
  *  2) Runs the network
  */
  
  // VARIABLES
  ArrayList<Node> nodes;    // An arraylist for all the cells
  IntList nodeList;         // A list of integers used to pick node content when populating the network (to permit shuffling the order)
  PVector nodepos, nodedir;         // Used when pulling pos & vel Vectors from their respective seed-arrays
  int noderows, nodecols;
  int vertexes;             // The number of vertexes a node will have
  
  // CONSTRUCTOR: Create a 'Network' object containing an set of nodes
  Network() {
    nodes = new ArrayList<Node>();
    nodeList = new IntList();
    nodeListSequential();
    //nodeList.shuffle();
    populate();
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
      vertexes = nodevertexes.vertexes[nodeID];

      // How should I pass the new colour values into the cell? As 6 integer values or 2 colour objects?
      nodes.add(new Node(nodepos, nodedir, vertexes));
    }
  }
  
}
