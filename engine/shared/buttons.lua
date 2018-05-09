--=========== Copyright © 2018, Planimeter, All rights reserved. ===========--
--
-- Purpose: Input enumeration
--
--==========================================================================--

_E = _E or {}
_E.IN_FORWARD = bit.lshift( 1, 0 ) -- (1 << 0)
_E.IN_BACK    = bit.lshift( 1, 1 ) -- (1 << 1)
_E.IN_LEFT    = bit.lshift( 1, 2 ) -- (1 << 2)
_E.IN_RIGHT   = bit.lshift( 1, 3 ) -- (1 << 3)
