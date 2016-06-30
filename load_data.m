function [results] = load_data(numPart,numSess)
%%This function will load results from a selected session



dirName=sprintf('/Users/Christoffer/Dropbox/Data-sets-matching-task/Data/s0%d/',numPart);

%dirName=sprintf('/home/thomasme/MATLAB/mtask/Data/s0%d/',numPart);

filename=sprintf('s0%d_sess%d',numPart,numSess);


files = dir( fullfile(dirName,sprintf('%s*',filename)) );   %# list all *.xyz files
files = {files.name}';  


filename=sprintf('%s%s',dirName,files{1});

results=load(filename);



end