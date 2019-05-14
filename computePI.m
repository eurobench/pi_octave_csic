%function result = computePI(csv_file, anthro_file)

    csv_file = "../sample_data/pi_csic/data/subject10/subject_10_trial_01.csv";
    anthro_file = "../sample_data/pi_csic/data/subject10/subject_10_anthropometry.yaml";

    disp(["Input parameters: ", csv_file, " ", anthro_file])
    isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;

    if isOctave
        disp('Using Octave')
        pkg load signal
        pkg load mapping
        pkg load statistics
    else
        disp('Using Matlab')
    end

    % get the scv data

    angles = csv2cell(csv_file);
    header = angles(1, :);
    angles = cell2mat(angles(2:end, :));
    angles(1, :)

    display("segment the trial")
    segmentData = segment_gait(angles);

    display("Calculate the event")

    eventData = calculate_events(segmentData);

    display("Compute SpatioTemporal information")

    % First, estimate the frequency
    delta_t = diff(angles(:, 1));
    frequency = 1.0/mean(delta_t);
    % read anthropomorphic data
    anthropomorphic_data = read_simple_yaml(anthro_file)

    sp_data = calculate_spatiotemporal(anthropomorphic_data, frequency, angles, eventData);
%end