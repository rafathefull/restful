#include "hbclass.ch"

/* ------------------------------------------------------------------------ */
CLASS StatusServiceAPI FROM BaseService

   METHOD New() CONSTRUCTOR
   METHOD OpenTables()
   METHOD CreateJSON()

   // OVERRIDE methods que necesitemos ----------------------------------
   METHOD getBydId( cId )
   METHOD findAll( offset, limit )
   METHOD DeleteBydId( cID )
   METHOD Create( hHash )
   METHOD Modify( hHash )
   // ---------------------------------------------------------------------

   DESTRUCTOR __End()

END CLASS


/* ------------------------------------------------------------------------ */
METHOD New() CLASS StatusServiceAPI

   ::Super:New()
   ::OpenTables()

   RETURN Self

/* ------------------------------------------------------------------------ */
METHOD OpenTables() CLASS StatusServiceAPI

   USE "status" NEW
   SET INDEX TO "status"

   IF NetErr()
      USetStatusCode( 500 )
      ::lError := .T.
   ENDIF

   RETURN NIL

/* ------------------------------------------------------------------------ */
METHOD CreateJSON() CLASS StatusServiceAPI

   LOCAL hHash

   hHash := { => }
   hHash[ "id" ]     := status->id
   hHash[ "status" ] := hb_StrToUTF8( AllTrim( status->STATUS ) )
   hHash[ "name" ]   := hb_StrToUTF8( AllTrim( status->name ) )

   RETURN hHash


/* ------------------------------------------------------------------------ */
METHOD getBydId( cId ) CLASS StatusServiceAPI

   IF dbSeek( Val( cId ) )
      ::uValue := ::CreateJSON()
   ELSE
      ::uValue := nil
      USetStatusCode( 404 )
   ENDIF

   RETURN ::uValue

/* ------------------------------------------------------------------------ */
METHOD findAll( offset, limit ) CLASS StatusServiceAPI

   LOCAL nCount := 0

   dbGoTop()

   IF !Empty( offset )
      dbSkip( offset )
   ENDIF

   WHILE !Eof() .AND. nCount <= limit

      IF limit > 0  // Si hemos pedido algún limite de registros
         nCount++
         IF nCount > limit
            EXIT
         ENDIF
      ENDIF

      AAdd( ::uValue, ::CreateJSON() )

      dbSkip()

   END WHILE

   RETURN ::uValue

/* ------------------------------------------------------------------------ */
METHOD DeleteBydId( cId ) CLASS StatusServiceAPI

   IF dbSeek( Val( cId ) )
      IF status->( dbRLock() )
         status->( dbDelete() )
         status->( dbUnlock() )
      ELSE
         USetStatusCode( 500 )
      ENDIF
   ELSE
      USetStatusCode( 404 )
   ENDIF

   RETURN NIL

/* ------------------------------------------------------------------------ */
METHOD Create( hHash ) CLASS StatusServiceAPI

   LOCAL nId := Val( hHash[ "id" ] )

   IF !dbSeek( nId )
      dbAppend()
      IF !NetErr()
         status->id     := nId
         status->STATUS := hHash[ "status" ]
         status->name   := hHash[ "name" ]
         UNLOCK
         USetStatusCode( 201 )
      ELSE
         USetStatusCode( 500 )
      ENDIF
   ELSE
      USetStatusCode( 409 )
   ENDIF

   RETURN NIL

/* ------------------------------------------------------------------------ */
METHOD Modify( hHash ) CLASS StatusServiceAPI

   LOCAL nId := Val( hHash[ "id" ] )

   IF dbSeek( nId, .F. )

      IF RLock()
         status->STATUS := hHash[ "status" ]
         status->name   := hHash[ "name" ]
         UNLOCK
      ELSE
         USetStatusCode( 500 )
      ENDIF
   ENDIF

   RETURN NIL

/* ------------------------------------------------------------------------ */
METHOD __End() CLASS StatusServiceAPI

   // TODO: END

   RETURN NIL
