

% Date: 2006-12-17
%
% This function changes from a H.%M timescale to HH:MM. 
% The tickmarks are fixed, they won't change when zooming.
%
%   USAGE:
%   
%   Just call set_timeaxis() for a plot/subplot of your choice  
% 



% First, make sure that the tick marks are fixed - Otherwise they will
% not manage scale changes.
    
tick = get(gca,'XTick');


set(gca,'XTick',tick);

    % Second, import the tick labels and converr them to HH:MM

tick = get(gca,'XTicklabel');
tick = str2num(tick);

hour = floor(tick);

aa=find(hour>=24);
while(aa > 0)
aa=find(hour>=24);
hour(aa)=hour(aa)-24;
end 


minute = (tick-floor(tick))*60;
minute = floor(minute);
second = (tick-floor(tick)).*3600-(minute.*60.);

temp = find(round(second)==60);
second(temp) = 0;
minute(temp) = minute(temp)+1;

temp2 = find(minute==60);
minute(temp2) = 0;
hour(temp2) = hour(temp2)+1;

hour = int2str(hour(:));
minute = int2str(minute(:));
second = int2str(second(:));


% Exchange spaces for zeroes ( 08:05 makes more sense than ' 8: 5') 
hour(:,1) = regexprep(hour(:,1)',' ','0');
minute(:,1) = regexprep(minute(:,1)',' ','0');
second(:,1) = regexprep(second(:,1)',' ','0');
if(min(size(minute))==1)
  %  minute = [minute,minute];
   minute = [int2str(zeros(size(minute))),minute];
end
if(min(size(second))==1)
  %  second = [second,second];
       second = [int2str(zeros(size(second))),second];
end

    % Make strings and set as label

tick = strcat(hour,':',minute,':',second);
set(gca,'XTickLabel',tick);

set(gca,'xminortick','on')
