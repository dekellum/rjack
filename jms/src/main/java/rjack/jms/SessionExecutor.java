/*
 * Copyright (c) 2011-2013 David Kellum
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

import java.util.concurrent.ExecutorService;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

import javax.jms.Connection;
import javax.jms.JMSException;
import javax.naming.NamingException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SessionExecutor<T extends SessionState>
{
    public SessionExecutor( JMSConnector connector,
                            SessionStateFactory<T> factory )
    {
        this( connector, factory, 100 );
    }

    public SessionExecutor( JMSConnector connector,
                            SessionStateFactory<T> factory,
                            int queueLength )
    {
        this( connector, factory, queueLength, 1 );
    }

    public SessionExecutor( JMSConnector connector,
                            SessionStateFactory<T> factory,
                            int queueLength,
                            int threads )
    {
        this( connector, factory, queueLength, threads, 10 * 1000 );
    }

    public SessionExecutor( JMSConnector connector,
                            SessionStateFactory<T> factory,
                            int queueLength,
                            int threads,
                            int offerTimeout )
    {
        _connector = connector;
        _factory = factory;

        BlockingOfferQueue queue =
            new BlockingOfferQueue( queueLength, offerTimeout );

        _execService =
            new ThreadPoolExecutor( threads, threads,
                                    30, TimeUnit.SECONDS,
                                    queue,
                                    new SessionThreadFactory() );
    }

    public boolean isDoCloseSessions()
    {
        return _doCloseSessions;
    }

    public void setDoCloseSessions( boolean doCloseSessions )
    {
        _doCloseSessions = doCloseSessions;
    }

    public void execute( SessionTask<T> task )
        throws JMSException, NamingException, InterruptedException
    {
        try {
            _execService.execute( task );
        }

        // A failure to connect via awaitConnection() could result in any of the
        // following being thrown.
        // FIXME: Or possibly just log these, as would be the case
        // if added to queue?
        catch( JMSRuntimeException x ) {
            Throwable cause = x.getCause();

            if( cause instanceof JMSException ) {
                throw (JMSException) cause;
            }
            else if( cause instanceof NamingException ) {
                throw (NamingException) cause;
            }
            else if( cause instanceof InterruptedException ) {
                throw (InterruptedException) cause;
            }
        }
    }

    public void shutdown()
    {
        _execService.shutdown();
    }

    public boolean awaitTermination( long timeout, TimeUnit unit )
        throws InterruptedException
    {
        return _execService.awaitTermination( timeout, unit );
    }

    static class SessionThread<S extends SessionState> extends Thread
    {
        public SessionThread( Runnable r,
                              JMSConnector connector,
                              SessionStateFactory<S> factory,
                              int factoryId,
                              int threadId,
                              boolean doCloseSessions )

            throws InterruptedException, JMSException, NamingException
        {
            super( r, String.format( "jms-st-%d-%d", factoryId, threadId ) );
            _doClose = doCloseSessions;
            Connection connection = connector.awaitConnection();
            _state = factory.createSessionState( connector.context(),
                                                 connection );
        }

        public void run()
        {
            try {
                super.run();
            }
            catch( JMSRuntimeException x ) {
                _log.warn( "Exit due to: ", x.getCause() );
            }
            finally {
                close();
            }
        }

        public S state()
        {
            return _state;
        }

        private void close()
        {
            try {
                if( _doClose ) _state.close();
            }
            catch( JMSException x ) {
                _log.warn( "On close: ", x );
            }
        }

        private final S _state;
        private final boolean _doClose;
        private final Logger _log = LoggerFactory.getLogger( getClass() );
    }

    private final class SessionThreadFactory implements ThreadFactory
    {
        public Thread newThread( Runnable r )
        {
            try {
                return new SessionThread<T>( r,
                                             _connector,
                                             _factory,
                                             _factoryId,
                                             _threadCounter.incrementAndGet(),
                                             _doCloseSessions );
            }
            catch( InterruptedException x ) {
                Thread.currentThread().interrupt();
                throw new JMSRuntimeException( x );
            }
            catch( JMSException x ) {
                throw new JMSRuntimeException( x );
            }
            catch( NamingException x ) {
                throw new JMSRuntimeException( x );
            }
        }

        private final int _factoryId = _factoryCounter.incrementAndGet();
        private final AtomicInteger _threadCounter = new AtomicInteger( 0 );
    }

    private static final class BlockingOfferQueue
        extends LinkedBlockingQueue<Runnable>
    {
        public BlockingOfferQueue( int capacity, int offerTimeout )
        {
            super( capacity );
            _offerTimeout = offerTimeout;
        }

        @Override
        public boolean offer( Runnable e )
        {
            try {
                return offer( e, _offerTimeout, TimeUnit.MILLISECONDS );
            }
            catch( InterruptedException x ) {
                Thread.currentThread().interrupt();
                return false;
            }
        }

        private final int _offerTimeout; //ms
    }

    private final ExecutorService _execService;
    private final JMSConnector _connector;
    private final SessionStateFactory<T> _factory;
    private boolean _doCloseSessions = true;

    private static final AtomicInteger _factoryCounter = new AtomicInteger( 0 );
}
