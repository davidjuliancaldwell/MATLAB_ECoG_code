x = randn(500, 1);
c = (x+0.9*randn(size(x))) > 0;

nFoldCrossValidation(x, c, 5)