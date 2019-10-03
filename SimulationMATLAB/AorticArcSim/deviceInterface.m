% Initialization and handling of arduino connection
classdef deviceInterface
    methods (Static)
        % Initialization accordig to the device
        function [ard] = initializeDevice(device, hFig)
            fclose(instrfind);
            ard = serial('COM5', 'BaudRate', 9600);
            fopen(ard);
            pause(2);
            switch device
                case 'keyboard'
                    changeDevice(ard, '1');
                case 'remote'
                    changeDevice(ard, '2');
                case 'joystick'
                    changeDevice(ard, '3');
                case 'catheter'
                    changeDevice(ard, '4');
                otherwise
                    error('Input device is not recognized');
            end
        end
       
        function [rotationGain, movementGain] = getGains(device, ard, data)
            rotationGain = 0;
            movementGain = 0;
            switch device
                case 'keyboard'
                    [axVel, rotVel] = getSpeed(ard, '1');
                    % If right key is pressed
                    if data.rightKey
                        rotationGain = rotationGain - rotVel;
                    end
                    % If left key is pressed
                    if data.leftKey
                        rotationGain = rotationGain + rotVel;
                    end
                    % If down key is pressed
                    if data.downKey
                        movementGain = movementGain - axVel;
                    end
                    % If up key is pressed
                    if data.upKey
                        movementGain = movementGain + axVel;
                    end
                case 'remote'
                    [movementGain, rotationGain] = getSpeed(ard, '2');
                case 'joystick'
                    [movementGain, rotationGain] = getSpeed(ard, '3');
                case 'catheter'
                    [movementGain, rotationGain] = getSpeed(ard, '4');
                otherwise
                    error('Input device is not recognized');
            end
        end
    end
end

function [axVel, rotVel] = getSpeed(ard, device)
    % Get the current speed from the arduino device
    fprintf(ard, 'R');
    res = fscanf(ard,'%c');
    if strcmp(res, 'Error') || ~strcmp(device, res(1))
        error('Error requesting speed');
    end
    aIdx = find(res == 'a');
    rIdx = find(res == 'r');
    axVel = str2double(res(aIdx+1:rIdx-1));
    rotVel = str2double(res(rIdx+1:end));
end

function changeDevice(ard, device)
    % Change the device the arduino is recognizing
    fprintf(ard, device);
    res = fscanf(ard,'%d');
    if res ~= str2double(device)
        error('The device was not initialized correctly');
    end
end