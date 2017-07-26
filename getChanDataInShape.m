function getChanDataInShape(i_sub)

% function to transpose the channel data in the eeglab 
% structure so that it can play nicely with cosmomvpa 
    
    cfg = config_subjects_EEG_VTaim1;
    load(fullfile(cfg.dirs.preproc_dir,cfg.sub(i_sub).id,['design1_' cfg.sub(i_sub).id '.mat']));
    if exist('chanlabels','var')
       fprintf('data already in shape, skipping');
       return
    end
    chanlabels = labels;
    chan1 = chan1';
    chan2 = chan2';
    chan3 = chan3';
    chan4 = chan4';
    chan5 = chan5';
    chan6 = chan6';
    chan7 = chan7';
    chan8 = chan8';
    chan9 = chan9';
    chan10 = chan10';
    chan11 = chan11';
    chan12 = chan12';
    chan13 = chan13';
    chan14 = chan14';
    chan15 = chan15';
    chan16 = chan16';
    chan17 = chan17';
    chan18 = chan18';
    chan19 = chan19';
    chan20 = chan20';
    chan21 = chan21';
    chan22 = chan22';
    chan23 = chan23';
    chan24 = chan24';
    chan25 = chan25';
    chan26 = chan26';
    chan27 = chan27';
    chan28 = chan28';
    chan29 = chan29';
    chan30 = chan30';
    chan31 = chan31';
    chan32 = chan32';
    chan33 = chan33';
    chan34 = chan34';
    chan35 = chan35';
    chan36 = chan36';
    chan37 = chan37';
    chan38 = chan38';
    chan39 = chan39';
    chan40 = chan40';
    chan41 = chan41';
    chan42 = chan42';
    chan43 = chan43';
    chan44 = chan44';
    chan45 = chan45';
    chan46 = chan46';
    chan47 = chan47';
    chan48 = chan48';
    chan49 = chan49';
    chan50 = chan50';
    chan51 = chan51';
    chan52 = chan52';
    chan53 = chan53';
    chan54 = chan54';
    chan55 = chan55';
    chan56 = chan56';
    chan57 = chan57';
    chan58 = chan58';
    chan59 = chan59';
    chan60 = chan60';
    chan61 = chan61';
    chan62 = chan62';
    chan63 = chan63';
    chan64 = chan64';
    chan65 = chan65';
    save(fullfile(cfg.dirs.preproc_dir,cfg.sub(i_sub).id,['design1_' cfg.sub(i_sub).id '.mat']));

end