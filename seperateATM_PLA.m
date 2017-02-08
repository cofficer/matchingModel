function [ output_args ] = seperateATM_PLA( input_args )
%Sort out which session is which for the behavioral data.
%Sorts the pathnames for each session type. 

cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/All_behavior/')
%load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/All_behavior/RWi_sess1_2015_10_3_12_41.mat')

behav_part = dir('*.mat');



placebo.partlist = {
                          %269 channels
                          'AWi/20151007'
                          'SBa/20151006'
                          'JHo/20151004'
                          'JFo/20151007'
                          'AMe/20151008'
                          'SKo/20151011'
                          'JBo/20151011'
                          'DWe/20151003'
                          'FSr/20151003'
                          'JNe/20151004'
                          'RWi/20151003'
                          'HJu/20151004'
                          'LJa/20151006'
                          'BFu/20151010'
                          'EIv/20151003'
                          'JHa/20151010'
                          'FRa/20151007'
                          %268 channels
                          'MGo/20150815'
                          'JRi/20150828'
                          'HRi/20150816'
                          'AZi/20150818' 
                          'MTo/20150825'
                          'DLa/20150826'
                          'BPe/20150826'
                          'ROr/20150827'
                          'HEn/20150828'
                          'MSo/20150820'
                          'NSh/20150825'
                          'JRu/20150819'
                          'LMe/20150826'
 %                        'MAm/20150825' %Avoid for behavior analysis
                          'MAb/20150816'
  }; 


end

