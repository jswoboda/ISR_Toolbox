function setUpMail(myaddress,mypassword)

setpref('Internet','E_mail',myaddress);
setpref('Internet','SMTP_Server','smtp.gmail.com');
setpref('Internet','SMTP_Username',myaddress);
setpref('Internet','SMTP_Password',mypassword);

props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', ...
                  'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');


usr_resp = input('Do you want to send a test mail?  y/n: ','s');

if strcmpi(usr_resp,'y')
    
    sendmail(myaddress, 'Gmail Test', 'This is a test message.')
end
    
