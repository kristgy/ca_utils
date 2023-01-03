clear all
close all

run conf.m

invoice = false;
%invoice = true;
%info_str = "Kommer fakureras med SBC avin i januari 2023.";
info_str = "Kommer fakureras i januari 2023.";

import mlreportgen.dom.*
import mlreportgen.report.*

load([cf.tmp_data_dir cf.cons_file],'cons')
load([cf.tmp_data_dir cf.price_file],'price')

for u = 1:length(cons.users.ID)

	rpt = Report([cf.rep_dir cons.users.ID{u}], 'pdf');

	pageSizeObj = PageSize("11.69in","8.27in","portrait");
	rpt.Layout.PageSize = pageSizeObj;

	pageMarginsObj = PageMargins();
	%pageMarginsObj.Top = "0.98in";
	pageMarginsObj.Top = "0.5in";
	%pageMarginsObj.Bottom = "0.98in";
	pageMarginsObj.Bottom = "0in";
	%pageMarginsObj.Left = "0.98in";
	pageMarginsObj.Left = "0.3in";
	%pageMarginsObj.Right = "0.98in";
	pageMarginsObj.Right = "0.3in";
	%pageMArginsObj.Header = "0.5in";
	pageMArginsObj.Header = "0in";
	%pageMarginsObj.Footer = "0.5in";
	pageMarginsObj.Footer = "0in";
	pageMarginsObj.Gutter = "0in";
	rpt.Layout.PageMargins = pageMarginsObj;

	tp = TitlePage; 
	tp.Title = ['Månadens elförbrukning för ' cons.users.FirstName{u}]; 
	%tp.Subtitle = 'Columns, Rows, Diagonals: All Equal Sums'; 
	tp.Author = 'Brf. Bergshamra Gård'; 
	append(rpt,tp); 

	imgStyle = {ScaleToFit(true)};

	%img3 = Image([fc.fig_dir 'consumption_day_of_month_' cons.users.ID{u} '.png']);
	img3 = Image([cf.fig_dir 'consumption_day_of_month_' cons.users.ID{u} '.pdf']);
	%img3.Style = imgStyle;
	para = Paragraph(img3);
	para.Style = [para.Style {OuterMargin("0cm","0cm","1cm","1cm")}];
	para.HAlign = 'center';
	add(rpt, para);

%	Code for more figures in a table format
%	%img1 = Image(which('figures/consumption_hour_histogram.png'));
%	img1 = Image([cf.fig_dir 'monthly_IMD_cost_' cons.users.ID{u} '.png']);
%	img1.Style = imgStyle;
%	%img2 = Image([cf.fig_dir 'consumption_hour_histogram.png']);
%	img2 = Image([cf.fig_dir 'consumption_hour_month_' cons.users.ID{u} '.png']);
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
	if cf.hourly_prices
		spec = {"Elhandel";"Elöverföring "; "Energiskatt"; "Påslag"; "Moms"; "Summa"}
	else
		spec = {"Elhandel";"Elöverföring "; "Energiskatt"; "Moms"; "Summa"}
	end

	[cons_mon, eng_cost]  = cost_eng_usr_monthly(u,cf.yr,cons,cf)
	[cons_day_mon, eng_cost_mon, markup]  = cost_eng_usr_hourly(u,cf.yr,cons,price,cf);
	if ~cf.hourly_prices
		eng_cost_mon = eng_cost;
	end
	[cons_day_week, trans_cost_mon, eng_tax]  = cost_transport_usr(u,cf.yr,cons,cf);
	dtv = [cf.yr cf.m 1 0 0 0];
	dte = [cf.yr cf.m+1 0 0 0 0];
	per = compose('%s - %s',datestr(dtv,cf.dtfmt),datestr(dte,cf.dtfmt));
	if cf.hourly_prices
		tot_cost_ex_VAT = (eng_cost_mon(cf.m)+eng_tax(cf.m)+markup(cf.m)+trans_cost_mon(cf.m))/100;
		period = {per{1}; per{1}; per{1}; per{1}; ""; per{1}}
		kvant = {sprintf('%1.1f kWh',cons_mon(cf.m)); sprintf('%1.1f kWh',cons_mon(cf.m)); sprintf('%1.1f kWh',cons_mon(cf.m)); sprintf('%1.1f kWh',cons_mon(cf.m)); ""; ""};
		pris = {sprintf('%1.2f öre/kWh',eng_cost_mon(cf.m)/cons_mon(cf.m)); sprintf('%1.2f öre/kWh',trans_cost_mon(cf.m)/cons_mon(cf.m)); sprintf('%1.2f öre/kWh',cf.eng_tax(e_y_idx,cf.m)); sprintf('%1.2f öre/kWh',cf.markup); sprintf('%1.1f%%',cf.VAT*100); ""};
		summa = {sprintf('%1.2f kr',eng_cost_mon(cf.m)/100); sprintf('%1.2f kr',trans_cost_mon(cf.m)/100); sprintf('%1.2f kr',eng_tax(cf.m)/100); sprintf('%1.2f kr',markup(cf.m)/100); sprintf('%1.2f kr',cf.VAT*tot_cost_ex_VAT); sprintf('%1.2f kr',(1+cf.VAT)*tot_cost_ex_VAT)};
	else
		tot_cost_ex_VAT = (eng_cost_mon(cf.m)+eng_tax(cf.m)+trans_cost_mon(cf.m))/100;
		period = {per{1}; per{1}; per{1}; ""; per{1}}
		kvant = {sprintf('%1.1f kWh',cons_mon(cf.m)); sprintf('%1.1f kWh',cons_mon(cf.m)); sprintf('%1.1f kWh',cons_mon(cf.m)); ""; ""};
		pris = {sprintf('%1.2f öre/kWh',eng_cost_mon(cf.m)/cons_mon(cf.m)); sprintf('%1.2f öre/kWh',trans_cost_mon(cf.m)/cons_mon(cf.m)); sprintf('%1.2f öre/kWh',cf.eng_tax(e_y_idx,cf.m)); sprintf('%1.1f%%',cf.VAT*100); ""};
		summa = {sprintf('%1.2f kr',eng_cost_mon(cf.m)/100); sprintf('%1.2f kr',trans_cost_mon(cf.m)/100); sprintf('%1.2f kr',eng_tax(cf.m)/100); sprintf('%1.2f kr',cf.VAT*tot_cost_ex_VAT); sprintf('%1.2f kr',(1+cf.VAT)*tot_cost_ex_VAT)};
	end
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
	grps(1).Span = 3;
	specs(1) = TableColSpec;
	specs(1).Style = {Bold(true),HAlign('left')};
	grps(1).ColSpecs = specs;
	cellTbl.ColSpecGroups = grps;

	add(rpt, cellTbl);

	if invoice
		to_pay = (1+cf.VAT)*tot_cost_ex_VAT;
		ore = round((to_pay-floor(to_pay))*100);
		qr = generate_qr_code(cf.ocr,to_pay,cf.bankgiro);
		fQR = figure();
		colormap(gray);
		imagesc(qr);
		axis image;
		axis off;
		QR_kod = Paragraph("QR kod för betalning i app");
		QR_kod.Style = {HAlign('center'),Bold(true),FontSize('12pt'),OuterMargin("0cm","0cm","1cm","0cm")};
		add(rpt, QR_kod);
		fig = mlreportgen.report.Figure('SnapshotFormat','pdf');
		img = Image(getSnapshotImage(fig,rpt));
		img.Style = {Width('2.5in'),HAlign('center'),OuterMargin("0cm","0cm","0cm","0cm")};
		add(rpt, img);
		close(fQR)

		OCR = Paragraph('OCR');
		OCR.Style = {Bold(true),FontSize('16pt'),OuterMargin("0cm","0cm",".7cm","0cm")};
		add(rpt, OCR);

		OCR_str = sprintf('H   # %24d%d #%8.0f %02d   %d >%25s#41#    ',cf.ocr,modulo_checkdigit(cf.ocr),floor(to_pay),ore,modulo_checkdigit(round(to_pay*100)),strrep(cf.bankgiro,'-',''));
		cf.ocr = cf.ocr + 1;
		p = Preformatted(OCR_str);
		%p.Style = {FontFamily('OCR A Extended'),FontSize('10pt')};
		%p.Style = {FontFamily('ocr-b-std'),FontSize('10pt'),OuterMargin("0cm","0cm","1cm","1cm")};
		%p.Style = {FontFamily('ocr-b-std'),WhiteSpace('nowrap'),FontSize('18pt')};
		p.Style = {FontSize('11pt'),OuterMargin("0cm","0cm",".4cm","0cm")};
		%p.HAlign = 'center';
		add(rpt, p);
	else
		info = Paragraph(info_str);
		info.Style = {HAlign('center'),Bold(true),FontSize('12pt'),OuterMargin("0cm","0cm","1cm","0cm")};
		add(rpt, info);
	end

	close(rpt);
	%rptview(rpt);

end
