(load "Pantomime")

(class PantomimePOP3Client is NSObject
     (ivar (id) pop3 (id) user (BOOL) running)
     (ivar-accessors)
     
     (- (void) run is
        (set @pop3 ((CWPOP3Store alloc) initWithName:(@user server:) port:(@user port:)))
        (@pop3 setDelegate:self)
        (@pop3 connectInBackgroundAndNotify)
        (set @running YES)
        (while @running
               ((NSRunLoop currentRunLoop) runUntilDate:(NSDate dateWithTimeIntervalSinceNow:0.01))))
     
     (- (void) authenticationCompleted:(id) theNotification is
        (puts "Authentication completed! Checking for messages.")
        ((@pop3 defaultFolder) prefetch))
     
     (- (void) authenticationFailed:(id) theNotification is
        (puts "Authentication failed! Closing the connection.")
        (@pop3 close)
        (set @running NO))
     
     (- (void) connectionEstablished:(id) theNotification is
        ((@pop3 connection) startSSL))
     
     (- (void) connectionTerminated:(id) theNotification is
        (puts "Connection closed.")
        (set @running NO))
     
     (- (void) folderPrefetchCompleted:(id) theNotification is
        (set count ((@pop3 defaultFolder) count))
        (puts "There are #{count} messages on the server.")
        (if (> count 0)
            (then (puts "Prefetching and initializing.")
                  (((@pop3 defaultFolder) allMessages) each:
                   (do (message)
                       (message setInitialized:YES))))
            (else (puts "Closing the connection.")
                  (@pop3 close)
                  (set @running NO))))
     
     (- (void) messagePrefetchCompleted:(id) theNotification is
        (set message ((theNotification userInfo) Message:))
        (puts "Got the message: #{(message subject)}")
        (puts (NSString stringWithData:(message rawSource) encoding:NSUTF8StringEncoding))
        (@pop3 close))
     
     (- (void) serviceInitialized:(id) theNotification is
        ;(puts "SSL Handshake complete")
        ;(puts ((@pop3 supportedMechanisms) description))
        (@pop3 authenticate:(@user username:) password:(@user password:) mechanism:"none")))

(set user (dict username:(((NSProcessInfo processInfo) environment) objectForKey:"BOT_MAIL_USERNAME")
                password:(((NSProcessInfo processInfo) environment) objectForKey:"BOT_MAIL_PASSWORD")
                server:"pop.gmail.com"
                port:995))

(set client (PantomimePOP3Client new))
(client setUser:user)
(client run)
(puts "done")

