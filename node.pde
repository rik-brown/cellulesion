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
  int vertexes;         // The number of possible directions the redirector may use
  
  // **************************************************CONSTRUCTOR********************************************************
  // CONSTRUCTOR: create a 'node' object
  Node (PVector pos, PVector dir, int vert) {
    position = pos.copy();
    redirector = dir.copy();
    vertexes = vert;    
  }
  
  // Display a simple white circle at the node
  void display() {
    fill(255);
    ellipse(position.x, position.y, 2, 2);
    //point(position.x, position.y);
  }
  
  
}
