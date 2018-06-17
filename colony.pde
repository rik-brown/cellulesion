class Colony {
  /* The Colony class does the following:
  *  1) Starts a colony by spawning a given number of cells in a predetermined spawn-pattern
  *  2) Runs the colony
  */
  
  // VARIABLES
  ArrayList<Cell> population;    // An arraylist for all the cells
  IntList elementList;           // A list of integers used to pick the cell content
  PVector pos;
  
  
  
  // CONSTRUCTOR: Create a 'Colony' object containing an initial population of cells
  Colony() {
    population = new ArrayList<Cell>();
    elementList = new IntList();
    elementListSequential();
    //elementListShuffled();
    populate();
  }
  
  // Creates a list of integers used for picking the elements of a new Cell (can be shuffled if needed)
  void elementListSequential() {
    for(int element = 0; element<elements; element++) {
      elementList.append(element);
    }
  }
  
  // Creates a list of integers used for picking the elements of a new Cell (can be shuffled if needed)
  void elementListShuffled() {
    for(int element = 0; element<elements; element++) {
      elementList.append(element);
    }
    elementList.shuffle();
  }
  
  // Populates the colony
  void populate() {
    for(int element = 0; element<elements; element++) {
      int elementID = elementList.get(element);
      pos = positions.seedpos[elementID];
      float size = sizes.seedsize[elementID];
      float vMax = velocities.vMax[elementID];
      float hs = colours.hStart[elementID];
      float he = colours.hEnd[elementID];
      float ss = colours.sStart[elementID];
      float se = colours.sEnd[elementID];
      float bs = colours.bStart[elementID];
      float be = colours.bEnd[elementID];
      // More to come ...
      // How will I pass the new colour values into the cell? As 6 integer values or 2 colour objects?
      population.add(new Cell(element, pos, size, vMax, hs, he, ss, se, bs, be));
    }
  }
  
  
  
  // Populates the colony
  void populateShuffled() {
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
      population.add(new Cell(element, pos, size, vMax, hs, he, ss, se, bs, be));
    }
  }
    
  // Runs the colony
  void runREV() {
    int drawHandsNow = int(generations * 0.8);
    int directionValue = directions.dirArray[1].get(1);
    //float epochsProgress = epoch/epochs;
    pushMatrix();
    //translation();
    for (int i = population.size()-1; i >= 0; i--) {                       // Iterate backwards through the ArrayList in case we remove item(s) along the way
      if (debugMode) {debugFile.println("Item: " + i + " of " + (population.size()-1));}
      Cell c = population.get(i);  // Get one cell at a time
      //c.radius();
      c.update();
      //if (!c.dead()) {c.update();}                     // Update the cell
      //if (c.dead()) {println(i + " just died!"); population.remove(i);}  // If the cell has died, remove it from the array
      //if (epochsProgress > 0.5) {c.display();}
      //if ((epochsProgress > 0.5) && generation == generations) {c.last(i);}
      //if ((epochsProgress <= 0.5) && generation == generations) {c.first(i); c.last(i);}
      if (debugMode) {c.debug();}
      // Test for collision between current cell(i) and the others
      if (collisionMode) {  // Only check for collisons if collisionMode is enabled
        for (int others = population.size()-1; others >= 0; others--) {              // Since main iteration (i) goes backwards, this one needs to too
          // Changed to loop through all cells (not just those 'beneath' me) since we are checking historical positions too
          // Need to ignore myself (I can cross my own trail)
          if (others != i) {
            Cell other = population.get(others);                       // Get the other cells, one by one
            c.checkCollision2(other);
          }          
        }
      }
      c.display();
      //if (generation == drawHandsNow) {c.hands();}
      //if (generation == generations) {c.display();}
      //if (generation == generations) {c.eyes_Ahoj();}       
      if (!c.dead()) {
        //c.display();
        c.move();
        //if (generation == drawHandsNow) {c.hands();}
        //if (generation == generations) {c.eyes();}        
      }   // If the cell is still alive, draw it (but don't remove it from the array - it might be a ChosenOne)
      
      //c.move();                       // Cell position is updated
      //if (generation ==1) {positions.seedpos[i] = new PVector(c.position.x, c.position.y);} // To update each cell's start position for the next epoch      
    }
    popMatrix();
  }
  
  // Iterate FORWARDS through the ArrayList
  void runFWD() {
    int drawHandsNow = int(generations * 0.8);
    for (int i =0 ; i <= population.size()-1; i++) {
      if (debugMode) {debugFile.println("Item: " + i + " of " + (population.size()-1));}
      Cell c = population.get(i);  // Get one cell at a time
      c.update();                     // Update the cell
      //if (c.dead()) {println(i + " just died!"); population.remove(i);}  // If the cell has died, remove it from the array
      //if (epochsProgress > 0.5) {c.display();}
      //if ((epochsProgress > 0.5) && generation == generations) {c.last(i);}
      //if ((epochsProgress <= 0.5) && generation == generations) {c.first(i); c.last(i);}
      if (debugMode) {c.debug();}
      //c.display();
      //if (generation == drawHandsNow) {c.hands();}
      //if (generation == generations) {c.display();}
      if (generation == generations) {c.eyes_Ahoj();}       
      //if (!c.dead()) {
      //  c.display();
      //  if (generation == drawHandsNow) {c.hands();}
      //  if (generation == generations) {c.eyes();}        
      //}   // If the cell is still alive, draw it (but don't remove it from the array - it might be a ChosenOne)
      
      //c.move();                       // Cell position is updated
      //if (generation ==1) {positions.seedpos[i] = new PVector(c.position.x, c.position.y);} // To update each cell's start position for the next epoch      
    }
  }
  
  void translation() {
    float epochSpin = map(epochsProgress, 0, 1, 0, TWO_PI/6);
    float generationSpin = epochSpin * map(generation, 1, generations, 1, 3 );
    translate(width*0.5, height*0.5);
    rotate(-generationSpin);
    float transX = map(epochCosWave, -1, 1, 0.5, 0.45);
    translate(-width*transX, -height*0.5);
  }
  
}
