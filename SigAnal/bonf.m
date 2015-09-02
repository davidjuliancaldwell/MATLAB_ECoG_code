function [p_allowed, p_masked] = bonf(p, alpha)
    p_allowed = alpha/numel(p);
    p_masked = p <= p_allowed;
end