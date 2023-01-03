clear all
close all

run conf.m

load([cf.tmp_data_dir cf.cons_file],'cons')

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

for u = 1:length(cons.users.ID)
	ID_lut.(cons.users.ID{u}) = u
end

min_pause = .3;
max_pause = 1.5;

pauses = min_pause + (max_pause-min_pause).*rand(length(cf.send_list),1)

for user_nr = 1:length(cf.send_list)
	disp(cons.users.Email{ID_lut.(cf.send_list{user_nr})})
	% Send the email
	sendmail(cons.users.Email{ID_lut.(cf.send_list{user_nr})},'Månadens elförbrukning','Elförbrukning för laddning.',[cf.rep_dir cf.send_list{user_nr} '.pdf'])
	%sendmail(cons.users.Email{ID_lut.(cf.send_list{user_nr})},'Testutskick: Månadens elförbrukning','Testutskick: Elförbrukning för laddning.',[cf.rep_dir cf.send_list{user_nr} '.pdf'])
	pause(pauses(user_nr))
end
