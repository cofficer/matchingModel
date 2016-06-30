function [ PLA,ATM ] = loadSessions( ~ )
%Loads all the data necessary from the sessions

%Sort all sessions according to ATM/PLA


cd('/Users/Christoffer/Documents/MATLAB/matchingData/All_behavior')



partDate269            = {'AWi/20151007','SBa/20151006','JHo/20151004','JFo/20151007'... 
                          'AMe/20151008','SKo/20151011','JBo/20151011','DWe/20151003'...
                          'FSr/20151003','JNe/20151004','RWi/20151003','HJu/20151004'...
                          'LJa/20151006','BFu/20151010','EIv/20151003'};
partDate268            = {'JRi/20150828','HRi/20150816','AZi/20150818'...
                          'MTo/20150825','DLa/20150826','BPe/20150826','ROr/20150827'...
                          'HEn/20150828','MSo/20150820','NSh/20150825','JRu/20150819'}; %One channel less.

                      
%First load all the placebo behavior                      
PLA = [partDate268, partDate269];                  

partMatPLA = cell(1,length(PLA));

for isession = 1:length(PLA)

currentSession=PLA(isession);

currentSession=currentSession{1};

%Need to remove 0 if there is one on the day/month, ie 03 == 3.
if currentSession(11)=='0'
    day=currentSession(12);
else
    day=currentSession(11:12);
end

if currentSession(9)=='0'
    month=currentSession(10);
else
    month=currentSession(9:10);
end



partMatPLA(1,isession) = {sprintf('%s*%s_%s_%s*',currentSession(1:3),currentSession(5:8),month,day)};

loadP=partMatPLA(1,isession);

loadP = loadP{1};

loadP = dir(loadP);

loadP = loadP(cell2mat({loadP.bytes})>5000);



    

partMatPLA(1,isession)={loadP.name};


end

PLA=partMatPLA;

%Second load all the atomoxetine behavior
%Find indexes of all the files in placebo array. 

allBehavior = dir('*.mat');

ATM=setdiff({allBehavior.name},partMatPLA) ;






%resultsAll=load_data(names(ipart).name)



end

