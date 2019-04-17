class Colony {
  /* The Colony class does the following:
  *  1) Creates a colony by spawning a given number of cells in a predetermined spawn-pattern
  *  2) Runs the colony
  */
  
  // VARIABLES
  ArrayList<Cell> population;    // An arraylist for all the cells
  IntList elementList;           // A list of integers used to pick cell content when populating the colony (to permit shuffling the order)
  PVector pos, vel;              // Used when pulling pos & vel Vectors from their respective seed-arrays
  
  
  
  // CONSTRUCTOR: Create a 'Colony' object containing an initial population of cells
  Colony() {
    population = new ArrayList<Cell>();
    elementList = new IntList();
    elementListSequential();
    //elementListShuffled();
    populate();
    if (verboseMode) {println("Colony has created a population of cells");}
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
    int brood = 0;
    for(int element = 0; element<elements; element++) {
      int elementID = elementList.get(element);
      pos = positions.seedpos[elementID];
      vel = velocities.seedvel[elementID];
      float size = sizes.seedsize[elementID];
      float vMax = velMags.vMax[elementID];
      float offset = offsets.seedoffset[elementID];
      float maxAge = maxAges.seedMaxAge[elementID];
      float hs = colours.hStart[elementID];
      float he = colours.hEnd[elementID];
      float ss = colours.sStart[elementID];
      float se = colours.sEnd[elementID];
      float bs = colours.bStart[elementID];
      float be = colours.bEnd[elementID];
      // How should I pass the new colour values into the cell? As 6 integer values or 2 colour objects?
      population.add(new Cell(element, brood, pos, vel, size, vMax, offset, maxAge, hs, he, ss, se, bs, be));
      if (verboseMode) {println("Cell added to the population with id = " + element);}
    }
  }
    
  // Runs the colony
  // iterating BACKWARDS through the ArrayList
  void runREV() {
    //if (verboseMode) {println("Population size = " + population.size());}
    int populationCount = population.size()-1;
    int drawHandsNow = int(generations * 0.8);
    pushMatrix();
    //translation();
    for (int i = populationCount; i >= 0; i--) {                       // Iterate backwards through the ArrayList in case we remove item(s) along the way
      if (debugMode) {debugFile.println("Item: " + i + " of " + (population.size()-1));}
      Cell c = population.get(i);  // Get one cell at a time
      //println("Generation:" + generation + ", i=" + i + ", Cell ID =" + c.id + ", hasCollided=" + c.hasCollided + ", dead=" + c.dead() + ", fertile=" + c.fertile);
      //c.radius();
      c.update();
      
      
      // Test for collision between current cell(i) and the node in the network
      if (networkMode && !c.hasCollidedWithNode) { // Only check for collisons if networkMode is enabled && the cell hasn't already collided with a node
        for (int nodeID = network.nodepopulation.size()-1; nodeID>=0; nodeID--) {
          Node node = network.nodepopulation.get(nodeID);  // Get the nodes, one by one
          // Test for collision
          if (c.checkNodeCollision(node)) {
            //println("Cell " + i + " just collided with node " + nodeID);
            if (node.active) {
              //node.rotateRedirector(nodeID); // Redirector vector is only rotated on collision if node is active
              //node.rotateRedirector2(nodeID); // Redirector vector is only rotated on collision if node is active
              //node.active = false; // Node is inactive, will not be rotated again
              println("Active node " + nodeID + " has been set inactive");
              //nodestates.nodeseedstates[nodeID] = false; //update nodeseedstates with the new state
            }
            //network.nodepopulation.remove(nodeID); // Remove the node you collided with
            println(network.nodeList);
            network.nodeList.remove(nodeID);
            println("Node " + nodeID + " has been removed from the network nodeList");
            println(network.nodeList);
            int randomNodeID = int(random(network.nodepopulation.size()));
            //int nodeID = nodeList.get(element);
            println("Node " + randomNodeID + " has been selected as spawn position for new cell");
            PVector spawnPos = nodepositions.nodeseedpos[randomNodeID];
            PVector spawnVel = nodevelocities.nodeseedvel[randomNodeID];
            int spawnBrood = c.brood+1;
            //println("New cell spawned with id = " + c.id + " & brood = " + spawnBrood);
            //spawn(c.id, spawnBrood, spawnPos, spawnVel);
            // Spawn a new cell at a random node
          }
        }
      }
      
      
      //if (!c.dead()) {c.update();}                     // Update the cell
      //if (c.dead()) {println(i + " just died!"); population.remove(i);}  // If the cell has died, remove it from the array
      //if (eraCompleteness > 0.5) {c.display();}
      //if ((eraCompleteness > 0.5) && generation == generations) {c.last(i);}
      //if ((eraCompleteness <= 0.5) && generation == generations) {c.first(i); c.last(i);}
      if (debugMode) {c.debug();}
      
      //c.display(); // Draw the cell on each update whether it is dead or alive
      //if (generation == drawHandsNow) {c.hands();}
      //if (generation == generations) {c.display();}
      //if (generation == generations) {c.eyes_Ahoj();}       
      
      if (!c.dead()) {
        c.display(); // Only display living cells. Dead cells are not updated
        c.move(); // Only move living cells. Dead cells are stationary
        //if (generation == drawHandsNow) {c.hands();}
        //if (generation == generations) {c.eyes();}
        //if (generation ==1) {positions.seedpos[i] = new PVector(c.position.x, c.position.y);} // To update each cell's start position for the next epoch, creating movement in the epoch Mpeg
      } // End of test for !dead
      
      //if (c.dead()) {populationCount--; println("Living cells=" + populationCount);}
      //if (c.dead()) {populationCount--;}
      // This feature tries to save time by counting the number of dead cells
      
      
      // Test for collision between current cell(i) and the others
      if (collisionMode && !c.hasCollided && !c.hatchling) {  // Only check for collisons if collisionMode is enabled, the cell in question hasn't already collided and is not a hatchling...
        for (int others = population.size()-1; others >= 0; others--) {              // Since main iteration (i) goes backwards, this one needs to too
          // Changed to loop through all cells (not just those 'beneath' me) since we are checking historical positions too
          // Need to ignore myself (I can cross my own trail)
          if (others != i) {
            Cell other = population.get(others);                       // Get the other cells, one by one
            if (c.checkCollision2(other)) { // checkCollision2 checks all historical positions of the other cells
              c.hasCollided = true;
            } 
          } // End of test for others!= i          
        } // End of loop through all 'other' cells
      } // End of test for collision between cells
      
    } // End of loop through all cells in the population
    
    //if (populationCount == 0) {generation=generations;} // If all cells are dead, jump to the end of the epoch.
    popMatrix();
  }
  
  // Runs the colony (alternative version)
  // Iterating FORWARDS through the ArrayList
  void runFWD() {
    int drawHandsNow = int(generations * 0.8);
    for (int i =0 ; i <= population.size()-1; i++) {
      if (debugMode) {debugFile.println("Item: " + i + " of " + (population.size()-1));}
      Cell c = population.get(i);  // Get one cell at a time
      c.update();                     // Update the cell
      //if (c.dead()) {println(i + " just died!"); population.remove(i);}  // If the cell has died, remove it from the array
      //if (eraCompleteness > 0.5) {c.display();}
      //if ((eraCompleteness > 0.5) && generation == generations) {c.last(i);}
      //if ((eraCompleteness <= 0.5) && generation == generations) {c.first(i); c.last(i);}
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
  void spawn(int mothersID, int mothersBrood, PVector pos_, PVector vel_) {
    int elementID = elementList.get(mothersID); // This causes error once cellID > elements (which happens as soon as 2nd generation cell spawns)
    int brood = mothersBrood + 1;
    PVector pos = pos_.copy();
    //pos = new PVector(random(width),random(height));
    //PVector vel =vel_.copy().rotate(HALF_PI);
    PVector vel =vel_.copy();
    float size = sizes.seedsize[elementID];
    float vMax = velMags.vMax[elementID];
    float offset = offsets.seedoffset[elementID];
    float maxAge = maxAges.seedMaxAge[elementID];
    float hs = colours.hStart[elementID];
    float he = colours.hEnd[elementID];
    float ss = colours.sStart[elementID];
    float se = colours.sEnd[elementID];
    float bs = colours.bStart[elementID];
    float be = colours.bEnd[elementID];
    population.add(new Cell(mothersID, brood, pos, vel, size, vMax, offset, maxAge, hs, he, ss, se, bs, be)); // NOTE: Spawned cell inherits same cellID as mother (collider)
    println("New cell added with ID = " + mothersID + " Population size is now " + population.size());
  }
  
  void translation() {
    float epochSpin = map(eraCompleteness, 0, 1, 0, TWO_PI/6);
    float generationSpin = epochSpin * map(generation, 1, generations, 1, 3 );
    translate(width*0.5, height*0.5);
    rotate(-generationSpin);
    float transX = map(epochCosWave, -1, 1, 0.5, 0.45);
    translate(-width*transX, -height*0.5);
  }
  
  boolean extinct() {
    if (verboseMode) {println ("Population size = " + population.size());}
    for (Cell c:population) {
      // Get one cell at a time
      if (!c.dead()) {return false;} // If any one cell in the population is alive, extinction has not occurred
    }
    // If you get to this point without returning false, it means all cells must be dead
    if (verboseMode) {println("All the cells have died!");}
    return true;
  }
  
}
