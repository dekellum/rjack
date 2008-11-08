/*
 * Copyright (C) 2008 David Kellum
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.gravitext.testservlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigInteger;
import java.util.Random;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet for perform and chunked output testing. 
 * @author David Kellum
 */
public class PerfTestServlet extends HttpServlet
{

    @Override
    protected void doGet( HttpServletRequest req, HttpServletResponse resp )
        throws ServletException, IOException
    {
        int delayConst = getParam( req, "delay", 0 );
        int delayRandom = getParam( req, "rdelay", 0 );
        
        int burnConst = getParam( req, "burn", 0 );
        int burnRandom = getParam( req, "rburn", 0 );
                    
        int size = getParam( req, "size", 0 );
        int sizeRandom = getParam( req, "rsize", 0 );
        
        int count = getParam( req, "count", 0 );
        count += random( getParam( req, "rcount", 0 ) );

        resp.setContentType("text/html; charset=ISO-8859-1" );

        PrintWriter out = resp.getWriter();

        out.println( "<html>" );
        out.println( "<head>" );
        out.println( "<title>Wait/Flush Test</title>" );
        out.println( "</head>" );
        out.println( "<body>" );

        out.println( "<h2>Usage</h2>" );
        out.println( "<table><tr><th>GET Parameter</th><th>Meaning</th></tr>" );
        out.println( "<tr><td>size</td><td>Chunk constant size ~characters.</td></tr>" );
        out.println( "<tr><td>rsize</td><td>Chunk random [0,n) size ~characters.</td></tr>" );
        out.println( "<tr><td>delay</td><td>Constant chunk delay in ms</td></tr>" );
        out.println( "<tr><td>rdelay</td><td>Random [0,n) chunk delay in ms</td></tr>" );
        out.println( "<tr><td>burn</td><td>Constant chunk CPU burn time in ms</td></tr>" );
        out.println( "<tr><td>rburn</td><td>Random [0,n) chunk burn time in ms</td></tr>" );
        out.println( "</table>" );
               
        out.println( "<h2>Output</h2>" );
        out.flush();
        
        out.println( "<p>Writing " + count + " (delayed) chunks...</p>" );
        out.flush();

        try {
            for( int b = 0; b < count; ++b ) {
                
                long delay = delayConst + random( delayRandom );
                if( delay > 0 ) Thread.sleep( delay );

                int burn = burnConst + random ( burnRandom );
                if( burn > 0 ) {
                    delay += burnTime( burn );
                }
                
                out.println( "<p>(Delayed " + delay + " ms) " );

                int f = size + random( sizeRandom );
                while( f > 0 ) {
                    out.print( FILLER );
                    f -= FILLER.length();
                }

                out.println( "</p>" );
                out.flush();
            }
        }
        catch( InterruptedException x ) {}
        out.println( "</body>" );
        out.println( "</html>" );
        out.flush();
    }
    
    private long burnTime( int burn_ms )
    {
        long prime = 2;
        long begin = System.currentTimeMillis();
        long endTime = begin + burn_ms;
        long last = 0;
        do {
            prime = BigInteger.probablePrime( 64, new Random() ).longValue();
            last = System.currentTimeMillis(); 
        } while( last < endTime );

        if( prime == 2 ) {
            throw new IllegalStateException( "Not a prime!" );
        }
        return last - begin;
    }

    private int getParam( HttpServletRequest req, String name, int defVal )    
    {
        int value = defVal;
        String strVal = req.getParameter( name );
        if( strVal != null ) {
            value = Integer.parseInt( strVal ); 
        }
        
        return value;
    }
    
    private int random( int range )
    {
        Random _random = new Random();
        if( range > 0 ) return _random.nextInt( range );
        return 0;
    }
    
    private static final String FILLER = 
        "Lorem ipsum dolor sit amet, consectetur adipisicing elit, " + 
        "sed do eiusmod tempor incididunt ut labore et dolore magna " + 
        "aliqua. Ut enim ad minim veniam, quis nostrud exercitation " + 
        "ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis " + 
        "aute irure dolor in reprehenderit in voluptate velit esse cillum " + 
        "dolore eu fugiat nulla pariatur. Excepteur sint occaecat " + 
        "cupidatat non proident, sunt in culpa qui officia deserunt " + 
        "mollit anim id est laborum.  ";

    private static final long serialVersionUID = 1L;
}
