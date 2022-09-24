clear all
close all

run conf.m

import mlreportgen.dom.*
import mlreportgen.report.*

load([tmp_data_dir cons_file])
load([tmp_data_dir price_file])

sel_usr = [6 7 8];
%sel_usr = 2:11;

for u = 1:length(users)
%for u = sel_usr

	rpt = Report([rep_dir users{u}], 'pdf');

	tp = TitlePage; 
	tp.Title = ['M�nadens elf�rbrukning f�r ' users{u}]; 
	%tp.Subtitle = 'Columns, Rows, Diagonals: All Equal Sums'; 
	tp.Author = 'Brf. Bergshamra G�rd'; 
	append(rpt,tp); 

	imgStyle = {ScaleToFit(true)};

	%img3 = Image([fig_dir 'consumption_day_of_month_' users{u} '.png']);
	img3 = Image([fig_dir 'consumption_day_of_month_' users{u} '.pdf']);
	%img3.Style = imgStyle;
	para = Paragraph(img3);
	para.Style = [para.Style {OuterMargin("0cm","0cm","1cm","1cm")}];
	para.HAlign = 'center';
	add(rpt, para);

%	Code for more figures in a table format
%	%img1 = Image(which('figures/consumption_hour_histogram.png'));
%	img1 = Image([fig_dir 'monthly_IMD_cost_' users{u} '.png']);
%	img1.Style = imgStyle;
%	%img2 = Image([fig_dir 'consumption_hour_histogram.png']);
%	img2 = Image([fig_dir 'consumption_hour_month_' users{u} '.png']);
%	img2.Style = imgStyle;
%
%	lot = Table({img1, ' ', img2});
%	lot.entry(1,1).Style = {Width('3.2in'), Height('3in')};
%	lot.entry(1,2).Style = {Width('.2in'), Height('3in')};
%	lot.entry(1,3).Style = {Width('3.2in'), Height('3in')};
%	lot.Style = {ResizeToFitContents(false), Width('100%')};
%	add(rpt, lot);

	tableHeaderStyles = {BackgroundColor("LightGrey"), Bold(true)}; 
	footerStyle = { BackgroundColor("LightGrey"), ...
                ColSep("none"), ...
                HAlign("right"), ...
                Bold(true), ...
                WhiteSpace("preserve") };
	headerLabels = ["Specificering", "Period", "Kvantitet", "Pris", "Summa"];
	spec = {"Elhandel";"El�verf�ring "; "Energiskatt"; "P�slag"; "Moms"; "Summa"}

	y = length(cons_years);
	m = datetime('today').Month - 1;
	cons_mon = squeeze(sum(cons_full(u,:,:,:,:,:),[4 5 6],'omitnan'));
	eng_cost_mon = squeeze(sum(squeeze(sum(cons_full(u,:,:,:,:,:),6,'omitnan')).*pr_full,[3 4],'omitnan'));
	usr_cost_trans = squeeze(sum(cons_acc(u,:,:,:,:,:),6,'omitnan')).*transf_price;
	trans_cost_mon = squeeze(sum(usr_cost_trans,[3 4],'omitnan'));
	%tot_cost_ex_VAT = (eng_cost_mon+(eng_tax+markup)*cons_mon(y,m))/100;
	tot_cost_ex_VAT = (eng_cost_mon(y,m)+(eng_tax(y,m)+markup)*cons_mon(y,m)+trans_cost_mon(y,m))/100;
	% FIXME this fails for January
	dtv = [cons_years(y) m 1 0 0 0];
	dte = [cons_years(y) m+1 0 0 0 0];
	per = compose('%s - %s',datestr(dtv,dtfmt),datestr(dte,dtfmt));
	period = {per{1}; per{1}; per{1}; per{1}; ""; per{1}}
	kvant = {sprintf('%1.1f kWh',cons_mon(y,m)); sprintf('%1.1f kWh',cons_mon(y,m)); sprintf('%1.1f kWh',cons_mon(y,m)); sprintf('%1.1f kWh',cons_mon(y,m)); ""; ""};
	pris = {sprintf('%1.2f �re/kWh',eng_cost_mon(y,m)/cons_mon(y,m)); sprintf('%1.2f �re/kWh',trans_cost_mon(y,m)/cons_mon(y,m)); sprintf('%1.2f �re/kWh',eng_tax(y,m)); sprintf('%1.2f �re/kWh',markup); ""; ""};
	summa = {sprintf('%1.2f kr',eng_cost_mon(y,m)/100); sprintf('%1.2f kr',trans_cost_mon(y,m)/100); sprintf('%1.2f kr',eng_tax(y,m)*cons_mon(y,m)/100); sprintf('%1.2f kr',markup*cons_mon(y,m)/100); sprintf('%1.2f kr',VAT*tot_cost_ex_VAT); sprintf('%1.2f kr',(1+VAT)*tot_cost_ex_VAT)};
	tableData = [spec(1:end-1), period(1:end-1), kvant(1:end-1), pris(1:end-1), summa(1:end-1)]
	totalen = [' ', ' ', ' ', spec(end), summa(end)];

	cellTbl = FormalTable(headerLabels,tableData,totalen);
	cellTbl.HAlign = 'center';
	cellTbl.TableEntriesStyle = {HAlign('right')}; 
	cellTbl.Header.TableEntriesHAlign = "left";
	footer = cellTbl.Footer;
	footer.Style = footerStyle;
	%table.Header.Style = headerStyle;
	%cellTbl.Style = [cellTbl.Style, tableStyles];
	cellTbl.Header.Style = [cellTbl.Header.Style, tableHeaderStyles];
	cellTbl.TableEntriesInnerMargin = "2pt";

	     
	grps(1) = TableColSpecGroup;
	%grps(1).Style = {Color('red')};
	grps(1).Span = 3;
	specs(1) = TableColSpec;
	%specs(1).Style = {Color('green'),HAlign('left')};
	specs(1).Style = {Bold(true),HAlign('left')};
	grps(1).ColSpecs = specs;
	%table = Table(magic(5));
	%table.ColSpecGroups = grps;
	cellTbl.ColSpecGroups = grps;

	add(rpt, cellTbl);

	close(rpt);
	%rptview(rpt);

end
