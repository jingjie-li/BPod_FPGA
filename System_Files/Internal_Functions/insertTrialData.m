function insertTrialData( protocol,save_info,trial_data )
%Save trials data into proto.protocol
%   insertTrialData('operant',colstrain={'trialid','trials_in_this_stage','target_port_1','target_port_2'...
%   ,'choice_port_1','choice_port_2','viol','reward','trialnum','RT','sessid',...
%    'subjid','trialtime'},{0,1,'','','','',0,1,1,0.1,0,1000,'2017-12-05 15:50:15.0049'})
current_add=pwd;
try
    cd('/Users/apple/Documents/MATLAB/BPOD_FPGA/Data/Sess_Data')
    load('proto.mat');
    eval(sprintf('trialid=max(proto.%s.trialid)+1;',protocol))
    new_data=cell2table([trialid,trial_data],'Variablename',['trialid',save_info]);
    eval(sprintf('proto.%s=[proto.%s;new_data];',protocol,protocol))
    %proto.operant=[proto.operant;new_data];
    save('proto.mat','proto');
catch
    fprintf('Error Parsing Saving Trial Data\n')
end
cd(current_add);
end

