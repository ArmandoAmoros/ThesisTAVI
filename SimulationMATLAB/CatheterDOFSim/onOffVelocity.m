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
            rotationGain = rotationGain * (1 + prevRotState/1300);
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