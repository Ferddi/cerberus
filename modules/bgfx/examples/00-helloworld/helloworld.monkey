
Import mojo.app
Import tools

Import bgfx

Class MojoGame Extends App

	Field width:Int = 1280
	Field height:Int = 720

	Field debug:Int = BGFX_DEBUG_TEXT

	Field sLogoBuffer:DataBuffer

	Method OnCreate:Int()

		SetUpdateRate(60)

		InitTools()

		Print "Randomi()=" + Randomi()

		Local len:Int = s_Logo.Length()
		sLogoBuffer = New DataBuffer( len )
		For Local i:Int = 0 Until len
			sLogoBuffer.PokeByte(i, s_Logo[i])
		Next

		' Enable debug text.
		bgfxSetDebug(debug)

		' Set view 0 clear state.
		bgfxSetViewClear(0, BGFX_CLEAR_COLOR|BGFX_CLEAR_DEPTH, $303030ff, 1.0, 0)

		Return 0
	End

	Method OnUpdate:Int()
		Return 0
	End

	Method OnRender:Int()

		' Set view 0 default viewport.
		bgfxSetViewRect(0, 0, 0, width, height)

		' This dummy draw call is here to make sure that view 0 is cleared
		' if no other draw calls are submitted to view 0.
		bgfxTouch(0)

		' Use debug font to print information about this example.
		bgfxDbgTextClear(0, False)
'  		bgfxDbgTextImageArray(Max(width/2/8, 20)-20, Max(height/2/16, 6)-6, 40, 12, _sLogo, 160)
		bgfxDbgTextImage(Max(width/2/8, 20)-20, Max(height/2/16, 6)-6, 40, 12, sLogoBuffer, 160)
		bgfxDbgTextPrintf(0, 1, $4f, "bgfx/examples/25-c99")
		bgfxDbgTextPrintf(0, 2, $6f, "Description: Initialization and debug text with C99 API.")

		' Advance to next frame. Rendering thread will be kicked to
		' process submitted rendering primitives.
		bgfxFrame(False)

		Return 0
	End
End

Function Main:Int()
	New MojoGame()
	Return 0
End

Global s_Logo:Int[] = [
	$dc, $03, $dc, $03, $dc, $03, $dc, $03, $20, $0f, $20, $0f, $20, $0f, $20, $0f, ' ........ . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $dc, $08, '  . . . . . . ...
	$dc, $03, $dc, $07, $dc, $07, $dc, $08, $20, $0f, $20, $0f, $20, $0f, $20, $0f, ' ........ . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$de, $03, $b0, $3b, $b1, $3b, $b2, $3b, $db, $3b, $20, $0f, $20, $0f, $20, $0f, ' ...;.;.;.; . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $dc, $03, $b1, $3b, $b2, $3b, '  . . . . ....;.;
	$db, $3b, $df, $03, $df, $3b, $b2, $3f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, ' .;...;.? . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $b1, $3b, $b1, $3b, $b2, $3b, $b2, $3f, $20, $0f, $20, $0f, $20, $0f, '  ..;.;.;.? . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $b1, $3b, $b1, $3b, $b2, $3b, '  . . . . ..;.;.;
	$b2, $3f, $20, $0f, $20, $0f, $df, $03, $20, $0f, $20, $0f, $20, $0f, $20, $0f, ' .? . ... . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $b1, $3b, $b1, $3b, $b1, $3b, $b1, $3f, $dc, $0b, $dc, $03, $dc, $03, '  ..;.;.;.?......
	$dc, $03, $dc, $03, $20, $0f, $20, $0f, $dc, $08, $dc, $03, $dc, $03, $dc, $03, ' .... . .........
	$dc, $03, $dc, $03, $dc, $03, $dc, $08, $20, $0f, $b1, $3b, $b1, $3b, $b1, $3b, ' ........ ..;.;.;
	$b1, $3f, $b1, $3f, $b2, $0b, $20, $0f, $20, $0f, $dc, $03, $dc, $03, $dc, $03, ' .?.?.. . .......
	$20, $0f, $20, $0f, $dc, $03, $dc, $03, $dc, $03, $20, $0f, $20, $01, $20, $0f, '  . ....... . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $b2, $3b, $b1, $3b, $b0, $3b, $b0, $3f, $20, $0f, $de, $03, $b0, $3f, '  ..;.;.;.? ....?
	$b1, $3f, $b2, $3f, $dd, $03, $de, $03, $db, $03, $db, $03, $b2, $3f, $20, $0f, ' .?.?.........? .
	$20, $0f, $b0, $3f, $b1, $3f, $b2, $3f, $de, $38, $b2, $3b, $b1, $3b, $b0, $3b, '  ..?.?.?.8.;.;.;
	$b0, $3f, $20, $0f, $20, $0f, $20, $0f, $b0, $3b, $b1, $3b, $b2, $3b, $b2, $3f, ' .? . . ..;.;.;.?
	$dd, $03, $de, $03, $b0, $3f, $b1, $3f, $b2, $3f, $dd, $03, $20, $01, $20, $0f, ' .....?.?.?.. . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $b2, $3b, $b1, $3b, $b0, $3b, $b0, $3f, $20, $0f, $20, $0f, $db, $03, '  ..;.;.;.? . ...
	$b0, $3f, $b1, $3f, $dd, $03, $b1, $3b, $b0, $3b, $db, $03, $b1, $3f, $20, $0f, ' .?.?...;.;...? .
	$20, $0f, $20, $3f, $b0, $3f, $b1, $3f, $b0, $3b, $b2, $3b, $b1, $3b, $b0, $3b, '  . ?.?.?.;.;.;.;
	$b0, $3f, $20, $0f, $20, $0f, $20, $0f, $dc, $08, $dc, $3b, $b1, $3b, $b1, $3f, ' .? . . ....;.;.?
	$b1, $3b, $b0, $3b, $b2, $3b, $b0, $3f, $dc, $03, $20, $0f, $20, $01, $20, $0f, ' .;.;.;.?.. . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $b2, $3b, $b1, $3b, $b0, $3b, $b0, $3f, $dc, $0b, $dc, $07, $db, $03, '  ..;.;.;.?......
	$db, $03, $dc, $38, $20, $0f, $df, $03, $b1, $3b, $b0, $3b, $b0, $3f, $dc, $03, ' ...8 ....;.;.?..
	$dc, $07, $b0, $3f, $b1, $3f, $b2, $3f, $dd, $3b, $b2, $3b, $b1, $3b, $dc, $78, ' ...?.?.?.;.;.;.x
	$df, $08, $20, $0f, $20, $0f, $de, $08, $b2, $3b, $b1, $3b, $b0, $3b, $b0, $3f, ' .. . ....;.;.;.?
	$20, $0f, $df, $03, $b1, $3b, $b2, $3b, $db, $03, $dd, $03, $20, $01, $20, $0f, '  ....;.;.... . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $dc, $08, $dc, $08, $dc, $08, $20, $0f, '  . . . ....... .
	$20, $0f, $b0, $3f, $b0, $3f, $b1, $3f, $dd, $3b, $db, $0b, $df, $03, $20, $0f, '  ..?.?.?.;.... .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $df, $08, $df, $03, $df, $03, $df, $08, '  . . . .........
	$20, $0f, $20, $0f, $df, $08, $df, $03, $df, $03, $20, $0f, $20, $01, $20, $0f, '  . ....... . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $db, $08, $b2, $38, $b1, $38, $dc, $03, '  . . . ....8.8..
	$dc, $07, $b0, $3b, $b1, $3b, $df, $3b, $df, $08, $20, $0f, $20, $0f, $20, $0f, ' ...;.;.;.. . . .
	$20, $0b, $20, $0b, $20, $0b, $20, $0b, $20, $0b, $20, $0b, $20, $0b, $20, $0b, '  . . . . . . . .
	$20, $0b, $20, $0b, $20, $0b, $20, $0b, $20, $0b, $20, $0b, $20, $0b, $20, $0b, '  . . . . . . . .
	$20, $0b, $20, $0b, $20, $0b, $20, $0b, $20, $0b, $20, $0b, $20, $0b, $20, $0b, '  . . . . . . . .
	$20, $0b, $20, $0b, $20, $0b, $20, $0b, $20, $0b, $20, $0b, $20, $0b, $20, $0b, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0b, $20, $0b, $20, $0b, $20, $0b, '  . . . . . . . .
	$20, $0b, $20, $0b, $20, $0b, $20, $0b, $20, $0b, $20, $0b, $20, $0b, $20, $0b, '  . . . . . . . .
	$20, $0b, $20, $0b, $20, $0b, $20, $0b, $20, $0b, $20, $0b, $20, $0b, $20, $0b, '  . . . . . . . .
	$20, $0b, $20, $0b, $20, $0b, $20, $0b, $20, $0b, $20, $0b, $20, $0b, $20, $0b, '  . . . . . . . .
	$20, $0b, $20, $0b, $20, $0b, $20, $0b, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$2d, $08, $3d, $08, $20, $0a, $43, $0b, $72, $0b, $6f, $0b, $73, $0b, $73, $0b, ' -.=. .C.r.o.s.s.
	$2d, $0b, $70, $0b, $6c, $0b, $61, $0b, $74, $0b, $66, $0b, $6f, $0b, $72, $0b, ' -.p.l.a.t.f.o.r.
	$6d, $0b, $20, $0b, $72, $0b, $65, $0b, $6e, $0b, $64, $0b, $65, $0b, $72, $0b, ' m. .r.e.n.d.e.r.
	$69, $0b, $6e, $0b, $67, $0b, $20, $0b, $6c, $0b, $69, $0b, $62, $0b, $72, $0b, ' i.n.g. .l.i.b.r.
	$61, $0b, $72, $0b, $79, $0b, $20, $0f, $3d, $08, $2d, $08, $20, $01, $20, $0f, ' a.r.y. .=.-. . .
	$20, $0a, $20, $0a, $20, $0a, $20, $0a, $20, $0a, $20, $0a, $20, $0a, $20, $0a, '  . . . . . . . .
	$20, $0a, $20, $0a, $20, $0a, $20, $0a, $20, $0a, $20, $0a, $20, $0a, $20, $0a, '  . . . . . . . .
	$20, $0a, $20, $0a, $20, $0a, $20, $0a, $20, $0a, $20, $0a, $20, $0a, $20, $0a, '  . . . . . . . .
	$20, $0a, $20, $0a, $20, $0a, $20, $0a, $20, $0a, $20, $0a, $20, $0a, $20, $0a, '  . . . . . . . .
	$20, $0a, $20, $0a, $20, $0a, $20, $0a, $20, $0a, $20, $0a, $20, $0a, $20, $0a, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, '  . . . . . . . .
	$20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f, $20, $0f] '  . . . . . . . .

