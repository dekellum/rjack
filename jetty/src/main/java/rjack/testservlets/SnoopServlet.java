/*
 * Copyright (c) 2008-2012 David Kellum
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

package rjack.testservlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Enumeration;

import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class SnoopServlet extends HttpServlet
{

    @Override
    protected void doGet( HttpServletRequest request,
                              HttpServletResponse response )
        throws ServletException, IOException
    {
        response.setContentType("text/html; charset=UTF-8" );

        PrintWriter out = response.getWriter();

        out.println( "<html>" );
        out.println( "<head>" );
        out.println( "<title>Wait/Flush Test</title>" );
        out.println( "</head>" );
        out.println( "<body>" );

        writeTableHeader( out, "Request Properties", "Property" );
        writeRow( out, "Request URI", request.getRequestURI() );
        writeRow( out, "HTTP Method", request.getMethod() );
        writeRow( out, "Path Info", request.getPathInfo() );
        writeRow( out, "Path Trans", request.getPathTranslated() );
        writeRow( out, "Query String", request.getQueryString() );
        writeRow( out, "Context Path", request.getContextPath() );
        writeRow( out, "Servlet Path", request.getServletPath() );
        writeRow( out, "Is Secure", String.valueOf( request.isSecure() ) );
        writeRow( out, "Auth Type", request.getAuthType() );
        writeRow( out, "Remote User", request.getRemoteUser() );
        out.println( "</table>" );

        writeTableHeader( out, "Request Headers", "Header" );
        Enumeration<?> hNames = request.getHeaderNames();
        while( hNames.hasMoreElements() ) {
            String hname = hNames.nextElement().toString();
            String hvalue = request.getHeader( hname );
            writeRow( out, hname, hvalue );
        }
        out.println( "</table>" );

        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            writeTableHeader( out, "Cookies", "Cookie" );
            for( Cookie cookie : cookies ) {
                writeRow( out, cookie.getName(), cookie.getValue() );
            }
            out.println( "</table>" );
        }

        out.println( "</body>" );
        out.println( "</html>" );
        out.close();
    }

    private void writeTableHeader( PrintWriter out,
                                   String heading, String name )
    {
        out.println( "<h2>" + heading + "</h2>" );
        out.println( "<table><tr><th>" + name + "</th><th>Value</th></tr>" );
    }

    private void writeRow( PrintWriter out, String name, String value )
    {
        out.println( String.format( "<tr><td>%s</td><td>%s</td></tr>",
                                    name, value ) );
    }

    private static final long serialVersionUID = 1L;
}
