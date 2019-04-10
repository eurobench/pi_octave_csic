%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% find_local_minima.m 
% 
% Segments the gait cycle using the leg extension 
%
% Jose Gonzalez-Vargas
% v0.1 2016/08/08
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = segment_gait(data, sub_num)

h = figure('Name','Segmentation','NumberTitle','off');
set(h,'units','normalized','outerposition',[0 0 1 1]);
%sgtitle('Angles until the turn. Meters15 test, three trials, with each stride marked', 'fontSize',18,'fontWeight','bold')
% set the color of the plot: trial1=red, trial2=green, trial3=blue
color='bgr';

%% segment the data for the 15 meters
% if sub_num == 28
%     num_trial = 2;
% else 
%     num_trial = 3;
%     
% end
num_trial = 3;

%We loop from 1 to 3, segmenting the strides of every trial.
    for i = 1:num_trial
        
        varname = strcat('trial',int2str(i));
        segment_trial= strcat('Trial ',int2str(i));
        
        % segment using the right leg
        % We prepare the plot where we will plot the segmented trial
        segment_element='Right Knee';
        subplot(2,3,i)
        title(strcat(segment_trial),'fontSize',18,'fontWeight','bold');
        if i==1
            ylabel (segment_element,'fontSize',18,'fontWeight','bold');
        end
        % find_leg_extension finds the mimnima after each peak in the angle
        % funcition of the right knee. Each minima corresponds to a leg
        % extension. find_leg_extension returns a matrix, where the first row contains the angle
        % at leg extension (a negative angle in this case), and the second
        %row will contain the indeces where the leg extension occurs.
        %find_leg_extension also plots the angle for every trial, the
        %threshold use to find the peaks, and each leg extension.
        segments = find_leg_extension(data.angles.meters15.untilTurnTrials.(varname)(:,5),color(i)); % Column 5 corresponds to right knee angle in the angle .capa file
        
        %Now, in data we save the segments. Each segment is one step with
        %the right leg
        for j = 1:length(segments)-1
            segmentName = strcat('segment',int2str(j));
            data.angles.meters15.untilTurnTrials.segments.rightleg.(varname).(segmentName) = ...
                data.angles.meters15.untilTurnTrials.(varname)(segments(2,j):segments(2,j+1),:);
        end

        
        
        % segment using the left leg. It is basically the same process than
        % with the right leg
        
        segment_element='Left Knee';
        subplot(2,3,i+3)
        segments = find_leg_extension(data.angles.meters15.untilTurnTrials.(varname)(:,14),color(i)); % Column 14 corresponds to left knee angle in the angle .capa file
        if i==1
            ylabel (segment_element,'fontSize',18,'fontWeight','bold');
        end

        for j = 1:length(segments)-1
            segmentName = strcat('segment',int2str(j));
            data.angles.meters15.untilTurnTrials.segments.leftleg.(varname).(segmentName) = ...
                data.angles.meters15.untilTurnTrials.(varname)(segments(2,j):segments(2,j+1),:);
        end
    end
end
