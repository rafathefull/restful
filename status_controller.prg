#include "hbclass.ch"

/* ------------------------------------------------------------------------
  Punto de Entrada
  "/v1/statusType"
  "/v1/statusType/*"
  -------------------------------------------------------------------------*/

/* ------------------------------------------------------------------------ */
CLASS StatusController FROM BaseController

   METHOD NEW( cID )

END CLASS


METHOD NEW( cID ) CLASS StatusController

   ::oService := StatusServiceAPI():New()
   ::Super:New( cID )

   RETURN Self
