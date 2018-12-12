function magnitude = theta_min_func(thetaD,thetaA)

magnitude = min(abs(thetaD-thetaA),360-(abs(thetaD-thetaA)));

end
