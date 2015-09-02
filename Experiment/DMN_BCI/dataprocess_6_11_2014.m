%%acquire data from 4 patients 
addpath(genpath(fullfile('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects')))

%patient a557cc
%no real data?


%patient 3f5a8c - 6/16/2014- updated to include notes from laboratory
%notebook 
%day 6 - 2 target
%[sig_3f5a8c_d6_r01, sta_3f5a8c_d6_r01, par_3f5a8c_d6_r01] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\3f5a8c\data\d6\3f5a8c_ud_dmn001\3f5a8c_ud_dmnS001R01.dat');
[sig_3f5a8c_d6_r02, sta_3f5a8c_d6_r02, par_3f5a8c_d6_r02] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\3f5a8c\data\d6\3f5a8c_ud_dmn001\3f5a8c_ud_dmnS001R02.dat');
[sig_3f5a8c_d6_r03, sta_3f5a8c_d6_r03, par_3f5a8c_d6_r03] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\3f5a8c\data\d6\3f5a8c_ud_dmn001\3f5a8c_ud_dmnS001R03.dat');
[sig_3f5a8c_d6_r04, sta_3f5a8c_d6_r04, par_3f5a8c_d6_r04] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\3f5a8c\data\d6\3f5a8c_ud_dmn001\3f5a8c_ud_dmnS001R04.dat');

%day 7 - 2 target 
%[sig_3f5a8c_d7_r01, sta_3f5a8c_d7_r01, par_3f5a8c_d7_r01] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\3f5a8c\data\d7\3f5a8c_ud_dmn001\3f5a8c_ud_dmnS001R01.dat');
%[sig_3f5a8c_d7_r02, sta_3f5a8c_d7_r02, par_3f5a8c_d7_r02] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\3f5a8c\data\d7\3f5a8c_ud_dmn001\3f5a8c_ud_dmnS001R02.dat');
%[sig_3f5a8c_d7_r03, sta_3f5a8c_d7_r03, par_3f5a8c_d7_r03] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\3f5a8c\data\d7\3f5a8c_ud_dmn001\3f5a8c_ud_dmnS001R03.dat');
[sig_3f5a8c_d7_r04, sta_3f5a8c_d7_r04, par_3f5a8c_d7_r04] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\3f5a8c\data\d7\3f5a8c_ud_dmn001\3f5a8c_ud_dmnS001R04.dat');
[sig_3f5a8c_d7_r05, sta_3f5a8c_d7_r05, par_3f5a8c_d7_r05] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\3f5a8c\data\d7\3f5a8c_ud_dmn001\3f5a8c_ud_dmnS001R05.dat');

%day6/7 - 3 target
[sig_3f5a8c_d6_3targ_r01, sta_3f5a8c_d6_3targ_r01, par_3f5a8c_d6_3targ_r01] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\3f5a8c\data\d6\3f5a8c_ud_dmn_3targ001\3f5a8c_ud_dmn_3targS001R01.dat');
[sig_3f5a8c_d6_3targ_r02, sta_3f5a8c_d6_3targ_r02, par_3f5a8c_d6_3targ_r02] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\3f5a8c\data\d6\3f5a8c_ud_dmn_3targ001\3f5a8c_ud_dmn_3targS001R02.dat');

[sig_3f5a8c_d7_r06, sta__3f5a8c_d7_r06, par_3f5a8c_d7_r06] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\3f5a8c\data\d7\3f5a8c_ud_dmn001\3f5a8c_ud_dmnS001R06.dat');

%patient 9d10c8
%day 13 - 2 target 
%[sig_9d10c8_d13_r01, sta_9d10c8_d13_r01, par_9d10c8_d13_r01] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\9d10c8\data\d13\9d10c8_ud_dmn001\9d10c8_ud_dmnS001R01.dat');
[sig_9d10c8_d13_r02, sta_9d10c8_d13_r02, par_9d10c8_d13_r02] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\9d10c8\data\d13\9d10c8_ud_dmn001\9d10c8_ud_dmnS001R02.dat');
[sig_9d10c8_d13_r03, sta_9d10c8_d13_r03, par_9d10c8_d13_r03] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\9d10c8\data\d13\9d10c8_ud_dmn001\9d10c8_ud_dmnS001R03.dat');
[sig_9d10c8_d13_r04, sta_9d10c8_d13_r04, par_9d10c8_d13_r04] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\9d10c8\data\d13\9d10c8_ud_dmn001\9d10c8_ud_dmnS001R04.dat');
%[sig_9d10c8_d13_r05, sta_9d10c8_d13_r05, par_9d10c8_d13_r05] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\9d10c8\data\d13\9d10c8_ud_dmn001\9d10c8_ud_dmnS001R05.dat');
%[sig_9d10c8_d13_r07, sta_9d10c8_d13_r07, par_9d10c8_d13_r07] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\9d10c8\data\d13\9d10c8_ud_dmn001\9d10c8_ud_dmnS001R07.dat');
%[sig_9d10c8_d13_r08, sta_9d10c8_d13_r08, par_9d10c8_d13_r08] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\9d10c8\data\d13\9d10c8_ud_dmn001\9d10c8_ud_dmnS001R08.dat');

% day 13 - 3 target
[sig_9d10c8_d13_r06, sta_9d10c8_d13_r06, par_9d10c8_d13_r06] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\9d10c8\data\d13\9d10c8_ud_dmn001\9d10c8_ud_dmnS001R06.dat');

%patient bf889c
%day 4
[sig_bf889c_d4_r01, sta_bf889c_d4_r01, par_bf889c_d4_r01] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\bf889c\data\d4\bf889c_ud_dmn001\bf889c_ud_dmnS001R01.dat');
[sig_bf889c_d4_r02, sta_bf889c_d4_r02, par_bf889c_d4_r02] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\bf889c\data\d4\bf889c_ud_dmn001\bf889c_ud_dmnS001R02.dat');

%day 5
[sig_bf889c_d5_r01, sta_bf889c_d5_r01, par_bf889c_d5_r01] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\bf889c\data\d5\bf889c_ud_dmn001\bf889c_ud_dmnS001R01.dat');
[sig_bf889c_d5_r02, sta_bf889c_d5_r02, par_bf889c_d5_r02] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\bf889c\data\d5\bf889c_ud_dmn001\bf889c_ud_dmnS001R02.dat');
[sig_bf889c_d5_r03, sta_bf889c_d5_r03, par_bf889c_d5_r03] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\bf889c\data\d5\bf889c_ud_dmn001\bf889c_ud_dmnS001R03.dat');
[sig_bf889c_d5_r04, sta_bf889c_d5_r04, par_bf889c_d5_r04] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\bf889c\data\d5\bf889c_ud_dmn001\bf889c_ud_dmnS001R04.dat');
[sig_bf889c_d5_r05, sta_bf889c_d5_r05, par_bf889c_d5_r05] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\bf889c\data\d5\bf889c_ud_dmn001\bf889c_ud_dmnS001R05.dat');
[sig_bf889c_d5_r06, sta_bf889c_d5_r06, par_bf889c_d5_r06] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\bf889c\data\d5\bf889c_ud_dmn001\bf889c_ud_dmnS001R06.dat');
    
%% after loading, use sta to look at types of data available and PlotStates to look at data overall (this here is the general procedure)
[sig, sta, par] = load_bcidatUI();
sta
PlotStates(sta, par)

% compute number of trials completed using .Feedbac
x = diff(double(sta.Feedback)); %compute difference along vector of Feedback
ind = find(x<0); %find indices of feedback transition from 1 to 0 (difference of -1), representing a completed trial
y = size(ind); % vector of completed trials 
num_trials_complete = y(1)

%Compare target and results at each point of completed trial
target = double(sta.TargetCode(ind))
result = double(sta.ResultCode(ind+1)) %to account for delay

success = sum(target==result)/length(target)

%binom chance
[chance, hv, lv] = chanceBinom(.5,num_trials_complete,1000)

%plot bar graph 
y = [chance, success]

%% analysis for patient 3f5a8c
patient_3f5a8c = [sta_3f5a8c_d6_r02 sta_3f5a8c_d6_r03 sta_3f5a8c_d6_r04 sta_3f5a8c_d7_r04 sta_3f5a8c_d7_r05]';
patient_3f5a8c_feedback = {patient_3f5a8c(1).Feedback; patient_3f5a8c(2).Feedback; patient_3f5a8c(3).Feedback; patient_3f5a8c(4).Feedback; patient_3f5a8c(5).Feedback};
patient_3f5a8c_target = {patient_3f5a8c(1).TargetCode; patient_3f5a8c(2).TargetCode; patient_3f5a8c(3).TargetCode; patient_3f5a8c(4).TargetCode; patient_3f5a8c(5).TargetCode};
patient_3f5a8c_result = {patient_3f5a8c(1).ResultCode; patient_3f5a8c(2).ResultCode; patient_3f5a8c(3).ResultCode; patient_3f5a8c(4).ResultCode; patient_3f5a8c(5).ResultCode};

% convert all of the data to type double for analysis 
patient_3f5a8c_feedback = cellfun(@double, patient_3f5a8c_feedback, 'UniformOutput', false);
patient_3f5a8c_target = cellfun(@double, patient_3f5a8c_target, 'UniformOutput', false);
patient_3f5a8c_result = cellfun(@double, patient_3f5a8c_result, 'UniformOutput', false);

% compute indices of transitions for all data, keep it in cells 
x1 = cellfun(@diff, patient_3f5a8c_feedback, 'UniformOutput', false);
ind1 = cellfun(@(x) find(x<0),x1, 'UniformOutput', false);
y1 = cellfun(@(x) size(x), ind1, 'UniformOutput', false);
num_trials_complete1 = cellfun(@(x)x(1), y1); %extract from the array, not the cell!!!

% use for loops to create cells that at each cell location have an array
% comprised of all of the target or resultcode numbers at that location 

patient_3f5a8c_targetind = cell(1,length(num_trials_complete1));
for i = 1:length(patient_3f5a8c_target)
    patient_3f5a8c_targetind{i} = patient_3f5a8c_target{i}(ind1{i});
end

patient_3f5a8c_resultind = cell(1,length(num_trials_complete1));
for i = 1:length(patient_3f5a8c_result)
    patient_3f5a8c_resultind{i} = patient_3f5a8c_result{i}(ind1{i}+1);
end

% compare using @eq the resultind and targetind at each point, then sum
% each cell to acquire the total number of successful trials for each run
% (per cell) 
patient_3f5a8c_compare = cellfun(@eq,patient_3f5a8c_resultind,patient_3f5a8c_targetind,'UniformOutput',false);
patient_3f5a8c_comparesum = cellfun(@sum,patient_3f5a8c_compare);

% compute success (on a scale of 0 to 1)
success_3f5a8c = patient_3f5a8c_comparesum./num_trials_complete1';

%pre initialize and compute chance variables 
chance_3f5a8c = zeros(1,length(success_3f5a8c));
hv_3f5a8c = zeros(1,length(success_3f5a8c));
lv_3f5a8c = zeros(1,length(success_3f5a8c));

% create array of chances for individual comparisons
for i = 1:length(success_3f5a8c)
    [chance_3f5a8c(i), hv_3f5a8c(i), lv_3f5a8c(i)] = chanceBinom(.5,num_trials_complete1(i),1000);
end

% create single value of chances for combined and aggregated data

[chance_3f5a8c_comb, hv_3f5a8c_comb, lv_3f5a8c_comb] = chanceBinom(.5,sum(num_trials_complete1),1000);
% bring it all together, do a weighted average of success, compare to total
% chance

success_3f5a8c_comb = sum(patient_3f5a8c_comparesum)/sum(num_trials_complete1);

bar_data = [success_3f5a8c_comb, hv_3f5a8c_comb];
bar(bar_data)
title('Success vs. Chance for DMN BCI')
xlabel('patients')
ylabel('proportion sucess')
legend('success', 'chance')

%% analysis for patient 9d10c8

patient_9d10c8 = [sta_9d10c8_d13_r02 sta_9d10c8_d13_r03 sta_9d10c8_d13_r04];
patient_9d10c8_feedback = {patient_9d10c8(1).Feedback; patient_9d10c8(2).Feedback; patient_9d10c8(3).Feedback};
patient_9d10c8_target = {patient_9d10c8(1).TargetCode; patient_9d10c8(2).TargetCode; patient_9d10c8(3).TargetCode};
patient_9d10c8_result = {patient_9d10c8(1).ResultCode; patient_9d10c8(2).ResultCode; patient_9d10c8(3).ResultCode};

% convert all of the data to type double for analysis 
patient_9d10c8_feedback = cellfun(@double, patient_9d10c8_feedback, 'UniformOutput', false);
patient_9d10c8_target = cellfun(@double, patient_9d10c8_target, 'UniformOutput', false);
patient_9d10c8_result = cellfun(@double, patient_9d10c8_result, 'UniformOutput', false);


% compute indices of transitions for all data, keep it in cells 
x2 = cellfun(@diff, patient_9d10c8_feedback, 'UniformOutput', false);
ind2 = cellfun(@(x) find(x<0),x2, 'UniformOutput', false);
y2 = cellfun(@(x) size(x), ind2, 'UniformOutput', false);
num_trials_complete2 = cellfun(@(x)x(1), y2); %extract from the array, not the cell!!!

patient_9d10c8_targetind = cell(1,length(num_trials_complete2));
for i = 1:length(patient_9d10c8_target)
    patient_9d10c8_targetind{i} = patient_9d10c8_target{i}(ind2{i});
end

patient_9d10c8_resultind = cell(1,length(num_trials_complete2));
for i = 1:length(patient_9d10c8_result)
    patient_9d10c8_resultind{i} = patient_9d10c8_result{i}(ind2{i}+1);
end

% compare using @eq the resultind and targetind at each point, then sum
% each cell to acquire the total number of successful trials for each run
% (per cell) 
patient_9d10c8_compare = cellfun(@eq,patient_9d10c8_resultind,patient_9d10c8_targetind,'UniformOutput',false);
patient_9d10c8_comparesum = cellfun(@sum,patient_9d10c8_compare);

% compute success (on a scale of 0 to 1)
success_9d10c8 = patient_9d10c8_comparesum./num_trials_complete2';

%pre initialize and compute chance variables 
chance_9d10c8 = zeros(1,length(success_9d10c8));
hv_9d10c8 = zeros(1,length(success_9d10c8));
lv_9d10c8 = zeros(1,length(success_9d10c8));

% create array of chances for individual comparisons
for i = 1:length(success_9d10c8)
    [chance_9d10c8(i), hv_9d10c8(i), lv_9d10c8(i)] = chanceBinom(.5,num_trials_complete2(i),1000);
end

% create single value of chances for combined and aggregated data

[chance_9d10c8_comb, hv_9d10c8_comb, lv_9d10c8_comb] = chanceBinom(.5,sum(num_trials_complete2),1000);
% bring it all together, do a weighted average of success, compare to total
% chance

success_9d10c8_comb = sum(patient_9d10c8_comparesum)/sum(num_trials_complete2);

%% analysis for patient bf889c 

patient_bf889c = [sta_bf889c_d4_r01 sta_bf889c_d4_r02];

patient_bf889c_feedback = {patient_bf889c(1).Feedback; patient_bf889c(2).Feedback};
patient_bf889c_target = {patient_bf889c(1).TargetCode; patient_bf889c(2).TargetCode};
patient_bf889c_result = {patient_bf889c(1).ResultCode; patient_bf889c(2).ResultCode};

% convert all of the data to type double for analysis 
patient_bf889c_feedback = cellfun(@double, patient_bf889c_feedback, 'UniformOutput', false);
patient_bf889c_target = cellfun(@double, patient_bf889c_target, 'UniformOutput', false);
patient_bf889c_result = cellfun(@double, patient_bf889c_result, 'UniformOutput', false);


% compute indices of transitions for all data, keep it in cells 
x3 = cellfun(@diff, patient_bf889c_feedback, 'UniformOutput', false);
ind3 = cellfun(@(x) find(x<0),x3, 'UniformOutput', false);
y3 = cellfun(@(x) size(x), ind3, 'UniformOutput', false);
num_trials_complete3 = cellfun(@(x)x(1), y3); %extract from the array, not the cell!!!

patient_bf889c_targetind = cell(1,length(num_trials_complete3));
for i = 1:length(patient_bf889c_target)
    patient_bf889c_targetind{i} = patient_bf889c_target{i}(ind3{i});
end

patient_bf889c_resultind = cell(1,length(num_trials_complete3));
for i = 1:length(patient_bf889c_result)
    patient_bf889c_resultind{i} = patient_bf889c_result{i}(ind3{i}+1);
end

% compare using @eq the resultind and targetind at each point, then sum
% each cell to acquire the total number of successful trials for each run
% (per cell) 
patient_bf889c_compare = cellfun(@eq,patient_bf889c_resultind,patient_bf889c_targetind,'UniformOutput',false);
patient_bf889c_comparesum = cellfun(@sum,patient_bf889c_compare);

% compute success (on a scale of 0 to 1)
success_bf889c = patient_bf889c_comparesum./num_trials_complete3';

%pre initialize and compute chance variables 
chance_bf889c = zeros(1,length(success_bf889c));
hv_bf889c = zeros(1,length(success_bf889c));
lv_bf889c = zeros(1,length(success_bf889c));

% create array of chances for individual comparisons
for i = 1:length(success_bf889c)
    [chance_bf889c(i), hv_bf889c(i), lv_bf889c(i)] = chanceBinom(.5,num_trials_complete3(i),1000);
end

% create single value of chances for combined and aggregated data

[chance_bf889c_comb, hv_bf889c_comb, lv_bf889c_comb] = chanceBinom(.5,sum(num_trials_complete3),1000);
% bring it all together, do a weighted average of success, compare to total
% chance

success_bf889c_comb = sum(patient_bf889c_comparesum)/sum(num_trials_complete3);
%% bar graph 

bar_data = [success_3f5a8c_comb chance_3f5a8c_comb; success_9d10c8_comb chance_9d10c8_comb; success_bf889c_comb chance_bf889c_comb; success_3f5a8c_3targ_comb chance_3f5a8c_3targ_comb; success_9d10c8_3targ_comb chance_9d10c8_3targ_comb];
bar(bar_data)
title('Success vs. Chance for DMN BCI','fontsize',14,'fontweight','bold')
xlabel('Patients and Task','fontsize',12,'fontweight','bold')
ylabel('Proportion Success','fontsize',12,'fontweight','bold')
set(gca,'XtickLabel',{'3f5a8c 2 target','9d10c8 2 target', 'bf889c 2 target', '3f5a8c 3 target', '9d10c8 3 target'})
ylim([0,1])

hold on
line([1 1.3], [hv_3f5a8c_comb hv_3f5a8c_comb], 'linestyle', '--','linewidth',3)
line([2 2.3], [hv_9d10c8_comb hv_9d10c8_comb], 'linestyle', '--','linewidth',3)
line([3 3.3], [hv_bf889c_comb hv_bf889c_comb], 'linestyle', '--','linewidth',3)
line([4 4.3], [hv_3f5a8c_3targ_comb hv_3f5a8c_3targ_comb], 'linestyle', '--','linewidth',3)
line([5 5.3], [hv_9d10c8_3targ_comb hv_9d10c8_3targ_comb], 'linestyle', '--','linewidth',3)
legend('Success', 'Chance', '95% confidence interval')



%% new way to do data all at once? 
for i = 1:9
    x1 = diff(double(patient_3f5a8c(i).Feedback));
    ind1 = find(x<0);
    y1(i)=size(ind);
    num_trials_complete1(i)=y1(i);
    
%     patient_3f5a8c_target = double(patient_3f5a8c(i).TargetCode);
%     patient_3f5a8c_result = double(patient_3f5a8c(i).ResultCode);
%     patient_3f5a8c_targentind = patient_3f5a8c_target(ind1);
%     patient_3f5a8c_resultind = patient_3f5a8c_result(ind1+1);
%     
%     
%     success_3f5a8c(i) = sum(patient_3f5a8c_resultind==patient_3f5a8c_targentind)/length(patient_3f5a8c_resultind);
    
    %[chance_3f5a8c(i), hv_3f5a8c(i), lv_3f5a8c(i)] = chanceBinom(.5,num_trials_complete1(i),1000);

end

%% 3 target 

%patient 3f5a8c
%day6/7 - 3 target - input data 
[sig_3f5a8c_d6_3targ_r01, sta_3f5a8c_d6_3targ_r01, par_3f5a8c_d6_3targ_r01] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\3f5a8c\data\d6\3f5a8c_ud_dmn_3targ001\3f5a8c_ud_dmn_3targS001R01.dat');
[sig_3f5a8c_d6_3targ_r02, sta_3f5a8c_d6_3targ_r02, par_3f5a8c_d6_3targ_r02] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\3f5a8c\data\d6\3f5a8c_ud_dmn_3targ001\3f5a8c_ud_dmn_3targS001R02.dat');

[sig_3f5a8c_d7_r06, sta__3f5a8c_d7_r06, par_3f5a8c_d7_r06] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\3f5a8c\data\d7\3f5a8c_ud_dmn001\3f5a8c_ud_dmnS001R06.dat');

% convert data to cell from structure
patient_3f5a8c_3targ = [sta_3f5a8c_d6_3targ_r01 sta_3f5a8c_d6_3targ_r02 sta__3f5a8c_d7_r06]';
patient_3f5a8c_3targ_feedback = {patient_3f5a8c_3targ(1).Feedback; patient_3f5a8c_3targ(2).Feedback; patient_3f5a8c_3targ(3).Feedback};
patient_3f5a8c_3targ_target = {patient_3f5a8c_3targ(1).TargetCode; patient_3f5a8c_3targ(2).TargetCode; patient_3f5a8c_3targ(3).TargetCode};
patient_3f5a8c_3targ_result = {patient_3f5a8c_3targ(1).ResultCode; patient_3f5a8c_3targ(2).ResultCode; patient_3f5a8c_3targ(3).ResultCode};

% convert all of the data to type double for analysis 
patient_3f5a8c_3targ_feedback = cellfun(@double, patient_3f5a8c_3targ_feedback, 'UniformOutput', false);
patient_3f5a8c_3targ_target = cellfun(@double, patient_3f5a8c_3targ_target, 'UniformOutput', false);
patient_3f5a8c_3targ_result = cellfun(@double, patient_3f5a8c_3targ_result, 'UniformOutput', false);

% compute indices of transitions for all data, keep it in cells 
x1_3targ = cellfun(@diff, patient_3f5a8c_3targ_feedback, 'UniformOutput', false);
ind1_3targ = cellfun(@(x) find(x<0),x1_3targ, 'UniformOutput', false);
y1_3targ = cellfun(@(x) size(x), ind1_3targ, 'UniformOutput', false);
num_trials_complete1_3targ = cellfun(@(x)x(1), y1_3targ); %extract from the array, not the cell!!!

% use for loops to create cells that at each cell location have an array
% comprised of all of the target or resultcode numbers at that location 

patient_3f5a8c_3targ_targetind = cell(1,length(num_trials_complete1_3targ));
for i = 1:length(patient_3f5a8c_3targ_target)
    patient_3f5a8c_3targ_targetind{i} = patient_3f5a8c_3targ_target{i}(ind1_3targ{i});
end

patient_3f5a8c_3targ_resultind = cell(1,length(num_trials_complete1_3targ));
for i = 1:length(patient_3f5a8c_3targ_result)
    patient_3f5a8c_3targ_resultind{i} = patient_3f5a8c_3targ_result{i}(ind1_3targ{i}+1);
end

% compare using @eq the resultind and targetind at each point, then sum
% each cell to acquire the total number of successful trials for each run
% (per cell) 
patient_3f5a8c_3targ_compare = cellfun(@eq,patient_3f5a8c_3targ_resultind,patient_3f5a8c_3targ_targetind,'UniformOutput',false);
patient_3f5a8c_3targ_comparesum = cellfun(@sum,patient_3f5a8c_3targ_compare);

% compute success (on a scale of 0 to 1)
success_3f5a8c_3targ = patient_3f5a8c_3targ_comparesum./num_trials_complete1_3targ';

%pre initialize and compute chance variables 
chance_3f5a8c_3targ = zeros(1,length(success_3f5a8c_3targ));
hv_3f5a8c_3targ = zeros(1,length(success_3f5a8c_3targ));
lv_3f5a8c_3targ = zeros(1,length(success_3f5a8c_3targ));

% create array of chances for individual comparisons
for i = 1:length(success_3f5a8c_3targ)
    [chance_3f5a8c_3targ(i), hv_3f5a8c_3targ(i), lv_3f5a8c_3targ(i)] = chanceBinom(1/3,num_trials_complete1_3targ(i),1000);
end

% create single value of chances for combined and aggregated data

[chance_3f5a8c_3targ_comb, hv_3f5a8c_3targ_comb, lv_3f5a8c_3targ_comb] = chanceBinom(1/3,sum(num_trials_complete1_3targ),1000);
% bring it all together, do a weighted average of success, compare to total
% chance

success_3f5a8c_3targ_comb = sum(patient_3f5a8c_3targ_comparesum)/sum(num_trials_complete1_3targ);
%%
%patient 9d10c8
% day 13 - 3 target
[sig_9d10c8_d13_r06, sta_9d10c8_d13_r06, par_9d10c8_d13_r06] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\9d10c8\data\d13\9d10c8_ud_dmn001\9d10c8_ud_dmnS001R06.dat');

patient_9d10c8_3targ = [sta_9d10c8_d13_r06]';
patient_9d10c8_3targ_feedback = {patient_9d10c8_3targ(1).Feedback};
patient_9d10c8_3targ_target = {patient_9d10c8_3targ(1).TargetCode};
patient_9d10c8_3targ_result = {patient_9d10c8_3targ(1).ResultCode};

% convert all of the data to type double for analysis 
patient_9d10c8_3targ_feedback = cellfun(@double, patient_9d10c8_3targ_feedback, 'UniformOutput', false);
patient_9d10c8_3targ_target = cellfun(@double, patient_9d10c8_3targ_target, 'UniformOutput', false);
patient_9d10c8_3targ_result = cellfun(@double, patient_9d10c8_3targ_result, 'UniformOutput', false);

% compute indices of transitions for all data, keep it in cells 
x2_3targ = cellfun(@diff, patient_9d10c8_3targ_feedback, 'UniformOutput', false);
ind2_3targ = cellfun(@(x) find(x<0),x2_3targ, 'UniformOutput', false);
y2_3targ = cellfun(@(x) size(x), ind2_3targ, 'UniformOutput', false);
num_trials_complete2_3targ = cellfun(@(x)x(1), y2_3targ); %extract from the array, not the cell!!!

% use for loops to create cells that at each cell location have an array
% comprised of all of the target or resultcode numbers at that location 

patient_9d10c8_3targ_targetind = cell(1,length(num_trials_complete2_3targ));
for i = 1:length(patient_9d10c8_3targ_target)
    patient_9d10c8_3targ_targetind{i} = patient_9d10c8_3targ_target{i}(ind2_3targ{i});
end

patient_9d10c8_3targ_resultind = cell(1,length(num_trials_complete2_3targ));
for i = 1:length(patient_9d10c8_3targ_result)
    patient_9d10c8_3targ_resultind{i} = patient_9d10c8_3targ_result{i}(ind2_3targ{i}+1);
end

% compare using @eq the resultind and targetind at each point, then sum
% each cell to acquire the total number of successful trials for each run
% (per cell) 
patient_9d10c8_3targ_compare = cellfun(@eq,patient_9d10c8_3targ_resultind,patient_9d10c8_3targ_targetind,'UniformOutput',false);
patient_9d10c8_3targ_comparesum = cellfun(@sum,patient_9d10c8_3targ_compare);

% compute success (on a scale of 0 to 1)
success_9d10c8_3targ = patient_9d10c8_3targ_comparesum./num_trials_complete2_3targ';

%pre initialize and compute chance variables 
chance_9d10c8_3targ = zeros(1,length(success_9d10c8_3targ));
hv_9d10c8_3targ = zeros(1,length(success_9d10c8_3targ));
lv_9d10c8_3targ = zeros(1,length(success_9d10c8_3targ));

% create array of chances for individual comparisons, assume binomial
% distribution with a probability of 1/3, so p = 1/3 
for i = 1:length(success_9d10c8_3targ)
    [chance_9d10c8_3targ(i), hv_9d10c8_3targ(i), lv_9d10c8_3targ(i)] = chanceBinom(1/3,num_trials_complete2_3targ(i),1000);
end

% create single value of chances for combined and aggregated data

[chance_9d10c8_3targ_comb, hv_9d10c8_3targ_comb, lv_9d10c8_3targ_comb] = chanceBinom(1/3,sum(num_trials_complete2_3targ),1000);
% bring it all together, do a weighted average of success, compare to total
% chance

success_9d10c8_3targ_comb = sum(patient_9d10c8_3targ_comparesum)/sum(num_trials_complete2_3targ);

