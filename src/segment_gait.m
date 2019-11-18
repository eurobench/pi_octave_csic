%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% find_local_minima.m
%
% Segments the gait cycle using the leg extension
%
% Jose Gonzalez-Vargas
% v0.1 2016/08/08
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function segment_data = segment_gait(angles, header)

    % segment using the right leg

    % find_leg_extension finds the mimnima after each peak in the angle
    % funcition of the right knee. Each minima corresponds to a leg
    % extension. find_leg_extension returns a matrix, where the first row contains the angle
    % at leg extension (a negative angle in this case), and the second
    %row will contain the indeces where the leg extension occurs.
    %find_leg_extension also plots the angle for every trial, the
    %threshold use to find the peaks, and each leg extension.

    col_r_knee_z = find(strcmp(header, 'r_knee_z'));
    [segments_right threshold_right] = find_leg_extension(angles(:, col_r_knee_z));

    %Now, in data we save the segments. Each segment is one step with
    %the right leg
    for j = 1:length(segments_right) - 1
        segmentName = strcat('segment', int2str(j));
        segment_data.rightleg.(segmentName) = angles(segments_right(2, j):segments_right(2, j + 1),:);
    end

    % segment using the left leg. It is basically the same process than
    % with the right leg

    segment_element='Left Knee';

    col_l_knee_z = find(strcmp(header, 'l_knee_z'))
    [segments_left threshold_left] = find_leg_extension(angles(:, col_l_knee_z));

    for j = 1:length(segments_left) - 1
        segmentName = strcat('segment', int2str(j));
        segment_data.leftleg.(segmentName) = angles(segments_left(2, j):segments_left(2, j + 1),:);
    end
end
