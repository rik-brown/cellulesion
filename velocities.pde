class Velocities {
  /* The Velocities class does the following:
  *  1) Creates a set of initial Vmax values for all the elements in a population
  *  2) Stores the values as an array of floats independently of the colony object so they can be reused in successive colonies
  *  3) The floats are pulled out of the array sequentially as the Colony is populated in the constructor
  */

  // VARIABLES
  float[] vMax;  // 'vMax' is an array of floats used for storing the initial sizes of all the elements in colony.population
  float vMaxMin, vMaxMax;
  
  // Constructor (makes a Sizes object)
  Velocities() {
    vMax = new float[elements];  // Array size matches the size of the population
    vMaxMin = 0.5;
    vMaxMax = 1.0;
  }
  
  // Populates the seedsize array in a cartesian grid layout
  void randomvMax() {
    for(int element = 0; element<elements; element++) {
      float vMaxRandom = random(vMaxMin, vMaxMax);
      //println("Writing to seedsize[" + element + "]  with values size=" + size);
      vMax[element] = vMaxRandom;
    }
  }
}