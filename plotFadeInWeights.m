%%
fs = 44100;
% fake IR
ir = ones(1,2000);

onset = 500;

mixingTime = 0.0272;

var1 = fadeInFunction( mixingTime, fs, onset, ir, 'var1' );
var2 = fadeInFunction( mixingTime, fs, onset, ir, 'var2' );
var3 = fadeInFunction( mixingTime, fs, onset, ir, 'var3' );
var4 = fadeInFunction( mixingTime, fs, onset, ir, 'var4' );
var5 = fadeInFunction( mixingTime, fs, onset, ir, 'var5' );
var6 = fadeInFunction( mixingTime, fs, onset, ir, 'var6' );

figure;
plot(var1);
hold on;
plot(var2);
plot(var3);
plot(var4);
plot(var5);
plot(var6);

legend('var1','var2','var3','var4','var5','var6');





