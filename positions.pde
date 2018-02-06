class Positions {
  /* The Positions class does the following:
  *  1) Provides a repository for the initial positions of all the elements (so they can be reused in successive colonies)
  */
  
  // WORK IN PROGRESS 06.02.2018 20:22
  // The spawn patterns need to be called from here (seedpos.cartesian() etc.)
  // Then when colony creates a population it just needs to iterate through all the elements, pulling out the vectors


  // VARIABLES
  PVector[] seedpos;  // 'seedpos' is an array of vectors used for storing the initial positions of all the elements in colony.population
  
  // Constructor (makes a Positions object)
  Positions() {
    seedpos = new PVector[colony.population.size()];  // Array size matches the size of the population
  }
  
  // Populates the seedpos array in a cartesian grid layout
  void cartesian() {
    for(int col = 0; col<columns; col++) {
      for(int row = 0; row<rows; row++) {
        int element = (col*row) + col;
        float xpos = map (col, 0, columns, 0, width) + colOffset; // xpos is in 'canvas space'
        float ypos = map (row, 0, rows, 0, height) + rowOffset;   // ypos is in 'canvas space'
        seedpos[element] = new PVector(xpos, ypos);
      }
    }
  }










}