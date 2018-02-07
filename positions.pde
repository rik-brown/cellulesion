class Positions {
  /* The Positions class does the following:
  *  1) Creates a set of initial positions for all the elements in a population in one of a range of different patterns (random, cartesian etc.)
  *  2) Stores the positions as an array of PVectors independently of the colony object so they can be reused in successive colonies
  *  3) The PVectors are pulled out of the array sequentially as the Colony is populated in the constructor
  */
  
  // WORK IN PROGRESS 06.02.2018 20:22
  // The spawn patterns need to be called from here (seedpos.cartesian() etc.)
  // Then, when colony creates a population it just needs to iterate through all the elements, pulling out the vectors one by one
  // Note: Positions needs to be created before colony (so population size is not known yet)
  // Consider using noise() for a less random random
  // DEBUGGING: 2018-02-07 08:30 NullPointerException. Need to check the element numbering!

  // VARIABLES
  PVector[] seedpos;  // 'seedpos' is an array of vectors used for storing the initial positions of all the elements in colony.population
  
  // Constructor (makes a Positions object)
  Positions() {
    seedpos = new PVector[elements];  // Array size matches the size of the population
  }
  
  // Populates the seedpos array in a cartesian grid layout
  void gridPos() {
    for(int row = 0; row<rows; row++) {
      for(int col = 0; col<columns; col++) {
        int element = (columns*row) + col;
        float xpos = map (col, 0, columns, 0, width) + colOffset; // xpos is in 'canvas space'
        float ypos = map (row, 0, rows, 0, height) + rowOffset;   // ypos is in 'canvas space'
        println("Writing to seedpos[" + element + "]  with values xpos=" + xpos + " & ypos=" + ypos);
        seedpos[element] = new PVector(xpos, ypos);
      }
    }
  }
  
  // Populates the seedpos array in a cartesian grid layout
  void randomPos() {
    for(int element = 0; element<elements; element++) {
      float xpos = random(width);
      float ypos = random(height);
      println("Writing to seedpos[" + element + "]  with values xpos=" + xpos + " & ypos=" + ypos);
      seedpos[element] = new PVector(xpos, ypos);
    }
  }

}