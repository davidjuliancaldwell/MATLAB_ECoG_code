function [newMu,newSig]=gaussInterpolate(mu1,sig1,mu2,sig2,learnFactor)
    if mu1>mu2
        sign1 = 1;
    else
        sign1 = -1;
    end
    
    if sig1>sig2
        sign2 = 1;
    else
        sign2 = -1;
    end
    
    ht = (sig2-sig1)*learnFactor + sig1;
    a = sign1*log(sig1/sig2) - sign2*2*(mu2-mu1)/(sig1+sig2);
    gt = sign2*(1/2)*(sign1*log(sig1/ht) - a*learnFactor)*(sig1+ht) + mu1;
    
    newMu = gt;
    newSig = ht;