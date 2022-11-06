clear all
close all

run conf.m

%sel_m = [1];
sel_m = [10];
sel_y = [3];
%sel_u = [4];

papersize = [18 8];
offs_x = -.9;
offs_y = -.7;
printfigs = 1;
%printfigs = 0;

load([cf.tmp_data_dir cf.cons_file],'cons');
load([cf.tmp_data_dir cf.price_file],'price')

cons_hour = squeeze(sum(cons.day_of_month,6,'omitnan'));
mon_price = transpose(squeeze(price.day_of_month(sel_y,sel_m,:,:)));
num_days_mon = datetime(price.years(sel_y),sel_m+1,0).Day;
hours = 1:24*31;
days = 1:31;
start_weekday_mon = weekday(sprintf('%d-%d-01',price.years(sel_y),sel_m));
weekdays = mod(start_weekday_mon+days-2,7) + 1;
mon_trans = transpose(squeeze(cf.transf_price(sel_y,sel_m,weekdays,:)));
mon_trans(:,num_days_mon+1:end) = NaN;
tax = cf.eng_tax(sel_y)*ones(24,31);
tax(:,num_days_mon+1:end) = NaN;
moms = cf.VAT*(tax + mon_trans + mon_price + cf.markup);
moms(:,num_days_mon+1:end) = NaN;

for u = 1:length(cons.users.ID)
%for u = sel_u
	figure()
	colororder([0 0 0; 1 0 0])

	yyaxis left;
	ar = area(hours,[tax(:)+cf.markup, mon_trans(:), mon_price(:)+cf.markup, moms(:)]/100,'LineStyle','none');
	ar(1).FaceColor = .55*[1 1 1];
	ar(2).FaceColor = .65*[1 1 1];
	ar(3).FaceColor = .75*[1 1 1];
	ar(4).FaceColor = .85*[1 1 1];
	hold on 
%	h = plot(hours([1,end]),mean(mon_price,'all','omitnan')*[1 1]/100,'k-.');
	%l = legend({'Energiskatt','Elöverföring','Elhandel','Moms',sprintf('Snitt elh. över tid %.2f öre/kWh',mean(mon_price,'all','omitnan'))}, 'Box','off','Location','SouthOutside','Orientation','horizontal');
	l = legend({'Energiskatt+påslag','Elöverföring',sprintf('Elhandel (snitt över tid %.2f öre/kWh)',mean(mon_price,'all','omitnan')),'Moms'}, 'Box','off','Location','SouthOutside','Orientation','horizontal');
	l.AutoUpdate = 'off';
	ylabel('Pris [kr/kWh]')
	set(gca,'XLim',[1 24*num_days_mon]);

	yyaxis right;
	usr_hour = transpose(squeeze(cons_hour(u,sel_y,sel_m,:,:)));
	b = bar(hours,usr_hour(:));
	b.FaceAlpha = .5;
	ylabel('Laddning per timme [kWh]')
	set(gca,'XLim',[1 24*num_days_mon]);

	xlabel('Timme i månaden')
	title(sprintf('Sammanställning för %s under %s (total laddning %.1f kWh)', cons.users.FirstName{u}, cf.month_l_se(sel_m,:), sum(cons.day_of_week(u,sel_y,sel_m,:,:,:),[2,3,4,5,6])));
	%l.Position(2) = l.Position(2) + .25;
	if printfigs
	    set(gcf,'paperunits','centimeters','papersize',papersize,'paperposition',[offs_x,offs_y,papersize(1)-offs_x,papersize(2)-offs_y])
		print([cf.fig_dir 'consumption_day_of_month_' cons.users.ID{u}],'-dpng')
		print([cf.fig_dir 'consumption_day_of_month_' cons.users.ID{u}],'-dpdf')
	end
end
