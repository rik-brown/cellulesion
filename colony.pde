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
    int deadCount = 0;
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
            c.checkCollision2(other); // checkCollision2 checks all historical positions of the other cells
          } // End of test for others!= i          
        } // End of loop through all 'other' cells
      } // End of test for collisionMode
      
      //c.display(); // Draw the cell on each update whether it is dead or alive
      //if (generation == drawHandsNow) {c.hands();}
      //if (generation == generations) {c.display();}
      //if (generation == generations) {c.eyes_Ahoj();}       
      
      if (!c.dead()) {
        c.display(); // Only display living cells. Dead cells are not updated
        c.move(); // Only move living cells. Dead cells are stationary
        //if (generation == drawHandsNow) {c.hands();}
        //if (generation == generations) {c.eyes();}        
      } // End of test for !dead
      
      if (c.dead()) {deadCount++; println("deadCount=" + deadCount + " elements=" + elements);}
      // This feature tries to save time by counting the number of dead cells
      //c.move(); // Cell position is updated (Note: This is the original line, before the concept of death was introduced. Can probably be removed now :-)
      //if (generation ==1) {positions.seedpos[i] = new PVector(c.position.x, c.position.y);} // To update each cell's start position for the next epoch, creating movement in the epoch Mpeg      
    } // End of loop through all cells in the population
    
    //if (deadCount == elements) {generation=generations;} // If all cells are dead, jump to the end of the epoch.
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
  
  // Spawns a new cell using the received values for position, velocity
  void spawn(int cellID, PVector pos_) {
    int elementID = elementList.get(cellID); // This causes error once cellID > elements (which happens as soon as 2nd generation cell spawns)
    PVector pos = pos_.copy();
    //pos = new PVector(random(width),random(height));
    //PVector vel =vel_.copy().rotate(HALF_PI);
    float size = sizes.seedsize[elementID] * 0.5;
    float vMax = velocities.vMax[elementID];
    float hs = colours.hStart[elementID];
    float he = colours.hEnd[elementID];
    float ss = colours.sStart[elementID];
    float se = colours.sEnd[elementID];
    float bs = colours.bStart[elementID];
    float be = colours.bEnd[elementID];
    //int element = population.size();
    int element = cellID; // Spawned cell inherits same cellID as mother (collider)
    population.add(new Cell(element, pos, size, vMax, hs, he, ss, se, bs, be));
    println("New cell added with ID = " + element);
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
