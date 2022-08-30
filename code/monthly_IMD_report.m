clear all
close all

run conf.m

load([tmp_data_dir cons_file])
load([tmp_data_dir price_file])

sel_usr = [6 7 8];

for u = sel_usr
	eng_cost_mon = squeeze(sum(squeeze(sum(cons_full(u,:,:,:,:,:),6,'omitnan')).*[pr_full+markup],[3 4],'omitnan'));
	eng_tax_mon = squeeze(sum(cons_full(u,:,:,:,:,:),[4 5 6],'omitnan')).*eng_tax;
	usr_cost_trans = squeeze(sum(cons_acc(u,:,:,:,:,:),6,'omitnan')).*transf_price;
	figure()
%	plot(1:12,squeeze(sum(usr_cost,[3 4],'omitnan'))'/100)
	plot(1:12,(1+VAT)*(eng_cost_mon+eng_tax_mon)'/100)
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
