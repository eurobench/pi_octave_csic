## PI CSIC

The current documentation is a copy-paste of an email description.

Here I attach a [drive link][drive_link] to our Matlab algorithm to obtain some spatiotemporal data (step length, step and stride time) for human gait.

[drive_link]: https://drive.google.com/file/d/1MkoTb8KmQFJ2ReeoejvMpYuTjFyTbwwf/view?usp=sharing


I send the main algorithm (Main.m) that uses four functions (listed below) to calculate pre-processed data in order to obtain the desired spatiotemporals:

- find_leg_extension.m
- segment_gait.m
- calculate_events.m
- calculate_spatiotemporal.m

I also attach the raw and pre-processed data obtained from the experiment into a .mat file (Data02_09.mat).

## Experimental Protocol Description

We analysed 61 healthy subjects in this experiment.  We captured motion with an inertial sensor system and carried out three trials (runs) of flat ground walking and turning for each one. All of this raw data is available in Data02_09.mat, which contains a data matrix named experimentalData. It has the following raw data:

- Relative angles of the inertial sensors (experimentalData.subjectX.data.angles.meters15.untilTurnTrials.TrialX)
- Quaternions (experimentalData.subjectX.data.quaternions.meters15.raw)
- Anthropometric data of the subject (experimentalData.subjectX.data.anthropometry):
 - Shank,Thigh, Arm, Trunk, Foot
- Sampling frequency: 50 Hz


## FUNCTIONS

**find_leg_extension.m**

This function detects each leg extension as the minimum after each peak in the angle of the knee.

It returns a matrix, where the first row contains the angle at leg extension (a negative angle in this case), and the second row will contain the indeces where the leg extension occurs.

**segment_gait.m**

This function segments the gait cycle using the leg extension. To do that:
- As an input, it takes the data matrix experimentalData
- It calls the function find_leg_extension (explained above)
- It saves each segment in:

experimentalData.subjectX.data.angles.meters15.untilTurnTrials.segments.Xleg.trialX.segmentX

**calculate_events.m**

In this function we are simply saving the beginning of each stride (segment) in another part of the structure, and we are saving it as the heel strike.

Since we used the leg extension to mark the beginning of each stide, this will coincide with the heel strike.

**calculate_spatiotemporal.m**

This function:

- Calculates the stride and the step time using the Heel Strike (obtained in calculate_events.m; above explained).
- Uses these pre-processed parameters to obtain the step length.
- As a bonus: it also takes the angles measured by the inertial sensors to calculate the joint positions.
- It makes a representation. (I also attach an .eps example)