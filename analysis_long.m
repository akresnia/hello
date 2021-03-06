function [fr,frf, R2, R2_ear, mean_SFL, gen_mean_clean, times] = analysis_long(name, name_idx,snr_value,SaveFlag, option, StdInterTrialPlotFlag, PrctileFilename)
%directory_name = 'C:\Users\Alicja\Desktop\praca mgr\moje OAE\20_03\';
% options: 'clean', 'max_snr', 'all'

% snr_value = 9;
% SaveFlag = 0;
prc = 0.25:0.25:0.75; % population percentiles values

y_lim = [-30 30];

%% loading data
directory_name = ['C:\Users\Alicja\Desktop\praca mgr\OAE ' name '\'];
[a, b, c, short, long, longest] = wczytanie(directory_name);
%b - 1 - # of long trials
n = 25; %length(data.sfe.fp)
m = 5; %length(data.sfe.fclist)

el.R = 0;
el.L = 0;
frf.L = NaN(1,m);
frf.R = NaN(1,m);
ears = ['L';'o';'R'];

%% creating matrices for plotting
for i=1:b-1 %for each trial in dataset
    data = long{i,3};
    y = real(20*log10(data.sfe.dP));
    if sum(isnan(y))>0
        continue
    else
    y_clusters = reshape(y,[],m); %clusters in columns
    noisy_pts = (data.eval.snr<snr_value);
    noise_clusters = reshape(noisy_pts,[],m);
    snr_clusters = reshape(data.eval.snr,[],m);
    val = max(snr_clusters); %over columns=freqs
    % assuming that there are no 2 identical snrs:
    [tf,loc] = ismember(val, data.eval.snr); %finding indices of points with max snr over freqs' clusters
    max_snr_vals = y(loc);

    d=long{i,1};
    if d=='L' || d=='R'
        el.(d) = el.(d) + 1;
        small= mean(y_clusters); %size: 1 x m (1 x freqs)
        y_clusters(noise_clusters) = NaN; %replacing points with small snr with NaN
        small_clean = mean(y_clusters, 'omitnan'); %mean only over passed measurements
        noisy_clust = isnan(small_clean); %clusters without good snr measurements

        general.(d)(el.(d),:)= y;
        gen_mean.(d)(el.(d),:)= small;
        gen_mean_clean.(d)(el.(d),:)= small_clean; %may contain nans
        gen_max_snr.(d)(el.(d),:)= max_snr_vals;
        noise_idx.(d)(el.(d),:) = noisy_pts; % 25 idcs in rows
        noise_clu.(d)(el.(d),:) = noisy_clust; % 5 idcs in rows    
    end
    end
end
clear i j small 
if strcmp(option, 'clean')
    mean_SFL.L = mean(gen_mean_clean.L,'omitnan');
    mean_SFL.R = mean(gen_mean_clean.R,'omitnan');
elseif strcmp(option, 'max_snr')
    mean_SFL.L = mean(gen_max_snr.L);
    mean_SFL.R = mean(gen_max_snr.R);
else
    mean_SFL.L = mean(gen_mean.L);
    mean_SFL.R = mean(gen_mean.R);
end

times.L = long(1:el.L,4);
times.R = long(el.L+1:el.L+el.R, 4);

%% plotting
% grean dots are mean values in clusters calculated from measurements with
% good snr

%% max snr
if strcmp(option,'clean')
    dataopt = gen_mean_clean;
    titopt = 'Means of good snr points';
elseif strcmp(option,'max_snr')
    dataopt = gen_max_snr;
    titopt = 'Max snr points';
elseif strcmp(option, 'all')
    dataopt = gen_mean;
    titopt = 'All datapoints';
else
    error('wrong option')
end

figure('Name', ['Cluster SFOAE' name])
ear_id = 1;
for d=['L','R'] 
    hold on
    k=find(ears==d);
    subplot(2,2,k);    
    f = data.sfe.fclist;
    freqs = repmat(f,el.(d),1);
    if nargin == 7
        load(PrctileFilename)
        hold on
        quant = quantile(squeeze(mean_sfl(ear_id,:,:))',prc); %1st column is left ear
        fill([f f(end:-1:1)],[quant(1,:) quant(3,end:-1:1)],[.87 .87 .87],'EdgeColor', 'none') %// light grey
        hold on
        %q1 = plot(quant(1,:), 'DisplayName', ['Pop.' num2str(prc(1)*100) 'percentile']);
        %plot(quant(2,:),'r--', 'DisplayName', 'Population median')
        %q3 = plot(quant(3,:), 'DisplayName', ['Pop.' num2str(prc(3)*100) 'percentile']);
        ear_id = ear_id + 1;
    end

    plot(f,dataopt.(d)','-.')
%     title([titopt ' "' d '" ear'])
    title(['"' d '" ear'])
    hold on
    scatter(freqs(noise_clu.(d)), gen_mean.(d)(noise_clu.(d))', 30, 'r')
    scatter(freqs(~noise_clu.(d)), dataopt.(d)(~noise_clu.(d))', 30, 'g', 'filled')
    
    pl = plot(f, mean(gen_mean.(d), 'omitnan'),'r', 'LineWidth', 1.5, ...
    'DisplayName', 'Mean ("all")');
    legend(pl)
    xlabel('Frequency [Hz]'); ylabel('SFOAE [dB SPL]'); 
    xlim([800 4200]); ylim(y_lim)
    
    %% calculatingfraction of measurements that pass snr criterion
    s = sum(noise_idx.(d)(:));
    den = length(noise_idx.(d)(:));
    p=den-s;
    fr.(d) = 100* p/den ;
    
    for fi = 1:m %frequency analysis
        denf = el.(d)*m; %denominator - #of measurements
        pf = denf - sum(sum(noise_idx.(d)(:, 5*fi-4:5*fi))); %number of passes
       frf.(d)(fi) = 100*pf/denf; 
    end
    
    text(900, y_lim(1)+3, ['passed: ' num2str(p) '/' num2str(den) ' = '...
        num2str(round(fr.(d),1)) ' %'])
    hold off
end

%% boxplots
subplot(2,2,2); boxplot(gen_mean.L,round(data.sfe.fclist,-1)); ylim(y_lim)
%suptitle(['Cluster SFOAE, ID: ' num2str(name_idx)])
%title('Means of all pts in clusters')
%xlabel('Frequency [Hz]')
subplot(2,2,4); boxplot(gen_mean.R,round(data.sfe.fclist,-1)); ylim(y_lim)
%xlabel('Frequency [Hz]')

%% saving the plot
if SaveFlag
    print([directory_name 'images\' option 'long_SFOAE_trials_boxplots_' name], '-dpng', '-noui')
end

%% Reproducibility analysis
frac = (fr.L + fr.R)/2;

if StdInterTrialPlotFlag
    InterTrialPlot(m, dataopt, f, el, ['Cluster SFOAE ' titopt], name, name_idx,SaveFlag)
end
[~, R2,R2_ear] =StdPlot(f, dataopt, ['Cluster SFOAE ' titopt],name,name_idx,SaveFlag, StdInterTrialPlotFlag);
end

