% TAVI simulator game to test the performance of master devices.
function TaviFollow(subject, mode)
    [~, b] = mkdir(sprintf('Results/Exp%s/Sub%d', mode, subject));
    if ~isempty(b)
        error('The folder already exist, override may happen');
    end
    %% Initialize multiple experiments
    devices = {'keyboard', 'remote', 'joystick', 'catheter'};
    numTrials = 5;
    deviceVec = devices(randperm(numel(devices)));
    
    for trial = 1:numel(deviceVec)
    worldIt = repmat([1 2 3], [1, numTrials]);
    worldIt = worldIt(randperm(numel(worldIt)));
    keyboard;
    for repeat = 1:numel(worldIt)
    %% Initialization
    % Device
    % Set world
    world = World('Worlds/empty.mat');
    title(world.ax, sprintf('TAVI Follow, Subject %d, device %s, mode %s, world %d, trial % d', subject, deviceVec{trial}, mode, worldIt(repeat), repeat));
    % Configure the device
    device = Device(deviceVec{trial}, world.hFig);
    %device = Device('keyboard', world.hFig);
    % Configure catheter
    catheter = Catheter('catheter3.mat', world.hFig);
    % Initiliaze variables for on/off devices velocity incremental
    prevRotState = 0;
    prevAxState = 0;
    % Load shadow
    t = 0;
    load(sprintf('Shadows/%s/shadow%d.mat', mode, worldIt(repeat)), 'ref');
    %load(sprintf('Shadows/%s/shadow3.mat', mode), 'ref');
    shadow = hgtransform(world.ax);
    rectangle(shadow, 'Position', [-25 -25 50 50], 'FaceColor', 'r', 'EdgeColor', 'none');
    rectangle(shadow, 'Position', [-15 -15 30 30], 'FaceColor', [0.8 0.8 0.8], 'EdgeColor', 'none');
    shadow.Matrix = makehgtform('translate', [ppval(ref.x, t) ppval(ref.y, t) 500]);
    
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
        if ~world.hFig.UserData.start && (movementGain ~= 0 || rotationGain ~= 0)
            tic;
            world.hFig.UserData.start = true;
        end
        if world.hFig.UserData.start
            t = toc;
            shadow.Matrix = makehgtform('translate', [ppval(ref.x, t) ppval(ref.y, t) 500]);
        end
        
        % Moves the catheter and arrow according the keys pressed. Collisions are handled inside
        [catheter] = catheter.moveCatheter2(rotationGain, movementGain);
        
        % Check if goal was reached
        if world.goalReached(t)
            set(world.hFig, 'Color', [0.2 0.8 0.2]);
            drawnow;
            break;
        end
    end
    
    %% Data Process
    outData = processData(catheter, ref);
    
    %% Save Data
    save(sprintf('Results/Exp%s/Sub%d/%s_%d_%s_%d_%d.mat', mode, subject, device.name, subject, mode, worldIt(repeat), repeat), 'outData');
    
    %% Conclude
    close all;
    end
    fclose(device.ard);
    end
end

function outData = processData(catheter, ref)
    % Save main info
    outData.catheter = catheter;
    outData.catheter = outData.catheter.removeFigs();
    outData.ref = ref;
    % RMSE X
    refX = ppval(ref.x, catheter.time);
    posX = -cos(catheter.direction)*catheter.radius + catheter.yAxis;
    outData.rmseX = sqrt(mean((posX - refX).^2));
    % RMSE Y
    refY = ppval(ref.y, catheter.time);
    posY = catheter.position;
    outData.rmseY = sqrt(mean((posY - refY).^2));
end