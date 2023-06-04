clear all
close all

run conf.m

load([cf.tmp_data_dir cf.cons_file],'cons')

%dry_run = true
dry_run = false

setpref('Internet','E_mail', cf.sender_mail);
setpref('Internet','SMTP_Server', cf.smtp_server);
setpref('Internet','SMTP_Username', cf.smtp_user);
setpref('Internet','SMTP_Password', cf.smtp_password);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
% This is needed for TLS encryption
%props.setProperty('mail.smtp.starttls.enable','true');
%props.setProperty('mail.smtp.port', cf.smtp_port);
props.setProperty('mail.smtp.socketFactory.class', ...
    'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port',cf.smtp_port);

email_subject = sprintf(cf.email_subject,cf.inv_l_se{cf.invoice+1},cf.month_l_se(cf.m,:),cf.yr);

disp(email_subject)
disp(cf.email_body)

for u = 1:length(cons.users.ID)
	ID_lut.(cons.users.ID{u}) = u;
end

min_pause = .3;
max_pause = 1.5;

load([cf.rep_dir cf.send_list_file],'send_list')

pauses = min_pause + (max_pause-min_pause).*rand(length(send_list),1)

for user_nr = 1:length(send_list)
	disp(cons.users.Email{ID_lut.(send_list{user_nr})})
	if ~dry_run
		% Send the email with attachement
		%sendmail(cons.users.Email{ID_lut.(send_list{user_nr})},email_subject,cf.email_body,{[cf.rep_dir send_list{user_nr} '.pdf'], [cf.rep_dir 'filename.pdf']})
		% Send the email without attachement
		sendmail(cons.users.Email{ID_lut.(send_list{user_nr})},email_subject,cf.email_body,[cf.rep_dir send_list{user_nr} '.pdf'])
	end
	pause(pauses(user_nr))
end
