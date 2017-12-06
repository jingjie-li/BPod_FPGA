function  run_exp( protocol,subjid,varargin )
% run_exp(subjid)
% run_exp(protocol_name, subjid, ...)
% For Example
% run_exp(1001)
% run_exp('Operant',1000,'test',1)
addpath([pwd '/System_Files/Internal_Functions']);
test = inputordefault('test',false,varargin);
%stage_name = inputordefault('stage_name','reward_train',varargin);
stage = inputordefault('stage',1,varargin);


addpath([pwd,'/Data/Subj_Data'])
addpath([pwd,'/Data/Sess_Data'])
addpath([pwd,'/Data/exp_setting_data'])
load('subj.mat');
load('exp_settings.mat');

if nargin == 1
    subjid = protocol;
end

tar_subj_data = subj.subj_info(subj.subj_info.Subjid == subjid,:);

if ~test
    expgroupid = tar_subj_data.expgroupid;
    expgroup_table = subj.expgroup_info(subj.expgroup_info.expgroupid == expgroupid,:);
    protocol = expgroup_table.protocol{1};
    exp_settings_table = exp_settings(exp_settings.Subjid == subjid,:);
    if isempty(exp_settings_table)
        exp_settings_add=cell2table({subjid,[],protocol,expgroupid,stage},...
            'VariableNames',{'Subjid','subj_settings','Protocol','expgroupid','stage'});
        exp_settings = [exp_settings ;exp_settings_add];
        current_folder = pwd;
        cd([pwd, '/Data/exp_setting_data'])
        save('exp_settings.m','exp_settings')
        cd(current_folder)
        clear exp_settings_add
        clear current_folder
    else
        stage = exp_settings.stage(1);
    end
    stage_name = expgroup_table.stage_name(stage);
else
    expgroup_table = subj.expgroup_info(strcmp(subj.expgroup_info.protocol,protocol),:);
    try
        stage_name = expgroup_table.stage_name(stage);
    catch
        fprintf('You may entered a wrong protocol name ? Trying ''Operant'' ?\n');
        protocol = 'Operant';
        expgroup_table = subj.expgroup_info(strcmp(subj.expgroup_info.protocol,protocol),:);
        stage_name = expgroup_table.stage_name(stage);
    end
end


addpath([pwd '/System_Files/Modules']);
addpath([pwd,'/Protocols/',protocol])

obj = eval(protocol);
fprintf('Now Start Trian the animal %d\n',subjid)

dispatch(obj,'name',subjid,'action','all','protocol',protocol,'stage',stage,'stage_name',stage_name,'test',test);


end
