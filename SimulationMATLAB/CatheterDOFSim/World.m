% Initialization and handling of arduino connection
classdef World
    properties (GetAccess = public, SetAccess = private)   
        % Figure handle
        hFig;
        % Axis handle
        ax;
        % Name of the world
        name;
        % Coordinate Parameters
        maxX = 1920;
        maxY = 1080;
        % Scalators
        hScale = 100;
        wScale = 150;
        % Goals to finish the experiment
        goalY;
    end
    
    methods (Access = public)
        function obj = World(name)
        % Creates a new world object
            % Set name
            obj.name = name;
            % Create figure and axis
            obj.hFig = figure;
            obj.ax = axes(obj.hFig);
            hold on;
            % Configure figure
            set(obj.hFig, 'menubar', 'none');
            set(obj.hFig, 'InnerPosition', [1 41 1920 1017]);
            set(obj.hFig, 'OuterPosition', [obj.maxX 1 obj.maxX obj.maxY]);
            set(obj.hFig, 'Color', [0.8 0.2 0.2]);
            % Configure axis
            set(obj.ax, 'XTick', []);
            set(obj.ax, 'YTick', []);
            set(obj.ax, 'XLim', [0 obj.maxX]);
            set(obj.ax, 'YLim', [0 obj.maxY]);
            set(obj.ax, 'Position', [0.05 0.05 0.9 0.9]);
            % Print World
            obj = obj.drawWorld();
            % Declare global variables and initialize
            obj.hFig.UserData = struct('upKey',      false, ...
                                       'rightKey',   false, ...
                                       'downKey',    false, ...
                                       'leftKey',    false, ...
                                       'escape',     false, ...
                                       'start',      false ...
                                       );
        end
        
        function flag = goalReached(obj, coord)
        % If the goal is reached raise the flag
            if coord >= obj.goalY
                flag = true;
            else
                flag = false;
            end
        end
    end
    
    methods (Access = private)
        function obj = drawWorld(obj)
            % Load the world information
            load(obj.name, 'typeArray');
            % For empty world
            if isempty(typeArray)
                % Print backgorund
                rectangle('Position', [0, 0, obj.maxX, obj.maxY], 'FaceColor', [0.8 0.8 0.8], 'EdgeColor', 'none');
                % Print first row
                obj.ax.UserData.rows{1} = rectangle('Position', [0, -obj.hScale, obj.maxX, obj.hScale], 'FaceColor', 'k', 'EdgeColor', 'none');
                % Print last row
                obj.ax.UserData.rows{1} = rectangle('Position', [0, obj.maxY, obj.maxX, obj.hScale], 'FaceColor', 'k', 'EdgeColor', 'none');
                obj.goalY = 10;
                return;
            end
            % Print backgorund
            rectangle('Position', [obj.maxX/2-3.5*obj.wScale, 0, obj.wScale*7, obj.hScale*(numel(typeArray)*2+3)], 'FaceColor', [0.8 0.8 0.8], 'EdgeColor', 'none');
            % Print boundaries
            obj.ax.UserData.bounds(1) = rectangle('Position', [obj.maxX/2-3.5*obj.wScale, 0, obj.wScale, obj.hScale*(numel(typeArray)*2+3)], 'FaceColor', 'k', 'EdgeColor', 'none');
            obj.ax.UserData.bounds(2) = rectangle('Position', [obj.maxX/2+2.5*obj.wScale, 0, obj.wScale, obj.hScale*(numel(typeArray)*2+3)], 'FaceColor', 'k', 'EdgeColor', 'none');
            % Print first row
            obj.ax.UserData.rows{1} = rectangle('Position', [obj.maxX/2-2.5*obj.wScale, 0, obj.wScale*5, obj.hScale], 'FaceColor', 'k', 'EdgeColor', 'none');
            % Print body
            for i = 1:numel(typeArray)
                switch typeArray(i)
                    case 1
                        obj.ax.UserData.rows{end+1} = rectangle('Position', [obj.maxX/2-2.5*obj.wScale, obj.hScale*2*i, obj.wScale*4, obj.hScale], 'FaceColor', 'k', 'EdgeColor', 'none');
                    case 2
                        obj.ax.UserData.rows{end+1} = rectangle('Position', [obj.maxX/2-1.5*obj.wScale, obj.hScale*2*i, obj.wScale*4, obj.hScale], 'FaceColor', 'k', 'EdgeColor', 'none');
                    case 3
                        obj.ax.UserData.rows{end+1}  = rectangle('Position', [obj.maxX/2-2.5*obj.wScale, obj.hScale*2*i, obj.wScale*1, obj.hScale], 'FaceColor', 'k', 'EdgeColor', 'none');
                        obj.ax.UserData.rows{end}(2) = rectangle('Position', [obj.maxX/2-0.5*obj.wScale, obj.hScale*2*i, obj.wScale*3, obj.hScale], 'FaceColor', 'k', 'EdgeColor', 'none');
                    case 4
                        obj.ax.UserData.rows{end+1}  = rectangle('Position', [obj.maxX/2-2.5*obj.wScale, obj.hScale*2*i, obj.wScale*3, obj.hScale], 'FaceColor', 'k', 'EdgeColor', 'none');
                        obj.ax.UserData.rows{end}(2) = rectangle('Position', [obj.maxX/2+1.5*obj.wScale, obj.hScale*2*i, obj.wScale*1, obj.hScale], 'FaceColor', 'k', 'EdgeColor', 'none');
                    case 5
                        obj.ax.UserData.rows{end+1}  = rectangle('Position', [obj.maxX/2-2.5*obj.wScale, obj.hScale*2*i, obj.wScale*2, obj.hScale], 'FaceColor', 'k', 'EdgeColor', 'none');
                        obj.ax.UserData.rows{end}(2) = rectangle('Position', [obj.maxX/2+0.5*obj.wScale, obj.hScale*2*i, obj.wScale*2, obj.hScale], 'FaceColor', 'k', 'EdgeColor', 'none');
                    otherwise
                        error('Error in the map typeArray');
                end
            end
            % Print last row
            obj.ax.UserData.rows{end+1} = rectangle('Position', [obj.maxX/2-2.5*obj.wScale, obj.hScale*(numel(typeArray)*2+2), obj.wScale*5, obj.hScale], 'FaceColor', 'k', 'EdgeColor', 'none');
            % Save goal
            obj.goalY = obj.hScale*(numel(typeArray)*2+2);
        end
    end
end