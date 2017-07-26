function cfg = config_subjects_EEG_VTaim1(cfg)

%% set analysis specifc variables 
cfg.name = 'VTaim1'; % project name

%% set paths 

[~,hostname] = system('hostname');
if strcmp(cellstr(hostname),'hmaxinator') 
    data_dir = '/data/Data/Data_MBP/vibrotactile/EEG';
else 
    data_dir = '/Volumes/maloneHD/Data/vibrotactile/EEG';
end

cfg.dirs.data_dir = data_dir;
cfg.dirs.preproc_dir = fullfile(data_dir,'preproc');
cfg.dirs.results_dir = fullfile(data_dir,'results');
cfg.dirs.behav_dir = fullfile(data_dir,'behavData');

%% set basic analysis variables
cfg.numSess     = 4;
cfg.sess        = {'A','B','C','D'};
cfg.stimIDs     = {'3','4','5','7','8','9'};
cfg.conds       = {'TAC3' 'TAC4' 'TAC5' 'TAC7' 'TAC8' 'TAC9'}; % 3/9 prototypes, 5/7 boundary
cfg.resampFrq   = 250; % resampling frequency 
cfg.filtFrq     = [1 30]; %[hpf lpf]
cfg.epoch       = [-0.1 0.800];
cfg.SLsize      = 5; % size of searchlight (num chans)
cfg.tm_bins     = 4; % time bins; 4*2+1=9 time points, 2 time points before, and 2 time points after so 9 time points

%% set subjects and runs to use in analysis
% TO DO: this is currently not implemented
excluded_subjects = [];
excluded_runs = {};

%% set subject variables 

% Subject 1
cfg.sub(1).id = '1028'; 
cfg.sub(1).age = 27;
cfg.sub(1).gender = 0;  % 0=male, 1=female

% Subject 2
cfg.sub(2).id = '1058'; 
cfg.sub(2).age = 19;
cfg.sub(2).gender = 0;  % 0=male, 1=female

% Subject 3
cfg.sub(3).id = '1062'; 
cfg.sub(3).age = 20;
cfg.sub(3).gender = 0; % 0=male, 1=female

% Subject 4
cfg.sub(4).id = '1064'; 
cfg.sub(4).age = 21;
cfg.sub(4).gender = 0; % 0=male, 1=female

% Subject 5
cfg.sub(5).id = '1072'; 
cfg.sub(5).age = 20;
cfg.sub(5).gender = 0; % 0=male, 1=female

% Subject 6
cfg.sub(6).id = '1073'; 
cfg.sub(6).age = 22;
cfg.sub(6).gender = 0; % 0=male, 1=female

end

