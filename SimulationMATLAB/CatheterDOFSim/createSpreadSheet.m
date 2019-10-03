function [flag] = createSpreadSheet(experiment)
%% Get all the data from the mat files
    % Create the path to the data
    path = ['Results/' experiment '/'];
    % Get all the subjects    
    subs = ls(path);
    % Remove the first 2 directories
    subs([1,2], :) = [];
    % Initialize struct
    switch experiment
        case {'Exp1stDOF', 'Exp2ndDOF'}
            data = ones(size(subs,1)* 5 * 3, 8) * -1;
        case 'ExpMaze'
            data = ones(size(subs,1)* 5 * 2, 20) * -1;
        otherwise
            error('There was an error here');     
    end
    % Iterate through every subject
    for i = 1:size(subs, 1)
        subIter = subs(i, :);
        subIter = subIter(subIter ~= ' ');
        % For every subject go through every file
        files = ls([path subIter]);
        % Remove first 2 directories
        files([1,2], :) = [];
        % Initiate device iterations
        itKey = 0;
        itRem = 0;
        itJoy = 0;
        itCat = 0;
        % Iterate through every file
        for j = 1:size(files, 1)
            fileIter = files(j, :);
            fileIter = fileIter(fileIter ~= ' ');
            load([path subIter '/' fileIter], 'outData');
            % Find what device, subject and world was used
            underScr = find(fileIter == '_');
            device = fileIter(1:underScr(1)-1);
            switch device
                case 'keyboard'; device = 0; itKey = itKey + 1; iter = itKey;
                case 'remote'; device = 1; itRem = itRem + 1; iter = itRem;
                case 'joystick'; device = 2; itJoy = itJoy + 1; iter = itJoy;
                case 'catheter'; device = 3; itCat = itCat + 1; iter = itCat;
                otherwise; error('Something failed');
            end
            subject = str2double(fileIter(underScr(1)+1:underScr(2)-1));
            switch experiment
                case {'Exp1stDOF', 'Exp2ndDOF'}
                    world = str2double(fileIter(underScr(3)+1));
                    data(subject*5 + iter + 5*(world-1)*(size(subs,1)-1), device + 1) = outData.rmseX;
                    data(subject*5 + iter + 5*(world-1)*(size(subs,1)-1), device + 5) = outData.rmseY;
                case 'ExpMaze'
                    world = str2double(fileIter(underScr(2)+1));
                    data(subject*5 + iter + 5*(world-2)*(size(subs,1)-1), device + 1) = outData.time;
                    data(subject*5 + iter + 5*(world-2)*(size(subs,1)-1), device + 5) = outData.numCollisions;
                    data(subject*5 + iter + 5*(world-2)*(size(subs,1)-1), device + 9) = outData.pathLength;
                    data(subject*5 + iter + 5*(world-2)*(size(subs,1)-1), device + 13) = outData.dimenSquaredJerk;
                    data(subject*5 + iter + 5*(world-2)*(size(subs,1)-1), device + 17) = outData.avgDist;
                otherwise
                    error('There was an error here');     
            end
        end
    end
    
%% Write it on excel file
    xlswrite('Results/report', data, experiment, 'D4');
    % Create titles
    switch experiment
        case {'Exp1stDOF', 'Exp2ndDOF'}
            % Data fields
            xlswrite('Results/report', [repmat("rmseX", 1, 4) repmat("rmseY", 1, 4)], experiment, 'D3');
            % Device
            xlswrite('Results/report', repmat(["Keyboard" "Remote" "Joystick" "Catheter"], 1, 2), experiment, 'D2');
            % Subject and world
            for j = 0:2
            for i = 1:size(subs, 1)
                xlswrite('Results/report', ["" string(sprintf('subs%d', i-1))], experiment, sprintf('B%d', 4 + (i-1)*5 + j*5*size(subs,1)));
            end
                xlswrite('Results/report', ["" string(sprintf('world%d', j+1))], experiment, sprintf('A%d', 4 + j*5*size(subs,1)));
            end
        case 'ExpMaze'
            % Data fields
            xlswrite('Results/report', ["time" "time" "time" "time" "numColl" "numColl" "numColl" "numColl" "pathLen" "pathLen" "pathLen" "pathLen" "dimSquaJerk" "dimSquaJerk" "dimSquaJerk" "dimSquaJerk" "avgDist" "avgDist" "avgDist" "avgDist"], experiment, 'D3');
            % Device
            xlswrite('Results/report', repmat(["Keyboard" "Remote" "Joystick" "Catheter"], 1, 5), experiment, 'D2');
            % Subject and world
            for j = 0:1
            for i = 1:size(subs, 1)
                xlswrite('Results/report', ["" string(sprintf('subs%d', i-1))], experiment, sprintf('B%d', 4 + (i-1)*5 + j*5*size(subs,1)));
            end
                xlswrite('Results/report', ["" string(sprintf('world%d', j+1))], experiment, sprintf('A%d', 4 + j*5*size(subs,1)));
            end
        otherwise
            error('There was an error here');     
    end
    % Save the mat file
    save(sprintf('Results/resutlsData%s.mat', experiment), 'data');
    
%% Perform all the ANOVA permutations and save the results
    % 
    switch experiment
        case {'Exp1stDOF', 'Exp2ndDOF'}
            % Initialize output matrix
            anovaData = ones(size(data, 2)/4*3*3, 7) * -1;
            numData = size(subs,1)*5;
            % Generate the ANOVAs
            for w = 0:2 % worlds
            for i = 0:1 % different measurements
                % Get the full experiment ANOVA
                anovaData(i*3 + (1:3) + w*6,1) = anova2(data((1:numData) + w*numData, (1:4) + i*4), 5, 'off')';
                % Get all the permutation ANOVA
                m = 2;
                for j = (1:3) + i*4 % Column 1
                    for k = j+1:(4 + i*4) % Column 2
                        anovaData(i*3 + (1:3) + w*6, m) = anova2(data((1:numData) + w*numData, [j k]), 5, 'off')';
                        m = m+1;
                    end
                end
            end
            end
            % Save the mat file
            save(sprintf('Results/%sPvalues.mat', experiment), 'anovaData');
            xlswrite('Results/report', anovaData, experiment, 'O4');
            xlswrite('Results/report', ["All" "Key-Rem"	"Key-Joy" "Key-Cat" "Rem-Joy" "Rem-Cat" "Joy-Cat"], experiment, 'O3');
            xlswrite('Results/report', repmat(["rmseX" "" "" "rmseY" "" ""]', 3, 1), experiment, 'N4');
            xlswrite('Results/report', ["world1" "" "" "" "" "" "world2" "" "" "" "" "" "world3"]', experiment, 'M4');
            
        case 'ExpMaze'
            % Initialize output matrix
            anovaData = ones(size(data, 2)/4*3*2, 7) * -1;
            numData = size(subs,1)*5;
            % Generate the ANOVAs
            for w = 0:1 % worlds
            for i = 0:4 % different measurements
                % Get the full experiment ANOVA
                anovaData(i*3 + (1:3) + w*15,1) = anova2(data((1:numData) + w*numData, (1:4) + i*4), 5, 'off')';
                % Get all the permutation ANOVA
                m = 2;
                for j = (1:3) + i*4 % Column 1
                    for k = j+1:(4 + i*4) % Column 2
                        anovaData(i*3 + (1:3) + w*15, m) = anova2(data((1:numData) + w*numData, [j k]), 5, 'off')';
                        m = m+1;
                    end
                end
            end
            end
            % Save the mat file
            save(sprintf('Results/%sPvalues.mat', experiment), 'anovaData');
            xlswrite('Results/report', anovaData, experiment, 'AA4');
            xlswrite('Results/report', ["All" "Key-Rem"	"Key-Joy" "Key-Cat" "Rem-Joy" "Rem-Cat" "Joy-Cat"], experiment, 'AA3');
            xlswrite('Results/report', repmat(["time" "" "" "numColl" "" "" "pathLen" "" "" "dimJerk" "" "" "avgDist" "" ""]', 2, 1), experiment, 'Z4');
            xlswrite('Results/report', ["world1" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "world2"]', experiment, 'Y4');
            
        otherwise
            error('There was an error here');     
    end
end