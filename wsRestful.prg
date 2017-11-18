/*
 Simple esqueleto de un Servidor RestFul
 Para Harbour 3.4
 (c)2017 Rafa Carmona

 En este ejemplo vamos a mostrar como mantener una DBF a traves de los verbos HTTP.
 GET  : Consulta lista de la dbf o un ID en concreto
 POST : Crear un registro
 PUT  : Modificar un registro
 DELETE : Borra un registro

*/
#include "hbclass.ch"
#include "error.ch"

#require "hbssl"
#require "hbhttpd"

REQUEST __HBEXTERN__HBSSL__

MEMVAR server, GET, post, cookie, session


PROCEDURE Main()

   LOCAL oServer, hConfig

   LOCAL oLogAccess
   LOCAL oLogError

   IF hb_argCheck( "help" )
      ? "Usage: app [options]"
      ? "Options:"
      ? "  //help               Print help"
      ? "  //stop               Stop running server"
      RETURN
   ENDIF

   IF hb_argCheck( "stop" )
      hb_MemoWrit( ".uhttpd.stop", "" )
      RETURN
   ELSE
      hb_vfErase( ".uhttpd.stop" )
   ENDIF

   Set( _SET_DATEFORMAT, "yyyy-mm-dd" )
   SET DELETE ON

   rddSetDefault( "DBFCDX" )

   DO CASE
   CASE ! hb_dbExists( "status.dbf" )
      hb_dbDrop( "status.dbf", "status.cdx" )
      dbCreate( "status.dbf", { { "ID", "N", 3, 0 }, { "STATUS", "C", 10, 0 }, { "NAME", "C", 50, 0 } }, , .T., "status" )
      ordCreate( "status.cdx", "status", "ID" )
      dbCloseArea()
   ENDCASE

   oLogAccess := UHttpdLog():New( "ws_access.log" )

   IF ! oLogAccess:Add( "" )
      oLogAccess:Close()
      ? "Access log file open error", hb_ntos( FError() )
      RETURN
   ENDIF

   oLogError := UHttpdLog():New( "ws_error.log" )

   IF ! oLogError:Add( "" )
      oLogError:Close()
      oLogAccess:Close()
      ? "Error log file open error", hb_ntos( FError() )
      RETURN
   ENDIF

   oServer := UHttpdNew()

   hConfig := { ;
      "FirewallFilter"      => "", ;
      "LogAccess"           => {| m | oLogAccess:Add( m + hb_eol() ) }, ;
      "LogError"            => {| m | oLogError:Add( m + hb_eol() ) }, ;
      "PostProcessRequest"  => {|| dbCloseAll() }, ;
      "Trace"               => {| ... | QOut( ... ) }, ;
      "Port"                => 8002, ;
      "Idle"                => {| o | iif( hb_vfExists( ".uhttpd.stop" ), ( hb_vfErase( ".uhttpd.stop" ), o:Stop() ), NIL ) }, ;
      "SupportedMethods"    => { "GET", "POST", "DELETE", "PUT" }, ;
      "Mount"          => { ;
      "/info"              => {|| UProcInfo() }, ;
      "/v1/statusType"     => {|| StatusController():New():getJSON() }, ;
      "/v1/statusType/*"   => {| cPath | StatusController():New( cPath ):getJSON() }, ;
      "/"                  => {|| URedirect( "/info" ) } } }

   ? "Listening on port:", hConfig[ "Port" ]

   IF ! oServer:Run( hConfig )
      oLogError:Close()
      oLogAccess:Close()
      ? "Server error:", oServer:cError
      ErrorLevel( 1 )
      RETURN
   ENDIF

   oLogError:Close()
   oLogAccess:Close()

   RETURN
