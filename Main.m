%%Additional command to get it working

all_data = load('Data02_09.mat');
sub_num = 10;

%% extracting the data from the subject
subject_field=strcat('subject',int2str(10));

subject_data = getfield(all_data.experimentalData, subject_field);
subject_data = subject_data.data

%% segment gait cycle
% segment gait for 15 meters. We find each step with the right and left
% leg using the knee extension. Then, we save the segments in the structure
% data.

subject_data = segment_gait(subject_data,sub_num);


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

subject_data = calculate_events(subject_data,sub_num);

%% calculate spatiotemporal parameters. This function calculates:
%   Stride time (left and right legs): mean, STD, CoV
%   Step time (left and right legs): mean, STD, CoV
%   Step Lenght (left and right legs): mean, STD, CoV
%   Note: These parameters are only calculated with the strides until the
%   patient reaches the turn
subject_data = calculate_spatiotemporal(subject_data,sub_num);

