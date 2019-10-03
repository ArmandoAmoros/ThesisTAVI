% TAVI simulator game to test the performance of master devices.
function TaviSim
    %% Initialize multiple experiments
    devices = {'keyboard', 'remote', 'joystick', 'catheter'};
    numTrials = 5;
    subject = 1;
    trialVec = repmat(devices, [1, numTrials]);
    trialVec = trialVec(randperm(numel(trialVec)));
    
    for trial = 1:numel(trialVec)
    %% Parameters
    % Size of the 'playing field'.
    maxX = 1920;
    maxY = 1080;
    % Name of the world
    world = 'aorticArc.mat';
    
    %% Initialization
    % Device
    device = trialVec{trial};
    % Set the figure configurations
    [hFig, ax] = setFigure(maxX, maxY);

    % Configure callback functions
    set(hFig, 'WindowKeyPressFcn',   @(hFig, event)keyPressCallback(hFig, event));
    set(hFig, 'WindowKeyReleaseFcn', @(hFig, event)keyReleaseCallback(hFig, event));
    
    % Declare global variables and initialize
    hFig.UserData = struct('upKey',      false, ...
                           'rightKey',   false, ...
                           'downKey',    false, ...
                           'leftKey',    false, ...
                           'escape',     false, ...
                           'start',      false ...
                           );
    
    % Draw the world in the figure
    [catheter, boundStruct] = drawWorld(ax, world);
    
    % Initialize arrow head
    arrowHead = hgtransform(ax);
    line(arrowHead, [-10, 3, -10], [10, 0, -10], 'Color', 'w', 'LineWidth', 3);
    arrowHead.Matrix = makehgtform('translate', [catheter.XData(end) catheter.YData(end) 0], 'zrotate', catheter.UserData.Dir(end));
    
    % Configure the device
    ard = deviceInterface.initializeDevice(device, hFig);
    
    %% Loop during the game
    % Loop for catching keys and drawing
    set(hFig, 'Color', [0.2 0.2 0.2]);
    while ~hFig.UserData.escape
        % For callbacks to be excecuted
        drawnow;
        % Get the current velocities from arduino board
        [rotationGain, movementGain] = deviceInterface.getGains(device, ard, hFig.UserData);
        % Start time of simulation when the first key is pressed
        if ~hFig.UserData.start && (movementGain > 0 || rotationGain ~= 0)
            tic;
            hFig.UserData.start = true;
        end
        % Moves the catheter and arrow according the keys pressed. Collisions are handled inside
        sCol = moveLine(catheter, arrowHead, rotationGain, movementGain, boundStruct);
        % Check if goal was reached
        if ~isempty(sCol) && sCol > boundStruct.goal(1) && sCol < boundStruct.goal(2)
            % Remove the last rebound
            catheter.XData(end) = [];
            catheter.YData(end) = [];
            catheter.UserData.Dir(end) = [];
            catheter.UserData.PosData(:,end) = [];
            catheter.UserData.Time(end) = [];
            catheter.UserData.CollAngle(end) = [];
            set(hFig, 'Color', [0.2 0.8 0.2]);
            drawnow;
            break;
        end
    end
    fclose(ard);
    
    %% Data Process
    outData = processData(catheter, boundStruct);
    
    %% Save Data
    save(sprintf('%s_%d_%d.mat', device, subject, trial), 'outData');
    
    %% Conclude
    close all;
    end
end

function [hFig, ax] = setFigure(maxX, maxY)
    % Create figure and axis
    hFig = figure;
    ax = axes(hFig);
    hold on;
    % Configure figure
    set(hFig, 'menubar', 'none');
    set(hFig, 'InnerPosition', [1 41 1920 1017]);
    set(hFig, 'OuterPosition', [-7 33 1936 1056]);
    set(hFig, 'Color', [0.8 0.2 0.2]);
    % Configure axis
    set(ax, 'XTick', []);
    set(ax, 'YTick', []);
    set(ax, 'XLim', [0 maxX]);
    set(ax, 'YLim', [0 maxY]);
    set(ax, 'Position', [0.05 0.05 0.9 0.9]);
    
end

function [catheter, boundStruct] = drawWorld(ax, world)
    % Load the world information
    load(['Worlds/' world], 'boundStruct');
    % Get the boundary information
    breaks = boundStruct.boundarySpline.ppx.breaks;
    xPoints = ppval(boundStruct.boundarySpline.ppx, 0:1:breaks(end));
    yPoints = ppval(boundStruct.boundarySpline.ppy, 0:1:breaks(end));
    % Plot the boundary with high resolution
    fill(ax, xPoints, yPoints, 'k', 'FaceColor', [0.7 0.7 0.7], 'LineWidth', 2);
    
    % Plot goal
    goalS = boundStruct.goal(1):0.1:boundStruct.goal(2);
    plot(ppval(boundStruct.boundarySpline.ppx, goalS), ppval(boundStruct.boundarySpline.ppy, goalS), 'r', 'LineWidth', 2);
    
    % Initialize Catheter according to world
    initPos = boundStruct.initPos;
    catheter = line(ax, initPos(1,:), initPos(2,:), 'Color', 'w', 'LineWidth', 8);
    % Initialize catheter user data struct
    catheter.UserData = struct('PosData', initPos(:,2), ...
                               'Dir', atan2(initPos(2,2) - initPos(2,1), initPos(1,2) - initPos(1,1)), ...
                               'NCollision', 0, ...
                               'CollAngle',  [], ...
                               'Time', 0, ...
                               'PullBackStatus', false, ...
                               'NPullBack', 0 ...
                               );
    
end

function sCol = moveLine(catheter, arrowHead, rotationGain, movementGain, boundStruct)
    % Initialize output
    sCol = [];
    % If there is rotation movement present
    if rotationGain ~= 0
        catheter.UserData.Dir(end) = catheter.UserData.Dir(end) + rotationGain;
        arrowHead.Matrix = makehgtform('translate', [catheter.XData(end) catheter.YData(end) 0], 'zrotate', catheter.UserData.Dir(end));
    end
    % If axial movement present
    if movementGain > 0
        nextPoint = [catheter.XData(end) + movementGain * cos(catheter.UserData.Dir(end)); catheter.YData(end) + movementGain * sin(catheter.UserData.Dir(end))];
        [nextPoint, direction, sCol, collisionDir] = checkCollision([[catheter.XData(end);catheter.YData(end)], nextPoint], catheter.UserData.Dir(end), boundStruct, movementGain);
        % Move only if different position, if stuck on a wall do not save
        % repeated states
        if ~(catheter.XData(end) == nextPoint(1,end) && catheter.YData(end) == nextPoint(2,end) && catheter.UserData.Dir(end) == direction(end))
            % Save collision information
            if ~isempty(sCol)
                catheter.UserData.NCollision = catheter.UserData.NCollision + 1;
                % enclose the angle between 0 and pi/2
                if collisionDir > pi/2
                    collisionDir = pi - collisionDir;
                end
                catheter.UserData.CollAngle(catheter.UserData.NCollision) = collisionDir;
                % Save the collision point if rebound
                if numel(direction) > 1
                    catheter.XData(end+1) = nextPoint(1,1);
                    catheter.YData(end+1) = nextPoint(2,1);
                    catheter.UserData.Dir(end+1) = direction(1);
                    catheter.UserData.PosData(:,end+1) = nextPoint(:,1);
                    catheter.UserData.Time(end+1) = toc;
                end
            end
            % Save next catheter state
            catheter.XData(end+1) = nextPoint(1,end);
            catheter.YData(end+1) = nextPoint(2,end);
            catheter.UserData.Dir(end+1) = direction(end);
            catheter.UserData.PosData(:,end+1) = nextPoint(:,end);
            catheter.UserData.Time(end+1) = toc;
            arrowHead.Matrix = makehgtform('translate', [catheter.XData(end) catheter.YData(end) 0], 'zrotate', catheter.UserData.Dir(end));
        end
    end
    % If pullback movement present
    if movementGain < 0
        catheter.XData(end) = [];
        catheter.YData(end) = [];
        catheter.UserData.Dir(end) = [];
        catheter.UserData.PosData(:,end+1) = [catheter.XData(end); catheter.YData(end)];
        catheter.UserData.Time(end+1) = toc;
        arrowHead.Matrix = makehgtform('translate', [catheter.XData(end) catheter.YData(end) 0], 'zrotate', catheter.UserData.Dir(end));
        
        if ~catheter.UserData.PullBackStatus
            catheter.UserData.NPullBack = catheter.UserData.NPullBack + 1;
            catheter.UserData.PullBackStatus = true;
        end
    else
        catheter.UserData.PullBackStatus = false;
    end
end

function [nextPoint, nextDir, sCol, collisionDir] = checkCollision(line, dir, boundStruct, movementGain)
    % Initialize output
    sCol = [];
    collisionDir = [];
    % Distance to every BP
    dist = sqrt(sum((boundStruct.boundary - line(:,2)).^2));
    % Get the minimum distance and index
    [value, idx] = min(dist);
    % Save (temporary) the next point and direction
    nextPoint = line(:,2);
    nextDir = dir;
    % If the boundaries are close enough, try to find a collision
    if value < boundStruct.resolution/2 + movementGain
        % Get the -90 orthogonal vector of the boudnary
        rSpline = boundStruct.boundarySpline;
        point = [ppval(rSpline.ppx, rSpline.ppx.breaks(idx)); ppval(rSpline.ppy, rSpline.ppy.breaks(idx))];
        ortVec = [ppval(rSpline.dppy, rSpline.dppy.breaks(idx)), -ppval(rSpline.dppx, rSpline.dppx.breaks(idx))];
        % If the new point is outside the world, make a rebound and save
        % the new point and direcction
        if ortVec * (line(:,2) - point) <= 0
            % Find where exactly the cross happened
            sCol = splineIntersect(line(:,1), dir, boundStruct.boundarySpline, boundStruct.boundary);
            % Direction of the bound at collision point
            boundDir = atan2(ppval(rSpline.dppy, sCol), ppval(rSpline.dppx, sCol));
            boundPoint = [ppval(rSpline.ppx, sCol); ppval(rSpline.ppy, sCol)];
            % Collision angle
            collisionDir = mod(dir - boundDir + pi, 2*pi) - pi;
            % Define new point and direction
            if collisionDir < pi/4 || collisionDir > 3*pi/4
                % Collision point
                nextPoint = boundPoint;
                nextDir = dir;
                % Rebound
                nextDir(2) = dir - 2*collisionDir;
                nextPoint(:,2) = boundPoint + [cos(nextDir(2)); sin(nextDir(2))]*(movementGain - norm(boundPoint - line(:,1)));
            else
                % Stop moving
                nextPoint = boundPoint;
                nextDir = dir;
            end
        end
    end
end

function outData = processData(catheter, boundStruct)
    % time until completion
    outData.time = catheter.UserData.Time(end);
    % path length
    outData.pathLength = sum(sqrt(diff(catheter.UserData.PosData(1,:)).^2 + diff(catheter.UserData.PosData(2,:)).^2));
    % average velocity
    outData.avgVel = outData.pathLength / outData.time;
    % get average minimum wall distance
    res = 0.1;
    boundarySampledPoints = [ppval(boundStruct.boundarySpline.ppx, 0:res:boundStruct.boundarySpline.ppx.breaks(end)); ppval(boundStruct.boundarySpline.ppy, 0:res:boundStruct.boundarySpline.ppy.breaks(end))];
    catheterPoints(1, 1, :) = catheter.UserData.PosData(1,:);
    catheterPoints(2, 1, :) = catheter.UserData.PosData(2,:);
    distPoints = sqrt(sum((boundarySampledPoints - catheterPoints).^2));
    outData.avgMinDistBound = mean(min(distPoints));
    % number of collisions
    outData.numCollisions = catheter.UserData.NCollision - 1;
    % maximum collision angle
    outData.maxCollisionAngle = max(catheter.UserData.CollAngle);
    % number of pullbacks
    outData.numPullBacks = catheter.UserData.NPullBack;
    % get dimensionless squared jerk
    velX = diff(catheter.UserData.PosData(1,:))./diff(catheter.UserData.Time);
    velY = diff(catheter.UserData.PosData(2,:))./diff(catheter.UserData.Time);
    velT = cumsum(diff(catheter.UserData.Time));
    accX = diff(velX)./diff(velT);
    accY = diff(velY)./diff(velT);
    accT = cumsum(diff(velT));
    jerX = diff(accX)./diff(accT);
    jerY = diff(accY)./diff(accT);
    jerT = cumsum(diff(accT));
    integralPart = trapz(jerT, jerX.^2 + jerY.^2);
    outData.dimenSquaredJerk = 0.5 * integralPart * (outData.time^5/outData.pathLength^2);
end

function [hFig, event] = keyPressCallback(hFig, event)
    % Check which key was pressed
    switch event.Key
        case 'uparrow'
            hFig.UserData.upKey = true;
        case 'leftarrow'
            hFig.UserData.leftKey = true;
        case 'downarrow'
            hFig.UserData.downKey = true;
        case 'rightarrow'
            hFig.UserData.rightKey = true;
        case 'escape'
            hFig.UserData.escape = true;
    end
end

function [hFig, event] = keyReleaseCallback(hFig, event)
    % Check which key was released
    switch event.Key
        case 'uparrow'
            hFig.UserData.upKey = false;
        case 'leftarrow'
            hFig.UserData.leftKey = false;
        case 'downarrow'
            hFig.UserData.downKey = false;
        case 'rightarrow'
            hFig.UserData.rightKey = false;
    end
end