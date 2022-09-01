
clear all
close all

run conf.m

load([tmp_data_dir cons_file])

cons_hour = squeeze(sum(cons_full,[1 6],'omitnan'));

histogram(cons_hour)
set(gca,'YScale','log')
xlabel('Charged per hour [kWh]')
ylabel('Number of hours')
print('-dpng',[fig_dir 'consumption_hour_histogram'])
