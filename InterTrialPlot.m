function [y] = InterTrialPlot (NoFreqs, gen_mean, fclist, NoTrials, MeasurType)
l = NoTrials;
colors = {'m','c','r','g','b','k'};
ears = ['L';'R'];
for p=1:2
    ear = ears(p);
    figure(p+1)
    hold on
    grid on
    for i=1:NoFreqs
        disp(mean(gen_mean.(ear)(:,i)))
        plot(1:l.(ear),5*i+gen_mean.(ear)(:,i)-mean(gen_mean.(ear)(:,i)),'Color', char(colors(i)),'DisplayName', ...
            ['f_' num2str(i) ' = ' num2str(round(fclist(i),-2))...
             ' [Hz]'])
        plot(1:l.(ear),zeros(1,l.(ear))+5*i, '-.', 'Color', char(colors(i)), ...
            'DisplayName', ['Zero level for f_', num2str(i)])
    end
    title([MeasurType ', "' ear '"' ' ear'])
    xlabel('Number of trial')
    ylabel('dP + 5*i - mean(f_i) [dB SPL]');
    legend('Location', 'eastoutside')
end
hold off
end