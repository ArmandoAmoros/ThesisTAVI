% TAVI simulator game to test the performance of master devices.
function TaviTest
    %% Initialize multiple experiments
    devices = {'keyboard', 'remote', 'joystick', 'catheter'};
    deviceVec = devices(randperm(numel(devices)));
    
    for trial = 1:numel(deviceVec)%% Initialization
    % Device
    % Set world
    world = World('Worlds/empty.mat');
    title(world.ax, sprintf('TAVI Test, Device %s', deviceVec{trial}));
    keyboard;
    % Configure the device
    device = Device(deviceVec{trial}, world.hFig);
    %device = Device('keyboard', world.hFig);
    % Configure catheter
    catheter = Catheter('catheter3.mat', world.hFig);
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
            world.hFig.UserData.start = true;
        end
        
        % Moves the catheter and arrow according the keys pressed. Collisions are handled inside
        [catheter] = catheter.moveCatheter2(rotationGain, movementGain);
    end
    
    %% Conclude
    close all;
    fclose(device.ard);
    end
end

function [rotationGain, movementGain, prevRotState, prevAxState] = ...
                onOffVelocity(device, rotationGain, movementGain, prevRotState, prevAxState)
    % This function helps changing the behaviour of the on off devices
    % making the speed incremental in time
    if strcmp(device.name, 'keyboard')
        if movementGain~= 0
            movementGain = (movementGain * (1 + prevAxState));
            prevAxState = prevAxState + 1;
        else
            prevAxState = 0;
        end
        
        if rotationGain ~= 0
            rotationGain = rotationGain * (1 + prevRotState/1000);
            prevRotState = prevRotState + 1;
        else
            prevRotState = 0;
        end
    elseif strcmp(device.name, 'remote')
        if movementGain~= 0
            movementGain = (movementGain * (1 + prevAxState));
            prevAxState = prevAxState + 1;
        else
            prevAxState = 0;
        end
    end
end

function [rotationGain, movementGain] = limitVel(rotationGain, movementGain)
    rotationGain = sign(rotationGain)*min(sign(rotationGain)*rotationGain, 0.5);
    movementGain = sign(movementGain)*min(sign(movementGain)*movementGain, 20);
end