%% clustering machine learning example from Mathworks

%% load data
clear
load fisheriris 
X = meas;
y = categorical(species);

%% evaluate multiple clusters from 1 to 10 to find optimal cluster

eva = evalclusters(X,'kmeans','CalinskiHarabasz','Klist',[1:10]);
plot(eva)
disp(categories(y)')

%% dimensionality reduction for visualization

% since none of our features are negative, lets use nnmf to confirm the 3
% clusters visually

Xred = nnmf(X,2);
gscatter(Xred(:,1),Xred(:,2),y)
xlabel('Column 1')
ylabel('Column 2')
legend(categories(y))
grid on