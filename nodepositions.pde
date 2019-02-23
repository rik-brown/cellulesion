class Nodepositions {
  /* The Positions class does the following:
  *  1) Creates a set of initial positions for all the nodes in a network in one of a range of different patterns (random, cartesian etc.)
  *  2) Stores the positions as an array of PVectors independently of the colony object so they can be reused in successive colonies
  *  3) The PVectors are pulled out of the array sequentially as the network is populated in the constructor
  */
  
  // TO DO: Consider using noise() for a less random random
  
  // VARIABLES
  PVector[] nodeseedpos;  // 'nodeseedpos' is an array of vectors used for storing the initial positions of all the nodes in network.nodes
  
  // Constructor (makes a Positions object)
  Nodepositions() {
    nodeseedpos = new PVector[nodecount];  // Array size matches the size of the population
    randomPos(); // Default mode if no other alternative is selected
  }
  
  // Populates the nodeseedpos array in a cartesian grid layout
  void centerPos() {
    for(int row = 0; row<noderows; row++) {
      for(int col = 0; col<nodecols; col++) {
        int element = (nodecols*row) + col;
        float xpos = width*0.5;
        float ypos = height*0.5;
        nodeseedpos[element] = new PVector(xpos, ypos);
      }
    }
  }
  
  // Populates the nodeseedpos array in a cartesian grid layout
  void gridPos() {
    for(int row = 0; row<noderows; row++) {
      for(int col = 0; col<nodecols; col++) {
        int element = (nodecols*row) + col;
        float xpos = map (col, 0, nodecols, -colWidth, width+colWidth) + colWidth; // xpos is in 'canvas space'
        float ypos = map (row, 0, noderows, -rowHeight, height+rowHeight) + rowHeight;   // ypos is in 'canvas space'
        //println("Writing to nodeseedpos[" + element + "]  with values xpos=" + xpos + " & ypos=" + ypos);
        nodeseedpos[element] = new PVector(xpos, ypos);
      }
    }
  }
  
  // Populates the nodeseedpos array in a cartesian grid layout
  void scaledGridPos() {
    float widthScale = 1.0; // 1.0 = use 100% of canvas
    float heightScale = widthScale;
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
        float ypos = ((row*2)-1)*rowHeight*0.5  + yOffset;  // ypos is in 'canvas space'
        //println("Writing to nodeseedpos[" + element + "]  with values xpos=" + xpos + " & ypos=" + ypos);
        nodeseedpos[element] = new PVector(xpos, ypos);
        element++;
      }
    }
  }
  
  // Populates the nodeseedpos array in a cartesian grid layout
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
        //println("Writing to nodeseedpos[" + element + "]  with values xpos=" + xpos + " & ypos=" + ypos);
        nodeseedpos[element] = new PVector(xpos, ypos);
        element++;
      }
    }
  }
  
  // Populates the nodeseedpos array in a cartesian grid layout
  void offsetGridPos() {
    float rowOffIso = colWidth * (sqrt(3))/2;
    for(int row = 0; row<noderows; row++) {
      for(int col = 0; col<nodecols; col++) {
        int element = (nodecols*row) + col;
        float xpos = map (col, 0, nodecols, -colWidth, width+colWidth) + colWidth; // xpos is in 'canvas space'
        if (isOdd(row)) {xpos += colWidth;}
        float ypos = map (row, 0, noderows, -rowOffIso, height+rowOffIso) + rowOffIso;   // ypos is in 'canvas space'
        //println("Writing to nodeseedpos[" + element + "]  with values xpos=" + xpos + " & ypos=" + ypos);
        nodeseedpos[element] = new PVector(xpos, ypos);
      }
    }
  }
  
  // Populates the nodeseedpos array with random values
  void randomPos() {
    for(int element = 0; element<nodecount; element++) {
      float xpos = random(width);
      float ypos = random(height);
      //println("Writing to nodeseedpos[" + element + "]  with values xpos=" + xpos + " & ypos=" + ypos);
      nodeseedpos[element] = new PVector(xpos, ypos);
    }
  }
  
  // Populates the nodeseedpos array in a phyllotaxic spiral
  void phyllotaxicPos() {
    float c = w * 0.011;
    for (int element = 0; element<nodecount; element++) {    
      // Simple Phyllotaxis formula:
      float angle = element * radians(137.5);
      float radius = c * sqrt(element);   
      float xpos = radius * cos(angle) + width * 0.5;
      float ypos = radius * sin(angle) + height * 0.5;
      nodeseedpos[element] = new PVector(xpos, ypos);
      c *= 1.004;
      //c += width * 0.0002;
    }
  }
  
  // Populates the nodeseedpos array in a phyllotaxic spiral
  void phyllotaxicPos2() {
    float c = w * 0.1;
    for (int element = 0; element<nodecount; element++) {    
      // Simple Phyllotaxis formula:
      float angle = element * radians(137.5);
      float radius = c * sqrt(element);   
      float xpos = radius * cos(angle) + width * 0.5;
      float ypos = radius * sin(angle) + height * 0.5;
      nodeseedpos[element] = new PVector(xpos, ypos);
      c *= 0.99;
      //c -= width * 0.0005;
    }
  }
  
  //Test if a number is even:
  boolean isEven(int n){
    return n % 2 == 0;
  }
  
  //Test if a number is odd:
  boolean isOdd(int n){
    return n % 2 != 0;
  }

}
