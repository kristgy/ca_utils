clear all
close all

run conf.m

%plot_data = false;
plot_data = true;
pad_len = 19;
dcom = @(fmt,num) strrep(sprintf(fmt,num),'.',',');

load([tmp_data_dir cons_file])
load([tmp_data_dir price_file])

%sel_usr = [5 6 7 8];
sel_usr = [6 7 8];
%sel_usr = 2:11;

fid = fopen([tmp_data_dir 'IMD.csv'],'w');

for u = sel_usr
	cons_mon = squeeze(sum(cons_full(u,:,:,:,:,:),[4 5 6],'omitnan'));
	eng_cost_mon = squeeze(sum(squeeze(sum(cons_full(u,:,:,:,:,:),6,'omitnan')).*[pr_full+markup],[3 4],'omitnan'));
	eng_tax_mon = cons_mon.*eng_tax;
	usr_cost_trans = squeeze(sum(cons_acc(u,:,:,:,:,:),6,'omitnan')).*transf_price;
	tot_cost = (1+VAT)*(eng_cost_mon+eng_tax_mon)/100;
	if plot_data
		figure()
		%plot(1:12,(1+VAT)*(eng_cost_mon+eng_tax_mon)'/100)
		plot(1:12,tot_cost')
		leg_str_1 = compose('%d elh. (in skatt, ex elcert)',price_years);
		hold on
		set(gca,'ColorOrderIndex',1)
		plot(1:12,(1+VAT)*squeeze(sum(usr_cost_trans,[3 4],'omitnan'))'/100,'--')
		leg_str_2 = compose('%d elöverföring',price_years);
		legend({leg_str_1{:}, leg_str_2{:}},'Location','best')
		title(compose('IMD kostnad per månad för %s',users{u}))
		xlabel('Månad')
		ylabel('Kostnad (inkl moms) [kr/mån]')
		print('-dpng',[fig_dir 'monthly_IMD_cost_' users{u}])
	end
	for y = 1:3
		for m = 1:12
			dtv = [cons_years(y) m 1 0 0 0];
			dte = [cons_years(y) m+1 0 0 0 0];
			imd_line = compose('%s%s%sELM kWh %s%s0%s%07d,%s%s0',datestr(now,dtfmt),pad(users{u},pad_len),pad(users{u},pad_len),...
				datestr(dtv,dtfmt),datestr(dte,dtfmt),dcom('%013.2f',cons_mon(y,m)),3,dcom('%020.2f',tot_cost(y,m)),dcom('%013.2f',cons_mon(y,m)))
			fprintf(fid,'%s\n',imd_line{1});
		end
	end
end
fclose(fid);
