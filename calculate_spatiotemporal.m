%% Consider only the second and third trials in the calculation of parameters

function sp_data = calculate_spatiotemporal (subject_data, frequency, angles_data, event_data, isBatch)

    strideTime_3trials_r=[];
    strideTime_3trials_l=[];
    stepTime_3trials_r =[];
    stepTime_3trials_l=[];
    stepLength_3trials_r=[];
    stepLength_3trials_l=[];

    shank = subject_data.shank;
    thigh = subject_data.thigh;
    trunk = subject_data.trunk;
    foot = subject_data.foot;
    % foot = 15;

    if ~isBatch
        color='bgr';
        h = figure('Name','Foot-foot distance','NumberTitle','off');
        set(h,'units','normalized','outerposition',[0 0 1 1]);
    end

    num_trial = 3;

    for trial = 1:num_trial
        trialName = strcat('trial',int2str(trial));

        %% calculate stride time and step time
        HS_right = event_data.heelstrike.rightleg.(trialName);
        HS_left = event_data.heelstrike.leftleg.(trialName);

        % stride time, right leg, in seconds
        sp_data.('strideTime').('rightleg').(trialName) = diff(HS_right)/frequency;

        % stride time, left leg, in seconds
        sp_data.('strideTime').('leftleg').(trialName) = diff(HS_left)/frequency;

        % step time (= time from contralateral to ipsilateral HS), in seconds
        step_time_all = diff(sort([HS_right HS_left]))/frequency; % all step times not classified by side

        if HS_left(1) < HS_right(1)
            % first heel strike: left --> first step time: right
            % values in odd position
            sp_data.('stepTime').('rightleg').(trialName) = step_time_all(1:2:end);
            % values in even position
            sp_data.('stepTime').('leftleg').(trialName) = step_time_all(2:2:end);
        else
            % first heel strike: right --> first step time: left
            sp_data.('stepTime').('rightleg').(trialName) = step_time_all(2:2:end);
            sp_data.('stepTime').('leftleg').(trialName) = step_time_all(1:2:end);
        end

        strideTime_3trials_r = [strideTime_3trials_r sp_data.('strideTime').('rightleg').(trialName)];
        strideTime_3trials_l = [strideTime_3trials_l sp_data.('strideTime').('leftleg').(trialName)];
        stepTime_3trials_r = [stepTime_3trials_r sp_data.('stepTime').('rightleg').(trialName)];
        stepTime_3trials_l = [stepTime_3trials_l sp_data.('stepTime').('leftleg').(trialName)];

        % Length
        sT_r(trial) = length(strideTime_3trials_r);
        sT_l(trial) = length(strideTime_3trials_l);
        ST_r(trial) = length(stepTime_3trials_r);
        ST_l(trial) = length(stepTime_3trials_l);

        %% calculate Joint Positions
        HIP_angle_r = angles_data.(trialName)(:,2:4);
        HIP_angle_l = angles_data.(trialName)(:,11:13);
        KNEE_angle_r = angles_data.(trialName)(:,5:7);
        KNEE_angle_l = angles_data.(trialName)(:,14:16);
        ANKLE_angle_r = angles_data.(trialName)(:,8:10);
        ANKLE_angle_l = angles_data.(trialName)(:,17:19);
        WAIST_angle = angles_data.(trialName)(:,20:21);
        pelvis_angle = 10; % reference angle (pelvis) in space. All other segments will be plotted with respect to this.

        first_right_HS = event_data.heelstrike.rightleg.(trialName)(1); % first heel strike of the right leg (taken as time & space reference)
        t = 0;

        feetDist=[];
        knee_r_pos=[];
        ankle_r_pos=[];
        toe_r_pos= [];
        knee_l_pos=[];
        ankle_l_pos=[];
        toe_l_pos= [];

        % i goes from first right heel strike until the end of trial 1
        for i = find(angles_data.(trialName)(:,1)==first_right_HS):size(angles_data.(trialName),1)
            t = t + 1;
            gamma_r = deg2rad(HIP_angle_r(i,1)-pelvis_angle);
            beta_r = deg2rad(KNEE_angle_r(i,1));
            alfa_r = gamma_r - beta_r + deg2rad(ANKLE_angle_r(i,1)); % old: -deg2rad

            knee_r_pos(t, 1:2) = [sin(gamma_r) - cos(gamma_r)] * thigh;
            ankle_r_pos(t, 1:2) = knee_r_pos(t, :) + [sin(gamma_r - beta_r) - cos(gamma_r - beta_r)] * shank;
            toe_r_pos(t, 1:2) = ankle_r_pos(t, :) + [cos(alfa_r) sin(alfa_r)] * foot;

            gamma_l = deg2rad(HIP_angle_l(i,1) - pelvis_angle);
            beta_l = deg2rad(KNEE_angle_l(i, 1));
            alfa_l = gamma_l - beta_l + deg2rad(ANKLE_angle_l(i, 1)); % old: -deg2rad

            knee_l_pos(t, 1:2) = [sin(gamma_l) - cos(gamma_l)] * thigh;
            ankle_l_pos(t, 1:2) = knee_l_pos(t, :) + [sin(gamma_l - beta_l) - cos(gamma_l - beta_l)] * shank;
            toe_l_pos(t, 1:2) = ankle_l_pos(t, :) + [cos(alfa_l) sin(alfa_l)] * foot;

            feetDist(t,1) = angles_data.(trialName)(i,1); % time
            feetDist(t,2) = pdist([toe_r_pos(t,:); toe_l_pos(t,:)],'euclidean');

        end

        %% plot foot-foot distance
        % find peaks of the foot-foot distance (taking away peaks closer than 1/5 stepTime)
        [step_length_rl index] = findpeaks(feetDist(:,2),'MinPeakDistance',floor(mean(stepTime_3trials_r)*frequency/5));
        sp_data.('stepLength').rightleg.(trialName)=step_length_rl(1:2:end)';
        sp_data.('stepLength').leftleg.(trialName)=step_length_rl(2:2:end)';

        if ~isBatch
            subplot(3,1,trial)
            h(1)= plot (feetDist(:,1), feetDist(:,2),color(trial));
            title(['Trial ', num2str(trial)])
            hold on
            h(2)= plot (feetDist(index,1),step_length_rl,['o' color(trial)]); % plot peaks
            for i=1:length(event_data.heelstrike.rightleg.(trialName))
                h(3)= plot ([event_data.heelstrike.rightleg.(trialName)(i),event_data.heelstrike.rightleg.(trialName)(i)],[0,max(feetDist(:,2))],'k');
            end
            for i=1:length(event_data.heelstrike.leftleg.(trialName))
                h(4)= plot ([event_data.heelstrike.leftleg.(trialName)(i),event_data.heelstrike.leftleg.(trialName)(i)],[0,max(feetDist(:,2))],'--k');
            end
            legend (h(1:4),['foot-foot distance'],'peaks','right HS','left HS')
        end

        stepLength_3trials_r=[stepLength_3trials_r sp_data.('stepLength').rightleg.(trialName)];
        stepLength_3trials_l=[stepLength_3trials_l sp_data.('stepLength').leftleg.(trialName)];

        SL_r(trial) = length(stepLength_3trials_r);
        SL_l(trial) = length(stepLength_3trials_l);
    end

    for trial = 1:num_trial
        trialName = strcat('trial',int2str(trial));
        sp_data.stepLength.rightleg.allmeans.(trialName)=mean(sp_data.stepLength.rightleg.(trialName));
        sp_data.stepLength.rightleg.allstds.(trialName)=std(sp_data.stepLength.rightleg.(trialName));
    end

    for trial = 1:num_trial
        trialName = strcat('trial',int2str(trial));
        sp_data.stepLength.leftleg.allmeans.(trialName)=mean(sp_data.stepLength.leftleg.(trialName));
        sp_data.stepLength.leftleg.allstds.(trialName)=std(sp_data.stepLength.leftleg.(trialName));
    end

    for trial = 1:num_trial
        trialName = strcat('trial',int2str(trial));
        sp_data.strideTime.rightleg.allmeans.(trialName)=mean(sp_data.strideTime.rightleg.(trialName));
        sp_data.strideTime.rightleg.allstds.(trialName)=std(sp_data.strideTime.rightleg.(trialName));
    end

    for trial = 1:num_trial
        trialName = strcat('trial',int2str(trial));
        sp_data.strideTime.leftleg.allmeans.(trialName)=mean(sp_data.strideTime.leftleg.(trialName));
        sp_data.strideTime.leftleg.allstds.(trialName)=std(sp_data.strideTime.leftleg.(trialName));
    end

    %% calculate mean values & STD across all trials
    sp_data.strideTime.rightleg.('mean')= mean (strideTime_3trials_r(1,sT_r(1)+1:end));
    sp_data.strideTime.rightleg.('std')= std (strideTime_3trials_r(1,sT_r(1)+1:end));
    sp_data.strideTime.rightleg.varCoeff=(std (strideTime_3trials_r(1,sT_r(1)+1:end)))/(mean (strideTime_3trials_r(1,sT_r(1)+1:end)));
    sp_data.strideTime.leftleg.('mean')= mean (strideTime_3trials_l(1,sT_l(1)+1:end));
    sp_data.strideTime.leftleg.('std')= std (strideTime_3trials_l(1,sT_l(1)+1:end));
    sp_data.strideTime.leftleg.varCoeff=(std (strideTime_3trials_l(1,sT_l(1)+1:end)))/(mean (strideTime_3trials_l(1,sT_l(1)+1:end)));


    sp_data.stepTime.rightleg.('mean')= mean (stepTime_3trials_r(1,ST_r(1)+1:end));
    sp_data.stepTime.rightleg.('std')= std (stepTime_3trials_r(1,ST_r(1)+1:end));
    sp_data.stepTime.leftleg.('mean')= mean (stepTime_3trials_l(1,ST_l(1)+1:end));
    sp_data.stepTime.leftleg.('std')= std (stepTime_3trials_l(1,ST_l(1)+1:end));
    sp_data.stepTime.rightleg.varCoeff=(std (stepTime_3trials_r(1,ST_r(1)+1:end)))/(mean (stepTime_3trials_r(1,ST_r(1)+1:end)));
    sp_data.stepTime.leftleg.varCoeff=(std (stepTime_3trials_l(1,ST_l(1)+1:end)))/(mean (stepTime_3trials_l(1,ST_l(1)+1:end)));

    sp_data.stepLength.rightleg.('mean')= mean (stepLength_3trials_r(1,SL_r(1)+1:end));
    sp_data.stepLength.rightleg.('std')= std (stepLength_3trials_r(1,SL_r(1)+1:end));
    sp_data.stepLength.leftleg.('mean')= mean (stepLength_3trials_l(1,SL_l(1)+1:end));
    sp_data.stepLength.leftleg.('std')= std (stepLength_3trials_l(1,SL_l(1)+1:end));
    sp_data.stepLength.rightleg.varCoeff=(std (stepLength_3trials_r(1,SL_r(1)+1:end)))/(mean (stepLength_3trials_r(1,SL_r(1)+1:end)));
    sp_data.stepLength.leftleg.varCoeff=(std (stepLength_3trials_l(1,SL_l(1)+1:end)))/(mean (stepLength_3trials_l(1,SL_l(1)+1:end)));

end
