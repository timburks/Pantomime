(load "Pantomime")

(class PantomimeSMTPClient is NSObject
     (ivar (id) smtp (id) user (BOOL) running)
     (ivar-accessors)
     
     (- (void) sendMessage:(id) message is
        (set cwmessage ((CWMessage alloc) init))
        (cwmessage setSubject:(message subject:))
        (cwmessage setFrom:((CWInternetAddress alloc) initWithString:(@user username:)))
        ((message recipients:) each:
         (do (recipient)
             (set address ((CWInternetAddress alloc) initWithString:recipient))
             (address setType:1)
             (cwmessage addRecipient:address)))
        (cwmessage setContentType:"text/plain")
        (cwmessage setContent:((message text:) dataUsingEncoding:NSUTF8StringEncoding))
        (set @smtp ((CWSMTP alloc) initWithName:(@user server:) port:(@user port:)))
        (@smtp setDelegate:self)
        (@smtp setMessage:cwmessage)
        (set @running YES)
        (@smtp connectInBackgroundAndNotify))
     
     (- (void) authenticationCompleted:(id) notification is
        (@smtp sendMessage))
     
     (- (void) authenticationFailed:(id) notification is
        (puts "authentication failed")
        (@smtp close))
     
     (- (void) connectionEstablished:(id) notification is
        ((@smtp connection) startSSL))
     
     (- (void) connectionTerminated:(id) notification is
        (set @running NO))
     
     (- (void) messageSent:(id) notificaiton is
        (puts "message sent")
        (set @running NO))
     
     (- (void) serviceInitialized:(id) notification is
        ;(puts ((@smtp supportedMechanisms) description))
        (@smtp authenticate:(@user username:) password:(@user password:) mechanism:"LOGIN"))
     
     (- (void) synchronouslySendMessage:(id) message  is
        (self sendMessage:message)
        (while @running
               ((NSRunLoop currentRunLoop) runUntilDate:(NSDate dateWithTimeIntervalSinceNow:0.01)))))


(set user (dict username:(((NSProcessInfo processInfo) environment) objectForKey:"BOT_MAIL_USERNAME")
                password:(((NSProcessInfo processInfo) environment) objectForKey:"BOT_MAIL_PASSWORD")
                server:"smtp.gmail.com"
                port:465))

(set client (PantomimeSMTPClient new))
(client setUser:user)
(10 times:
    (do (i)
        (puts i)
        (set message (dict recipients:(array (user username:))
                           subject:"Test Message #{i}"
                           text:"Hello #{i}"))
        (client synchronouslySendMessage:message)))
(puts "done")
