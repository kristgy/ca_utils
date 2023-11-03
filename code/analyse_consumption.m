
clear all
close all

run conf.m

sel_year = [2 3 4];
sel_mon = 4;
years_l = string(cf.years(sel_year));


load([cf.tmp_data_dir cf.cons_file],'cons')

cons_hour = squeeze(sum(cons.day_of_month,[1 6],'omitnan'));
cons_usr_hour = squeeze(sum(cons.day_of_month,6,'omitnan'));
cons_hour_of_day = squeeze(sum(cons.day_of_month,[1 4 6],'omitnan'));

figure()
histogram(cons_hour)
set(gca,'YScale','log')
xlabel('Charged per hour [kWh]')
ylabel('Number of hours')
print('-dpng',[cf.fig_dir 'consumption_hour_histogram'])

figure()
histogram(cons_usr_hour)
set(gca,'YScale','log')
xlabel('Charged per hour [kWh]')
ylabel('Number of hours')
print('-dpng',[cf.fig_dir 'consumption_hour_histogram'])

figure()
%ha = tight_subplot(3,4,[.01 .03],[.1 .01],[.01 .01])
ha = tight_subplot(3,4,0,[.1 .02],[.1 .02]);
for sel_mon = 1:12
	axes(ha(sel_mon))
	plot(1:24,squeeze(cons_hour_of_day(sel_year,sel_mon,:)))
	text(10,150,cf.month_l(sel_mon,:))
	set(gca,'XLim',[1 24],'YLim',[0 300])
end
set(ha(1:8),'XTickLabel','');
set(ha([2 3 4 6 7 8 10 11 12]),'YTickLabel','')
legend(ha(1),years_l,'Location','best')
ylabel(ha(5),'Charged per hour [kWh]')
xlabel(ha(10),'                                   Hour of day')
%set(gcf,'PaperUnits','centimeters','PaperSize',[30 40])
print('-dpdf',[cf.fig_dir 'consumption_hour_of_day'])
print('-dpng',[cf.fig_dir 'consumption_hour_of_day'])

%for user = 1:length(cons.users.ID)
%	figure()
%	histogram(cons_usr_hour(user,:))
%	title(cons.users.ID(user),'Interpreter','none')
%	set(gca,'YScale','log')
%	xlabel('Charged per hour [kWh]')
%	ylabel('Number of hours')
%	print('-dpng',[cf.fig_dir 'consumption_hour_histogram_' num2str(user)])
%end
