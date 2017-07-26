

function result = ASRClean(controlFile)

try
eval(controlFile);
catch
    error('Incorrect or no control file specified');
end

N2Proc=length(SUBStoPROCESS);


for i=1:N2Proc    

   CURRENTsub = SUBStoPROCESS(i);
    
       subpath = sprintf('%s%s\\',localpath,subnum{CURRENTsub});
    
             
       FULLfn = sprintf('%s_%s_TAC.set',subnum{CURRENTsub},sess{CURRENTsub});
       CLEANfn = sprintf('%s_%s_TACcleanavref.set',subnum{CURRENTsub},sess{CURRENTsub});
       epochclrfn = sprintf('%sBDRDIDCLRpos2.set',subnum{CURRENTsub});
       epochvocfn = sprintf('%sBDRDIDVOCpos2.set',subnum{CURRENTsub});


        [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
      
        fprintf('detect and interpolate bridged electrodes CLEAN Processing %s \n',subnum{CURRENTsub} );
  
        %setnm = sprintf('%s_%s_%s.set',subnum{CURRENTsub},sess{CURRENTsub},condlst{j});
        
        
        
       % epochsetfn = sprintf('%s%s%spos2Epoch.set',subpath,subnum{CURRENTsub},condlst{j});
       % epochset = sprintf('%s%s%spos2Epoch',subpath,subnum{CURRENTsub},condlst{j});     
        
       EEG = pop_loadset('filename',FULLfn ,'filepath',subpath);        
       [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
       EEG = pop_select( EEG,'nochannel',{'HEOG' 'VEOG'});
       [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off'); 
        eeglab redraw;

       % Find the bridged channels and interpolate them
       
       [EB, ED] = eBridge(EEG);

    
       EEG = pop_interp(EEG, EB.Bridged.Indices, 'spherical');
       
       
       originalEEG = EEG;
       
        
       % Clean the data using the clean raw
       
       fprintf('ASR CLEAN Processing %s \n',subnum{CURRENTsub} );
       EEG = clean_rawdata(EEG, 5, [0.25 0.75], 0.8, 4, 5, 0.5);
       EEG = eeg_checkset( EEG );
    
        
        
       [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
       
         % Interpolate channels.
       EEG = pop_interp(EEG, originalEEG.chanlocs, 'spherical');

       
       %%%%%%%%%AVERAGE REFERENCE
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
        
       
       EEG = pop_saveset( EEG, 'filename',CLEANfn,'filepath',subpath);
         
       [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        
end
  
    %[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'setname',epochclrfn,'gui','off'); 
    %EEG = pop_saveset( EEG, 'filename',epochallfn,'filepath',subpath);
    %[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    eeglab redraw;
end