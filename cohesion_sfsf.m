% MATLAB R2015a
%% parameters
names = {'Kasia_K','Magda_P','Ewa_K','Agnieszka_K','Krystyna',...
    'Jan_M', 'Mikolaj_M','Michal_P','Krzysztof_B','Justyna_G',...
    'Alicja_K','Joanna_K','Joanna_R', 'Kasia_P','Monika_W',...
    'Teresa_B', 'Jedrzej_R'
    };
names2 = {'Alicja_B','Ula_M', 'Urszula_O', 'Jan_B'};

%jest jeszcze zmierzona Klaudia_W, ale u niej zla aud. imped.
% Alicja_B, Ula_O i Ula_M maj� s�abe wyniki, Jan_B nienajlepiej
SaveFlag = 0; LegFlag = 0; StdInterTrialPlotFlag=0;
snr_value = 9; sndiff = 6;
option = 'clean'; % options: 'clean', 'max_snr', 'all'
load('2OAE17osobclean.mat')
% OAE vectors (clean):
% OAE_quick = NaN(length(names),2, 4, 6); %subjects x ears x freqs x trials
% OAE_cluster = NaN(length(names),2, 5, 6); %subjects x ears x freqs x trials
% OAE_dp = NaN(length(names),2, 6, 6); %subjects x ears x freqs x trials
load('freq short.mat'); %ds 
load('freq dp.mat'); %f2s
load('freq cluster.mat'); %d
dc = round(d(3:5:end),-2);
Adqc = NaN(30, 3); %entries, freqs
Adqc2 = NaN(34, 3); %entries, freqs

al = 0; %counter
bal = 0;
for i = 1:length(names)
    name = char(names(i));
    for ea = 1:2
        values_q = squeeze(OAE_quick(i,ea,[1,2,4],:));
        values_c = squeeze(OAE_cluster(i,ea,[1,3,5],:));
        bal = bal + 1;
        Adqc2(bal,:) = mean(values_q,2,'omitnan') - mean(values_c,2,'omitnan');
        lenc = length(values_c(~(sum(isnan(values_c))==3)));%cut off columns with only NaNs
        lenq = length(values_q(~(sum(isnan(values_q))==3))); 
        %lenq = size(values_q,2); %calculate number of trials
        %lenc = size(values_c,2);
        for j = 1:lenq
            for k = 1:lenc
                diff = values_q(:,j)-values_c(:,k);
                al = al + 1;
                Adqc(al,:) = diff;
            end
        end
    end
end
medqc = median(Adqc, 'omitnan')
medqc2 = median(Adqc2, 'omitnan')
meanqc = mean(Adqc, 'omitnan')
meanqc2 = mean(Adqc2, 'omitnan')
stdqc = std(reshape(Adqc,1,[]), 'omitnan')
stdqc2 = std(reshape(Adqc2,1,[]), 'omitnan')

y_lim = [-15 15];
figure()
boxplot(Adqc,round(ds([1,2,4]),-2),'notch','on')
ylabel('Ad_{qc}(f) [dB SPL]', 'Interpreter', 'tex')
set(gca,'XTickLabel',{'1000','2000','4000'})
xlabel('Frequency [Hz]')
ylim(y_lim);
% hold on
% plot(qu(3,[1,2,4]),'g:','DisplayName','Quick')
% plot(cl(3,[1,3,5]),'g--','DisplayName','Cluster')
% legend()

y_lim = [-10, 10];
figure()
boxplot(Adqc2,round(ds([1,2,4]),-2),'notch','on')
ylabel('Ad_{qc}(f) [dB SPL]', 'Interpreter', 'tex')
set(gca,'XTickLabel',{'1000','2000','4000'})
xlabel('Frequency [Hz]')
% hold on
% plot(qu(3,[1,2,4]),'g:','DisplayName','Quick')
% plot(cl(3,[1,3,5]),'g--','DisplayName','Cluster')
% legend()
ylim(y_lim);

figure()
ala = NaN(6,17);
for i = 1:17
    ala(:,i) = reshape(Adqc2(2*i-1:2*i,:),[],1);
end
boxplot(ala)
grid on
ylabel('Ad_{qc} [dB SPL]', 'Interpreter', 'tex')
xlabel('Subject ID');
ylim(y_lim);