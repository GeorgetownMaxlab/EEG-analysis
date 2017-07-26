function cfg = analysis_EEG_VTaim1(i_sub)
% i_sub = subject to be processed (i.e 1:nsubs). see config_subjects*.m

%% load config file
cfg = config_subjects_EEG_VTaim1;

%% preprocessing
cfg.do.electPosFile      = 0; 
cfg.do.resampAndFilt     = 0;
cfg.do.ASRclean          = 0;
cfg.do.epochAndExportERP = 0;

%% mvpa
cfg.do.makeTargetsFile   = 0;
cfg.do.searchlight       = 1; 

%% PREPROCESSING 

%% create electrode position file
if cfg.do.electPosFile
    fprintf('Importing neuroscan files for %s \n',cfg.sub(i_sub).id);
    subpath = fullfile(cfg.dirs.preproc_dir,cfg.sub(i_sub).id);
    elecPosFile = fullfile(subpath,[cfg.sub(i_sub).id '.xyz']);
    if exist(elecPosFile,'file') == 0
        fprintf('Warning: electrode position file does not exist:%s\n', elecPosFile);
        fprintf('Attempting to create:%s\n', elecPosFile);
        try
            cd(subpath);
            dat2xyz_ETA(cfg.sub(i_sub).id);
        catch
            error('failed to create elec pos file');
        end
    end
end
%% import .cnt files to eeglab, resample and filter data
if cfg.do.resampAndFilt
   fprintf('Resampling %s to %d Hz and filtering %d - %d Hz \n', ... 
            cfg.sub(i_sub).id,cfg.resampFrq,cfg.filtFrq(1),cfg.filtFrq(2));
   subpath = fullfile(cfg.dirs.preproc_dir,cfg.sub(i_sub).id);
   elecPosFile = fullfile(fullfile(cfg.dirs.preproc_dir,cfg.sub(i_sub).id),[cfg.sub(i_sub).id '.xyz']);
   for i_sess=1:cfg.numSess
       cntFile = fullfile(cfg.dirs.preproc_dir,cfg.sub(i_sub).id,[cfg.sub(i_sub).id cfg.sess{i_sess} '.cnt']);
       setnm   = sprintf('%s%s.set',cfg.sub(i_sub).id,cfg.sess{i_sess});
       if exist(cntFile,'file')
           [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
           EEG = pop_loadcnt(cntFile, 'dataformat', 'auto', 'memmapfile', '');
           [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname',setnm,'gui','off');
           EEG = eeg_checkset( EEG );
           EEG = pop_resample( EEG, cfg.resampFrq);
           [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off');
           EEG = eeg_checkset( EEG );
           EEG = pop_chanedit(EEG, 'load',{elecPosFile 'filetype' 'xyz'},'changefield',{70 'datachan' 0},'setref',{'70' ''});
           [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
           EEG = eeg_checkset( EEG );
           EEG = pop_eegfiltnew(EEG, cfg.filtFrq(1), cfg.filtFrq(2), 9900, 0, [], 0); % LPF and HPF seperate rather than BPF?
           EEG = eeg_checkset( EEG );
           EEG = pop_saveset( EEG, 'filename',setnm,'filepath',subpath);
           [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
       else
           fprintf('Warning: file does not exist: %s, file not processed\n', cntFile);
       end
   end
end

%% ASRclean
%  detect and interpolate bridged electrodes
%  clean data using clean_rawdata
%  rereference data
if cfg.do.ASRclean
    fprintf('cleaning data for %s \n',cfg.sub(i_sub).id);
    subpath = fullfile(cfg.dirs.preproc_dir,cfg.sub(i_sub).id);
    for i_sess=1:cfg.numSess
        fn = sprintf('%s%s.set',cfg.sub(i_sub).id,cfg.sess{i_sess});
        cleanfn = sprintf('%s%scleanavref.set',cfg.sub(i_sub).id,cfg.sess{i_sess});
        
        [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
        EEG = pop_loadset('filename',fn ,'filepath',subpath);
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
        EEG = pop_select( EEG,'nochannel',{'HEOG' 'VEOG'});
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off');
        eeglab redraw;
        
        % find and interpolate bridged channels
        [EB, ED] = eBridge(EEG);
        
        EEG = pop_interp(EEG, EB.Bridged.Indices, 'spherical');
        originalEEG = EEG;
        % clean using clean_rawdata
        EEG = clean_rawdata(EEG, 5, [0.25 0.75], 0.8, 4, 5, 0.5);
        EEG = eeg_checkset( EEG );

        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        % interpolate channels.
        EEG = pop_interp(EEG, originalEEG.chanlocs, 'spherical');
        % average referencing 
        % find index of ref channel in EEG structure
        nodatchanlist = [EEG.chaninfo.nodatchans.urchan];
        orig_ref = find(nodatchanlist==70);
        
        EEG = eeg_checkset( EEG );
        EEG = pop_reref( EEG, [],'refloc',struct('Y',{EEG.chaninfo.nodatchans(orig_ref).Y},...
            'X',{EEG.chaninfo.nodatchans(orig_ref).X},...
            'Z',{EEG.chaninfo.nodatchans(orig_ref).Z},'labels',{'REF'},...
            'sph_theta',{EEG.chaninfo.nodatchans(orig_ref).sph_theta},...
            'sph_phi',{EEG.chaninfo.nodatchans(orig_ref).sph_phi},...
            'sph_radius',{EEG.chaninfo.nodatchans(orig_ref).radius},...
            'theta',{EEG.chaninfo.nodatchans(orig_ref).theta},...
            'radius',{EEG.chaninfo.nodatchans(orig_ref).radius},'type',{''},'ref',{''},'urchan',{70},'datachan',{0}));
        
        EEG = pop_saveset( EEG, 'filename',cleanfn,'filepath',subpath);
        
        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    end
end

%% epoch and export ERP data
if cfg.do.epochAndExportERP
    fprintf('epoching and exporting data for %s \n',cfg.sub(i_sub).id); 
    subpath = fullfile(cfg.dirs.preproc_dir,cfg.sub(i_sub).id);
    
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    EEG = pop_loadset('filename',[cfg.sub(i_sub).id 'cleanavref_merged.set'],'filepath',subpath);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    EEG = eeg_checkset( EEG );
    EEG = pop_epoch( EEG, {'3' '4' '5' '7' '8' '9'}, [cfg.epoch(1) cfg.epoch(2)], 'newname', [cfg.sub(i_sub).id '.setepochs'], 'epochinfo', 'yes');
    EEG = eeg_checkset( EEG );
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'savenew',fullfile(subpath,[cfg.sub(i_sub).id '_epoch.set']),'gui','off'); 
    EEG = eeg_checkset( EEG );
    % export events
    pop_expevents(EEG, fullfile(subpath,[cfg.sub(i_sub).id '_events.csv']), 'samples');
    % create study, export ERP data
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
    EEG = pop_loadset('filename',[cfg.sub(i_sub).id '_epoch.set'],'filepath',subpath);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    [STUDY ALLEEG] = std_editset( STUDY, ALLEEG, 'name',cfg.name,'commands',{{'index' 1 'subject' cfg.sub(i_sub).id}},'updatedat','on','rmclust','on' );
    [STUDY ALLEEG] = std_checkset(STUDY, ALLEEG);
    CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = [1:length(EEG)];
    EEG = eeg_checkset( EEG );
    [STUDY EEG] = pop_savestudy( STUDY, EEG, 'filename',[cfg.sub(i_sub).id '_epoch.study'],'filepath',subpath);
    CURRENTSTUDY = 1; EEG = ALLEEG; CURRENTSET = [1:length(EEG)];
    [STUDY ALLEEG] = std_precomp(STUDY, ALLEEG, {},'savetrials','on','interp','on','recompute','on','erp','on');
    eeglab redraw; 
end

%% make targets file
if cfg.do.makeTargetsFile
    filename = fullfile(cfg.dirs.preproc_dir,cfg.sub(i_sub).id,[cfg.sub(i_sub).id '_events.csv']);
    delimiter = '\t';
    startRow = 2;
    formatSpec = '%*s%s%*s%*s%*s%*s%[^\n\r]';
    
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);
    fclose(fileID);
 
    targets_str = dataArray{:, 1};
    targets = zeros(length(targets_str),1);
    %convert from str to int
    for i=1:length(targets)
        targets(i) = str2num(targets_str{i});
    end
    
    targets = targets(targets<=9 & targets>=3); % had a problem with other stimIDs being saved, so this removes them
    
    save(fullfile(cfg.dirs.preproc_dir,cfg.sub(i_sub).id,[cfg.sub(i_sub).id '_targets']),'targets');
end

%% time-locked searchlight mvpa using cosmomvpa toolbox
if cfg.do.searchlight 
    addpath(genpath('/Users/pmalone/Documents/MATLAB/fieldtrip-20161231'));
    addpath(genpath('/Users/pmalone/CoSMoMVPA'));
    
    % set configuration
    config=cosmo_config();
    subpath = fullfile(cfg.dirs.preproc_dir,cfg.sub(i_sub).id);
    
    % get data in shape 
    getChanDataInShape(i_sub);
    
    % load data
    data_fn=fullfile(subpath,['design1_' cfg.sub(i_sub).id '.mat']);
    load(fullfile(subpath,[cfg.sub(i_sub).id '_targets.mat']));
    data_tl=load(data_fn);
    
    % convert targets to category
    targets(targets == 3 | targets == 4 | targets == 5) = 1;
    targets(targets == 7 | targets == 8 | targets == 9) = 2;
    
    % convert to cosmomvpa struct
    ds_tl=cosmo_meeg_dataset(data_tl,'targets',targets);
    
%     % get subset of targets for within category clf
%     ds_tl=cosmo_slice(ds_tl,ds_tl.sa.targets==7 | ds_tl.sa.targets==8 | ds_tl.sa.targets==9,1);
    
    % set the chunks (independent measurements)
    ds_tl.sa.chunks = (1:size(ds_tl.samples,1))';
    
    % condition labels
    %index2label={'','','3','4','5','','7','8','9'}; 
    index2label={'','','1','1','1','','2','2','2'};
    ds_tl.sa.labels=cellfun(@(x)index2label(x),num2cell(ds_tl.sa.targets));
    
    % check everything is ok
    cosmo_check_dataset(ds_tl);
    
    % remove features with at least one NaN value across samples
    fa_nan_mask=sum(isnan(ds_tl.samples),1)>0;
    fprintf('%d / %d features have NaN\n', ...
        sum(fa_nan_mask), numel(fa_nan_mask));
    ds_tl=cosmo_slice(ds_tl, ~fa_nan_mask, 2);
    
    % set MVPA parameters
    fprintf('The input has feature dimensions %s\n', ...
        cosmo_strjoin(ds_tl.a.fdim.labels,', '));
    
    % set chunks for cross-validation
    nchunks=10;
    ds_tl.sa.chunks=cosmo_chunkize(ds_tl, nchunks);
    
    % define neighborhood parameters for each dimension
    
    % channel neighborhood uses meg_combined_from_planar, which means that the
    % input are planar channels but the output has combined-planar channels.
    % to use the magnetometers, use 'meg_axial'
    chan_type='eeg';
    chan_count=cfg.SLsize;        % use 10 channel locations (relative to the combined
    % planar channels)
    % as we use meg_combined_from_planar there are
    % 20 channels in each searchlight because
    % gradiometers are paired
    time_radius=cfg.tm_bins; % 2*2+1=5 time bines time point, 2 time points before, and 2 time points after so 5 time points
    
    % define the neighborhood for each dimensions
    chan_nbrhood=cosmo_meeg_chan_neighborhood(ds_tl, 'count', chan_count, ...
        'chantype', chan_type);
    time_nbrhood=cosmo_interval_neighborhood(ds_tl,'time',...
        'radius',time_radius);
    
    % cross neighborhoods for chan-time searchlight
    nbrhood=cosmo_cross_neighborhood(ds_tl,{chan_nbrhood,...
        time_nbrhood});
    
    % print some info
    nbrhood_nfeatures=cellfun(@numel,nbrhood.neighbors);
    fprintf('Features have on average %.1f +/- %.1f neighbors\n', ...
        mean(nbrhood_nfeatures), std(nbrhood_nfeatures));
    
    % only keep features with at least 10 neighbors
    center_ids=find(nbrhood_nfeatures>10);
    
    measure_args=struct();
    measure=@cosmo_crossvalidation_measure;
    measure_args.classifier=@cosmo_classify_lda;
    
    % split-half, as there are just two chunks
    % (when using a classifier, do not use 'half' but the number of chunks to
    % leave out for testing, e.g. 1)
    % measure_args.partitions=cosmo_nchoosek_partitioner(ds_tl,1);
    % measure_args.partitions_unbalanced=cosmo_nchoosek_partitioner(ds_tl,'half');
    % measure_args.partitions=cosmo_balance_partitions(measure_args.partitions_unbalanced,ds_tl);
    measure_args.partitions_unbalanced=cosmo_nchoosek_partitioner(ds_tl,1);
    measure_args.partitions=cosmo_balance_partitions(measure_args.partitions_unbalanced,ds_tl);
    
    
    % run searchlight
    sl_tl_ds=cosmo_searchlight(ds_tl,nbrhood,measure,measure_args,...
        'center_ids',center_ids);
    
    save(fullfile(subpath,[cfg.sub(i_sub).id '_MVPA_SL_category_5SL']));
end

    