function [ new_data ] = add_new_subj( subjid,species,strain,status,date_born,expgroupid )
%add a new subject to the subj list
%   you can use the following tips to add a new subject by call
%   add_new_subj( subjid,species,strain,status,date_born,expgroupid )
%   also,
%   add_new_subj( strain,date_born ) or add_new_subj( subjid,strain,date_born )
%   For example:
%   add_new_subj( 1001,'human','strain','running','2010-10-10',1 )
%   add_new_subj( 1001,'strain','2010-10-10' )
%   add_new_subj( 'strain','2010-10-10' )  (Recommended Input!)
%   Tips:
%   We recommended to input the first letter of the real strain as a strain
%   for example: strain: 'C57B6' INPUT for mouse
%                strain: 'BN'  for RATs
%   IMPORTANT! After insert, you need to add this subject into the paper
%   as a hard copy! The information will be shown on the command window
cd('/Users/apple/Documents/MATLAB/BPOD_FPGA/Data/Subj_Data');
load('subj.mat');
if nargin==2
    strain=subjid;
    date_born=species;
    subjid=max(subj.subj_info.Subjid)+1;
    species='mouse';
    status='running';
    expgroupid=1;
elseif nargin==3
    date_born=strain;
    strain=species;
    species='mouse';
    status='running';
    expgroupid=1;
end
date_add = datestr(now,29);
colstrain={'Subjid','species','strain','status','date_born','date_add','date_end','expgroupid'};
new_data={subjid,species,strain,status,date_born,date_add,'',expgroupid};
new_data=cell2table(new_data,'Variablename',colstrain);
subj.subj_info=[subj.subj_info;new_data];
save('subj.mat','subj');
end

