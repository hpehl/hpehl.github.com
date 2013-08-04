---
layout: post
title: "Send Mails from OpenShift"
date: 2013-08-04 19:42
comments: true
categories: jboss openshift mail
---
OpenShift is a great place to host your applications. In this post I'm going to show you how you can easily send mails
from your JEE applications running on JBoss. For sending mails I'm going to configure an external SMTP server. Any SMTP 
server will do, I'm going to use GMail.<!-- more --> 

In case you don't already have an application ready, create one selecting the JBoss AS 7 cartridge. Clone the git 
repository and open the JBoss standalone configuration: `.openshift/config/standalone.xml`. Look for the mail subsystem 
which should look like this:

```xml
<subsystem xmlns="urn:jboss:domain:mail:1.0">
    <mail-session jndi-name="java:jboss/mail/Default">
        <smtp-server outbound-socket-binding-ref="mail-smtp"/>
    </mail-session>
</subsystem>
```

We're going to add another mail session / smtp server using GMail:

```xml
<subsystem xmlns="urn:jboss:domain:mail:1.0">
    ...
    <mail-session jndi-name="java:/mail/Gmail" from="your.name@gmail.com">
        <smtp-server ssl="true" outbound-socket-binding-ref="gmail-smtp">
            <login name="your.name@gmail.com" password="..."/>
        </smtp-server>
    </mail-session>
</subsystem>
```

Enter your credentials for the SMTP server you want to use. In case you have activated application specific passwords 
in your Google profile, the password is not your Google password, but an application specific one you have to create 
first.

As you can see we're referencing a named socket binding, which we're going to create now. Towards the end of the 
standalone configuration you can see all configured socket bindings:

```xml
<socket-binding-group name="standard-sockets" default-interface="public" port-offset="0">
    <socket-binding name="http" port="8080"/>
    <socket-binding name="jacorb" interface="unsecure" port="3528"/>
    <socket-binding name="jacorb-ssl" interface="unsecure" port="3529"/>
    <socket-binding name="jgroups-tcp" port="7600"/>
    <socket-binding name="management-native" interface="management" port="9999"/>
    <socket-binding name="management-http" interface="management" port="9990"/>
    <socket-binding name="messaging" port="5445"/>
    <socket-binding name="messaging-throughput" port="5455"/>
    <socket-binding name="osgi-http" interface="management" port="8090"/>
    <socket-binding name="remoting" port="4447"/>
    <socket-binding name="txn-recovery-environment" port="4712"/>
    <socket-binding name="txn-status-manager" port="4713"/>
    <outbound-socket-binding name="mail-smtp">
        <remote-destination host="localhost" port="25"/>
    </outbound-socket-binding>
</socket-binding-group>
```

Add an outbound socket binding for you SMTP server: 

```xml
<socket-binding-group name="standard-sockets" default-interface="public" port-offset="0">
    ...
    <outbound-socket-binding name="gmail-smtp" source-port="0" fixed-source-port="false">
        <remote-destination host="smtp.gmail.com" port="465"/>
    </outbound-socket-binding>
</socket-binding-group>
```

We're almost done! Now you can use the mail session in your application. In my case I'm using the mail session from an 
[Errai](http://www.jboss.org/errai) service, but any other server side class (REST endpoint, servlet, EJB, POJO) should 
work also:

```java
import static javax.mail.Message.RecipientType.TO;

import java.util.Date;

import javax.annotation.Resource;
import javax.mail.Address;
import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

import com.google.common.base.Optional;

import org.jboss.errai.bus.client.api.messaging.Message;
import org.jboss.errai.bus.client.api.messaging.MessageCallback;
import org.jboss.errai.bus.server.annotations.Service;
import org.jboss.errai.common.client.protocols.MessageParts;

@Service
public class FeedbackService implements MessageCallback {

    @Resource(mappedName = "java:/mail/Gmail") private Session mailSession;

    @Override
    public void callback(Message message) {
    
        // get data out of the message and persist feedback 
        String guest = Optional.fromNullable(message.get(String.class, "guest")).or("n/a");
        boolean commitment = Optional.fromNullable(message.get(Boolean.class, "commitment")).or(false);
        saveFeedback(guest, commitment);
        
        // send response using the Errai message bus
        // see http://docs.jboss.org/errai/2.4.0.Beta1/errai/reference/html_single/#sid-5931263 
        // for more details
        createConversation(message)
                .subjectProvided()
                .done()
                .reply();

        // sending the mail might take a moment, so this is done *after* sending the response to the client.
        sendMail(guest, commitment);
    }

    private void saveFeedback(final String guest, final boolean commitment) {
        ...
    }

    private void sendMail(final String guest, final boolean commitment) {
        try {
            MimeMessage message = new MimeMessage(mailSession);
            Address[] to = new InternetAddress[]{new InternetAddress("your.name@gmail.com")};
            message.setRecipients(TO, to);
            message.setSubject("Your subject");
            message.setContent("Your message", "text/plain");
            Transport.send(message);
        } catch (MessagingException e) {
            // error handling
        }
    }
}
```

That's all - any feedback, thoughts and objections are welcome.