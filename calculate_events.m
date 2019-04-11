function data = calculate_events(data, sub_num)

% if sub_num == 28
%     num_trial = 2;
% else
%     num_trial = 3;
% end

num_trial = 3;

    for i = 1:num_trial
        varname = strcat('trial',int2str(i));
        n_segments_right=length(fieldnames(data.angles.meters15.untilTurnTrials.segments.rightleg.(varname)));%We find the number of strides with the right leg

        %In this two fors,we are simply saving the beginning of each stride
        %(segment) in another part of the structure, and we are saving it
        %as the heel strike. Since we used the leg extension to mark the
        %beginning of each stide, this willcoincide with the heel strike.
        for j = 1:n_segments_right
            segmentName = strcat('segment',int2str(j));
            data.angles.meters15.untilTurnTrials.('events').('heelstrike').('rightleg').(varname)(1,j)=...
                data.angles.meters15.untilTurnTrials.segments.rightleg.(varname).(segmentName)(1,1);
        end

        n_segments_left=length(fieldnames(data.angles.meters15.untilTurnTrials.segments.leftleg.(varname)));
        for j = 1:n_segments_left
            segmentName = strcat('segment',int2str(j));
            data.angles.meters15.untilTurnTrials.('events').('heelstrike').('leftleg').(varname)(1,j)=...
                data.angles.meters15.untilTurnTrials.segments.leftleg.(varname).(segmentName)(1,1);
        end


    end


end

