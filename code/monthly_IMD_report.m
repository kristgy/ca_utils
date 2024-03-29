clear all
close all

run conf.m

plot_data = false;
%plot_data = true;

invoice_year = 2023;
invoice_month = 1;

%sel_usr = [5 6 7 8];
%sel_usr = [3 4 6];
%sel_usr = 2:11;
sel_y = 3;
year = 2022;
sel_m = 10;
%sel_m = [7 8 9];

pad_len = 19;

load([cf.tmp_data_dir cf.cons_file],'cons')
load([cf.tmp_data_dir cf.price_file],'price')

Objectnr = {};
Start = {};
End = {};

invoice_date_start = [invoice_year invoice_month 1 0 0 0];
invoice_date_end = [invoice_year invoice_month+1 0 0 0 0];

fid = fopen([cf.rep_dir 'IMD.csv'],'w');

r = 1;
%for u = sel_usr
for u = 1:length(cons.users.Email)
	% new calculation code
	[cons_day_mon, energy, markup]  = cost_eng_usr_hourly(u,year,cons,price,cf);
	%[cons_mon, energy]  = cost_eng_usr_monthly(u,year,cons,cf)
	cons_mon = squeeze(sum(cons.day_of_month(u,:,:,:,:,:),[4 5 6],'omitnan'));
	% FIXME This fails if cons and price don't have the same size
	%eng_cost_mon = squeeze(sum(squeeze(sum(cons.day_of_month(u,:,:,:,:,:),6,'omitnan')).*[price.day_of_month+cf.markup],[3 4],'omitnan'));
	eng_cost_mon = squeeze(sum(squeeze(sum(cons.day_of_month(u,:,:,:,:,:),6,'omitnan')).*price.day_of_month,[3 4],'omitnan'));
	%eng_tax_mon = cons_mon.*cf.eng_tax;
	usr_cost_trans = squeeze(sum(cons.day_of_week(u,:,:,:,:,:),6,'omitnan')).*cf.transf_price;
	trans_cost_mon = squeeze(sum(usr_cost_trans,[3 4],'omitnan'));
	% new calculation code
	%[cons_day_week, transport, engtax]  = cost_transport_usr(u,year,cons,cf);
	%tot_cost = (1+cf.VAT)*(eng_cost_mon+eng_tax_mon)/100;
	tot_cost_ex_VAT = (eng_cost_mon+(cf.eng_tax+cf.markup).*cons_mon+trans_cost_mon)/100;
	if plot_data
		figure()
		%plot(1:12,(1+cf.VAT)*(eng_cost_mon+eng_tax_mon)'/100)
		plot(1:12,tot_cost_ex_VAT')
		leg_str_1 = compose('%d elh. (ex moms, ex elcert)',price.years);
		hold on
		set(gca,'ColorOrderIndex',1)
		plot(1:12,(1+cf.VAT)*squeeze(sum(usr_cost_trans,[3 4],'omitnan'))'/100,'--')
		leg_str_2 = compose('%d el�verf�ring',price.years);
		legend({leg_str_1{:}, leg_str_2{:}},'Location','best')
		title(compose('IMD kostnad per m�nad f�r %s',cons.users.FirstName{u}))
		xlabel('M�nad')
		ylabel('Kostnad (inkl moms) [kr/m�n]')
		print('-dpng',[cf.fig_dir 'monthly_IMD_cost_' cons.users.FirstName{u}])
	end
	for y = sel_y
		for m = sel_m
			if tot_cost_ex_VAT(y,m) > 0
				dtv = [cons.years(y) m 1 0 0 0];
				dte = [cons.years(y) m+1 0 0 0 0];

				imd_line = compose('%s%s%sELM kWh %s%s0%s%07d,%s%s0',datestr(now,cf.dtfmt),pad(cons.users.FirstName{u},pad_len),pad(cons.users.FirstName{u},pad_len),...
					datestr(dtv,cf.dtfmt),datestr(dte,cf.dtfmt),cf.dcom('%013.2f',cons_mon(y,m)),3,cf.dcom('%020.2f',tot_cost_ex_VAT(y,m)),cf.dcom('%013.2f',cons_mon(y,m)))
				fprintf(fid,'%s\n',imd_line{1});

				Objectnr{r} = [cf.SBC_kundnr '-' sprintf('%05d',cf.SBC_objektnr.(cons.users.ID{u}))];
				Start{r} = datetime(invoice_date_start,'Format','yyyy-MM-dd');
				End{r} = datetime(invoice_date_end,'Format','yyyy-MM-dd');
				Cat{r} = 'El';
				Cost{r} = round(tot_cost_ex_VAT(y,m));
				Text{r} = [cf.dcom('%.1f',cons_mon(y,m)) ' kWh el ' datestr(dtv,'yymmdd') '-' datestr(dte,'yymmdd')];
				r = r + 1;
			end
		end
	end
end
fclose(fid);
varNames = {'Objektsnr','Fr�n och med','Till och med','Vad ska debiteras?','Belop exkl moms (kr)','Avitext (om annan �n Vad ska debiteras?)'}; 
imd_tab = table(Objectnr',Start',End',Cat',Cost',Text','VariableNames',varNames)
writetable(imd_tab,[cf.rep_dir 'IMD.xlsx'],'WriteMode','replacefile');
