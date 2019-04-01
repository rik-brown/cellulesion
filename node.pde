class Node {
  /* The Node class does the following:
  *  1) Creates a node object
  *
  * A node is intended to be like a static cell
  * When a cell collides with a node, it will change direction by adopting the 'latent velocity vector' at the node
  * A nodes LVV may be changed by this collision, so the next colliding cell will follow a different path
  */
  
  PVector position;     // The node's position on the canvas
  PVector redirector;   // The redirecting vector that a colliding cell will inherit
  int vertexes, nodeID;         // The number of possible directions the redirector may use
  Boolean active;
  ArrayList<PVector> vertices;      // An arraylist of vectors pointing to (a selection of) the node's neighbours
  
  // **************************************************CONSTRUCTOR********************************************************
  // CONSTRUCTOR: create a 'node' object
  Node (PVector pos, PVector dir, int vert, Boolean state, int nodeID_) {
    vertices = new ArrayList<PVector>();
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
    ellipse(position.x, position.y, 2, 2);
    //point(position.x, position.y);
    PVector endpoint = PVector.add(position, redirector);
    line(position.x, position.y, endpoint.x, endpoint.y);
  }
  
  boolean findNearestNeighbours(Node other, int searchRadius) {
    // Calculate the vector pointing to each node & save it in the arraylist 'vertices' if it is within the searchRadius
    // It may also selectively remove some of these connections
    // There will also need to be a 'pointer' in each node showing which neighbour is currently selected.
    PVector distVect = PVector.sub(other.position, position); // Static vector to get distance between the cell & other
    int distMag = int(distVect.mag());
    if ( distMag == searchRadius) {
      println("I found a node with nodeID = " + other.nodeID + " at a distance of " + distMag);
      vertices.add(distVect); // Add this vector to the vertices Arraylist
      return true;
    }
    else {return false;}
  }
  
  void updateRedirector() {
    int randomVertexPicker = int(random(vertices.size()));
    PVector toNeighbour = vertices.get(randomVertexPicker);
    redirector = toNeighbour.copy();
    redirector.setMag(1);
  }
  
  void rotateRedirector(int nodeID) {
    // When this method is called the redirector vector gets rotated through one sector in a 'positive direction'
    // In which direction?
    float fixedAngle = PI;
    float dynamicAngle = TWO_PI/vertexes;
    println("Node ID " + nodeID + " with " + vertexes + " vertexes was redirected!");
    redirector.rotate(dynamicAngle);
    //nodevelocities.nodeseedvel[nodeID] = redirector; //update nodevelocities with the new position
  }
  
  void rotateRedirector2(int nodeID) {
    // When this method is called the redirector vector gets rotated through one sector in a 'positive direction'
    // In which direction?
    int randomDirection = (int(random(2))*2)-1;
    int randomVertexes = int(random(ceil(vertexes*0.5)));
    float dynamicAngle = TWO_PI * randomVertexes * randomDirection / vertexes;
    println("Node ID " + nodeID + " with " + vertexes + " vertexes was redirected!");
    redirector.rotate(dynamicAngle);
    //nodevelocities.nodeseedvel[nodeID] = redirector; //update nodevelocities with the new position
  }
  
}
