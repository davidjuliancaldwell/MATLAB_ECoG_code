%% 4/17/2016 
% Plotting theory vs. experiment for Larry 

%% 7db 

% 7db numbers

% voltage at point 142

t142 = [0.00539645626329032	0.00990710172513001	0.0100064556698532	-0.0106406465040213	-0.0111669293152615	-0.00617727697356383	-0.00355002170554015	-0.00149883058094464
0.00626828263726634	0.0211241326454937	0	0	-0.0183502551012122	-0.00842542099555265	-0.00449049872135628	-0.00300132941983431
0.00570889136946783	0.0118331266503990	0.0104401373147772	-0.0106147348938724	-0.0108786612285447	-0.00666705096293716	-0.00423782709284467	-0.00283833500779695
0.00330958784079020	0.00418821762279204	0.00170707166573929	-0.00330698823594177	-0.00514886577319870	-0.00417699295888556	-0.00326232508922917	-0.00248072393221617
0.00116219450462149	0.000618725339381770	-0.000159978002143062	-0.00159129314433017	-0.00248841269956575	-0.00290236315082871	-0.00263143830315238	-0.00217591900743133
0.00145758005849373	0.00116426961838474	-7.45468155458325e-05	-0.00113209700263168	-0.00178226345157462	-0.00210639621646563	-0.00205257504496170	-0.00180812387990301
0.000478398147179632	0.000299675306744447	-0.000283598886360838	-0.000955988459713850	-0.00131763306121300	-0.00158792495168344	-0.00166953567680728	-0.00153595940214229
0.000214091645109955	-0.000155618312509053	-0.000455210887208608	-0.000815921276327204	-0.00106721621576108	-0.00118423826953491	-0.00126120045113200	-0.00128701751543443];

% t142 = t142(:);

% voltage at point 158

v185 = [-0.00539560044627322	-0.00977778286132009	-0.00992851606951780	0.0105921620002690	0.0111808839632234	0.00621498768801445	0.00357612313836691	0.00233242800589722
-0.00634748676363712	-0.0204503913005459	0	0	0.0185074492013948	0.00847892088784583	0.00453715618741105	0.00302600217793763
-0.00566834865183267	-0.0117193786177764	-0.0104519732710197	0.0107939832066877	0.0109723606594458	0.00671678411074841	0.00428599443599967	0.00286027820332140
-0.00333792988761217	-0.00420683964002976	-0.00168545773987058	0.00335217917242471	0.00521698008803278	0.00420334757229937	0.00330451347773926	0.00250370904006516
-0.00117082365087589	-0.000630488621243632	0.000157031611627197	0.00161055300262248	0.00250418736652178	0.00293432799555552	0.00265277161064098	0.00219291764592955
-0.00147703164155972	-0.00117498850907547	6.79647148495122e-05	0.00113719491901990	0.00180054938021700	0.00212747285173241	0.00206444986763933	0.00181933907270937
-0.000486815232955059	-0.000309421322507707	0.000276827293694753	0.000956928496061378	0.00132669960400399	0.00160189557845520	0.00168616555991094	0.00155150373812044
0.00155342947871370	0.000152543217164270	0.000452524119328827	0.000811464813706027	0.00106850225325701	0.00119441969087634	0.00127283678837958	0.00129517616909393];

% v185 = v185(:);


%theory

tV = [0.130985829483120	0.259893185686590	0.292893218813453	-0.292893218813453	-0.259893185686590	-0.130985829483120	-0.0736921409805050	-0.0464194898981489
0.166666666666667	0.500000000000000	0	0	-0.500000000000000	-0.166666666666667	-0.0833333333333333	-0.0500000000000000
0.130985829483120	0.259893185686590	0.292893218813453	-0.292893218813453	-0.259893185686590	-0.130985829483120	-0.0736921409805050	-0.0464194898981489
0.0762032924806592	0.0936602049066842	0.0527864045000421	-0.0527864045000421	-0.0936602049066842	-0.0762032924806592	-0.0537433003626356	-0.0379114595729271
0.0416478377170987	0.0388776679042234	0.0171055673164954	-0.0171055673164954	-0.0388776679042234	-0.0416478377170987	-0.0357022603955159	-0.0285014148574912
0.0236067977499790	0.0189288272863540	0.00746437496366703	-0.00746437496366703	-0.0189288272863540	-0.0236067977499790	-0.0232233047033631	-0.0206029334080308
0.0141967530345430	0.0104207969611322	0.00388386486181597	-0.00388386486181597	-0.0104207969611322	-0.0141967530345430	-0.0153248232539027	-0.0147524056512966
0.00904268450843299	0.00628510429693832	0.00226767936130937	-0.00226767936130937	-0.00628510429693832	-0.00904268450843299	-0.0103961494436787	-0.0106381691234113];

% tV = tV(:);
%% Plotting

figure

subplot(2,2,1)
contour3(tV,'ShowText','On')
title('contour3')
subplot(2,2,2)
contourf(tV,'ShowText','On')
title('contourf')
subplot(2,2,3)
surf(tV)
title('surf')
subplot(2,2,4)
pcolor(tV)
title('pcolor')
