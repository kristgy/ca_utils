clear all
close all

run conf.m
e_y_idx = find(cf.years==cf.yr);

papersize = [18 8];
offs_x = -.9;
offs_y = -.7;
printfigs = true;
%printfigs = false;
%show_plots = true;
show_plots = false;

load([cf.tmp_data_dir cf.cons_file],'cons');
c_y_idx = find(cons.years==cf.yr);
load([cf.tmp_data_dir cf.price_file],'price')
p_y_idx = find(price.years==cf.yr);

sel_usr = 1:length(cons.users.ID);
%sel_usr = 7;

num_days_mon = datetime(price.years(p_y_idx),cf.m+1,0).Day;
hours = 1:24*31;
days = 1:31;
start_weekday_mon = weekday(sprintf('%d-%d-01',price.years(p_y_idx),cf.m));
weekdays = mod(start_weekday_mon+days-2,7) + 1;
mondays = days(weekdays==2);
weeks_of_year = weeknum(datenum(cf.yr,cf.m,mondays(1))+[0:7:7*(length(mondays)-1)],2,1);
d = repmat(weekdays,24,1);
week_start_hours = hours((d(:)'==2)&~mod(hours-1,24));
week_str = mat2cell(reshape(sprintf('v%02d',weeks_of_year),3,length(mondays))',ones(1,length(mondays)));

cons_hour = squeeze(sum(cons.day_of_month,6,'omitnan'));
if cf.hourly_prices
	mon_price = transpose(squeeze(price.day_of_month(p_y_idx,cf.m,:,:)));
else
	mon_price = cf.telge_avg(e_y_idx,cf.m)*ones(24,31);
end
mon_trans = transpose(squeeze(cf.transf_price(e_y_idx,cf.m,weekdays,:)));
mon_trans(:,num_days_mon+1:end) = NaN;
tax = cf.eng_tax(e_y_idx)*ones(24,31);
tax(:,num_days_mon+1:end) = NaN;
moms = cf.VAT*(tax + mon_trans + mon_price + cf.markup);
moms(:,num_days_mon+1:end) = NaN;

for u = sel_usr
	if show_plots
		figure()
	else
		figure('visible','off');
	end
	colororder([0 0 0; 1 0 0])

	yyaxis left;
	ar = bar(hours,[tax(:)+cf.markup, mon_trans(:), mon_price(:)+cf.markup, moms(:)]/100,1,'stacked');
	ar(1).FaceColor = .55*[1 1 1];
	ar(2).FaceColor = .65*[1 1 1];
	ar(3).FaceColor = .75*[1 1 1];
	ar(4).FaceColor = .85*[1 1 1];
	hold on 
	ylims = get(gca,'YLim');
	plot([week_start_hours;week_start_hours],ylims,'k-')
	text(week_start_hours+5,0.93*ylims(2)*ones(1,length(week_start_hours)),week_str);
	set(gca,'YLim',ylims);
	fixed = 'Energiskatt';
	if cf.hourly_prices
		fixed = [fixed '+påslag'];
	end
	l = legend({fixed,'Elöverföring',sprintf('Elhandel (snitt över tid %.2f öre/kWh)',mean(mon_price,'all','omitnan')),'Moms'}, 'Box','off','Location','SouthOutside','Orientation','horizontal');
	l.AutoUpdate = 'off';
	ylabel('Pris [kr/kWh]')
	set(gca,'XLim',[1 24*num_days_mon]);

	yyaxis right;
	usr_hour = transpose(squeeze(cons_hour(u,c_y_idx,cf.m,:,:)));
	b = bar(hours,usr_hour(:),1);
	b.FaceAlpha = .5;
	ylabel('Laddning per timme [kWh]')
	set(gca,'XLim',[1 24*num_days_mon]);

	xlabel('Timme i månaden')
	title(sprintf('Sammanställning för %s under %s %d (total laddning %.1f kWh)', cons.users.FirstName{u}, cf.month_l_se(cf.m,:), cf.yr, sum(cons.day_of_week(u,c_y_idx,cf.m,:,:,:),[2,3,4,5,6])));
	if printfigs
	    set(gcf,'paperunits','centimeters','papersize',papersize,'paperposition',[offs_x,offs_y,papersize(1)-offs_x,papersize(2)-offs_y])
		print([cf.fig_dir 'consumption_day_of_month_' cons.users.ID{u}],'-dpng')
		print([cf.fig_dir 'consumption_day_of_month_' cons.users.ID{u}],'-dpdf')
	end
end
