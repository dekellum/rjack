/*
 * Copyright (c) 2011 David Kellum
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you
 * may not use this file except in compliance with the License.  You may
 * obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
 * implied.  See the License for the specific language governing
 * permissions and limitations under the License.
 */

package rjack.jms;

import javax.jms.Connection;
import javax.jms.Destination;
import javax.jms.JMSException;
import javax.jms.Session;
import javax.naming.NamingException;

/**
 * A simple JMS setup facade which can hide such details as the JMS
 * Connection Factory, JNDI setup, context, and lookup, and session
 * creation options.
 */
public interface JMSContext
{
    /**
     * Create a new connection. The caller should close this
     * connection when done.
     */
    Connection createConnection() throws JMSException;

    /**
     * Create a Session from the specified connection previously
     * obtained via createConnection().
     */
    Session createSession( Connection connection ) throws JMSException;

    /**
     * Lookup or create a Destination by name.
     */
    Destination lookupDestination( String name ) throws NamingException;

    /**
     * Close any resources, such any JNDI context, created as part of
     * using this interface. This is independent of closing a created
     * connection and can be done after the last use of this
     * interface.
     */
    void close();
}
