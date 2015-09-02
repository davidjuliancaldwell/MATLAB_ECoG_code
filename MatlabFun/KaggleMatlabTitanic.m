%%Kaggle Titanic Matlab script 
%from http://blogs.mathworks.com/loren/2015/06/18/getting-started-with-kaggle-data-science-competitions/

%% Data import and preview 
Train = readtable('./MatlabFun/train.csv','Format','%f%f%f%q%C%f%f%f%q%f%q%C');
Test = readtable('./MatlabFun/test.csv','Format','%f%f%q%C%f%f%f%q%f%q%C');
disp(Train(1:5,[2:3 5:8 10:11]))

%% Establish baseline
disp(grpstats(Train(:,{'Survived','Sex'}), 'Sex'));

gendermdl = grpstats(Train(:,{'Survived','Sex'}),{'Survived','Sex'})
all_female = (gendermdl.GroupCount('0_male') + gendermdl.GroupCount('1_female'))/ sum(gendermdl.GroupCount)

%% Examing data
Train.Fare(Train.Fare == 0) = NaN; %treat 0 fare as NaN
Test.Fare(Test.Fare == 0) = NaN; % treat 0 fare as NaN
vars = Train.Properties.VariableNames;

figure
imagesc(ismissing(Train))
ax = gca;
ax.XTick = 1:12;
ax.XTickLabel = vars;
ax.XTickLabelRotation = 90;
title('Missing Values')

%% cleaning up data
avgAge = nanmean(Train.Age)
Train.Age(isnan(Train.Age)) = avgAge;
Test.Age(isnan(Test.Age)) = avgAge;

fare = grpstats(Train(:,{'Pclass','Fare'}),'Pclass'); %get class average 
disp(fare)
for i = 1:height(fare) % for each |Pclass|
    % apply the class average to missing values
    Train.Fare(Train.Pclass == i & isnan(Train.Fare)) = fare.mean_Fare(i);
    Test.Fare(Test.Pclass == i & isnan(Test.Fare)) = fare.mean_Fare(i);
end

% tokenize the text string by white space
train_cabins = cellfun(@strsplit, Train.Cabin, 'UniformOutput', false);
test_cabins = cellfun(@strsplit, Test.Cabin, 'UniformOutput', false);

% count the number of tokens
Train.nCabins = cellfun(@length, train_cabins);
Test.nCabins = cellfun(@length, test_cabins);

% deal with exceptions - only the first class people had multiple cabins
Train.nCabins(Train.Pclass ~= 1 & Train.nCabins > 1,:) = 1;
Test.nCabins(Test.Pclass ~= 1 & Test.nCabins >1,:) = 1;

% if |Cabin| is empty, then |nCabins| should be 0
Train.nCabins(cellfun(@isempty, Train.Cabin)) = 0;
Test.nCabins(cellfun(@isempty, Test.Cabin)) = 0;

% get most frequent value
freqVal = mode(Train.Embarked);

% apply to missing value
Train.Embarked(isundefined(Train.Embarked)) = freqVal;
Test.Embarked(isundefined(Test.Embarked)) = freqVal;

% convert the data tye from categorical to double
Train.Embarked = double(Train.Embarked);
Test.Embarked = double(Test.Embarked);

% sex to numeric variable
Train.Sex = double(Train.Sex);
Test.Sex = double(Test.Sex);

% remove variables don't want to use
Train(:,{'Name','Ticket','Cabin'}) = [];
Test(:,{'Name','Ticket','Cabin'}) = [];

%% Exploratory data analysis and visualization

figure
histogram(Train.Age(Train.Survived == 0)) % age histogram of non-survivors
hold on
histogram(Train.Age(Train.Survived == 1)) % age histogram of survivors
hold off
legend('Didn''t Survive', 'Survived')
title('The Titanic Passenger Age Distribution')

%% feature engineering

% group values into separate bins
Train.AgeGroup = double(discretize(Train.Age, [0:10:20 65 80], ...
    'categorical',{'child','teen','adult','senior'}));
Test.AgeGroup = double(discretize(Test.Age, [0:10:20 65 80], ...
    'categorical',{'child','teen','adult','senior'}));

figure
histogram(Train.Fare(Train.Survived == 0)); % fare histogram of non-survivors
hold on
histogram(Train.Fare(Train.Survived == 1), 0:10:520); % fare histogram of survivors
hold off
legend('Didn''t Survive', 'Survived')
title('The Titanic Passenger Fare Distribution')

% group values into separate bins
Train.FareRange = double(discretize(Train.Fare, [0:10:30, 100, 520], ...
    'categorical',{'<10','10-20','20-30','30-100','>100'}));
Test.FareRange = double(discretize(Test.Fare, [0:10:30, 100, 520], ...
    'categorical',{'<10','10-20','20-30','30-100','>100'}));

%% after training random forest (bagged trees) classifier 
% use trainedClassifier on Test

yfit = predict(trainedClassifier, Test{:,trainedClassifier.PredictorNames});

%% generate random forest model programmatically using treebagger

Y_train = Train.Survived; %slice response variable
X_train = Train(:,3:end); %select predictor variables
vars = X_train.Properties.VariableNames; %get variable names
X_train = table2array(X_train); %convert to a numeric matrix
X_test = table2array(Test(:,2:end)); % convert to a numeric matrix
categoricalPredictors = {'Pclass','Sex','Embarked','AgeGroup','FareRange'};
rng(1) % for reproducibility
c = cvpartition(Y_train,'holdout',0.30); % 30% holdout cross validation

% generate random forest model. get out of bag sampling accuracy metric,
% similar to error metric from k-fold cross validation. Generate random
% indices from cvpartition object c to partition dataset for training

RF = TreeBagger(200, X_train(training(c),:), Y_train(training(c)),...
    'PredictorNames', vars, 'Method', 'classification',...
    'CategoricalPredictors', categoricalPredictors, 'oobvarimp', 'on');

% compute out of bag accuracy
oobAccuracy = 1 - oobError(RF, 'mode', 'ensemble')

%% feature importance metric

[~,order] = sort(RF.OOBPermutedVarDeltaError); % sort the metrics
figure
barh(RF.OOBPermutedVarDeltaError(order)) % horizontal bar chart 
title('Feature Importance Metric')
ax = gca; ax.YTickLabel = vars(order); % variable names as labels

%% model evaluation - check it against hold out data

[Yfit, Yscore] = predict(RF, X_train(test(c),:)); % use holdout data 
cfm = confusionmat(Y_train(test(c)), str2double(Yfit)); % confusion matrix
cvAccuracy = sum(cfm(logical(eye(2))))/length(Yfit)

%% perfcurve plot

posClass = strcmp(RF.ClassNames,'1'); % get index of positive class
curves = zeros(2,1); labels = cell(2,1); % pre-allocated variables
[rocX, rocY, ~, auc] = perfcurve(Y_train(test(c)),Yscore(:,posClass),'1');
figure
curves(1) = plot(rocX, rocY); % use perfcurve output to plot
labels{1} = sprintf('Random Forest - AUC: %.1f%%', auc*100);
curves(end) = refline(1,0); set(curves(end),'Color','r');
labels{end} = 'Reference Line - a random classifier';
xlabel('False Positive Rate')
ylabel('True Positive Rate')
title('ROC Plot')
legend(curves, labels, 'Location', 'SouthEast')

%% create submission file 

PassengerID = Test.PassengerId; % extract passenger Ids
Survived = predict(RF, X_Test); % generate response variable
Survived = str2double(Survived); % convert to double
submission = table(PassengerId,Survived); % combine them into a table
disp(submission(1:5,:)) % preview table
writetable(submission,'submission.csv') % write to CSV 



