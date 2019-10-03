function [rotationGain, movementGain] = limitVel(rotationGain, movementGain)
    rotationGain = sign(rotationGain)*min(sign(rotationGain)*rotationGain, 0.5);
    movementGain = sign(movementGain)*min(sign(movementGain)*movementGain, 20);
end