#include "hbclass.ch"

/*
 Clase que define los methods que seran necesarios sobrecargar
 para darle funcionalidad */

CLASS BaseService

   // La data uValue inicialmente es un array. Lo he dejado de esta manera
   // pensando más en devolver una lista que un objeto JSON.
   DATA uValue
   DATA lError INIT .F.

   METHOD New()                    CONSTRUCTOR
   METHOD getError()              INLINE ::lError
   METHOD GetJSON()
   METHOD getBydId()
   METHOD findAll()
   METHOD DeleteBydId()
   METHOD Create()
   METHOD Modify()

END CLASS


METHOD New()  CLASS BaseService

   ::uValue := {}

   RETURN Self
/*
 Por defecto, los methods , si no estan sobreescritos, el valor de retorno
 dará un error 501 Not Implemented
*/

METHOD getBydId() CLASS BaseService
   RETURN ( ::lError := .T.,  USetStatusCode( 501 ) )

METHOD findAll()  CLASS BaseService
   RETURN ( ::lError := .T.,  USetStatusCode( 501 ) )

METHOD DeleteBydId() CLASS BaseService
   RETURN ( ::lError := .T.,  USetStatusCode( 501 ) )

METHOD Create() CLASS BaseService
   RETURN ( ::lError := .T.,  USetStatusCode( 501 ) )

METHOD Modify() CLASS BaseService
   RETURN ( ::lError := .T.,  USetStatusCode( 501 ) )

METHOD GetJSON() CLASS BaseService
   RETURN if( ::uValue != NIL, hb_jsonEncode( ::uValue, .T. ), NIL )
