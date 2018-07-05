class Velocities {
  /* The Velocities class does the following:
  *  1) Creates a set of initial velocity PVectors for all the elements in a population
  *  2) Stores the values as an array of PVectors independently of the colony object so they can be reused in successive colonies
  *  3) The PVectors are pulled out of the array sequentially as the Colony is populated in the constructor
  */

  // VARIABLES
  PVector[] seedvel;  // 'vMax' is an array of floats used for storing the initial sizes of all the elements in colony.population
    
  // Constructor (makes a Sizes object)
  Velocities() {
    seedvel = new PVector[elements];  // Array size matches the size of the population
    randomVel(); // Default mode if no other alternative is selected
  }

  // Populates the seedpos array with random values
  void randomVel() {
    for(int element = 0; element<elements; element++) {
      PVector v = PVector.random2D();
      seedvel[element] = v;
    }
  }  

}
