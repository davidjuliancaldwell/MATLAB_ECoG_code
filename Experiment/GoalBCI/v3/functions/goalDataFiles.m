function [files, hemi, Montage, controlChannel, isbias] = goalDataFiles(subjid)
    switch(subjid)
        case 'd6c834'
            % o	d6c834 – all of these runs are approximately the same length, subject was eager to perform the task.  Run 1 was aborted due to unclear instructions.  All of the channels look good, and I did not see any specific time periods that needed to be eliminated or otherwise accounted for.
            % •	d6c834\data\d4\goal_bci\d6c834_goal_bci001\d6c834_goal_bciS001R02.dat
            % o	Adaptation on
            % •	d6c834\data\d4\goal_bci\d6c834_goal_bci001\d6c834_goal_bciS001R03.dat
            % o	Adaptation on
            % •	d6c834\data\d4\goal_bci\d6c834_goal_bci001\d6c834_goal_bciS001R04.dat
            % o	Adaptation off
            % •	d6c834\data\d4\goal_bci\d6c834_goal_bci001\d6c834_goal_bciS001R05.dat
            % o	Adaptation off
            % •	d6c834\data\d4\goal_bci\d6c834_goal_bci001\d6c834_goal_bciS001R06.dat  
            
            hemi = 'b';
            bads = [];
            controlChannel = 53;

            files = {...
              fullfile(myGetenv('subject_dir'), 'd6c834\data\d4\goal_bci\d6c834_goal_bci001\d6c834_goal_bciS001R02.dat'), ...
              fullfile(myGetenv('subject_dir'), 'd6c834\data\d4\goal_bci\d6c834_goal_bci001\d6c834_goal_bciS001R03.dat'), ...
              fullfile(myGetenv('subject_dir'), 'd6c834\data\d4\goal_bci\d6c834_goal_bci001\d6c834_goal_bciS001R04.dat'), ...
              fullfile(myGetenv('subject_dir'), 'd6c834\data\d4\goal_bci\d6c834_goal_bci001\d6c834_goal_bciS001R05.dat'), ...
              fullfile(myGetenv('subject_dir'), 'd6c834\data\d4\goal_bci\d6c834_goal_bci001\d6c834_goal_bciS001R06.dat'), ...  
            };
        
            isbias = [0 0 0 0 0];
            
        case '6cc87c'
            % o	6cc87c – electrode 26 is the control electrode. 
            % •	6cc87c\Data\d4\goal_bci\6cc87c_goal_bci001\6cc87c_goal_bciS001R01.dat
            % o	Adaptation on
            % •	6cc87c\Data\d4\goal_bci\6cc87c_goal_bci001\6cc87c_goal_bciS001R02.dat
            % o	Adaptation on
            % •	6cc87c\Data\d4\goal_bci\6cc87c_goal_bci001\6cc87c_goal_bciS001R03.dat
            % o	Adaptation off (not working well)
            % •	6cc87c\Data\d4\goal_bci\6cc87c_goal_bci001\6cc87c_goal_bciS001R04.dat
            % o	Adaptation on
            % •	6cc87c\Data\d4\goal_bci\6cc87c_goal_bci001\6cc87c_goal_bciS001R05.dat
            % o	Adaptation off
            % •	6cc87c\Data\d4\goal_bci\6cc87c_goal_bci001\6cc87c_goal_bciS001R06.dat
            % o	Adaptation off

            hemi = 'l';
            bads = 36;
            controlChannel = 26;

            % R03 aborted because it is only 3 trials ...    
            files = {...
              fullfile(myGetenv('subject_dir'), '6cc87c\Data\d4\goal_bci\6cc87c_goal_bci001\6cc87c_goal_bciS001R01.dat'), ...
              fullfile(myGetenv('subject_dir'), '6cc87c\Data\d4\goal_bci\6cc87c_goal_bci001\6cc87c_goal_bciS001R02.dat'), ...
              fullfile(myGetenv('subject_dir'), '6cc87c\Data\d4\goal_bci\6cc87c_goal_bci001\6cc87c_goal_bciS001R04.dat'), ...
              fullfile(myGetenv('subject_dir'), '6cc87c\Data\d4\goal_bci\6cc87c_goal_bci001\6cc87c_goal_bciS001R05.dat'), ...
              fullfile(myGetenv('subject_dir'), '6cc87c\Data\d4\goal_bci\6cc87c_goal_bci001\6cc87c_goal_bciS001R06.dat'), ...
            };
        
            isbias = [0 0 0 0 0];
        
        case 'ada1ab'
            % o	ada1ab – need to double check recording montage.  Notes are trash from this day.
            % •	ada1ab\data\d5\goal_bci\ada1ab_goal_bci001\ada1ab_goal_bciS001R01.dat
            % •	ada1ab\data\d5\goal_bci\ada1ab_goal_bci001\ada1ab_goal_bciS001R02.dat 
            hemi = 'r';
            bads = [15 16 54 58]; % channels 63 and 64 are just empty
            controlChannel = 29;

            files = {...
              fullfile(myGetenv('subject_dir'), 'ada1ab\data\d5\goal_bci\ada1ab_goal_bci001\ada1ab_goal_bciS001R01.dat'), ...
              fullfile(myGetenv('subject_dir'), 'ada1ab\data\d5\goal_bci\ada1ab_goal_bci001\ada1ab_goal_bciS001R02.dat'), ... 
            };
        
            isbias = [0 0];
        
        case '6b68ef'
            % o	6b68ef – only subject who performed the task over multiple days… interesting to ask about changes in representation across days
            % montage changes between days!!
            % •	6b68ef\data\D5\6b68ef_goal_bci001\6b68ef_goal_bciS001R01.dat
            % •	6b68ef\data\D5\6b68ef_goal_bci001\6b68ef_goal_bciS001R02.dat
            % •	6b68ef\data\D5\6b68ef_goal_bci001\6b68ef_goal_bciS001R03.dat
            % •	6b68ef\data\D6\6b68ef_goal_bci001\6b68ef_goal_bciS001R01.dat
            % •	6b68ef\data\D6\6b68ef_goal_bci001\6b68ef_goal_bciS001R02.dat
            % •	6b68ef\data\D6\6b68ef_goal_bci001\6b68ef_goal_bciS001R03.dat
            
            hemi = 'r';
            bads = [];
            controlChannel = 5;

            files = {...
              fullfile(myGetenv('subject_dir'), '6b68ef\data\D5\6b68ef_goal_bci001\6b68ef_goal_bciS001R01.dat'), ...
              fullfile(myGetenv('subject_dir'), '6b68ef\data\D5\6b68ef_goal_bci001\6b68ef_goal_bciS001R02.dat'), ...
              fullfile(myGetenv('subject_dir'), '6b68ef\data\D5\6b68ef_goal_bci001\6b68ef_goal_bciS001R03.dat'), ...
...%               fullfile(myGetenv('subject_dir'), '6b68ef\data\D6\6b68ef_goal_bci001\6b68ef_goal_bciS001R01.dat'), ...
...%               fullfile(myGetenv('subject_dir'), '6b68ef\data\D6\6b68ef_goal_bci001\6b68ef_goal_bciS001R02.dat'), ...
...%               fullfile(myGetenv('subject_dir'), '6b68ef\data\D6\6b68ef_goal_bci001\6b68ef_goal_bciS001R03.dat'), ...  
            };

%             isbias = [0 0 0 0 0 0];        
            isbias = [0 0 0];        
            
        case '8adc5c'
            % notes from the day
            % signals look good
            % having difficulties
            % fell asleep 1/2way through 3rd and 4th training task
            
            % [ ] review notes from this subject, the bias probabilities seem
            % way too high to be reasonable...
            
            hemi = 'r';
            bads = [];
            controlChannel = 8;

            files = {...
              fullfile(myGetenv('subject_dir'), '8adc5c\data\D7\8adc5c_goal_bci001\8adc5c_goal_bciS001R04.dat'), ...
              fullfile(myGetenv('subject_dir'), '8adc5c\data\D7\8adc5c_goal_bci001\8adc5c_goal_bciS001R05.dat'), ...
              fullfile(myGetenv('subject_dir'), '8adc5c\data\D7\8adc5c_goal_bci001\8adc5c_goal_bciS001R06.dat'), ...
             ... %fullfile(myGetenv('subject_dir'), '8adc5c\data\D7\8adc5c_goal_bci001\8adc5c_goal_bciS001R07.dat'), ...
            };
        
%             isbias = [0 0 0 1]; % This is the actual case of when biasing was enabled if we keep R07, but something completely whacked out the classifier, so I'm going to eliminate this run.            
            isbias = [0 0 0];
    
        case '5050b0'
            % notes are not available for this subject.  Used the hand BCI
            % runs instead because (a) there are more of them and (b) I
            % don't see what control signal channel 32 of the grid would
            % readily be covering.  Potentially foot motor?
            
            hemi = 'r';
            bads = [];
            controlChannel = 8;
            
            files = {
                fullfile(myGetenv('subject_dir'), '5050b0\data\d5\5050b0_goal_bci_hand001\5050b0_goal_bci_handS001R01.dat'), ...
                fullfile(myGetenv('subject_dir'), '5050b0\data\d5\5050b0_goal_bci_hand001\5050b0_goal_bci_handS001R02.dat'), ...
                fullfile(myGetenv('subject_dir'), '5050b0\data\d5\5050b0_goal_bci_hand001\5050b0_goal_bci_handS001R03.dat'), ...
            };
        
            isbias = [0 0 0];
            
        case 'a9952e'
            hemi = 'l';
            bads = [];
            controlChannel = 32;
            
            files = {...
              fullfile(myGetenv('subject_dir'), 'a9952e\data\D9\a9952e_goal_bci001\a9952e_goal_bciS001R03.dat'), ...
              fullfile(myGetenv('subject_dir'), 'a9952e\data\D9\a9952e_goal_bci001\a9952e_goal_bciS001R04.dat'), ...
              fullfile(myGetenv('subject_dir'), 'a9952e\data\D9\a9952e_goal_bci001\a9952e_goal_bciS001R06.dat'), ...
              fullfile(myGetenv('subject_dir'), 'a9952e\data\D9\a9952e_goal_bci001\a9952e_goal_bciS001R07.dat'), ...
            };
        
            isbias = [0 0 1 1];
%             isbias = [0 0 1];
            
        case 'd5cd55'
            % R03 calibrating normalizer, about 16 trials
            % R04 full run, subject showed decent control, was stuck using
            % overt motor movement and not motor imagery
            % R05 full Run w/ Goal inference PT transitioned to motor
            % imagery, control capability suffered
            % R06 re-run model building script using both R04 and R05,
            % again, patient had fairly poor control            
            hemi = 'l';
            bads = [];
            controlChannel = 45;
            
            files = {...
              fullfile(myGetenv('subject_dir'), 'd5cd55\data\D6\d5cd55_goal_bci001\d5cd55_goal_bciS001R03.dat'), ...
              fullfile(myGetenv('subject_dir'), 'd5cd55\data\D6\d5cd55_goal_bci001\d5cd55_goal_bciS001R04.dat'), ...
              fullfile(myGetenv('subject_dir'), 'd5cd55\data\D6\d5cd55_goal_bci001\d5cd55_goal_bciS001R05.dat'), ...
              fullfile(myGetenv('subject_dir'), 'd5cd55\data\D6\d5cd55_goal_bci001\d5cd55_goal_bciS001R06.dat'), ...
            };
        
%             isbias = [0 0 1];
            isbias = [0 0 1 1];
            
         case '9d10c8'
            % Run 3 Overt tongue (12 trials)
            % Run 4 Imagined Tongue, phone call during 1st 4 trials, run
            % paused (not included in analyses)
            % Run 5: New Run of IM Tongue, subject using tongue for up
            % target.  trying to use clicking w/ mouth.  new nurse comes in
            % at trial 16.  subject asks what we are writing at t 22
            % Run 6: 16 more trials still wiggling tongue
            % Run 7: Biasing enabled continued overt motor movement.
            % subject is "in the zone"
            % Run 8: 16 more, nurse comes in to give medicine, cell phone
            % rings loudly nurse gives subject coke at t=11 ( not included
            % in analyses)
            
            hemi = 'l';
            bads = [];
            controlChannel = 14;
            
            files = {...
              fullfile(myGetenv('subject_dir'), '9d10c8\data\d5\9d10c8_goal_bci001\9d10c8_goal_bciS001R03.dat'), ...
              fullfile(myGetenv('subject_dir'), '9d10c8\data\d5\9d10c8_goal_bci001\9d10c8_goal_bciS001R05.dat'), ...
              fullfile(myGetenv('subject_dir'), '9d10c8\data\d5\9d10c8_goal_bci001\9d10c8_goal_bciS001R06.dat'), ...
              fullfile(myGetenv('subject_dir'), '9d10c8\data\d5\9d10c8_goal_bci001\9d10c8_goal_bciS001R07.dat'), ...
              fullfile(myGetenv('subject_dir'), '9d10c8\data\d7\9d10c8_goal_bci001\9d10c8_goal_bciS001R09.dat'), ...
              fullfile(myGetenv('subject_dir'), '9d10c8\data\d7\9d10c8_goal_bci001\9d10c8_goal_bciS001R10.dat'), ...
            };
        
%             isbias = [0 0 1];           
            isbias = [0 0 0 1 1 1]; 
            
        case 'c91479'
            % Control off of 48, Wrist seems to be primary control, but
            % subj needs practice w/ isolation (concurrent arm movement
            % observed)
            %
            % R01 w/ Adaptation
            % R02 w/ Adaptation -> interrupted by dr holmes entering 17/24
            % trials
            % R03 w/o Adaptation, attempting to control, failures,
            % interrupted, very short run
            % R04 w/ adaptation, erratic control
            % R05 w/ adaptation, maybe more promising at end
            % R06 w/ adaptation, trial 7 nurse on speaker, good control in some trials, mid-run
            % R09 w/o adaptation, improved performance compared to last
            % times running GoalBCI
            %
            % Goal BCI session 2
            % R02 w/o adaptation Monitor was off, nurse interrupting
            % R03 w/o adaptation, interruption by nurse
            hemi = 'r';
            bads = [];
%             controlChannel = 48; % later runs were done off 64
            controlChannel = 64;
            
            files = {                
%                 fullfile(myGetenv('subject_dir'), 'c91479\data\d5\c91479_goal_bci001\c91479_goal_bciS001R01.dat'), ...
%                 fullfile(myGetenv('subject_dir'), 'c91479\data\d5\c91479_goal_bci001\c91479_goal_bciS001R02.dat'), ...
%                 fullfile(myGetenv('subject_dir'), 'c91479\data\d5\c91479_goal_bci001\c91479_goal_bciS001R03.dat'), ...
%                 fullfile(myGetenv('subject_dir'), 'c91479\data\d5\c91479_goal_bci001\c91479_goal_bciS001R04.dat'), ...
%                 fullfile(myGetenv('subject_dir'), 'c91479\data\d5\c91479_goal_bci001\c91479_goal_bciS001R05.dat'), ...
%                 fullfile(myGetenv('subject_dir'), 'c91479\data\d5\c91479_goal_bci001\c91479_goal_bciS001R06.dat'), ...
%                 fullfile(myGetenv('subject_dir'), 'c91479\data\d5\c91479_goal_bci001\c91479_goal_bciS001R09.dat'), ...
% %                 fullfile(myGetenv('subject_dir'), 'c91479\data\d5\c91479_goal_bci_session2001\c91479_goal_bci_session2S001R02.dat'), ...
% %                 fullfile(myGetenv('subject_dir'), 'c91479\data\d5\c91479_goal_bci_session2001\c91479_goal_bci_session2S001R03.dat'), ...
                fullfile(myGetenv('subject_dir'), 'c91479\data\d5\c91479_goal_bci_session2_shoulder001\c91479_goal_bci_session2_shoulderS001R01.dat'), ...
                fullfile(myGetenv('subject_dir'), 'c91479\data\d5\c91479_goal_bci_session2_shoulder001\c91479_goal_bci_session2_shoulderS001R02.dat'), ...
                fullfile(myGetenv('subject_dir'), 'c91479\data\d5\c91479_goal_bci_session2_shoulder001\c91479_goal_bci_session2_shoulderS001R03.dat'), ...
                fullfile(myGetenv('subject_dir'), 'c91479\data\d5\c91479_goal_bci_session2_shoulder001\c91479_goal_bci_session2_shoulderS001R04.dat'), ...
                fullfile(myGetenv('subject_dir'), 'c91479\data\d5\c91479_goal_bci_session2_shoulder001\c91479_goal_bci_session2_shoulderS001R05.dat'), ...
                fullfile(myGetenv('subject_dir'), 'c91479\data\d5\c91479_goal_bci_session2_shoulder001\c91479_goal_bci_session2_shoulderS001R06.dat'), ...                
                };

            isbias = [0 0 0 0 0 0];
            
        otherwise
            error('unknown subject entered');            
    end
    
    load(strrep(files{1}, '.dat', '_montage.mat'));
    Montage.BadChannels = bads;    
end

