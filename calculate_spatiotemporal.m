%% Consider only the second and third trials in the calculation of parameters

function data = calculate_spatiotemporal (data, sub_num)

    strideTime_3trials_r=[];
    strideTime_3trials_l=[];
    stepTime_3trials_r =[];
    stepTime_3trials_l=[];
    stepLength_3trials_r=[];
    stepLength_3trials_l=[];

    shank = data.anthropometry.shank;
    thigh = data.anthropometry.thigh;
    trunk = data.anthropometry.trunk;
    foot = data.anthropometry.foot;
%         foot = 15;

    color='bgr';

    h = figure('Name','Foot-foot distance','NumberTitle','off');
    set(h,'units','normalized','outerposition',[0 0 1 1]);

%
%     if sub_num == 28
%         num_trial = 2;
%     else
%         num_trial = 3;
%     end

    num_trial = 3;

    for trial = 1:num_trial
        varName = strcat('trial',int2str(trial));

        %% calculate stride time and step time

        HS_right = data.angles.meters15.untilTurnTrials.events.heelstrike.rightleg.(varName);
        HS_left = data.angles.meters15.untilTurnTrials.events.heelstrike.leftleg.(varName);

        % stride time, right leg, in seconds
        data.angles.meters15.untilTurnTrials.('spatiotemporal').('strideTime').('rightleg').(varName)=...
            diff(HS_right)/data.frequency;

        % stride time, left leg, in seconds
        data.angles.meters15.untilTurnTrials.('spatiotemporal').('strideTime').('leftleg').(varName)=...
            diff(HS_left)/data.frequency;

        % step time (= time from contralateral to ipsilateral HS), in seconds
        step_time_all = diff(sort([HS_right HS_left]))/data.frequency; % all step times not classified by side

            if HS_left(1)<HS_right(1) % first heel strike: left --> first step time: right
                data.angles.meters15.untilTurnTrials.('spatiotemporal').('stepTime').('rightleg').(varName) = ...
                    step_time_all(1:2:end); % values in odd position
                data.angles.meters15.untilTurnTrials.('spatiotemporal').('stepTime').('leftleg').(varName) = ...
                    step_time_all(2:2:end); % values in even position

            else % first heel strike: right --> first step time: left
                data.angles.meters15.untilTurnTrials.('spatiotemporal').('stepTime').('rightleg').(varName) = ...
                    step_time_all(2:2:end);
                data.angles.meters15.untilTurnTrials.('spatiotemporal').('stepTime').('leftleg').(varName) = ...
                    step_time_all(1:2:end);
            end

        strideTime_3trials_r = [strideTime_3trials_r data.angles.meters15.untilTurnTrials.('spatiotemporal').('strideTime').('rightleg').(varName)];
        strideTime_3trials_l = [strideTime_3trials_l data.angles.meters15.untilTurnTrials.('spatiotemporal').('strideTime').('leftleg').(varName)];
        stepTime_3trials_r = [stepTime_3trials_r data.angles.meters15.untilTurnTrials.('spatiotemporal').('stepTime').('rightleg').(varName)];
        stepTime_3trials_l = [stepTime_3trials_l data.angles.meters15.untilTurnTrials.('spatiotemporal').('stepTime').('leftleg').(varName)];

        % Length
        sT_r(trial) = length(strideTime_3trials_r);
        sT_l(trial) = length(strideTime_3trials_l);
        ST_r(trial) = length(stepTime_3trials_r);
        ST_l(trial) = length(stepTime_3trials_l);

        %% calculate Joint Positions

        HIP_angle_r = data.angles.meters15.untilTurnTrials.(varName)(:,2:4);
        HIP_angle_l = data.angles.meters15.untilTurnTrials.(varName)(:,11:13);
        KNEE_angle_r = data.angles.meters15.untilTurnTrials.(varName)(:,5:7);
        KNEE_angle_l = data.angles.meters15.untilTurnTrials.(varName)(:,14:16);
        ANKLE_angle_r = data.angles.meters15.untilTurnTrials.(varName)(:,8:10);
        ANKLE_angle_l = data.angles.meters15.untilTurnTrials.(varName)(:,17:19);
        WAIST_angle = data.angles.meters15.untilTurnTrials.(varName)(:,20:21);
        pelvis_angle = 10; % reference angle (pelvis) in space. All other segments will be plotted with respect to this.

        first_right_HS = data.angles.meters15.untilTurnTrials.events.heelstrike.rightleg.(varName)(1); % first heel strike of the right leg (taken as time & space reference)
        t=0;

        feetDist=[];
        knee_r_pos=[];
        ankle_r_pos=[];
        toe_r_pos= [];
        knee_l_pos=[];
        ankle_l_pos=[];
        toe_l_pos= [];

        % i goes from first right heel strike until the end of trial 1
        for i = find(data.angles.meters15.untilTurnTrials.(varName)(:,1)==first_right_HS):size(data.angles.meters15.untilTurnTrials.(varName),1)
            t=t+1;
            gamma_r = deg2rad(HIP_angle_r(i,1)-pelvis_angle);
            beta_r = deg2rad(KNEE_angle_r(i,1));
            alfa_r = gamma_r-beta_r+deg2rad(ANKLE_angle_r(i,1)); % old: -deg2rad

            knee_r_pos(t,1:2)=[sin(gamma_r) -cos(gamma_r)]*thigh;
            ankle_r_pos(t,1:2)=knee_r_pos(t,:) + [sin(gamma_r-beta_r) -cos(gamma_r-beta_r)]*shank;
            toe_r_pos(t,1:2)= ankle_r_pos(t,:) + [cos(alfa_r) sin(alfa_r)]*foot;

            gamma_l = deg2rad(HIP_angle_l(i,1)-pelvis_angle);
            beta_l = deg2rad(KNEE_angle_l(i,1));
            alfa_l = gamma_l-beta_l+deg2rad(ANKLE_angle_l(i,1)); % old: -deg2rad

            knee_l_pos(t,1:2)=[sin(gamma_l) -cos(gamma_l)]*thigh;
            ankle_l_pos(t,1:2)=knee_l_pos(t,:) + [sin(gamma_l-beta_l) -cos(gamma_l-beta_l)]*shank;
            toe_l_pos(t,1:2)= ankle_l_pos(t,:) + [cos(alfa_l) sin(alfa_l)]*foot;

            feetDist(t,1) = data.angles.meters15.untilTurnTrials.(varName)(i,1); % time
            feetDist(t,2) = pdist([toe_r_pos(t,:); toe_l_pos(t,:)],'euclidean');

        end

        %% plot foot-foot distance

        [step_length_rl index] = findpeaks(feetDist(:,2),'MinPeakDistance',floor(mean(stepTime_3trials_r)*data.frequency/5)); % find peaks of the foot-foot distance (taking away peaks closer than 1/5 stepTime)
        data.angles.meters15.untilTurnTrials.spatiotemporal.('stepLength').rightleg.(varName)=step_length_rl(1:2:end)';
        data.angles.meters15.untilTurnTrials.spatiotemporal.('stepLength').leftleg.(varName)=step_length_rl(2:2:end)';
        subplot(3,1,trial)
        h(1)= plot (feetDist(:,1), feetDist(:,2),color(trial));
        title(['Trial ', num2str(trial)])
        hold on
        h(2)= plot (feetDist(index,1),step_length_rl,['o' color(trial)]); % plot peaks
        for i=1:length(data.angles.meters15.untilTurnTrials.events.heelstrike.rightleg.(varName))
            h(3)= plot ([data.angles.meters15.untilTurnTrials.events.heelstrike.rightleg.(varName)(i),data.angles.meters15.untilTurnTrials.events.heelstrike.rightleg.(varName)(i)],[0,max(feetDist(:,2))],'k');
        end
        for i=1:length(data.angles.meters15.untilTurnTrials.events.heelstrike.leftleg.(varName))
            h(4)= plot ([data.angles.meters15.untilTurnTrials.events.heelstrike.leftleg.(varName)(i),data.angles.meters15.untilTurnTrials.events.heelstrike.leftleg.(varName)(i)],[0,max(feetDist(:,2))],'--k');
        end
        legend (h(1:4),['foot-foot distance'],'peaks','right HS','left HS')

        stepLength_3trials_r=[stepLength_3trials_r data.angles.meters15.untilTurnTrials.spatiotemporal.('stepLength').rightleg.(varName)];
        stepLength_3trials_l=[stepLength_3trials_l data.angles.meters15.untilTurnTrials.spatiotemporal.('stepLength').leftleg.(varName)];

        SL_r(trial) = length(stepLength_3trials_r);
        SL_l(trial) = length(stepLength_3trials_l);


    end;

for trial = 1:num_trial
        varName = strcat('trial',int2str(trial));
        data.angles.meters15.untilTurnTrials.spatiotemporal.stepLength.rightleg.allmeans.(varName)=mean(data.angles.meters15.untilTurnTrials.spatiotemporal.stepLength.rightleg.(varName));
        data.angles.meters15.untilTurnTrials.spatiotemporal.stepLength.rightleg.allstds.(varName)=std(data.angles.meters15.untilTurnTrials.spatiotemporal.stepLength.rightleg.(varName));

end

for trial = 1:num_trial
        varName = strcat('trial',int2str(trial));
        data.angles.meters15.untilTurnTrials.spatiotemporal.stepLength.leftleg.allmeans.(varName)=mean(data.angles.meters15.untilTurnTrials.spatiotemporal.stepLength.leftleg.(varName));
        data.angles.meters15.untilTurnTrials.spatiotemporal.stepLength.leftleg.allstds.(varName)=std(data.angles.meters15.untilTurnTrials.spatiotemporal.stepLength.leftleg.(varName));

end

for trial = 1:num_trial
        varName = strcat('trial',int2str(trial));
        data.angles.meters15.untilTurnTrials.spatiotemporal.strideTime.rightleg.allmeans.(varName)=mean(data.angles.meters15.untilTurnTrials.spatiotemporal.strideTime.rightleg.(varName));
        data.angles.meters15.untilTurnTrials.spatiotemporal.strideTime.rightleg.allstds.(varName)=std(data.angles.meters15.untilTurnTrials.spatiotemporal.strideTime.rightleg.(varName));

end

for trial = 1:num_trial
        varName = strcat('trial',int2str(trial));
        data.angles.meters15.untilTurnTrials.spatiotemporal.strideTime.leftleg.allmeans.(varName)=mean(data.angles.meters15.untilTurnTrials.spatiotemporal.strideTime.leftleg.(varName));
        data.angles.meters15.untilTurnTrials.spatiotemporal.strideTime.leftleg.allstds.(varName)=std(data.angles.meters15.untilTurnTrials.spatiotemporal.strideTime.leftleg.(varName));

end

%% calculate mean values & STD across all trials
data.angles.meters15.untilTurnTrials.spatiotemporal.strideTime.rightleg.('mean')= mean (strideTime_3trials_r(1,sT_r(1)+1:end));
data.angles.meters15.untilTurnTrials.spatiotemporal.strideTime.rightleg.('std')= std (strideTime_3trials_r(1,sT_r(1)+1:end));
data.angles.meters15.untilTurnTrials.spatiotemporal.strideTime.rightleg.varCoeff=(std (strideTime_3trials_r(1,sT_r(1)+1:end)))/(mean (strideTime_3trials_r(1,sT_r(1)+1:end)));
data.angles.meters15.untilTurnTrials.spatiotemporal.strideTime.leftleg.('mean')= mean (strideTime_3trials_l(1,sT_l(1)+1:end));
data.angles.meters15.untilTurnTrials.spatiotemporal.strideTime.leftleg.('std')= std (strideTime_3trials_l(1,sT_l(1)+1:end));
data.angles.meters15.untilTurnTrials.spatiotemporal.strideTime.leftleg.varCoeff=(std (strideTime_3trials_l(1,sT_l(1)+1:end)))/(mean (strideTime_3trials_l(1,sT_l(1)+1:end)));


data.angles.meters15.untilTurnTrials.spatiotemporal.stepTime.rightleg.('mean')= mean (stepTime_3trials_r(1,ST_r(1)+1:end));
data.angles.meters15.untilTurnTrials.spatiotemporal.stepTime.rightleg.('std')= std (stepTime_3trials_r(1,ST_r(1)+1:end));
data.angles.meters15.untilTurnTrials.spatiotemporal.stepTime.leftleg.('mean')= mean (stepTime_3trials_l(1,ST_l(1)+1:end));
data.angles.meters15.untilTurnTrials.spatiotemporal.stepTime.leftleg.('std')= std (stepTime_3trials_l(1,ST_l(1)+1:end));
data.angles.meters15.untilTurnTrials.spatiotemporal.stepTime.rightleg.varCoeff=(std (stepTime_3trials_r(1,ST_r(1)+1:end)))/(mean (stepTime_3trials_r(1,ST_r(1)+1:end)));
data.angles.meters15.untilTurnTrials.spatiotemporal.stepTime.leftleg.varCoeff=(std (stepTime_3trials_l(1,ST_l(1)+1:end)))/(mean (stepTime_3trials_l(1,ST_l(1)+1:end)));

data.angles.meters15.untilTurnTrials.spatiotemporal.stepLength.rightleg.('mean')= mean (stepLength_3trials_r(1,SL_r(1)+1:end));
data.angles.meters15.untilTurnTrials.spatiotemporal.stepLength.rightleg.('std')= std (stepLength_3trials_r(1,SL_r(1)+1:end));
data.angles.meters15.untilTurnTrials.spatiotemporal.stepLength.leftleg.('mean')= mean (stepLength_3trials_l(1,SL_l(1)+1:end));
data.angles.meters15.untilTurnTrials.spatiotemporal.stepLength.leftleg.('std')= std (stepLength_3trials_l(1,SL_l(1)+1:end));
data.angles.meters15.untilTurnTrials.spatiotemporal.stepLength.rightleg.varCoeff=(std (stepLength_3trials_r(1,SL_r(1)+1:end)))/(mean (stepLength_3trials_r(1,SL_r(1)+1:end)));
data.angles.meters15.untilTurnTrials.spatiotemporal.stepLength.leftleg.varCoeff=(std (stepLength_3trials_l(1,SL_l(1)+1:end)))/(mean (stepLength_3trials_l(1,SL_l(1)+1:end)));


end