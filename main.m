names = {'Kasia_K','Magda_P','Ewa_K','Agnieszka_K','Krystyna',...
    'Surala','Klaudia_W', 'Mikolaj_M','Michal_P','Krzysztof_B',...
    'Justyna_G','Alicja_B', 'Jan_B', 'Joanna_K','Joanna_R', ...
    'Kasia_P','Monika_W','Teresa_B','Ula_M','Urszula_O', ...
    };
SaveFlag = 1; LegFlag = 0; snr_value = 9;
fracs=NaN(1,length(names));
name_idx = 13; 
name = char(names(name_idx));
fr = analysis_short(name, name_idx,snr_value,SaveFlag, LegFlag); %fraction of passes in %
fracs(name_idx) = fr; 