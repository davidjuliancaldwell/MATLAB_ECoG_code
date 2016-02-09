function rhs = image_rhsD(t,A,dummy,L,D)
% rhs=D*L*A;
rhs = L*(A.*D);