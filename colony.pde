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
    populate();
  }
  
  // Populates the colony
  void populate() {
    for(int element = 0; element<elements; element++) {
      pos = positions.seedpos[element];
      float size = sizes.seedsize[element];
      float vMax = velocities.vMax[element];
      population.add(new Cell(pos, size, vMax));
    }
  }
    
  // Runs the colony
  void run() {
    for (int i = population.size()-1; i >= 0; i--) {                       // Iterate backwards through the ArrayList in case we remove item(s) along the way
      if (debugMode) {debugFile.println("Item: " + i + " of " + (population.size()-1));}
      Cell c = population.get(i);  // Get one cell at a time
      c.update();                     // Update the cell
      //if (c.dead()) {println(i + " just died!"); population.remove(i);}  // If the cell has died, remove it from the array
      if (!c.dead()) {c.display();}   // If the cell is still alive, draw it (but don't remove it from the array - it might be a ChosenOne)
      c.move();                       // Cell position is updated
      //if (generation ==1) {positions.seedpos[i] = new PVector(c.position.x, c.position.y);} // To update each cell's start position for the next epoch
    }
  }
}