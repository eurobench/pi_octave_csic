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
allAngles = subjectAllData.data.angles.meters15.untilTurnTrials;
frequency = subjectAllData.data.frequency;

nTrial = 3;

%% segment gait cycle
% segment gait for 15 meters. We find each step with the right and left
% leg using the knee extension. Then, we save the segments in the structure
% data.

display("segment the trials")

for i = 1:nTrial
    iTrial = strcat('trial',int2str(i));
    angles = allAngles.(iTrial);
    segmentData.(iTrial) = segment_gait(angles);
end

%% identify events: heel strike (HS), etc...
%In the function calculate_events,we are simply saving the beginning of each stride
%(segment) in another part of the structure, and we are saving it
%as the heel strike. Since we used the leg extension to mark the
%beginning of each stide, this will coincide with the heel strike.

display("Calculate the events")

for i = 1:nTrial
    iTrial = strcat('trial',int2str(i));
    allEventData.(iTrial) = calculate_events(segmentData.(iTrial));
end


%% calculate spatiotemporal parameters. This function calculates:
%   Stride time (left and right legs): mean, STD, CoV
%   Step time (left and right legs): mean, STD, CoV
%   Step Lenght (left and right legs): mean, STD, CoV
%   Note: These parameters are only calculated with the strides until the
%   patient reaches the turn

display("Compute spatiotemporal information")

for i = 1:nTrial
    iTrial = strcat('trial',int2str(i));
    angles = allAngles.(iTrial);
    eventData = allEventData.(iTrial);
    sp_data.(iTrial) = calculate_spatiotemporal(subjectData, frequency, angles, eventData);
end

display("Store results")

for i = 1:nTrial

    iTrial = strcat('trial',int2str(i));

    filename = strcat("pi_stride_time_right_subject_", int2str(subNum), "_trial_", int2str(i), ".txt");
    dlmwrite(filename, sp_data.(iTrial).strideTime.rightleg.data, 'delimiter', ' ');
    filename = strcat("pi_stride_time_left_subject_", int2str(subNum), "_trial_", int2str(i), ".txt");
    dlmwrite(filename, sp_data.(iTrial).strideTime.leftleg.data, 'delimiter', ' ');

    filename = strcat("pi_step_time_right_subject_", int2str(subNum), "_trial_", int2str(i), ".txt");
    dlmwrite(filename, sp_data.(iTrial).stepTime.rightleg.data, 'delimiter', ' ');
    filename = strcat("pi_step_time_left_subject_", int2str(subNum), "_trial_", int2str(i), ".txt");
    dlmwrite(filename, sp_data.(iTrial).stepTime.leftleg.data, 'delimiter', ' ');

    filename = strcat("pi_step_length_right_subject_", int2str(subNum), "_trial_", int2str(i), ".txt");
    dlmwrite(filename, sp_data.(iTrial).stepLength.rightleg.data, 'delimiter', ' ');
    filename = strcat("pi_step_length_left_subject_", int2str(subNum), "_trial_", int2str(i), ".txt");
    dlmwrite(filename, sp_data.(iTrial).stepLength.leftleg.data, 'delimiter', ' ');
end

display("Generate metric across trials")
display("This may be taken out in further version")
%% Generate metric across trials
strideTime_3trials_r = [];
strideTime_3trials_l = [];
stepTime_3trials_r = [];
stepTime_3trials_l = [];
stepLength_3trials_r = [];
stepLength_3trials_l = [];

for i = 1:nTrial
    iTrial = strcat('trial',int2str(i));

    strideTime_3trials_r = [strideTime_3trials_r sp_data.(iTrial).('strideTime').('rightleg').data];
    strideTime_3trials_l = [strideTime_3trials_l sp_data.(iTrial).('strideTime').('leftleg').data];
    stepTime_3trials_r = [stepTime_3trials_r sp_data.(iTrial).('stepTime').('rightleg').data];
    stepTime_3trials_l = [stepTime_3trials_l sp_data.(iTrial).('stepTime').('leftleg').data];
    stepLength_3trials_r = [stepLength_3trials_r sp_data.(iTrial).('stepLength').rightleg.data];
    stepLength_3trials_l = [stepLength_3trials_l sp_data.(iTrial).('stepLength').leftleg.data];

    sT_r(i) = length(strideTime_3trials_r);
    sT_l(i) = length(strideTime_3trials_l);
    ST_r(i) = length(stepTime_3trials_r);
    ST_l(i) = length(stepTime_3trials_l);
    SL_r(i) = length(stepLength_3trials_r);
    SL_l(i) = length(stepLength_3trials_l);
end

% we are only interested in the two last experiments for calculating the mean
% so that we focus the computation on the data coming from the two last values

sp_data.strideTime.rightleg.('mean') = mean (strideTime_3trials_r(1,sT_r(1)+1:end));
sp_data.strideTime.rightleg.('std') = std (strideTime_3trials_r(1,sT_r(1)+1:end));
sp_data.strideTime.rightleg.varCoeff = (std (strideTime_3trials_r(1,sT_r(1)+1:end)))/(mean (strideTime_3trials_r(1,sT_r(1)+1:end)));

sp_data.strideTime.leftleg.('mean')= mean (strideTime_3trials_l(1,sT_l(1)+1:end));
sp_data.strideTime.leftleg.('std') = std (strideTime_3trials_l(1,sT_l(1)+1:end));
sp_data.strideTime.leftleg.varCoeff = (std (strideTime_3trials_l(1,sT_l(1)+1:end)))/(mean (strideTime_3trials_l(1,sT_l(1)+1:end)));

sp_data.stepTime.rightleg.('mean') = mean (stepTime_3trials_r(1,ST_r(1)+1:end));
sp_data.stepTime.rightleg.('std') = std (stepTime_3trials_r(1,ST_r(1)+1:end));
sp_data.stepTime.rightleg.varCoeff = (std (stepTime_3trials_r(1,ST_r(1)+1:end)))/(mean (stepTime_3trials_r(1,ST_r(1)+1:end)));

sp_data.stepTime.leftleg.('mean') = mean (stepTime_3trials_l(1,ST_l(1)+1:end));
sp_data.stepTime.leftleg.('std') = std (stepTime_3trials_l(1,ST_l(1)+1:end));
sp_data.stepTime.leftleg.varCoeff = (std (stepTime_3trials_l(1,ST_l(1)+1:end)))/(mean (stepTime_3trials_l(1,ST_l(1)+1:end)));

sp_data.stepLength.rightleg.('mean') = mean (stepLength_3trials_r(1,SL_r(1)+1:end));
sp_data.stepLength.rightleg.('std') = std (stepLength_3trials_r(1,SL_r(1)+1:end));
sp_data.stepLength.rightleg.varCoeff = (std (stepLength_3trials_r(1,SL_r(1)+1:end)))/(mean (stepLength_3trials_r(1,SL_r(1)+1:end)));

sp_data.stepLength.leftleg.('mean') = mean (stepLength_3trials_l(1,SL_l(1)+1:end));
sp_data.stepLength.leftleg.('std') = std (stepLength_3trials_l(1,SL_l(1)+1:end));
sp_data.stepLength.leftleg.varCoeff = (std (stepLength_3trials_l(1,SL_l(1)+1:end)))/(mean (stepLength_3trials_l(1,SL_l(1)+1:end)));


display("Store global variable (to be done)");

display("End of the process")