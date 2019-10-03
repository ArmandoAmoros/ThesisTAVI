% This script is useful to remove figures from saved experiments

path = 'Results/ExpMaze/';
a = ls(path);
a([1 2],:) = [];

for j = 1:size(a, 1)
    folder = [a(j, a(j,:) ~= ' ') '/'];
    b = ls([path a(j,:)]);
    b([1 2],:) = [];
    for i = 1:size(b, 1)
        temp1 = b(i,:);
        temp = temp1(temp1 ~= ' ');
        underScr = find(temp == '_');
        point = find(temp == '.');
        number = str2double(temp(underScr(end)+1 : point-1));
        temp(underScr(end)+1:end) = [];
        temp = sprintf('%s%d.mat', temp, number+100);
        movefile([path folder temp1], [path folder temp], 'f');
    end
end

clear