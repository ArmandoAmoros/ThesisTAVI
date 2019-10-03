% Initialization and handling of arduino/device with computer connection
classdef Device
    properties (GetAccess = public, SetAccess = private)   
        % Figure handle
        hFig;
        % Axis handle
        ax;
        % Name of the device
        name;
        % Number of device for serial
        number;
        % Serial communication port
        ard;
        % Port for serial communication
        port = 'COM5';
        % Baud rate for serial communication
        rate = 9600;
    end
    
    methods (Access = public)
        function obj = Device(name, hfig)
        % Creates a new world object
            % Set name
            obj.name = name;
            % Set the figure and axis
            obj.hFig = hfig;
            obj.ax = hfig.Children;
            % Initialize the comunication with arduino
            obj = obj.initializeDevice();
        end
        
        function [rotationGain, movementGain] = getGains(obj)
            rotationGain = 0;
            movementGain = 0;
            switch obj.name
                case 'keyboard'
                    [axVel, rotVel] = obj.getSpeed();
                    % If right key is pressed
                    if obj.hFig.UserData.rightKey
                        rotationGain = rotationGain - rotVel;
                    end
                    % If left key is pressed
                    if obj.hFig.UserData.leftKey
                        rotationGain = rotationGain + rotVel;
                    end
                    % If down key is pressed
                    if obj.hFig.UserData.downKey
                        movementGain = movementGain - axVel;
                    end
                    % If up key is pressed
                    if obj.hFig.UserData.upKey
                        movementGain = movementGain + axVel;
                    end
                case 'remote'
                    [movementGain, rotationGain] = obj.getSpeed();
                case 'joystick'
                    [movementGain, rotationGain] = obj.getSpeed();
                case 'catheter'
                    [movementGain, rotationGain] = obj.getSpeed();
                otherwise
                    error('Input device is not recognized');
            end
        end
    end
    
    methods (Access = private)
        function obj = initializeDevice(obj)
        % Initialization accordig to the device
            if ~isempty(instrfind)
                fclose(instrfind);
                delete(instrfind);
            end
            obj.ard = serial(obj.port, 'BaudRate', obj.rate);
            fopen(obj.ard);
            pause(2);
            switch obj.name
                case 'keyboard'
                    obj.number = '1';
                    obj.changeDevice();
                case 'remote'
                    obj.number = '2';
                    obj.changeDevice();
                case 'joystick'
                    obj.number = '3';
                    obj.changeDevice();
                case 'catheter'
                    obj.number = '4';
                    obj.changeDevice();
                otherwise
                    error('Input device is not recognized');
            end
            % Configure callback functions
            set(obj.hFig, 'WindowKeyPressFcn',   @keyPressCallback);
            set(obj.hFig, 'WindowKeyReleaseFcn', @keyReleaseCallback);
        end
        
        function changeDevice(obj)
            % Change the device the arduino is recognizing
            fprintf(obj.ard, obj.number);
            res = fscanf(obj.ard,'%d');
            if res ~= str2double(obj.number)
                error('The device was not initialized correctly');
            end
        end
        
        function [axVel, rotVel] = getSpeed(obj)
            % Get the current speed from the arduino device
            fprintf(obj.ard, 'R');
            res = fscanf(obj.ard,'%c');
            if strcmp(res, 'Error') || ~strcmp(obj.number, res(1))
                error('Error requesting speed');
            end
            aIdx = find(res == 'a');
            rIdx = find(res == 'r');
            axVel = str2double(res(aIdx+1:rIdx-1));
            rotVel = str2double(res(rIdx+1:end));
        end
    end
end

function keyPressCallback(hFig, event)
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

function keyReleaseCallback(hFig, event)
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