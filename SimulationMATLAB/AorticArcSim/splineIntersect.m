function [interPoint] = splineIntersect(initPos, initDir, inputSpline, posBps)
    % Normalization
    initDir = [sin(initDir); -cos(initDir)];
    initDir = initDir / norm(initDir);
    % Initi Variables
    polinomialInter = [];
    % Compute the signs of the tangential Distance from the initial vector to posBps
    Signs = sign(round((posBps - initPos)' * initDir, 3));
    % There may be intersections at the exact breakpoints
    exactInter = inputSpline.ppx.breaks(Signs == 0);
    % Now check for intersections between BPS
    midInter = find(abs(diff(Signs)) == 2);
    for i = 1:numel(midInter)
        temp = PolySolve(initPos, initDir, inputSpline, midInter(i));
        polinomialInter = [polinomialInter temp]; %#ok<AGROW>
    end

    % Save the intersection found or return empty
    if(isempty(polinomialInter) && isempty(exactInter))
        interPoint = [];
    else
        % Find which intersection is the closest one and only return that
        interTemp = [polinomialInter exactInter];
        xyPoints = [ppval(inputSpline.ppx, interTemp); ppval(inputSpline.ppy, interTemp)] - initPos;
        [~, posIdx] = min(sqrt(xyPoints(1,:).^2 + xyPoints(2,:).^2));
        interPoint = interTemp(posIdx);
    end
end


function [interPoly] = PolySolve(initPoint, initDir, inputSpline, bpRef)

    % Find the polynomial coefficients
    a = initDir(1)*inputSpline.ppx.coefs(bpRef,1) + initDir(2)*inputSpline.ppy.coefs(bpRef,1);
    b = initDir(1)*inputSpline.ppx.coefs(bpRef,2) + initDir(2)*inputSpline.ppy.coefs(bpRef,2);
    c = initDir(1)*inputSpline.ppx.coefs(bpRef,3) + initDir(2)*inputSpline.ppy.coefs(bpRef,3);
    d = initDir(1)*(inputSpline.ppx.coefs(bpRef,4)-initPoint(1)) + ...
        initDir(2)*(inputSpline.ppy.coefs(bpRef,4)-initPoint(2));
    % The polynomial may have really small numbers, then treat it as if it
    % was lower order. This happens with really straight lines
    if (abs(a) >= 1e-10)
        Order = 3;
        Poly = [a b c d]./a;
    elseif (abs(b) >= 1e-10)
            Order = 2;
            Poly = [b c d]./b;
    end
    % Solve
    A = diag(ones(Order-1,1),-1);
    A(1,:) = -Poly(2:Order+1)./Poly(1);
    r = (eig(A));
    % Only use the real values
    idx = (r == real(r));
    r = r(idx);
    % Get only the intersections where the BPS of the spline are defined
    idx1 = (r >= 0);
    idx2 = (r <= (inputSpline.ppx.breaks(bpRef+1)-inputSpline.ppx.breaks(bpRef)));
    idx = (idx1 & idx2);
    % Select valid Intersection Points
    r = r(idx);
    % Add spline offset
    interPoly = r' + inputSpline.ppx.breaks(bpRef);
end