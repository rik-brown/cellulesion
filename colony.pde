class Colony {
  /* The Colony class does the following:
  *  1) Starts a colony by spawning a given number of cells in a predetermined spawn-pattern
  *  2) Runs the colony
  */
  
  // VARIABLES
  ArrayList<Cell> population;    // An arraylist for all the cells
  PVector pos;
  
  // CONSTRUCTOR: Create a 'Colony' object containing an initial population of cells
  Colony() {
    population = new ArrayList<Cell>();
    cartesian();
    //randomPos();
  }
  
  // Populates the colony in a cartesian grid layout
  void cartesian() {
    for(int col = 0; col<columns; col++) {
      for(int row = 0; row<rows; row++) {
        float xpos = map (col, 0, columns, 0, width) + colOffset; // xpos is in 'canvas space'
        float ypos = map (row, 0, rows, 0, height) + rowOffset;   // ypos is in 'canvas space'
        pos = new PVector(xpos, ypos);
        population.add(new Cell(pos));
      }
    }
  }
  
  // Populates the colony in a random layout
  void randomPos() {
    for(int col = 0; col<columns; col++) {
      for(int row = 0; row<rows; row++) {
        float xpos = random(width);
        float ypos = random(height);
        pos = new PVector(xpos, ypos);
        population.add(new Cell(pos));
      }
    }
  }
    
  // Runs the colony
  void run() {
    for (int i = population.size()-1; i >= 0; i--) {                       // Iterate backwards through the ArrayList in case we remove item(s) along the way
      if (debugMode) {debugFile.println("Item: " + i + " of " + (population.size()-1));}
      Cell c = population.get(i);  // Get one cell at a time
      c.run();                     // Run the cell
      //if (c.dead()) {println(i + " just died!"); population.remove(i);}  // If the cell has died, remove it from the array
    }
  }

}