# cellulesion
Cells with reverse noise, or 'Circulesion goes OOPs'

# Abstract
Cellulesion is a processing sketch which generates visual output in the form of still and/or moving images.
Still images are 'long exposures' documenting the movements and transformations of a set of 2D primitive shapes during a predefined number of frames.
Moving images are assmebled from a consecutive sequences of stills whose initial conditions vary between each cycle according to a predefined rule.
The algorithms responsible for the dynamic elements of the image are described in more detail below.
Compositional control consists of defining initial & final values for key control variables (e.g. position, colour, size etc.)

# Introduction

I guess there are two main goals to this work.
The first is at the tool/framework level:

For a given set of initial conditions, I want to be able to produce (or reproduce):
1) a single still image (at various resolutions)
2) a sequence of stills following a series of changing initial conditions
3) a video following a series of changing initial conditions (either linear or looping)
4) A logfile documenting all initial conditions (including noise seed) (for reproducibility)

The still images in 1), 2) and the individual video frames in 3) are themselves the result of a sequence of drawing iterations. Shapes are arranged on the canvas, then new shapes are added on top, with no refresh inbetween. The gradual change of position, shape, size, orientation, colour and transparency as the layers accumulate is what gives rise to the forms and patterns in the resulting image. The second goal is therefore to control and modulate these changes in an interesting way, both within one 'timelapse' sequence/image, and across 300 successive timelapses resulting in a 10 second 30fps video.

* A single draw cycle (where the positions, shapes, colours etc. of all drawn elements are updated) is counted as a one 'generation'
* The sequence of generations resulting in one timelapse image is called an 'epoch' (duration variable 'generations')
* The sequence of epochs resulting in one video does not have a name (duration variable 'epochs')

The main part of the code deals with coordinating these sequences within sequences.

# How do the patterns arise?

There are two forerunners to this project:
1) Cellendipity - where 'cell' objects move across the canvas by a composite of 3 velocity functions, one of which is a noise vector.
2) Palloise/circulesion - where static elements on the canvas change shape, size, colour etc. according to cyclic transformations in noise fields.

In this sketch, I initially wanted to combine the cyclic 'looping' noise with movement. My first step was to convert the drawn elements into a 'population' of 'cell' objects (borrowing from cellendipity ). However, once I gave the cells velocity, I realised that their individual pathways across the canvas could provide a more interesting source for variation in noise values compared to the 'circular looping paths' used in circulesion. Since all the cells would be moving across the same 2D 'noisefields', their patterns of movement should all be similar, but varying across the canvas in accordance with the current noise scale. In other words; each cell's position on the canvas is mapped to a corresponding position on a scaled 2D noisefield. 3 seperate noisefields are used, providing 3 seperate noise values for each cell at any given position. Among other things, current noise values influence the velocity vector, giving rise to a new position in the next cycle, and a new set of noise values. Repeat until the end of the epoch then store the resulting image.

The characteristics of the distribution of values across the noisefields depend on scaling factors which may also change as the drawing proceeds. I tried a short experiment using the mouse position to dynamically vary the scaling, trying locate some 'sweet spots' - values that gave a good balance between variety and harmony. Being quite pleased with results, it occurred to me that the position of a cell moving across the canvas could equally be used to 'feedback' into the noise calculations. This led to the 'chosenOne' being a randomly selected individual cell from the population, later extended to 'chosenTwo' and 'chosenThree' - one for each noisefield.

I believe the key to making 'interesting' images lies in the patterns of variance between the three noise values. These patterns arise due to simple differences in OFFSET (a combination of the cell position + an offset variable) and SCALE. Also important is how the noise values are expressed through the 'phenotype' of the cell - how they govern it's shape, size, colour & movement.

In order to produce a flow of changing images through a sequence of epochs, some initial conditions must vary incrementally whilst others reset to the original values. 'EpochDrivers' are typically epoch number (from 1 to total nr. of epochs) mapped to an angle (e.g. from PI to 3*PI) from which a SIN or COS is calculated. The resulting value in range -1 to 1 is in turn mapped to the required range for the variable to be modulated (e.g. noise scaling factor, number of generations in an epoch etc.)

# Attempting to describe what happens when the code is executed:
1) An array of 'starting position' vectors is populated according to the desired pattern (these are reused at the start of each epoch)
2) 'chosenOnes' for position feedback are selected (either at random or from predefined values)
3) Values used in all relevant variables are written to a logfile
4) 
5) 



Initial position of the drawn elements may be in a controlled, regular pattern (e.g. grid) or random

