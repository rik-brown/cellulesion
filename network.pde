class Network {
  /* The Network class does the following:
  *  1) Creates a network by spawning a given number of nodes in a predetermined spawn-pattern
  *  2) Runs the network
  */
  
  // VARIABLES
  ArrayList<Cell> population;    // An arraylist for all the cells
  IntList elementList;           // A list of integers used to pick cell content when populating the colony (to permit shuffling the order)
  PVector pos, vel;              // Used when pulling pos & vel Vectors from their respective seed-arrays
  
  // CONSTRUCTOR: Create a 'Network' object containing an set of nodes
  Network() {
    population = new ArrayList<Cell>();
    elementList = new IntList();
    elementListSequential();
    populate();
  }
  
}
