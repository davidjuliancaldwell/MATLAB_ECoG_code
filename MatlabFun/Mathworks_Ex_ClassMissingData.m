%% Classification in the presence of missing data

%% Load data for classification
rng(5); % for reproducibility
load ionosphere
labels = unique(Y);

%% partition 70% of data into a training set, 30% into Test

% training and test are used on objects from cvpartition
cv = cvpartition(Y,'holdout',0.3);
Xtrain = X(training(cv),:);
Ytrain = Y(training(cv));
Xtest = X(test(cv),:);
Ytest = Y(test(cv));

%% use bagged decision trees to classify the ionosphere data

% Classification tree is chosen as the learner
mdl1 = ClassificationTree.template('NvarToSample','all');
RF1 = fitensemble(Xtrain,Ytrain,'Bag',150,mdl1,'type','classification');

% classification tree with surrogate splits is chosen as the learner
mdl2 = ClassificationTree.template('NVarToSample','all','surrogate','on');
RF2 = fitensemble(Xtrain,Ytrain,'Bag',150,mdl2,'type','classification');

% suppose half of values in test set are missing
Xtest(rand(size(Xtest))>0.5) = NaN;

%% predict responses with both approaches 

y_pred1 = predict(RF1,Xtest);
confmat1 = confusionmat(Ytest,y_pred1);

y_pred2 = predict(RF2,Xtest);
confmat2 = confusionmat(Ytest,y_pred2);

disp('Confusion Matrix - without surrogates')
disp(confmat1)
disp('Confusion Matrix - with surrogates')
disp(confmat2)

%% visualize misclassification error

figure
subplot(2,2,1:2)
plot(loss(RF1,Xtest,Ytest,'mode','cumulative'),'LineWidth',3);
hold on;
plot(loss(RF2,Xtest,Ytest,'mode','cumulative'),'r','LineWidth',3);
legend('Regular trees','Trees with surrogate splits');
xlabel('Number of trees');
ylabel('Test classification error','FontSize',12);

subplot(2,2,3)
[hImage, hText, hXText] = heatmap(confmat1, labels, labels, 1,'Colormap','red','ShowAllTicks',1);
title('Confusion Matrix - without surrogates')
subplot(2,2,4)
heatmap(confmat2, labels, labels, 1,'Colormap','red','ShowAllTicks',1);
title('Confusion Matrix - with surrogates')