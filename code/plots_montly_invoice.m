clear all
close all

run conf.m

sel_m = [8];
sel_y = [3];
sel_u = [4];

papersize = [18 6];
offset = -.7;
printfigs = 1;

load([tmp_data_dir cons_file]);
load([tmp_data_dir price_file])

cons_hour = squeeze(sum(cons_full,6,'omitnan'));
hours = 1:24*31;

for u = 1:length(users)
	figure()
	colororder([0 0 0; 1 0 0])

	yyaxis left;
	mon_price = transpose(squeeze(pr_full(sel_y,sel_m,:,:)));
	area(hours,mon_price(:)/100,'LineStyle','none','FaceColor', .75*[1 1 1]);
	hold on 
	h = plot(hours([1,end]),mean(mon_price,'all')*[1 1]/100,'-.');
	l = legend(h, sprintf('Snittpris över tid %.2f öre/kWh',mean(mon_price,'all')), 'Location','NorthWest')
	l.AutoUpdate = 'off';
	ylabel('Pris elhandel [kr/kWh]')

	yyaxis right;
	usr_hour = transpose(squeeze(cons_hour(u,sel_y,sel_m,:,:)));
	b = bar(hours,usr_hour(:));
	b.FaceAlpha = .5;
	ylabel('Laddning per timme [kWh]')

	xlabel('Timme i månaden')
	title(sprintf('Laddning för %s i %s (total %.1f kWh)', users{u}, month_l_se(sel_m,:), sum(cons_acc(u,sel_y,sel_m,:,:,:),[2,3,4,5,6])));
	if printfigs
	    set(gcf,'paperunits','centimeters','papersize',papersize,'paperposition',[offset,0,papersize(1)-offset,papersize(2)])
		print([fig_dir 'consumption_day_of_month_' users{u}],'-dpng')
		print([fig_dir 'consumption_day_of_month_' users{u}],'-dpdf')
	end
end
