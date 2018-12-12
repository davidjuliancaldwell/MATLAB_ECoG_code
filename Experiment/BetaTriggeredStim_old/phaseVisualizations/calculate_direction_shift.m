function directionShift = calculate_direction_shift(thetaD,thetaA)

if thetaD == 0
    thetaD = 360;
end

calculated(1,:) = thetaD - thetaA;

calculated(2,:) = calculated(1,:);
calculated(2,calculated(1,:)>180) = -1*(360 - thetaD + thetaA(calculated(1,:)>180));
directionShift = sign(calculated(2,:));

end