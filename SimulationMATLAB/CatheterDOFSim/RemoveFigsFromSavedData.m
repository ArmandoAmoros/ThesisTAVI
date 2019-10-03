% This script is useful to remove figures from saved experiments

path = 'Results/ExpMaze/Sub0/';
a = ls(path);
a([1 2],:) = [];
for i = 1:size(a, 1)
    temp = a(i,:);
    temp = temp(temp ~= ' ');
    load([path temp], 'outData');
    close all
    outData.catheter = outData.catheter.removeFigs();
    save([path temp], 'outData');
end

clear