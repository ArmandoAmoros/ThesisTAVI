% Initialization and handling of the catheter in simulation
classdef Catheter
    properties (GetAccess = public, SetAccess = private)   
        % Figure handle
        hFig;
        % Axis handle
        ax;
        % Name of the catheter
        name;
        % Marker at the end of catheter
        marSize = 30;
        % Actual line of the catheter
        draw;
        % Position of catheter over time
        position;
        % Direction of catheter over time
        direction;
        % Center of the catheter in the y axis
        yAxis;
        % Catheter radius
        radius;
        % Coordinate Parameters
        maxX = 1920;
        maxY = 1080;
        % Scalators
        hScale = 100;
        % Times
        time = 0;
        % Collisions
        collisions = 0;
    end
    
    methods (Access = public)
        function obj = Catheter(name, hfig)
        % Creates a new world object
            % Set name
            obj.name = name;
            % Set the figure and axis
            obj.hFig = hfig;
            obj.ax = hfig.Children;
            % Initialize the comunication with arduino
            obj = obj.initializeCatheter();
        end
        
        function obj = moveCatheter(obj, rotationGain, movementGain)
            % If not movement then break
            if rotationGain == 0 && movementGain == 0
                return;
            end
            % If there is rotation movement present
            rotAngle = obj.direction(end) - rotationGain;
            rotAngle = min(max(rotAngle, 0), pi);
            % If axial movement present
            nextPoint = obj.position(end) + movementGain;
            % Check if there is a collision with the planned movement and
            % return a next point as a result
            [nextPoint, rotAngle, sCol] = obj.checkCollision(nextPoint, rotAngle);
            % Move only if different position, if stuck on a wall do not save
            % repeated states
            if ~(obj.position(end) == nextPoint && obj.direction(end) == rotAngle)
                % Save collision information and give color
                if ~isempty(sCol)
                    obj.draw.marker.Children.FaceColor = 'r';
                    obj.collisions = obj.collisions + 1;
                else
                    obj.draw.marker.Children.FaceColor = 'g';
                end
                % Save next state information
                obj.position(end+1) = nextPoint;
                obj.direction(end+1) = rotAngle;
                obj.time(end+1) = toc;
                % Rotate the body
                obj.draw.body.Matrix = makehgtform('translate', [obj.maxX/2 nextPoint-obj.position(1) 100], 'yrotate', rotAngle);
                % Move the green dot
                obj.draw.marker.Matrix = makehgtform('translate', [-cos(rotAngle)*obj.radius + obj.yAxis, nextPoint, 1000]);
                % Move Camera accordingly
                obj.ax.YLim = [-0.5 0.5]*obj.maxY + max(obj.maxY/2, nextPoint);
            end
        end
        
        function obj = moveCatheter2(obj, rotationGain, movementGain)
            % If not movement then break
            if ~obj.hFig.UserData.start
                return;
            end
            % If there is rotation movement present
            rotAngle = obj.direction(end) - rotationGain;
            rotAngle = min(max(rotAngle, 0), pi);
            % If axial movement present
            nextPoint = obj.position(end) + movementGain;
            % Save next state information
            obj.position(end+1) = nextPoint;
            obj.direction(end+1) = rotAngle;
            obj.time(end+1) = toc;
            % Rotate the body
            obj.draw.body.Matrix = makehgtform('translate', [obj.maxX/2 nextPoint-obj.position(1) 100], 'yrotate', rotAngle);
            % Move the green dot
            obj.draw.marker.Matrix = makehgtform('translate', [-cos(rotAngle)*obj.radius + obj.yAxis, nextPoint, 1000]);
        end
        
        function obj = removeFigs(obj)
            obj.hFig = [];
            obj.ax = [];
        end
    end
    
    methods (Access = private)
        function obj = initializeCatheter(obj)
            load(['Worlds/' obj.name], 'catheter');
            % Crate frame for drawing
            obj.draw.body = hgtransform(obj.ax);
            % Draw catheter
            line(obj.draw.body, catheter.x, catheter.y, 'lineWidth', 25, 'Color', 'w');
            % Put catheter in position
            obj.draw.body.Matrix = makehgtform('translate', [obj.maxX/2 0 100]);
            % Draw marker
            obj.draw.marker = hgtransform(obj.ax);
            rectangle(obj.draw.marker, 'Position', obj.marSize * [-0.5, -0.5, 1, 1], 'FaceColor', 'g', 'EdgeColor', 'none');
            obj.draw.marker.Matrix = makehgtform('translate', [catheter.x(end)+obj.maxX/2, catheter.y(end), 1000]);
            % Initialize position and direction
            obj.position = catheter.y(end);
            obj.direction = 0;
            obj.yAxis = catheter.x(1) + obj.maxX/2;
            obj.radius =  catheter.x(1) - catheter.x(end);
        end
        
        function [nextPoint, rotAngle, sCol] = checkCollision(obj, nextPoint, rotAngle)
            % Initialize output
            sCol = [];
            prePosX = -cos(obj.direction(end))*obj.radius + obj.yAxis;
            prePosY = obj.position(end);
            posX = -cos(rotAngle)*obj.radius + obj.yAxis;
            posY = nextPoint;
            % Check if the new point is in collision with rows
            idx = round((posY + obj.hScale*1.5) / (2*obj.hScale));
            for i = 1:numel(obj.ax.UserData.rows{idx})
                posRecX = cumsum(obj.ax.UserData.rows{idx}(i).Position([1 3]));
                posRecY = cumsum(obj.ax.UserData.rows{idx}(i).Position([2 4]));
                if posX >= posRecX(1) && posX <= posRecX(2) && posY >= posRecY(1) && posY <= posRecY(2)
                    if prePosX >= posRecX(1) && prePosX <= posRecX(2) && prePosY >= posRecY(1) && prePosY <= posRecY(2)
                        nextPoint = prePosY;
                        rotAngle = acos((obj.yAxis - prePosX) / obj.radius);
                        return;
                    end
                    % Get where the collision happened
                    if prePosX <= posRecX(1)
                        [xInter, yInter] = obj.inter(prePosX, posX, posRecX(1), posRecX(1), prePosY, posY, posRecY(1), posRecY(2));
                        nextPoint = yInter;
                        rotAngle = acos((obj.yAxis - xInter) / obj.radius);
                        sCol = true;
                        continue;
                    end
                    if prePosX >= posRecX(2)
                        [xInter, yInter] = obj.inter(prePosX, posX, posRecX(2), posRecX(2), prePosY, posY, posRecY(1), posRecY(2));
                        nextPoint = yInter;
                        rotAngle = acos((obj.yAxis - xInter) / obj.radius);
                        sCol = true;
                        continue;
                    end
                    if prePosY <= posRecY(1)
                        [xInter, yInter] = obj.inter(prePosX, posX, posRecX(1), posRecX(2), prePosY, posY, posRecY(1), posRecY(1));
                        nextPoint = yInter;
                        rotAngle = acos((obj.yAxis - xInter) / obj.radius);
                        sCol = true;
                        continue;
                    end
                    if prePosY >= posRecY(2)
                        [xInter, yInter] = obj.inter(prePosX, posX, posRecX(1), posRecX(2), prePosY, posY, posRecY(2), posRecY(2));
                        nextPoint = yInter;
                        rotAngle = acos((obj.yAxis - xInter) / obj.radius);
                        sCol = true;
                        continue;
                    end
                end
            end
        end
    end
    
    methods (Static, Access = private)
        function [xInter, yInter] = inter(x1, x2, x3, x4, y1, y2, y3, y4)
            uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
            uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
            xInter = x1 + (uA * (x2-x1));
            yInter = y1 + (uA * (y2-y1));
            if ~(uA >= 0 && uA <= 1 && uB >= 0 && uB <=1)
                xInter = [];
                yInter = [];
            end
        end
    end
end