class Directions {
  /* The Directions class does the following:
  *  1) Creates an array of intLists, one for each cell
  *  2) The intList contains a series of integer values, used by the cell to select a direction (or change of direction) at a given interval
  *  3) The planned implementation will use the values 1, 0, -1 where:
  *    +1 means "rotate by a given angle * +1"
  *     0 means "rotate by a given angle *  0"
  *    -1 means "rotate by a given angle * -1"
  */

  // VARIABLES
  IntList [] directions;
  Intlist dirList; 
  int numSteps = 3; // Number of different values in each IntList
  
  // Constructor (makes a Directions object)
  Directions() {
    directions = new IntList [elements]; // Array size matches the size of the population
  
  
  }
  
  // Populates the directions array with identical values
  void testDir() {
    for(int element=0; element<elements; element++) {
      // for each element, make an IntList & add it to the array
      dirList = directions[element] = new IntList();  // Create a new IntList
      for (int step=0; step<numSteps; step++) {
        int dirValue = 1; // Get a direction value
        dirList.append(dirValue); // Add the value to the IntList
      }
      // Will this work? Based on this recommendation: https://forum.processing.org/two/discussion/4453/is-it-possible-to-make-an-array-of-arrays-with-intlist
    }
  }

}
