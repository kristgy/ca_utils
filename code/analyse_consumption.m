
clear all
close all

run conf.m

load([cf.tmp_data_dir cf.cons_file],'cons')

cons_hour = squeeze(sum(cons.day_of_month,[1 6],'omitnan'));

histogram(cons_hour)
set(gca,'YScale','log')
xlabel('Charged per hour [kWh]')
ylabel('Number of hours')
print('-dpng',[cf.fig_dir 'consumption_hour_histogram'])
