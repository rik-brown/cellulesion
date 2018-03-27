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
      float hs = colours.hStart[element];
      float he = colours.hEnd[element];
      float ss = colours.sStart[element];
      float se = colours.sEnd[element];
      float bs = colours.bStart[element];
      float be = colours.bEnd[element];
      // More to come ...
      // How will I pass the new colour values into the cell? As 6 integer values or 2 colour objects?
      population.add(new Cell(pos, size, vMax, hs, he, ss, se, bs, be));
    }
  }
    
  // Runs the colony
  void run() {
    int drawHandsNow = int(generations * 0.8);
    //float epochsProgress = epoch/epochs;
    for (int i = population.size()-1; i >= 0; i--) {                       // Iterate backwards through the ArrayList in case we remove item(s) along the way
      if (debugMode) {debugFile.println("Item: " + i + " of " + (population.size()-1));}
      Cell c = population.get(i);  // Get one cell at a time
      c.update();                     // Update the cell
      //if (c.dead()) {println(i + " just died!"); population.remove(i);}  // If the cell has died, remove it from the array
      //if (epochsProgress > 0.5) {c.display();}
      //if ((epochsProgress > 0.5) && generation == generations) {c.last(i);}
      //if ((epochsProgress <= 0.5) && generation == generations) {c.first(i); c.last(i);}
      if (debugMode) {c.debug();}
      if (!c.dead()) {
        c.display();
        if (generation == drawHandsNow) {c.hands();}
        if (generation == generations) {c.eyes();}        
      }   // If the cell is still alive, draw it (but don't remove it from the array - it might be a ChosenOne)
      
      c.move();                       // Cell position is updated
      //if (generation ==1) {positions.seedpos[i] = new PVector(c.position.x, c.position.y);} // To update each cell's start position for the next epoch      
    }
  }
}
