function [ paramfits ] = saveAll_paramfits( ~ )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel/resultsParamFits/simulated')

paramfit_files = dir('*.mat');


for ifiles = 1:length(paramfit_files)
    
    load(paramfit_files(ifiles).name)
    
    lsATMfits(ifiles)=paramFits.lsATMfits;
    lsPLAfits(ifiles)=paramFits.lsPLAfits;
    betaPLAfits(ifiles)=paramFits.betaPLAfits;
    betaATMfits(ifiles)=paramFits.betaATMfits;
    tauPLAfits(ifiles)=paramFits.tauPLAfits;
    tauATMfits(ifiles)=paramFits.tauATMfits;
    
    
    
     
end



scatter(performance(1:2:end),betaPLAfits)
scatter(performance(1:2:end),l_switch(1:2:end))


scatter(betaPLAfits,lsPLAfits)
c=ones(1,length(l_switch));

sz=55;
c(1:2:end)=8.5789;
c(2:2:end)=9.8421;

scatter(l_switch(1:2:end),lsPLAfits,'color',r)
scatter(l_switch(1:2:end),lsPLAfits,sz,'MarkerFaceColor',[0 0.7 0.7])
hold on
scatter(l_switch(2:2:end),lsATMfits,sz,'MarkerFaceColor',[0.2 0.2 0.6])

legend PLA ATM


[r,p]=corr(l_switch(2:2:end)',lsATMfits')

end

