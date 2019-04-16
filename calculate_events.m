%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate_event.m
%
% TODO
%
% Author to be defined
% creation date to be defined
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function event_data = calculate_events(segment_data, nTrial)

    for i = 1:nTrial
        name_trial = strcat('trial',int2str(i));
        %We find the number of strides with the right leg
        n_segments_right=length(fieldnames(segment_data.rightleg.(name_trial)));

        %In this two fors,we are simply saving the beginning of each stride
        %(segment) in another part of the structure, and we are saving it
        %as the heel strike. Since we used the leg extension to mark the
        %beginning of each stide, this willcoincide with the heel strike.
        for j = 1:n_segments_right
            segmentName = strcat('segment',int2str(j));
            event_data.('heelstrike').('rightleg').(name_trial)(1,j)=...
                segment_data.rightleg.(name_trial).(segmentName)(1,1);
        end

        n_segments_left=length(fieldnames(segment_data.leftleg.(name_trial)));
        for j = 1:n_segments_left
            segmentName = strcat('segment',int2str(j));
            event_data.('heelstrike').('leftleg').(name_trial)(1,j)=...
                segment_data.leftleg.(name_trial).(segmentName)(1,1);
        end
    end
end

