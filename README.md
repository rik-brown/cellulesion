# cellulesion
Circulesion goes OOPs

Introduction

I guess there are two main goals to this work.
The first is at the tool/framework level: 
For a given set of initial conditions, I want to be able to produce (or reproduce):
1) a single still image (at various resolutions)
2) a sequence of stills following a series of changing initial conditions
3) a video following a series of changing initial conditions (either linear or looping)
4) A logfile documenting all initial conditions (including noise seed) (for reproducibility)

The still images in 1), 2) and the individual video frames in 3) are themselves the result of a sequence of drawing iterations. Shapes are arranged on the canvas, then new shapes are added on top, with no refresh inbetween. The gradual change of position, shape, size, orientation, colour and transparency as the layers accumulate is what gives rise to the forms and patterns in the resulting image. The second goal is therefore to control and modulate these changes in an interesting way, both within one 'timelapse' sequence/image, and across 300 successive timelapses resulting in a 10 second 30fps video.
