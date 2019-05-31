class Node {
  /* The Node class does the following:
  *  1) Creates a node object
  *
  * A node is intended to be like a static cell
  * When a cell collides with a node, it will change direction by adopting the 'latent velocity vector' at the node
  * A nodes LVV may be changed by this collision, so the next colliding cell will follow a different path
  *
  *
  * 04.04.2019 A node needs to know if it is an 'edge' or a 'corner' if the max nr. of connections is to be the means of preventing 45-degree angles in a grid
  *
  */
  
  PVector position;      // The node's position on the canvas
  PVector redirector;    // The redirecting vector that a colliding cell will inherit
  int vertexes, nodeID;  // The number of possible directions the redirector may use
  int selectedNeighbour; // The nodeID of the neighbour which the 'redirector' is currently pointing towards
  Boolean active;
  ArrayList<PVector> vertices;      // An arraylist of vectors pointing to (a selection of) the node's neighbours
  IntList neighbours;        // An Intlist of nodeIDs of the node's neighbours
  
  // **************************************************CONSTRUCTOR********************************************************
  // CONSTRUCTOR: create a 'node' object
  Node (PVector pos, PVector dir, int vert, Boolean state, int nodeID_) {
    vertices = new ArrayList<PVector>();
    neighbours = new IntList();
    position = pos.copy();
    //redirector = dir.copy();
    //redirector.setMag(20);
    vertexes = vert;
    active = state;
    nodeID = nodeID_;
  }
  
  // Display a simple white circle at the node
  void display() {
    fill(255);
    stroke(255);
    strokeWeight(1);
    ellipse(position.x, position.y, 2, 2);
    //point(position.x, position.y);
    PVector redirectorScaled = redirector.copy().setMag(20);
    PVector endpoint = PVector.add(position, redirectorScaled);
    line(position.x, position.y, endpoint.x, endpoint.y);
  }
  
  boolean findNearestNeighbours(Node other, int searchRadius) {
    // Calculate the vector pointing to each node & save it in the arraylist 'vertices' if it is within the searchRadius
    // It may also selectively remove some of these connections
    // There will also need to be a 'pointer' in each node showing which neighbour is currently selected.
    PVector distVect = PVector.sub(other.position, position); // Static vector to get distance between the cell & other
    int distMag = int(distVect.mag());
    if (distMag == searchRadius) {
      //println("I found a node with nodeID = " + other.nodeID + " at a distance of " + distMag);
      vertices.add(distVect); // Add this vector to the vertices Arraylist
      neighbours.append(other.nodeID); // Add the neighbour's nodeID to the neighbours Arraylist
      return true;
    }
    else {return false;}
  }
  
  void updateRedirector() {
    int randomVertexPicker = int(random(vertices.size()));
    PVector toNeighbour = vertices.get(randomVertexPicker);
    redirector = toNeighbour.copy();
    //redirector.setMag(1);
    redirector.normalize();
    nodevelocities.nodeseedvel[nodeID] = redirector; // Replace the original nodevelocity vector in the nodeseedvel array with the new redirector vector
  }
  
  void updateRedirectorToSelectedNeighbour() {
    // Redirector vector shall point from Node position to SelectedNeighbour's position
    // This vector isn't actually used for anything useful anymore, apart from when displayNode() is enabled.
    // I am node n and I know my position = position :-)
    // What is the position of my selectedNeighbour?
    // It has an ID: selectedNeighbour
    // Position can be found in nodepositions.nodeseedpos[selectedNeighbour];
    //println("In updateRedirectorToSelectedNeighbour, Node " + nodeID + " has SelectedNeighbour id: " + selectedNeighbour);
    PVector neighbourPos =  nodepositions.nodeseedpos[selectedNeighbour];
    redirector = PVector.sub(neighbourPos, position).normalize();
    nodevelocities.nodeseedvel[nodeID] = redirector; // Replace the original nodevelocity vector in the nodeseedvel array with the new redirector vector
  }
  
  void selectNeighbour() {
    // Need to select a nodeID from available neighbours in arraylist
    int availableNeighbours = neighbours.size();
    //if (verboseMode) {println("Selecting neighbour from a list of " + availableNeighbours + " alternatives.");}
    if (availableNeighbours > 0) {
      int randomNeighbourPicker = int(random(neighbours.size()));
      //println("Node: " + nodeID + " randomNeighbourPicker picks value: " + randomNeighbourPicker);
      selectedNeighbour = neighbours.get(randomNeighbourPicker);
    }
    else {selectedNeighbour = nodeID;}
    //if (verboseMode) {println("Node: " + nodeID + " Selected neighbour has nodeID: " + selectedNeighbour);}
  }
  
  void trimVertices() {
    // This method will randomly remove elements from the vertices arraylist, leaving at least one element
    // IT IS BUGGY & CAN REMOVE All ELEMENTS!
    // Need to do it like this:
    /* Get the number of elements
    *  Check to see if there are more than 1:
    *  If there are: Pick one at random, Test whether to remove it or not, If condition is met, remove
    *  Repeat until you have done this enough times to potentially have removed all but one
    *
    *  If trimming is tricky, another alternative would be to select from the list of 'all potential neighbours' to a 'selected neighbours' array
    *
    */
    
    int numVertices = vertices.size();
    int toRemove = numVertices-1;
    if (numVertices > 0) {
      for (int element = numVertices-1 ; element >= 0 && toRemove >=0 ; element --) {
        if (random(1) > 0.5) {
          toRemove --;
          //println("Removing element " + element + " from vertices arraylist in node " + nodeID + ". Items left to remove: " + toRemove);
          vertices.remove(element);
          
        }
      }
    }
    
  }
  
  void trimNeighbours() {
    // This method will randomly remove elements from the neighbours arraylist, leaving at least one element
    int numVertices = vertices.size()-1;
    if (numVertices > 0) {
      for (int element = numVertices ; element >=0 ; element --) {
        if (random(1) > 0.5) {
          //println("Removing element " + element + " from neighbours arraylist in node " + nodeID);
          neighbours.remove(element);
        }
      }
    }
    
  }
  
  void rotateRedirector(int nodeID) {
    // When this method is called the redirector vector gets rotated through one sector in a 'positive direction'
    // In which direction?
    float fixedAngle = PI;
    float dynamicAngle = TWO_PI/vertexes;
    //println("Node ID " + nodeID + " with " + vertexes + " vertexes was redirected!");
    redirector.rotate(dynamicAngle);
    //nodevelocities.nodeseedvel[nodeID] = redirector; //update nodevelocities with the new position
  }
  
  void rotateRedirector2(int nodeID) {
    // When this method is called the redirector vector gets rotated through one sector in a 'positive direction'
    // In which direction?
    int randomDirection = (int(random(2))*2)-1;
    int randomVertexes = int(random(ceil(vertexes*0.5)));
    float dynamicAngle = TWO_PI * randomVertexes * randomDirection / vertexes;
    //println("Node ID " + nodeID + " with " + vertexes + " vertexes was redirected!");
    redirector.rotate(dynamicAngle);
    //nodevelocities.nodeseedvel[nodeID] = redirector; //update nodevelocities with the new position
  }
  
}
