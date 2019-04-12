%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% find_leg_extension.m
%
% Finds all the minimal leg extension
%
% Jose Gonzalez-Vargas
% v0.1 2016/08/08
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [output threshold] = find_leg_extension(data, color)


data_temp = data; %Here, we set a threshold and everything below the threshold
                  %we set it to 0 to remove the peaks we do not want
threshold=rms(data);
%¿THRESHOLD ADECUADO PARA CADA PACIENTE?

%Whatever is lower than the threshold, we set it to 0 so that we do not
%have any other peaks than the big peaks.
data_temp(data_temp < threshold) = 0;

%We find all the peaks of the function
[val index] = findpeaks(data_temp);

% find the lowest point after each maximum. Low value will be the the final
% matrix we will output. The first row of low_value will contain the value
% of the minima after the peak, and the second row of low_value will
% contain the index of the minima after the peak.
low_value = zeros(2,length(index)-1);

%We loop from 1 to the number of peaks we have minus one. We basically do
%not want to find the minimum after the last peak, that is why we substract
%1
for i = 1:length(index)-1
m = -1;
j = index(i);

%In this loop, we basically look for a minimum after the peak i. Once we
%find it, we get out of the loop low_value(1,i) will contain the value of
%the minimum, and low_value (2,i) will contain the index of the minimum.
while (m < 0)
    m = data(j+1)- data(j);
    low_value(1,i) = data(j);
    low_value(2,i) = j;
    j = j + 1;
end
end

% %figure
% hold on
% xlim=[1 length(data)];
% plot(data,color);
% plot(low_value(2,:), low_value(1,:), '*r');
% plot(xlim,[threshold threshold],':k','LineWidth',1)
% hold off
output = low_value;
end

