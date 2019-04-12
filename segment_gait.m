%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% find_local_minima.m
%
% Segments the gait cycle using the leg extension
%
% Jose Gonzalez-Vargas
% v0.1 2016/08/08
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function segment_data = segment_gait(data, isBatch)

    num_trial = 3;

    %We loop from 1 to 3, segmenting the strides of every trial.
    for i = 1:num_trial

        trial_name = strcat('trial',int2str(i));
        segment_trial= strcat('Trial ',int2str(i));

        % segment using the right leg
        % We prepare the plot where we will plot the segmented trial
        segment_element='Right Knee';
        % subplot(2,3,i)
        % title(strcat(segment_trial),'fontSize',18,'fontWeight','bold');
        % if i==1
        %     ylabel (segment_element,'fontSize',18,'fontWeight','bold');
        % end
        % find_leg_extension finds the mimnima after each peak in the angle
        % funcition of the right knee. Each minima corresponds to a leg
        % extension. find_leg_extension returns a matrix, where the first row contains the angle
        % at leg extension (a negative angle in this case), and the second
        %row will contain the indeces where the leg extension occurs.
        %find_leg_extension also plots the angle for every trial, the
        %threshold use to find the peaks, and each leg extension.
        [segments_right threshold_right] = find_leg_extension(data.(trial_name)(:,5),'b'); % Column 5 corresponds to right knee angle in the angle .capa file

        %Now, in data we save the segments. Each segment is one step with
        %the right leg
        for j = 1:length(segments_right)-1
            segmentName = strcat('segment',int2str(j));
            segment_data.rightleg.(trial_name).(segmentName) = data.(trial_name)(segments_right(2,j):segments_right(2,j+1),:);
        end

        % segment using the left leg. It is basically the same process than
        % with the right leg

        segment_element='Left Knee';
        %subplot(2,3,i+3)
        [segments_left threshold_left] = find_leg_extension(data.(trial_name)(:,14),'b'); % Column 14 corresponds to left knee angle in the angle .capa file
        % if i==1
        %     ylabel (segment_element,'fontSize',18,'fontWeight','bold');
        % end

        for j = 1:length(segments_left)-1
            segmentName = strcat('segment',int2str(j));
            segment_data.leftleg.(trial_name).(segmentName) = data.(trial_name)(segments_left(2,j):segments_left(2,j+1),:);
        end
    end

    if ~isBatch
        h = figure('Name','Segmentation','NumberTitle','off');
        set(h,'units','normalized','outerposition',[0 0 1 1]);

        %sgtitle('Angles until the turn. Meters15 test, three trials, with each stride marked', 'fontSize',18,'fontWeight','bold')
        % set the color of the plot: trial1=red, trial2=green, trial3=blue
        color='bgr';

        for i = 1:num_trial
            trial_name = strcat('trial',int2str(i));
            segment_trial = strcat('Trial ',int2str(i));
            segment_element = 'Right Knee';

            subplot(2,3,i)

            title(strcat(segment_trial),'fontSize',18,'fontWeight','bold');
            if i == 1
                ylabel (segment_element,'fontSize',18,'fontWeight','bold');
            end

            hold on
            xlim=[1 length(data.(trial_name)(:,5))];
            plot(data.(trial_name)(:,5),color(i));
            plot(segments_right(2,:), segments_right(1,:), '*r');
            plot(xlim,[threshold_right threshold_right],':k','LineWidth',1)
            hold off

            segment_element='Left Knee';
            subplot(2,3,i+3)
            if i==1
                ylabel (segment_element,'fontSize',18,'fontWeight','bold');
            end

            hold on
            xlim=[1 length(data.(trial_name)(:, 14))];
            plot(data.(trial_name)(:, 14),color(i));
            plot(segments_left(2,:), segments_left(1,:), '*r');
            plot(xlim,[threshold_left threshold_left],':k','LineWidth',1)
            hold off
        end
    end
end
