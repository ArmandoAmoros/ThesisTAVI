%% Box Plots
data1 = 1;
for i = 1:4
for j = 1:size(data,1)/5
data1(j,i) = mean(data((1:5)+(j-1)*5,i));
end
end

names = {'Keyboard' 'Remote' 'Joystick' 'Catheter'};
boxplot(data1, names, 'Color', [[0 0.4470 0.7410]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]; [0.4940 0.1840 0.5560]]);
title('Maze Average Dimensionless Squared Jerk');
xlabel('Device');
ylabel('DSJ');
ax = gca; ax.FontSize = 15;

%% ANOVA Linear Graphs
data1 = 1;
for i = 1:4
for j = 1:size(data,1)/75
data1(j,i) = mean(data((1:75)+(j-1)*75,i));
end
end

names = {'World1' 'World2'};
plot(1:2, data1(:, 1), '^', 'MarkerSize', 20, 'MarkerFaceColor', [0 0.4470 0.7410]);
hold on
plot(1:2, data1(:, 2), 's', 'MarkerSize', 20, 'MarkerFaceColor', [0.8500 0.3250 0.0980]);
plot(1:2, data1(:, 3), 'o', 'MarkerSize', 20, 'MarkerFaceColor', [0.9290 0.6940 0.1250]);
plot(1:2, data1(:, 4), '+', 'MarkerSize', 20, 'MarkerFaceColor', [0.4940 0.1840 0.5560]);
set(gca,'xtick', 1:3,'xticklabel',names);
title('Maze Average Dimensionless Squared Jerk');
xlabel('World');
ylabel('DSJ');
legend({'Keyboard' 'Remote' 'Joystick' 'Catheter'});
set(gca, 'XLim', [0.8 2.2]);
%set(gca, 'YLim', [0 100]);
ax = gca; ax.FontSize = 15;

%% Training Graphs
data1 = 1;
for i = 1:4
for j = 1:5
data1(j,i) = mean(data(j:5:size(data,1), i));
end
end

names = {'1st' '2nd' '3rd' '4th' '5th'};
plot(1:5, data1(:, 1), '-^', 'MarkerSize', 10, 'MarkerFaceColor', [0 0.4470 0.7410]);
hold on
plot(1:5, data1(:, 2), 's-', 'MarkerSize', 10, 'MarkerFaceColor', [0.8500 0.3250 0.0980]);
plot(1:5, data1(:, 3), 'o-', 'MarkerSize', 10, 'MarkerFaceColor', [0.9290 0.6940 0.1250]);
plot(1:5, data1(:, 4), '+-', 'MarkerSize', 10, 'MarkerFaceColor', [0.4940 0.1840 0.5560]);
set(gca,'xtick', 1:5,'xticklabel',names);
title('Training graph 2nd DOF All');
xlabel('Attempts');
ylabel('Average RMSE');
legend({'Keyboard' 'Remote' 'Joystick' 'Catheter'});
set(gca, 'XLim', [0.8 5.2]);
set(gca, 'YLim', [0 150]);
ax = gca; ax.FontSize = 15;


%% Percentage graph
data = data > 0;
data = sum(data,1);
data = data * 100 / 225;

names = {'Keyboard' 'Remote' 'Joystick' 'Catheter'};
bar(1, data(1), 'FaceColor', [0 0.4470 0.7410]);
hold on
bar(2, data(2), 'FaceColor', [0.8500 0.3250 0.0980]);
bar(3, data(3), 'FaceColor', [0.9290 0.6940 0.1250]);
bar(4, data(4), 'FaceColor', [0.4940 0.1840 0.5560]);
set(gca,'xtick', 1:4,'xticklabel',names);
set(gca, 'YLim', [0 100]);
title('Maze Average Number of Collisions');
xlabel('Devices');
ylabel('Number Collisions');
text(1:length(data),data,num2str(data'),'vert','bottom','horiz','center'); 
ax = gca; ax.FontSize = 15;


%% Plot velocity keyboard
x=0;
i = 0;
while x(end) < 20
x(end+1) = 1 * (1+i);
i = i+1;
end
y = 0:30:600;

x=0;
i = 0;
while x(end) < 0.5
x(end+1) = 0.1 * (1+i/1300);
i = i+1;
end
y = 0:30:156030;

%% Poll Graphs
data = data*100;
names = {'Keyboard' 'Remote' 'Joystick' 'Catheter'};
bar(1, data(1), 'FaceColor', [0 0.4470 0.7410]);
hold on
bar(2, data(2), 'FaceColor', [0.8500 0.3250 0.0980]);
bar(3, data(3), 'FaceColor', [0.9290 0.6940 0.1250]);
bar(4, data(4), 'FaceColor', [0.4940 0.1840 0.5560]);
set(gca,'xtick', 1:4,'xticklabel',names);
set(gca, 'YLim', [0 100]);
title('Overall Poll Preference');
xlabel('Devices');
ylabel('Percentage');
text(1:length(data),data,num2str(data'),'vert','bottom','horiz','center','FontSize', 20); 
ax = gca; ax.FontSize = 15;

