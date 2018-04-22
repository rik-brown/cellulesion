class Positions {
  /* The Positions class does the following:
  *  1) Creates a set of initial positions for all the elements in a population in one of a range of different patterns (random, cartesian etc.)
  *  2) Stores the positions as an array of PVectors independently of the colony object so they can be reused in successive colonies
  *  3) The PVectors are pulled out of the array sequentially as the Colony is populated in the constructor
  */
  
  // TO DO: Consider using noise() for a less random random
  
  // VARIABLES
  PVector[] seedpos;  // 'seedpos' is an array of vectors used for storing the initial positions of all the elements in colony.population
  
  // Constructor (makes a Positions object)
  Positions() {
    seedpos = new PVector[elements];  // Array size matches the size of the population
    randomPos(); // Default mode if no other alternative is selected
  }
  
  // Populates the seedpos array in a cartesian grid layout
  void centerPos() {
    for(int row = 0; row<rows; row++) {
      for(int col = 0; col<columns; col++) {
        int element = (columns*row) + col;
        float xpos = width*0.5;
        float ypos = height*0.5;
        seedpos[element] = new PVector(xpos, ypos);
      }
    }
  }
  
  // Populates the seedpos array in a cartesian grid layout
  void gridPos() {
    for(int row = 0; row<rows; row++) {
      for(int col = 0; col<columns; col++) {
        int element = (columns*row) + col;
        float xpos = map (col, 0, columns, -colOffset, width+colOffset) + colOffset; // xpos is in 'canvas space'
        float ypos = map (row, 0, rows, -rowOffset, height+rowOffset) + rowOffset;   // ypos is in 'canvas space'
        //println("Writing to seedpos[" + element + "]  with values xpos=" + xpos + " & ypos=" + ypos);
        seedpos[element] = new PVector(xpos, ypos);
      }
    }
  }
  
  // Populates the seedpos array in a cartesian grid layout
  void offsetGridPos() {
    for(int row = 0; row<rows; row++) {
      for(int col = 0; col<columns; col++) {
        int element = (columns*row) + col;
        float xpos = map (col, 0, columns, -colOffset, width+colOffset) + colOffset; // xpos is in 'canvas space'
        if (isOdd(row)) {xpos += colOffset;}
        float ypos = map (row, 0, rows, -rowOffset, height+rowOffset) + rowOffset;   // ypos is in 'canvas space'
        //println("Writing to seedpos[" + element + "]  with values xpos=" + xpos + " & ypos=" + ypos);
        seedpos[element] = new PVector(xpos, ypos);
      }
    }
  }
  
  // Populates the seedpos array with random values
  void randomPos() {
    for(int element = 0; element<elements; element++) {
      float xpos = random(width);
      float ypos = random(height);
      //println("Writing to seedpos[" + element + "]  with values xpos=" + xpos + " & ypos=" + ypos);
      seedpos[element] = new PVector(xpos, ypos);
    }
  }
  
  // Populates the seedpos array in a phyllotaxic spiral
  void phyllotaxicPos() {
    float c = w * 0.011;
    for (int element = 0; element<elements; element++) {    
      // Simple Phyllotaxis formula:
      float angle = element * radians(137.5);
      float radius = c * sqrt(element);   
      float xpos = radius * cos(angle) + width * 0.5;
      float ypos = radius * sin(angle) + height * 0.5;
      seedpos[element] = new PVector(xpos, ypos);
      c *= 1.004;
      //c += width * 0.0002;
    }
  }
  
  // Populates the seedpos array in a phyllotaxic spiral
  void phyllotaxicPos2() {
    float c = w * 0.1;
    for (int element = 0; element<elements; element++) {    
      // Simple Phyllotaxis formula:
      float angle = element * radians(137.5);
      float radius = c * sqrt(element);   
      float xpos = radius * cos(angle) + width * 0.5;
      float ypos = radius * sin(angle) + height * 0.5;
      seedpos[element] = new PVector(xpos, ypos);
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
