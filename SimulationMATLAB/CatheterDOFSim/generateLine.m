% Save points generated with mouse clicks
function generateLine

    % Size of the 'playing field'.
    maxX = 1920;
    maxY = 1080;
    % Create figure and axis
    hFig = figure;
    ax = axes(hFig);
    % Initialize line
    line(ax, maxX/2*[1 1 1], [0 1080/2-10 1080/2], 'LineWidth', 8);
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
    % Configure callback functions
    set(hFig, 'WindowButtonDownFcn', @(hFig, event)mousePressCallback(hFig, event));
    set(hFig, 'WindowKeyPressFcn',     @(hFig, event)keyPressCallback(hFig, event));
    set(hFig, 'WindowKeyReleaseFcn',   @(hFig, event)keyReleaCallback(hFig, event));
    
end

function [hFig, event] = mousePressCallback(hFig, event)
    % Check which key was pressed
    switch hFig.SelectionType
        case 'normal'
           if hFig.UserData
               hFig.Children.Children.XData(end+1) = hFig.Children.CurrentPoint(1,1);
               hFig.Children.Children.YData(end+1) = hFig.Children.CurrentPoint(1,2);
           end
        case 'alt'
           if hFig.UserData
               hFig.Children.Children.XData(end) = [];
               hFig.Children.Children.YData(end) = [];
           end
        case 'extend'
           close all;
        otherwise
            error('Unexpected event');
    end
end

function [hFig, event] = keyPressCallback(hFig, event)
    % Check which key was pressed
    switch event.Character
        case 'a'
           hFig.UserData = true;
        otherwise
            error('Unexpected event');
    end
end

function [hFig, event] = keyReleaCallback(hFig, event)
    % Check which key was pressed
    switch event.Character
        case 'a'
           hFig.UserData = false;
        otherwise
            error('Unexpected event');
    end
end