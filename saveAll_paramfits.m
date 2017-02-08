function [ paramfits ] = saveAll_paramfits( ~ )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits')

paramfit_files = dir('*.mat');


for ifiles = 1:length(paramfit_files)
    
    load(paramfit_files(ifiles).name)
    
    lsATMfits(ifiles)=paramFits.lsATMfits;
    lsPLAfits(ifiles)=paramFits.lsPLAfits;
    betaPLAfits(ifiles)=paramFits.betaPLAfits;
end


lsATMfits
lsPLAfits


scatter(performance(1:2:end),betaPLAfits)
scatter(performance(1:2:end),l_switch(1:2:end))


scatter(betaPLAfits,lsPLAfits)

scatter(l_switch(1:2:end),lsPLAfits)

[r,p]=corr(l_switch(1:2:end)',lsPLAfits')

end

