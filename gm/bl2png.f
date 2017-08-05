{
1. load a block file
2. blocks are 20x20 8 bit pixels + a 20 byte header (420 bytes) so number of tiles is filesize/420
3. load a palette file - 256 x 3 bytes - convert 18-bit to 24-bit
4. create a surface and draw the tiles onto it - fit them in a 256x? space (240 used pixels)
5. save surface as an 8-bit PNG
}

bu: idiom gm:
    import bu/mo/draw
    import bu/mo/a

256 400 *bmp constant s
create filename #256 allot
create blocks #65536 allot
0 value #blocks
create palette #256 3 * allot

: loadblk  ( -- <filespec> )
    <filespec>  2dup filename place
        " gm/input/" 2swap strjoin file dup s>p 420 / to #blocks blocks swap move
    cr ." Number of blocks: " #blocks . ;

: loadpal  ( -- <filespec> )
   " gm/input/" <filespec> strjoin file palette swap move
   palette 256 3 * 0 do
      dup c@ 2 lshift over c! #1 +
   loop drop ;

: icolor  #3 * palette + @ $ffffff and >rgb 3reverse 1.0 color ;

: block  ( n x y -- )
   locals| y x |
   s onto
   #420 * blocks + a!>
   at@ 2>r
   y 20 bounds do
      x 20 bounds do
         i j at   c@+ s>p icolor pixel
      loop
   loop  2r> at ;

: convert  ( -- <filespec> )
    loadblk
    0 0 locals| y x |
    #blocks 0 do
        i x y block
        20 +to x
        x 240 = if  0 to x  20 +to y  then
    loop
    s " gm/output/" filename count strjoin -ext " .png" strjoin  savebmp
    render>  red backdrop  0 0 at s  white  blit ;
