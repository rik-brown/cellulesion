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
    if (networkMode) {setCellTargetNodeID();}
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
      population.add(new Cell(cellNumber, element, brood, pos, vel, size, vMax, offset, maxAge, hs, he, ss, se, bs, be));
      if (verboseMode) {println("Cell added to the population with serial = " + cellNumber + " & id = " + element);}
      cellNumber ++; // Increment the cellNumber for each cell added to the colony in the initial spawn
    }
  }
  
  void setCellTargetNodeID() {
    //Assign the targetNodeID in each cell using the value stored in positions.seedposNodes array when positions where defined
    for(Cell c:population) {
      c.targetNodeID = positions.seedposNodes[c.id];
      println("In setCellTargetNodeID, cell " + c.serial + " is assigned targetNodeID " + c.targetNodeID);
    }
  }
  
  void update() {
    println("Updating cells");
    updateCells();
    println("Checking for NodeCollisions");
    checkForNodeCollisions();
    println("Checking for CellCollisions");
    checkForCellCollisions();
    println("Displaying Cells");
    displayCells();
    println("Moving Cells");
    moveCells();
  }
  
  // Colony.run part 1: Check for collisions between cells & nodes
  // New cells will be added if cells & nodes collide & conditions are met
  // The loop must iterate backwards through the colony
  void checkForNodeCollisions() {
    //if (verboseMode) {println("Population size = " + population.size());}
    for (int i = population.size()-1; i >= 0; i--) { // Iterate backwards through the ArrayList in case we remove item(s) along the way
      if (debugMode) {debugFile.println("Item: " + i + " of " + (population.size()-1));}
      Cell c = population.get(i);  // Get one cell at a time
      // Test for collision between current cell(i) and the node in the network
      if (networkMode && !c.hasCollidedWithNode && !c.returnVisit) { // Only check for collisons if networkMode is enabled && the cell hasn't already collided with a node
        for (int nodeID = network.nodepopulation.size()-1; nodeID>=0; nodeID--) {
          Node node = network.nodepopulation.get(nodeID);  // Get the nodes, one by one
          
          // Test for collision: 
          // If (criteria for collision are met) {do the following}
          // NOTE: Some of the outcomes are already initiated in the cell code before returning 'true' to this section
          if (c.checkNodeCollision(node)) {
            //If a collision between cell & node has occurred
            
            if (node.active) {
              // RESERVED FOR ACTIONS CONDITIONAL ON NODE ACTIVATION (currently not in use)
              //node.selectNeighbour();
              //node.rotateRedirector(nodeID); // Redirector vector is only rotated on collision if node is active
              //node.rotateRedirector2(nodeID); // Redirector vector is only rotated on collision if node is active
              //node.active = false; // Node is inactive, will not be rotated again
              //println("Active node " + nodeID + " has been set inactive");
              //nodestates.nodeseedstates[nodeID] = false; //update nodeseedstates with the new state
            }
                        
            if (network.nodeList.hasValue(nodeID)) {
              int indX = network.nodeList.index(nodeID);
              network.nodeList.remove(indX);
              println("Node " + nodeID + " has been removed from the network nodeList");
            }
            
            //println(network.nodeList);
            if ( (c.nodeCollisions >= c.nodeCollisionThreshold) && (c.brood <= 5) ) {
              println("c.nodeCollisions: (>c.nCT) " + c.nodeCollisions + " c.nodeCollisionThreshold: " + c.nodeCollisionThreshold + " c.brood: (<=3) " + c.brood);
              spawnCellAtRandomNode(c.id, c.brood);
              c.nodeCollisions = 0; // reset the collision counter to prevent repeated spawning once threshold is exceeded
            }
          } // End of 'if(node collision has occurred)' 
        } // End of loop through all nodes in the network
      } // End of 'if (criteria for testing for cell-node collision are met)    
    } // End of loop through all cells in the population
  }
  
  
  void spawnCellAtRandomNode(int cell_ID, int cell_Brood) {
    int availableNodes = network.nodeList.size();
    println("availableNodes: (>0) " + availableNodes);
    
    // NOTE: HARDCODED value here (brood <= 3) - can't remember why I added this, but is a way to limit cell population explosion.
    if (availableNodes > 0) {
      int randomNode = int(random(availableNodes));
      int node_ID = network.nodeList.get(randomNode);
      println("Node " + node_ID + " has been selected as spawn position for new cell");
      PVector spawnPos = nodepositions.nodeseedpos[node_ID];
      //PVector spawnVel = nodevelocities.nodeseedvel[node_ID];
      Node nextNode = network.nodepopulation.get(node_ID);
      int headingForNodeID = nextNode.selectedNeighbour;
      PVector nextNodePos = nodepositions.nodeseedpos[headingForNodeID];
      PVector spawnVel = PVector.sub(spawnPos, nextNodePos).normalize();
      println("New cell with serial = " + cellNumber + " & id " + cell_ID + " will now be spawned after collision with node");
      spawn(cell_ID, cell_Brood, spawnPos, spawnVel);
    }
    else {println("availableNodes=" + availableNodes + ". Sorry, no more nodes available, try again later");}
  }
  
  
  // Colony.run part 2: Check for collisions between cells & other cells
  // New cells MAY be added if cells & cells collide & conditions are met
  // Some cells will be removed if conditions are met
  // The loop must iterate backwards through the colony
  void checkForCellCollisions() {
    //if (verboseMode) {println("Population size = " + population.size());}
    for (int i = population.size()-1; i >= 0; i--) { // Iterate backwards through the ArrayList in case we remove item(s) along the way
      if (debugMode) {debugFile.println("Item: " + i + " of " + (population.size()-1));}
      Cell c = population.get(i);  // Get one cell at a time
      //println("Generation:" + generation + ", i=" + i + ", Cell ID =" + c.id + ", hasCollided=" + c.hasCollided + ", dead=" + c.dead() + ", fertile=" + c.fertile);
      
      // Test for collision between current cell(i) and the others
      if (collisionMode && !c.hasCollided && !c.hatchling) {  // Only check for collisons if collisionMode is enabled, the cell in question hasn't already collided and is not a hatchling...
        for (int others = population.size()-1; others >= 0; others--) {              // Since main iteration (i) goes backwards, this one needs to too
          // Changed to loop through all cells (not just those 'beneath' me) since we are checking historical positions too
          // Need to ignore myself (I can cross my own trail)
          if (others != i || c.returnVisit ) {
            Cell other = population.get(others); // Get the other cells, one by one
            c.checkCollisionAllPositions(other); // Checks all historical positions of the other cells 
          } // End of test for others!= i     
        } // End of loop through all 'other' cells
      } // End of test for collision between cells    
    } // End of loop through all cells in the population
  }
  
  // Colony.run part 3: Update & render the cells (if they are alive)
  // No cells will be added or removed, so it doesn't really matter which direction the loop iterates through the colony
  void updateCells() {
    for (int i = population.size()-1; i >= 0; i--) {                       // Iterate backwards through the ArrayList in case we remove item(s) along the way
      if (debugMode) {debugFile.println("Item: " + i + " of " + (population.size()-1));}
      Cell c = population.get(i);  // Get one cell at a time
      //println("Generation:" + generation + ", i=" + i + ", Cell ID =" + c.id + ", hasCollided=" + c.hasCollided + ", dead=" + c.dead() + ", fertile=" + c.fertile);
      //c.radius();
      c.update();      
      //if (!c.dead()) {c.update();}                     // Update the cell
      //if (c.dead()) {println(i + " just died!"); population.remove(i);}  // If the cell has died, remove it from the array
      //if (eraCompleteness > 0.5) {c.display();}
      //if ((eraCompleteness > 0.5) && generation == generations) {c.last(i);}
      //if ((eraCompleteness <= 0.5) && generation == generations) {c.first(i); c.last(i);}
      if (debugMode) {c.debug();}    
    } // End of loop through all cells in the population
  }
  
  void displayCells() {
    int drawHandsNow = int(generations * 0.8);
    pushMatrix();
    //translation();
    for(Cell c: population) {
      //c.display(); // Draw the cell on each update whether it is dead or alive
      //if (generation == drawHandsNow) {c.hands();}
      //if (generation == generations) {c.display();}
      //if (generation == generations) {c.eyes_Ahoj();}   
      if (!c.dead()) {
        c.display(); // Only display living cells. Dead cells are not updated
        //if (generation == drawHandsNow) {c.hands();}
        //if (generation == generations) {c.eyes();}
      }    
    }
    popMatrix();
  }
  
  void moveCells() {
    for(Cell c: population) {
      if (!c.dead()) {
        c.move(); // Only move living cells. Dead cells are stationary
        //if (generation ==1) {positions.seedpos[i] = new PVector(c.position.x, c.position.y);} // To update each cell's start position for the next epoch, creating movement in the epoch Mpeg
      }    
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
    population.add(new Cell(cellNumber, mothersID, brood, pos, vel, size, vMax, offset, maxAge, hs, he, ss, se, bs, be)); // NOTE: Spawned cell inherits same cellID as mother (collider)
    println("New cell added with serial=" + cellNumber + " & ID = " + mothersID + " Population size is now " + population.size());
    cellNumber ++; // Increment the cellNumber for each new cell spawned by a collision
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
    //if (verboseMode) {println ("Population size = " + population.size());}
    for (Cell c:population) {
      // Get one cell at a time
      //println("Testing to see if cell " + c.serial + " is alive. Death-state is " + c.dead() );
      if (!c.dead()) {return false;} // If any one cell in the population is alive, extinction has not occurred
    }
    // If you get to this point without returning false, it means all cells must be dead
    if (verboseMode) {println("All the cells have died!");}
    return true;
  }
  
}
