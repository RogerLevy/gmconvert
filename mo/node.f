
[bu] idiom [node]
import mo/porpoise

object inherit  xvar prev  xvar next  xvar parent    class node
object inherit  xvar length  xvar first  xvar tail   class container

: nodelist  create  container instance, ;

: (unlink)  ( node -- )
  dup prev @ if  dup next @  over prev @ next !  then
  dup next @ if  dup prev @  over next @ prev !  then
  dup prev off  next off ;

: remove  ( node -- )
  ?dup -exit
  dup parent @ 0= if  drop exit  then  \ not already in any container
  dup parent @ >r
  r@ length --
  r@ length @ if
    dup r@ first @ = if  dup next @  r@ first !  then
    dup r@ tail @ =  if  dup prev @  r@ tail !  then
  else
    r@ first off  r@ tail off
  then
  r> ( container ) drop  ( node ) dup parent off  (unlink) ;
: pushnode  ( node container -- )
  dup 0= if  2drop exit  then
  over parent @ if
    over parent @ over = if  2drop exit  then  \ already in given container
    over remove  \ if already in another container, remove it first
  then
  >r
  r@ over parent !
  r@ length ++
  r@ length @ 1 = if
    dup r@ first !
  else
    r@ tail @
    over prev !  dup r@ tail @ next !
  then
  r> tail ! ;


0 value cxt
0 value xt
: thru>  ( ... client-xt first-item -- <code> ... )  ( ... item -- ... next-item|0 )  ( ... item -- ... )
  r>  cxt >r  xt >r   code> to xt  swap to cxt
  begin  dup while  >r  cxt execute  r> xt execute  repeat
  drop
  r> to xt  r> to cxt ;

: itterate  ( ... xt container -- ... )   ( ... obj -- ... )
  first @  thru>  next @ ;

: <itterate  ( ... xt container -- ... )   ( ... obj -- ... )
  tail @  thru>  prev @ ;


:noname  ( container node -- list )  over swap parent ! ; ( xt )

: graft  ( container1 container2 -- )  \ move the contents of container2 to container1
  locals| b a |
  b length @  ?dup -exit  a length +!  b length off
  a tail @ b first @ prev !
  a tail @ if    b first @ a tail @ next !  
           else  b first @ a first !
           then
  b tail @ a tail ! 
  b first off  b tail off
  a ( xt ) LITERAL over itterate drop  \ change the parent of each one
  ;

: popnode  tail @ dup remove ;


\ --- test ---


marker dispose
create a node instance,
create b node instance,
create c node instance,
nodelist l
a l pushnode
b l pushnode
c l pushnode
: test   <> abort" nodelist test failed" ;

l length @ 3 test
l popnode c test
  l length @ 2 test
    l tail @ b test
l popnode b test
  l length @ 1 test
    l tail @ a test

l popnode a test
  l length @ 0 test
    l tail @ 0 test
    
cr .( PASSED: nodelists )
dispose
