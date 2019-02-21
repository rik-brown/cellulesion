class Network {
  /* The Network class does the following:
  *  1) Creates a network by spawning a given number of nodes in a predetermined spawn-pattern
  *  2) Runs the network
  */
  
  // VARIABLES
  ArrayList<Node> nodes;    // An arraylist for all the cells
  PVector pos, dir;         // Used when pulling pos & vel Vectors from their respective seed-arrays
  int noderows, nodecols;
  int vertexes;             // The number of vertexes a node will have
  
  // CONSTRUCTOR: Create a 'Network' object containing an set of nodes
  Network() {
    nodes = new ArrayList<Cell>();
    noderows = 10;
    nodecols = 10;
    populate();
  }
  
  // Populates the network with nodes
  void populate() {
    for(int element = 0; element<elements; element++) {
      int elementID = elementList.get(element);
      pos = positions.seedpos[elementID];
      dir = velocities.seedvel[elementID];

      // How should I pass the new colour values into the cell? As 6 integer values or 2 colour objects?
      nodes.add(new Node(pos, red, vert));
    }
  }
  
  // Populates the seedpos array in a cartesian grid layout
  void isoGridPos() {
    float widthScale = 1.0; // 1.0 = use 100% of canvas
    float heightScale = widthScale * sqrt(3) * 0.5;
    float gridWidth = width * widthScale;
    float gridHeight = height * heightScale;
    float xOffset = (width-gridWidth)*0.5;
    float yOffset = (height-gridHeight)*0.5;
    int element = 0;
    colWidth = gridWidth/nodecols;
    rowHeight = gridHeight/noderows;
    for(int row = 1; row<=noderows; row++) {
      for(int col = 1; col<=nodecols; col++) {
        float xpos = ((col*2)-1)*colWidth*0.5 + xOffset;    // xpos is in 'canvas space'
        if (isOdd(row)) {xpos += colWidth*0.5;}
        float ypos = ((row*2)-1)*rowHeight*0.5  + yOffset;  // ypos is in 'canvas space'
        //println("Writing to seedpos[" + element + "]  with values xpos=" + xpos + " & ypos=" + ypos);
        seedpos[element] = new PVector(xpos, ypos);
        element++;
      }
    }
  }
  
}
