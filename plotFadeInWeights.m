%% plot fade-in weigts for all variations
fs = 44100;
% fake IR
ir = ones(1,2000);
% fake onset
onset = 500;
% fake mixing time
mixingTime = 0.0272;

var1 = fadeInFunction( mixingTime, fs, onset, ir, 'var1' );
var2 = fadeInFunction( mixingTime, fs, onset, ir, 'var2' );
var3 = fadeInFunction( mixingTime, fs, onset, ir, 'var3' );
var4 = fadeInFunction( mixingTime, fs, onset, ir, 'var4' );
var5 = fadeInFunction( mixingTime, fs, onset, ir, 'var5' );
var6 = fadeInFunction( mixingTime, fs, onset, ir, 'var6' );

AKf(8.89,8);
plot(var1);
hold on;
plot(var2);
plot(var3);
plot(var4);
plot(var5);
plot(var6);
grid on;
ylim([0,1.1]);
xticks([onset, fs*mixingTime]);
xticklabels({'first reflection', 'mixing time'});
%xlabel('time in [s]','FontSize',9,'Interpreter','latex');
ylabel('fade-in weight','FontSize',9,'Interpreter','latex');
ax = gca;
ax.FontSize = 9;
ax.TickLabelInterpreter = 'latex';
%ax.Legend.Interpreter = 'latex';
legend({'direct','fade-in 1','fade-in 2','fade-in 3','fade-in 4','fade-in 5'},'FontSize',9,'Interpreter','latex','Location','SOUTHEAST');




