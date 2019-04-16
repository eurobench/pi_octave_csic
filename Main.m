%%Additional command to get it working

isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;

if isOctave
    disp('Using Octave')
    pkg load signal
    pkg load mapping
    pkg load statistics
else
    disp('Using Matlab')
end

disp('Loading data')
allData = load('Data02_09.mat');
disp('data loaded')

subNum = 10;

%% extracting the data from the subject
subjectField = strcat('subject', int2str(subNum));
subjectAllData = getfield(allData.experimentalData, subjectField);

subjectData = subjectAllData.data.anthropometry;
angles = subjectAllData.data.angles.meters15.untilTurnTrials;
frequency = subjectAllData.data.frequency;

isBatch = false;
nTrial = 3

%% segment gait cycle
% segment gait for 15 meters. We find each step with the right and left
% leg using the knee extension. Then, we save the segments in the structure
% data.

segmentData = segment_gait(angles, nTrial, isBatch);

%Now we plot the angles of during each stride for every joint, for the
%three trials, using the right and left leg strides
%plot_segments(data.angles.meters15.untilTurnTrials, sub_num);

%% Plot all segmented trials
%We plot all the angles for every stride, but we plot the angles of the
%right side items using the right side strides, and the left side items
%using the left side strides

%plotAllSegmentedTrials( data ,sub_num);

%% identify events: heel strike (HS), etc...
%In the function calculate_events,we are simply saving the beginning of each stride
%(segment) in another part of the structure, and we are saving it
%as the heel strike. Since we used the leg extension to mark the
%beginning of each stide, this will coincide with the heel strike.

eventData = calculate_events(segmentData, nTrial);

%% calculate spatiotemporal parameters. This function calculates:
%   Stride time (left and right legs): mean, STD, CoV
%   Step time (left and right legs): mean, STD, CoV
%   Step Lenght (left and right legs): mean, STD, CoV
%   Note: These parameters are only calculated with the strides until the
%   patient reaches the turn
sp_data = calculate_spatiotemporal(subjectData, frequency, angles, eventData, nTrial, isBatch);