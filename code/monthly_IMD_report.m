clear all
close all

run conf.m

plot_data = false;
%plot_data = true;
pad_len = 19;
%dcom = @(fmt,num) strrep(sprintf(fmt,num),'.',',');

load([cf.tmp_data_dir cf.cons_file],'cons')
load([cf.tmp_data_dir cf.price_file],'price')

Objectnr = {};
Start = {};
EnEnd = {};

%sel_usr = [5 6 7 8];
sel_usr = [3 4 6];
%sel_usr = 2:11;
sel_y = 3;
sel_m = 9;

fid = fopen([cf.tmp_data_dir 'IMD.csv'],'w');

r = 1;
for u = sel_usr
%for u = 1:length(cons.users.Email)
	cons_mon = squeeze(sum(cons.day_of_month(u,:,:,:,:,:),[4 5 6],'omitnan'));
	% FIXME This fails if cons and price don't have the same size
	eng_cost_mon = squeeze(sum(squeeze(sum(cons.day_of_month(u,:,:,:,:,:),6,'omitnan')).*[price.day_of_month+cf.markup],[3 4],'omitnan'));
	eng_tax_mon = cons_mon.*cf.eng_tax;
	usr_cost_trans = squeeze(sum(cons.day_of_week(u,:,:,:,:,:),6,'omitnan')).*cf.transf_price;
	tot_cost = (1+cf.VAT)*(eng_cost_mon+eng_tax_mon)/100;
	if plot_data
		figure()
		%plot(1:12,(1+cf.VAT)*(eng_cost_mon+eng_tax_mon)'/100)
		plot(1:12,tot_cost')
		leg_str_1 = compose('%d elh. (in skatt, ex elcert)',price.years);
		hold on
		set(gca,'ColorOrderIndex',1)
		plot(1:12,(1+cf.VAT)*squeeze(sum(usr_cost_trans,[3 4],'omitnan'))'/100,'--')
		leg_str_2 = compose('%d elöverföring',price.years);
		legend({leg_str_1{:}, leg_str_2{:}},'Location','best')
		title(compose('IMD kostnad per månad för %s',cons.users.FirstName{u}))
		xlabel('Månad')
		ylabel('Kostnad (inkl moms) [kr/mån]')
		print('-dpng',[cf.fig_dir 'monthly_IMD_cost_' cons.users.FirstName{u}])
	end
	%for y = 1:3
	for y = sel_y
		%for m = 1:12
		for m = sel_m
			dtv = [cons.years(y) m 1 0 0 0];
			dte = [cons.years(y) m+1 0 0 0 0];
			imd_line = compose('%s%s%sELM kWh %s%s0%s%07d,%s%s0',datestr(now,cf.dtfmt),pad(cons.users.FirstName{u},pad_len),pad(cons.users.FirstName{u},pad_len),...
				datestr(dtv,cf.dtfmt),datestr(dte,cf.dtfmt),cf.dcom('%013.2f',cons_mon(y,m)),3,cf.dcom('%020.2f',tot_cost(y,m)),cf.dcom('%013.2f',cons_mon(y,m)))
			fprintf(fid,'%s\n',imd_line{1});
			Objectnr{r} = cons.users.ChargerName{u};
			Start{r} = datetime(dtv,'Format','yyyy-MM-dd');
			End{r} = datetime(dte,'Format','yyyy-MM-dd');
			Cat{r} = 'El';
			Cost{r} = round(tot_cost(y,m));
			Text{r} = 'El till laddning enligt utskick';
			r = r + 1;
		end
	end
end
fclose(fid);
varNames = {'Objektsnr','Från och med','Till och med','Vad ska debiteras?','Belop exkl moms (kr)','Avitext (om annan än Vad ska debiteras?)'}; 
imd_tab = table(Objectnr',Start',End',Cat',Cost',Text','VariableNames',varNames)
writetable(imd_tab,[cf.tmp_data_dir 'IMD.xlsx']);
