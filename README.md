# PI CSIC

## Current usage

The original entry point `Main.m` is deprecated, and left for having trace of the metric process across trials.

The current entry point is [computePI.m](computePI.m).
Assuming we have in `../sample_data` the repository [sample_data](https://git.code.tecnalia.com/eurobench/sample_data), then a typical command would be:

```octave
computePI("../sample_data/pi_csic/data/subject10/subject_10_trial_01.csv", "../sample_data/pi_csic/data/subject10/subject_10_anthropometry.yaml")
```

The two parameters expected are:

- `motion_capture.csv`: a `csv` file containing the joint angles recorded, assuming the first column ia a timestamp in second.
- `anthropometry.yaml`: yaml file containing anthropometric data related to the subject.

The current code is to be launched **per trial**.
There is no intertrial computation for the moment.

## Initial code structure

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

### ```find_leg_extension.m```

This function detects each leg extension as the minimum after each peak in the angle of the knee.

It returns a matrix, where the first row contains the angle at leg extension (a negative angle in this case), and the second row will contain the indeces where the leg extension occurs.

### ```segment_gait.m```

This function segments the gait cycle using the leg extension. To do that:

- As an input, it takes the data matrix experimentalData
- It calls the function find_leg_extension (explained above)
- It saves each segment in:

experimentalData.subjectX.data.angles.meters15.untilTurnTrials.segments.Xleg.trialX.segmentX

### ```calculate_events.m```

In this function we are simply saving the beginning of each stride (segment) in another part of the structure, and we are saving it as the heel strike.

Since we used the leg extension to mark the beginning of each stide, this will coincide with the heel strike.

### ```calculate_spatiotemporal.m```

This function:

- Calculates the stride and the step time using the Heel Strike (obtained in calculate_events.m; above explained).
- Uses these pre-processed parameters to obtain the step length.
- As a bonus: it also takes the angles measured by the inertial sensors to calculate the joint positions.
- It makes a representation. (I also attach an .eps example)

## Octave commands

To enable the code under octave, additional packages are needed.

```console
sudo apt-get install liboctave-dev
```

Follow [these recommandations](https://octave.org/doc/v4.2.1/Installing-and-Removing-Packages.html) to make the installation of the additional packages needed:

- [control](https://octave.sourceforge.io/control/index.html)
- [signal](https://octave.sourceforge.io/signal/index.html)
- [mapping](https://octave.sourceforge.io/mapping/index.html)
- [io](https://octave.sourceforge.io/io/index.html)
- [statistics](https://octave.sourceforge.io/statistics/index.html)

Once octave is configured:

```console
pkg load signal
pkg load mapping
pkg load statistics
Main
```

## Executable script

Another script has been added (pi_csic.m) in order to launch this PI from the shell of a machine with octave installed. The permissions of this file must be changed in order to be executable:

```
chmod 755 pi_csic.m
```

The way of calling this PI from the shell is the following one:

```
./calling_script.m ../sample_data/pi_csic/data/subject10/subject_10_trial_01.csv ../sample_data/pi_csic/data/subject10/subject_10_anthropometry.yaml
```

At this momment the script accepts two arguments (not less, not more).

## Build docker image

Run the following command in order to create the docker image for this PI:

```
docker built . -t pis_csic_docker_image
```
