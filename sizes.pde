class Sizes {
  /* The Sizes class does the following:
  *  1) Creates a set of initial sizes for all the elements in a population
  *  2) Stores the sizes as an array of floats independently of the colony object so they can be reused in successive colonies
  *  3) The floats are pulled out of the array sequentially as the Colony is populated in the constructor
  */

  // VARIABLES
  float[] seedsize;  // 'seedsize' is an array of floats used for storing the initial sizes of all the elements in colony.population
  float sizeMin, sizeMax;
  
  // Constructor (makes a Sizes object)
  Sizes() {
    seedsize = new float[elements];  // Array size matches the size of the population
    sizeMin = 0.5;
    sizeMax = 2.0;
  }
  
  // Populates the seedsize array in a cartesian grid layout
  void randomSize() {
    for(int element = 0; element<elements; element++) {
      float size = random(sizeMin, sizeMax);
      //println("Writing to seedsize[" + element + "]  with values size=" + size);
      seedsize[element] = size;
    }
  }

}