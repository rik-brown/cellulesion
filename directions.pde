class Directions {
  /* The Directions class does the following:
  *  1) Creates an array of intLists, one for each cell
  *  2) The intList contains a series of integer values, used by the cell to select a direction (or change of direction) at a given interval
  *  3) The planned implementation will use the values 1, 0, -1 where:
  *    +1 means "rotate by a given angle * +1"
  *     0 means "rotate by a given angle *  0"
  *    -1 means "rotate by a given angle * -1"
  *
  *  Made with help from this recommendation: https://forum.processing.org/two/discussion/4453/is-it-possible-to-make-an-array-of-arrays-with-intlist
  */

  // VARIABLES
  IntList[] dirArray;
  IntList dirList; 
  int numSteps;
  
  // Constructor (makes a Directions object)
  Directions() {
    dirArray = new IntList[elements]; // Create the array where size matches the size of the population
    numSteps = 5; //<>//
    for(int element=0; element<elements; element++) {
      // for each element, make an IntList & add it to the array
      dirList = dirArray[element] = new IntList();  // Create a new IntList inside the array at position [element]
      for (int step=0; step<numSteps; step++) {
        int dirValue = step; // Get a direction value
        int dirValue = int(random(2))-1;
        dirList.append(dirValue); // Add the value to the IntList
      }
      if (random(1) > 0.5) {dirList.shuffle();}
    }
  }
  
  // Populates the directions array with identical values
  void testDir() {
    
  }

}
