function [splineOut] = getSplineDerivatives(splineIn, orderInput)
orderOut = orderInput - 1;

[breaksIn, coefsIn, piecesIn, ~, dimIn] = unmkpp(splineIn);

coefsOut = coefsIn(:, 1:orderOut).*kron(ones(piecesIn,1), orderOut:-1:1);

splineOut = mkpp(breaksIn, coefsOut, dimIn);

end