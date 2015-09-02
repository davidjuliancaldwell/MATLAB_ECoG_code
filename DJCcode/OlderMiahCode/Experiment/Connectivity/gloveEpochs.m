[signal states params] = load_bcidat('C:\Research\Data\Patients\38e116\d1\38e116_fingerflex_L001\38e116_fingerflex_LS001R02');
smoothGlove = CreateSmoothGloveTrace(states, params, 'spline');

params = CleanBCI2000ParamStruct(params);

peaks = {};
for i=1:22
    [garbage peaks{i}] = findpeaks(smoothGlove(:,i).*(smoothGlove(:,i) > smoothGlove(100,i)), 'minpeakheight',10,'minpeakdistance',params.SampleBlockSize);
end

for i=1:22
    
    plot(peaks{i}, i*100+smoothGlove(peaks{i},i),'r.');
    hold on;
    plot(i*100+smoothGlove(:,i),'color',rand(3,1));
end