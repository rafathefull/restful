#include "hbclass.ch"

MEMVAR server, post, get

/* ------------------------------------------------------------------------
  Clase Base para el controlador
--------------------------------------------------------------------------*/
CLASS BaseController

   DATA lError INIT .F.
   DATA oService
   DATA REQUEST_METHOD
   DATA CONTENT_TYPE
   DATA offset    INIT 0
   DATA limit     INIT 0

   METHOD new( cID )
   METHOD getBydId( cID )
   METHOD findAll()
   METHOD deleteBydId( cID )
   METHOD create( hJSON )
   METHOD modify( hJSON )
   METHOD controller( cID )
   METHOD getJSON()
   METHOD check_content_type() INLINE ( "application/json" $ ::CONTENT_TYPE )

END CLASS

/* ------------------------------------------------------------------------ */
METHOD New( cID ) CLASS BaseController

   UAddHeader( "Content-Type", "application/json;charset=UTF-8" )
   IF ValType( ::oService ) = "O"
      ::controller( cID )
   ELSE
      // Simplemente para localizar facilmente que el servicio no fue creado.
      USetStatusCode( 412 ) // Precondition Failed.
   ENDIF

   RETURN Self

/* ------------------------------------------------------------------------ */
METHOD controller( cID ) CLASS BaseController

   ::REQUEST_METHOD  := server[ "REQUEST_METHOD" ]
   ::CONTENT_TYPE    := hb_HGetDef( server, "CONTENT_TYPE", "" )  

   IF !::oService:getError()
      DO CASE
      CASE ::REQUEST_METHOD == "GET" .AND. Empty( cId )
         ::findAll()

      CASE ::REQUEST_METHOD == "GET" .AND. !Empty( cId )
         ::getBydId( cID )

      CASE ::REQUEST_METHOD == "DELETE" .AND. !Empty( cID )
         ::DeleteBydId( cID )

      CASE ::REQUEST_METHOD == "POST"
         IF ::check_content_type()
            ::Create( hb_jsonDecode( server[ "BODY_RAW" ] ) )
         ELSE
            USetStatusCode( 415 ) // 415 Unsupported Media Type
            ::oService:lError := .T.
         ENDIF

      CASE ::REQUEST_METHOD == "PUT"
         IF ::check_content_type()
            ::Modify( hb_jsonDecode( server[ "BODY_RAW" ] ) )
         ELSE
            USetStatusCode( 415 ) // 415 Unsupported Media Type
            ::oService:lError := .T.
         ENDIF

      END CASE
   ENDIF

   RETURN NIL

/* ------------------------------------------------------------------------ */
METHOD getBydId( cID ) CLASS BaseController
   RETURN ::oService:getBydId( cID )

/* ------------------------------------------------------------------------ */
METHOD findAll() CLASS BaseController

   ::offset             := Val( hb_HGetDef( GET, "offset", "0" ) )
   ::limit              := Val( hb_HGetDef( GET, "limit", "0" ) )

   RETURN ::oService:findAll( ::offset, ::limit )

/* ------------------------------------------------------------------------ */
METHOD DeleteBydId( cID ) CLASS BaseController
   RETURN ::oService:DeleteBydId( cID )

/* ------------------------------------------------------------------------ */
METHOD Create( hJSON ) CLASS BaseController
   RETURN ::oService:Create( hJSON )

/* ------------------------------------------------------------------------ */
METHOD Modify( hJSON ) CLASS BaseController
   RETURN ::oService:Modify( hJSON )

METHOD getJSON() CLASS BaseController
   RETURN if( ::oService != NIL, ::oService:getJSON(), NIL  )
