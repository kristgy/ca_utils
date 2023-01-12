clear all
close all

run conf.m

%run process_cons_data.m              
%run process_price_data.m             

run plots_montly_invoice.m
% NB! Remember to update starting invoice (OCR) number before generating invoices.
run generate_monthly_invoice.m

% NB! Remember to updated the cf.send_list, cf.email_subject and cf.email_body 
% config variables before sending invoices.
%send_cons_report.m
