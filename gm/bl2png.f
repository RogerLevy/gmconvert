{
1. load a block file
2. blocks are 20x20 8 bit pixels (400 bytes) so number of tiles is filesize/400
3. load a palette file - 256 x 3 bytes - convert 18-bit to 24-bit
4. create a surface and draw the tiles onto it - fit them in a 256x? space (240 used pixels)
5. save surface as an 8-bit PNG
}

bu: idiom gm:
    import bu/mo/draw

256 400 *bmp constant s
create filename #256 allot
create blocks #65536 allot
0 value #blocks
create palette #256 3 * allot

: loadblk  ( -- <filespec> )
    <filespec>  2dup filename place
        " input/" 2swap strjoin file dup s>p 400 / to #blocks blocks swap move
    cr ." Number of blocks: " #blocks . ;

: loadpal  ( -- <filespec> )
   " input/" <filespec> strjoin file palette swap move
   palette 256 3 * 0 do
      dup c@ 4 * over c! #1 +
   loop drop ;

: icolor  #3 * palette + @ $ffffff and color ;

: block  ( n x y -- )
   locals| y x |  at@ 2>r
   s onto
   #420 * blocks +
   y 20 +  y do
      x 20 +  x do
         i j at   dup c@ icolor pixel
         #1 +
      loop
   loop drop  2>r at ;

: convert  ( -- <filespec> )
    loadblk
    0 0 locals| y x |
    0 begin
        dup x y block
        20 +to x
        x 240 = if 0 to x 20 +to y then
        1 +
    dup #blocks = until
    drop
    s blit
    " output" chdir
    filename count -ext " .png" strjoin  s  savebmp
    " .." chdir ;
