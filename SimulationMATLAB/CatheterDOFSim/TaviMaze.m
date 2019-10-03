% TAVI simulator game to test the performance of master devices.
function TaviMaze(subject)
    [~, b] = mkdir(sprintf('Results/ExpMaze/Sub%d', subject));
    if ~isempty(b)
        error('The folder already exist, override may happen');
    end
    %% Initialize multiple experiments
    devices = {'keyboard', 'remote', 'joystick', 'catheter'};
    numTrials = 5;
    deviceVec = devices(randperm(numel(devices)));
    
    for trial = 1:numel(deviceVec)
    worldIt = repmat([2 3], [1, numTrials]);
    worldIt = worldIt(randperm(numel(worldIt)));
    keyboard;
    for repeat = 1:numel(worldIt)
    %% Initialization
    % Set world
    world = World(sprintf('Maze/maze%d.mat', worldIt(repeat)));
    % world = World(sprintf('Maze/maze%d.mat', 3));
    title(world.ax, sprintf('TAVI Maze, Subject %d, device %s, world %d, trial % d', subject, deviceVec{trial}, worldIt(repeat), repeat));
    % Configure the device
    device = Device(deviceVec{trial}, world.hFig);
    % device = Device('remote', world.hFig);
    % Configure catheter
    catheter = Catheter('catheter2.mat', world.hFig);
    % Initiliaze variables for on/off devices velocity incremental
    prevRotState = 0;
    prevAxState = 0;
    
    %% Loop during the game
    % Set color background to gray, to indicate experiment may start
    set(world.hFig, 'Color', [0.2 0.2 0.2]);
    % Loop for catching keys and drawing
    while ~world.hFig.UserData.escape
        % For callbacks to be excecuted
        drawnow;
        % Get the current velocities from arduino board
        [rotationGain, movementGain] = device.getGains();
        % Make on/off devices velocity incremental
        [rotationGain, movementGain, prevRotState, prevAxState] = onOffVelocity(device, rotationGain, movementGain, prevRotState, prevAxState);
        % Limit the gains so all the devices have the same limits
        [rotationGain, movementGain] = limitVel(rotationGain, movementGain);
        % Start time of simulation when the first key is pressed
        if ~world.hFig.UserData.start && (movementGain > 0 || rotationGain ~= 0)
            tic;
            world.hFig.UserData.start = true;
        end
        
        % Moves the catheter and arrow according the keys pressed. Collisions are handled inside
        [catheter] = catheter.moveCatheter(rotationGain, movementGain);
        
        % Check if goal was reached
        if world.goalReached(catheter.position(end))
            set(world.hFig, 'Color', [0.2 0.8 0.2]);
            drawnow;
            break;
        end
    end
    
    %% Data Process
    outData = processData(catheter, world);
    
    %% Save Data
    save(sprintf('Results/ExpMaze/Sub%d/%s_%d_%d_%d.mat', subject, device.name, subject, worldIt(repeat), repeat), 'outData');
    
    %% Conclude
    close all;
    end
    fclose(device.ard);
    end
end

function outData = processData(catheter, world)
    % Save main info
    outData.catheter = catheter;
    outData.catheter = outData.catheter.removeFigs();
    % time until completion
    outData.time = catheter.time(end);
    % number of collisions
    outData.numCollisions = catheter.collisions - 1;
    % get dimensionless squared jerk
    % path lenght
    posX = -cos(catheter.direction)*catheter.radius + catheter.yAxis;
    posY = catheter.position;
    outData.pathLength = sum(sqrt(diff(posX).^2 + diff(posY).^2));
    % get dimensionless squared jerk
    velX = diff(posX)./diff(catheter.time);
    velY = diff(posY)./diff(catheter.time);
    velT = cumsum(diff(catheter.time));
    accX = diff(velX)./diff(velT);
    accY = diff(velY)./diff(velT);
    accT = cumsum(diff(velT));
    jerX = diff(accX)./diff(accT);
    jerY = diff(accY)./diff(accT);
    jerT = cumsum(diff(accT));
    integralPart = trapz(jerT, jerX.^2 + jerY.^2);
    outData.dimenSquaredJerk = 0.5 * integralPart * (outData.time^5/outData.pathLength^2);
    % get average distance against the walls
    idx = round((posY + world.hScale*1.5) / (2*world.hScale));
    dist = zeros(1, numel(posY));
    for i = 1:numel(posY)
        squares = world.ax.UserData.rows{idx(i)};
        distTemp = zeros(1, numel(squares));
        for j = 1:numel(squares)
            centerX = squares(j).Position(1) + squares(j).Position(3)/2;
            centerY = squares(j).Position(2) + squares(j).Position(4)/2;
            dx = max(abs(centerX - posX(i)) - squares(j).Position(3)/2, 0);
            dy = max(abs(centerY - posY(i)) - squares(j).Position(4)/2, 0);
            distTemp(j) = sqrt(dx^2 + dy^2);
        end
        dist(i) = min(distTemp);
    end
    outData.avgDist = mean(dist);
end