class Colony {
  /* The Colony class does the following:
  *  1) Starts a colony by spawning a given number of cells in a predetermined spawn-pattern
  *  2) Runs the colony
  */
  
  // VARIABLES
  ArrayList<Cell> population;    // An arraylist for all the cells
  PVector pos, vel;
  //int chosenOne; //moved to top level
  
  // CONSTRUCTOR: Create a 'Colony' object containing an initial population of cells
  Colony() {
    population = new ArrayList<Cell>();
    cartesian();
    //chosenOne = int(random(population.size()));
    //println("The chosen one is: " + chosenOne);
  }
  
  // Populates the colony in a cartesian grid layout
  void cartesian() {
    for(int col = 0; col<columns; col++) {
      for(int row = 0; row<rows; row++) {
        float xpos = map (col, 0, columns, 0, width) + colOffset; // gridx is in 'canvas space'
        float ypos = map (row, 0, rows, 0, height) + rowOffset;   // gridy is in 'canvas space'
        pos = new PVector(xpos, ypos);
        //vel = new PVector(0, 0); //To start with, velocity can be zero
        population.add(new Cell(pos));
      }
    }
  }
  
  // Updates the feedbackPosX & Y values.
  void updateFeedback() {
    feedbackPosX = population.get(chosenOne).position.x;
    feedbackPosY = population.get(chosenOne).position.y;
  }
  
  // Runs the colony
  void run() {
    //chosenOne = int(random(population.size())); // New chosenOne is picked each drawCycle - gives very odd results!
    for (int i = population.size()-1; i >= 0; i--) {  // Iterate backwards through the ArrayList because we are removing items
      if (debugMode) {debugFile.println("Item: " + i + " of " + (population.size()-1));}
      Cell c = population.get(i);  // Get one cell at a time
      c.run();                     // Run the cell
      //if (c.dead()) {println(i + " just died!"); population.remove(i);}           // If the cell has died, remove it from the array
    }
  }


}