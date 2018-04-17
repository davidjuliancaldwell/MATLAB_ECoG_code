dummy_dist = [randn(10000,1)+3;randn(10000,1)-3];
figure
histogram(dummy_dist)

ts_real = 6; 
vline(ts_real);
tested_vals_pos = sum((dummy_dist>ts_real));
tested_vals_neg = sum((dummy_dist<ts_real)); 

tested_vals_p = tested_vals_pos/length(dummy_dist);
tested_vals_n = tested_vals_neg/length(dummy_dist);
tested_vals_p;
tested_vals_n;
p_value = min(tested_vals_p,tested_vals_n);