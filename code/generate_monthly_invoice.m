clear all
close all

import mlreportgen.dom.*
%import mlreportgen.report.*

run conf.m
e_y_idx = find(cf.years==cf.yr);

%invoice = false;
invoice = true;
%show_QR = true;
show_QR = false;
show_rpt = true;
%show_rpt = false;
info_str = "Kommer fakureras i januari 2023.";
%info_str = "";

ocr = cf.ocr; % starting invoice number
today = datetime('today');
%sel_usr = 1:length(cons.users.ID)
sel_usr = 5;


load([cf.tmp_data_dir cf.cons_file],'cons')
load([cf.tmp_data_dir cf.price_file],'price')

%for u = 1:length(cons.users.ID)
for u = sel_usr

	d = Document([cf.rep_dir cons.users.ID{u}], 'pdf');
	open(d);

	curLayout = d.CurrentPageLayout;

	pageSizeObj = PageSize("297mm","210mm","portrait");
	curLayout.PageSize = pageSizeObj;

	pageMarginsObj = PageMargins();
	pageMarginsObj.Top = "10mm";
	pageMarginsObj.Bottom = "0mm";
	pageMarginsObj.Left = "8mm";
	pageMarginsObj.Right = "8mm";
	pageMArginsObj.Header = "10mm";
	pageMarginsObj.Footer = "10mm";
	pageMarginsObj.Gutter = "0mm";
	curLayout.PageMargins = pageMarginsObj;

	curLayout.PageHeaders = PDFPageHeader();
	append(curLayout.PageHeaders,cf.invoicer); 
	append(curLayout.PageHeaders,cf.invoicer_street); 
	append(curLayout.PageHeaders,cf.invoicer_town); 

	if invoice
		heading = Heading(1,"Faktura")
		heading.Style = {Color('Black'),HAlign('center'),Bold(true),FontSize('16pt'),OuterMargin("0cm","0cm","10mm","0cm")};
		heading.FontFamilyName = 'Helvetica';
		append(d,heading);
		invTbl = FormalTable({'Hyrestagare',['Fakturadatum: ' datestr(today,cf.dtfmt)]}, ...
		[{[cons.users.FirstName{u} ' ' cons.users.LastName{u}]; cf.usr_addres.(cons.users.ID{u}); cons.users.Email{u}; ''},{['Förfallodatum: ' datestr(today+days(cf.paytrms),cf.dtfmt)]; ['Fakturanummer: ' num2str(ocr)]; ['Betalning till bankgiro: ' cf.bankgiro];'Ange fakturanummer vid betalning'}]);
		invTbl.TableEntriesInnerMargin = '1pt';
		invTbl.Style = {OuterMargin("0cm","0cm","7mm","7mm")};
		%invTbl.HAlign = 'center';
		invTbl.Border = 'None';
		invTbl.Header.Style = {Bold(true)};
		invTbl.OuterLeftMargin = "20mm";
		invTbl.ColSep = "Solid";
		invTbl.ColSepColor = "White";
		invTbl.ColSepWidth = "35mm";
		append(d,invTbl);
	else
		heading = Heading(1,['Månadens elförbrukning för ' cons.users.FirstName{u}]);
		heading.Style = {Color('Black'),HAlign('center'),Bold(true),FontSize('14pt'),OuterMargin("0cm","0cm","1cm","0cm")};
		heading.FontFamilyName = 'Helvetica';
		append(d,heading);
		dat = Heading(2, datestr(today,cf.dtfmt));
		dat.Style = {Color('Black'),HAlign('center'),Bold(false),FontSize('12pt')};
		dat.FontFamilyName = 'Helvetica';
		append(d,dat);
	end

	img3 = Image([cf.fig_dir 'consumption_day_of_month_' cons.users.ID{u} '.pdf']);
	para = Paragraph(img3);
	para.Style = [para.Style {OuterMargin("0cm","0cm","1cm","1cm")}];
	para.HAlign = 'center';
	append(d, para);

	tableHeaderStyles = {BackgroundColor("LightGrey"), Bold(true)}; 
	footerStyle = {BackgroundColor("LightGrey"), ...
                ColSep("none"), ...
                HAlign("right"), ...
                Bold(true), ...
                WhiteSpace("preserve")};
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
	cellTbl.Border = 'None';
	cellTbl.TableEntriesStyle = {FontSize('10pt'),HAlign('right')}; 
	cellTbl.Header.TableEntriesHAlign = "left";
	footer = cellTbl.Footer;
	footer.Style = footerStyle;
	cellTbl.Header.Style = [cellTbl.Header.Style, tableHeaderStyles];
	cellTbl.TableEntriesInnerMargin = "3pt";
	     
	grps(1) = TableColSpecGroup;
	grps(1).Span = 3;
	specs(1) = TableColSpec;
	specs(1).Style = {Bold(true),HAlign('left')};
	grps(1).ColSpecs = specs;
	cellTbl.ColSpecGroups = grps;

	append(d, cellTbl);

	if invoice
		to_pay = (1+cf.VAT)*tot_cost_ex_VAT;
		ore = round((to_pay-floor(to_pay))*100);
		qr = generate_qr_code(ocr,to_pay,cf.bankgiro);
		if show_QR
			fQR = figure();
		else
			fQR = figure('visible','off');
		end
		colormap(gray);
		imagesc(qr);
		axis image;
		axis off;
		saveas(gcf, [cf.fig_dir 'QRPlot_img.png']);
		QR_kod = Paragraph("QR kod för betalning i bankapp");
		QR_kod.Style = {HAlign('center'),Bold(true),FontSize('12pt'),OuterMargin("0cm","0cm","1cm","0cm")};
		append(d, QR_kod);
		img = Image([cf.fig_dir 'QRPlot_img.png']);
		img.Style = {Width('2.5in'),HAlign('center'),OuterMargin("0cm","0cm","0cm","0cm")};
		append(d, img);
		close(fQR)

		OCR_str = sprintf('H   # %24d%d #%8.0f %02d   %d >%25s#41#    ',ocr,modulo_checkdigit(ocr),floor(to_pay),ore,modulo_checkdigit(round(to_pay*100)),strrep(cf.bankgiro,'-',''));
		ocr = ocr + 1;
		p = Preformatted(OCR_str);
		%p.Style = {FontFamily('OCR A Extended'),FontSize('10pt')};
		%p.Style = {FontFamily('ocr-b-std'),FontSize('10pt'),OuterMargin("0cm","0cm","1cm","1cm")};
		%p.Style = {FontFamily('ocr-b-std'),WhiteSpace('nowrap'),FontSize('18pt')};
		p.Style = {FontSize('11pt'),OuterMargin("0cm","0cm",".0cm","0cm")};
		curLayout.PageFooters = PDFPageFooter();
		append(curLayout.PageFooters,p); 
	else
		info = Paragraph(info_str);
		info.Style = {HAlign('center'),Bold(true),FontSize('12pt'),OuterMargin("0cm","0cm","1cm","0cm")};
		append(d, info);
	end

	close(d);
	if show_rpt
		rptview(d);
	end

end
