clear all
close all

run conf.m

%sel_m = [1];
sel_m = [2];
sel_y = [3];
sel_u = [4];

papersize = [18 8];
offs_x = -.9;
offs_y = -.7;
printfigs = 1;
%printfigs = 0;

load([tmp_data_dir cons_file]);
load([tmp_data_dir price_file])

cons_hour = squeeze(sum(cons_full,6,'omitnan'));
mon_price = transpose(squeeze(pr_full(sel_y,sel_m,:,:)));
hours = 1:24*31;
days = 1:31;
start_weekday_mon = weekday(sprintf('%d-%d-01',price_years(sel_y),sel_m));
weekdays = mod(start_weekday_mon+days-2,7) + 1;
mon_trans = transpose(squeeze(transf_price(sel_y,sel_m,weekdays,:)));
moms = VAT*(eng_tax(sel_y)*ones(length(hours),1) + mon_trans(:) + mon_price(:) + markup);

for u = 1:length(users)
%for u = sel_u
	figure()
	colororder([0 0 0; 1 0 0])

	yyaxis left;
	ar = area(hours,[eng_tax(sel_y)*ones(length(hours),1), mon_trans(:), mon_price(:)+markup, moms]/100,'LineStyle','none');
	ar(1).FaceColor = .55*[1 1 1];
	ar(2).FaceColor = .65*[1 1 1];
	ar(3).FaceColor = .75*[1 1 1];
	ar(4).FaceColor = .85*[1 1 1];
	hold on 
	h = plot(hours([1,end]),mean(mon_price,'all')*[1 1]/100,'-.');
	l = legend({'Energiskatt','Elöverföring','Elhandel','Moms',sprintf('Snitt elh. över tid %.2f öre/kWh',mean(mon_price,'all','omitnan'))}, 'Box','off','Location','SouthOutside','Orientation','horizontal');
	l.AutoUpdate = 'off';
	ylabel('Pris [kr/kWh]')

	yyaxis right;
	usr_hour = transpose(squeeze(cons_hour(u,sel_y,sel_m,:,:)));
	b = bar(hours,usr_hour(:));
	b.FaceAlpha = .5;
	ylabel('Laddning per timme [kWh]')

	xlabel('Timme i månaden')
	title(sprintf('Sammanställning för %s under %s (total laddning %.1f kWh)', users{u}, month_l_se(sel_m,:), sum(cons_acc(u,sel_y,sel_m,:,:,:),[2,3,4,5,6])));
	%l.Position(2) = l.Position(2) + .25;
	if printfigs
	    set(gcf,'paperunits','centimeters','papersize',papersize,'paperposition',[offs_x,offs_y,papersize(1)-offs_x,papersize(2)-offs_y])
		print([fig_dir 'consumption_day_of_month_' users{u}],'-dpng')
		print([fig_dir 'consumption_day_of_month_' users{u}],'-dpdf')
	end
end
