
function [ choiceStreamAll,rewardStreamAll] = plot_dynamic_behavior(results)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%New function for plotting figures 1b and 1c.
%%Created using Atom and tunnelling.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%load the names of the Sessions.
clear all;close all;
%plot 1b.
%Get the cumulative choices for each target.
%Load the table of all trial perhapd

codepath = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis/matchingModel';
load(sprintf('%s/fullTable24Nov-2.mat',codepath))

[c,ia,ic]=unique(Ttotal.resp_type);

%horizontal and vertical button presses
horBP = [21,23];
verBP = [20,22];

%select one example participant.3/10
pID      = unique(Ttotal.ID,'rows');
pIDcurrent = pID(25,:);
pIDlogic = ismember(Ttotal.ID,{pIDcurrent});
pIDtable = Ttotal(pIDlogic,:);

%vectorize choices into 0 for vertical and 1 for horizontal.
choice   = pIDtable.resp_type(pIDtable.resp_type~=0);
horID    = ismember(choice,horBP);
verID    = ismember(choice,verBP);
choice(horID)   = 1;
choice(verID)   = 0;

%x cumulative 0 (vertical) and y cumulative 1 (horizontal) choices.
cumXY = cumsum([horID';verID'],2);

%income ratio per block. Will need to load the originl result block2508 nsh.
%load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/All_behavior/FSr_sess1_2015_10_3_8_57.mat')
load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/All_behavior/NSh_sess1_2015_8_25_10_40.mat')

incomeRatio = results.probHor;

%block change points after trial error removal
blockchange = pIDtable.new_block==32;
blockchange(pIDtable.resp_type==0)=[];

blockchange=find(blockchange);

iRatioIdx = [zeros(1,11);zeros(1,11)];
blockver=zeros(1,11);
blockhor=zeros(1,11);
trlnum=zeros(1,11);
%insert indices of each incomeRatio per block
for iblock = 2:10

  %all choices for current block.
  blockchoices = [choice(blockchange(iblock-1):blockchange(iblock)-1)];

  trlnum(iblock) = length(blockchoices);

  %decompose into ver and hor choices.
  blockver(iblock)     = sum(blockchoices==0);
  blockhor(iblock)     = sum(blockchoices==1);



  %quantaties necessary:
  %incomeRatio, numtrials. (blockchange)

  blocklen  = blockchange(iblock) - blockchange(iblock-1);
  trlHor    = blocklen*(incomeRatio(iblock-1));
  trlVer    = blocklen - trlHor;


  %iRatioIdx contains the coordinates for income lines.
  %Need to change to start at the same point as new block.
  iRatioIdx(1,iblock) = trlHor;
  iRatioIdx(2,iblock) = trlVer;

  if iblock == 10

    blockchoices = [choice(blockchange(iblock):end)];
    blockver(iblock+1) = sum(blockchoices==0);
    blockhor(iblock+1) = sum(blockchoices==1);
    trlnum(iblock+1) = length(blockchoices);

    blocklen  = length(choice) - blockchange(iblock);
    trlHor    = blocklen*(incomeRatio(iblock));
    trlVer    = blocklen - trlHor;

    iRatioIdx(1,iblock+1) =  trlHor;
    iRatioIdx(2,iblock+1) =  trlVer;

  end

end



iRatioIdx=round(iRatioIdx);

%plot sugrue 1b.
cd(codepath)
hFig = figure(1);clf;
set(hFig, 'Position', [0 0 500 500])
plot(cumXY(1,:),cumXY(2,:),'LineWidth',4);
%plot the income ratio lines.
hold on;
%plot the changes in blocks

plot(cumsum(blockhor)',cumsum(blockver)','*','MarkerSize',10)

%plot(iRatioIdx(1,:),iRatioIdx(2,:))
%plot(cumsum(blockhor)',iRatioIdx(2,:))

blockpos = [cumsum(blockhor);cumsum(blockver)];

blockposx = blockpos(1,:);
blockposy = blockpos(2,:);

iRatioIdxx = iRatioIdx(1,:);
iRatioIdxy = iRatioIdx(2,:);

%plot([blockpos(1,:);iRatioIdx(1,:)],blockpos')
for iplot = 1:10
  plot([blockposx(iplot);iRatioIdxx(iplot+1)+blockposx(iplot)],...
  [blockposy(iplot);iRatioIdxy(iplot+1)+blockposy(iplot)],'k','LineWidth',2)
end
%plot([0,100;50,150],[0,100;50,150])

xlim([0 300])
ylim([0 300])
legend choiceRatio blockChange incomeRatio
xlabel('Cumulative horizontal choices')
ylabel('Cumulative vertical choices')
set(gca,'fontsize',16)


%Name of figure
formatOut = 'yyyy-mm-dd';
todaystr = datestr(now,formatOut);

namefigure = sprintf('Sugrue1b-%s',pIDcurrent);

figurename = sprintf('%s_%s.pdf',todaystr,namefigure);
saveas(gca,figurename,'pdf')



end
