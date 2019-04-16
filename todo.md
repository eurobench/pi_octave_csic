**Needed code evolution**

**Distinguish input-output**

Generated data are placed in the same structure as the input data.
This does not help in storing the experimental PI later on.

We propose to generate in another structure all results.

Open questions: Are all the result PI outcomes, or are some results intermediary information that does not need to be kept (i.e. saved)

**All user data in common structure**

The experiment consist of N subjects, each of them has repeated M times the protocol.

The code assume all the information is gathered into a single structure.
On a logisitc point of view, it would be better having the data split, in case there is a need to make things parallel.
Also it enables distinguishing:

* what is computed from a single run
* what is computed across runs.

I would thus suggest splitting the input data as follows:

* use csv file as a starting point
* use a filename-based organization of the experiment: `userX_runX_input.csv`

**Figure plotting**

The front-end is likely to provide visualizations of the PI.
The current code is also generating some figures.
As the processing will be done in batch, the creation of the figure is questionnable.

Open question:

* would it makes sense to store with the PI a set of figures (with an image format), that could be displayed for the user (as is), together with some general image description?


