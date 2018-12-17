
' using DrawText to draw some bgfx debug text
'  Import mojo1bgfx

' remove DrawText codes and use these minimal imports
Import mojo.app
Import bgfx

Function EncodeNormalRgba8:Int(_x:Float, _y:Float=0.0, _z:Float=0.0, _w:Float=0.0)

	Local srcx:Float = _x * 0.5 + 0.5
	Local srcy:Float = _y * 0.5 + 0.5
	Local srcz:Float = _z * 0.5 + 0.5
	Local srcw:Float = _w * 0.5 + 0.5

	Return (Int(srcx * 255) Shl 24) | (Int(srcy * 255) Shl 16) | (Int(srcz * 255) Shl 8) | Int(srcw * 255)
End

Class PosNormalTangentTexcoordVertex

	Field m_x:Float
	Field m_y:Float
	Field m_z:Float

	Field m_normal:Int
	Field m_tangent:Int

	Field m_u:Int
	Field m_v:Int

	Method New(m_x:Float, m_y:Float, m_z:Float, m_nx:Float, m_ny:Float, m_nz:Float, m_tangent:Int, m_u:Int, m_v:Int)

		Self.m_x = m_x
		Self.m_y = m_y
		Self.m_z = m_z
		Self.m_normal = EncodeNormalRgba8(m_nx, m_ny, m_nz)
		Self.m_tangent = m_tangent
		Self.m_u = m_u
		Self.m_v = m_v
	End

	Global ms_decl:BgfxVertexDecl = New BgfxVertexDecl()

	Function Init:Void()
		bgfxVertexDeclBegin( ms_decl )
		bgfxVertexDeclAdd( ms_decl, BGFX_ATTRIB_POSITION,  3, BGFX_ATTRIB_TYPE_FLOAT )
		bgfxVertexDeclAdd( ms_decl, BGFX_ATTRIB_NORMAL,    4, BGFX_ATTRIB_TYPE_UINT8,  True, True )
		bgfxVertexDeclAdd( ms_decl, BGFX_ATTRIB_TANGENT,   4, BGFX_ATTRIB_TYPE_UINT8,  True, True )
		bgfxVertexDeclAdd( ms_decl, BGFX_ATTRIB_TEXCOORD0, 2, BGFX_ATTRIB_TYPE_INT16, True, True )
		bgfxVertexDeclEnd( ms_decl )
	End
End

Global s_cubeVertices:PosNormalTangentTexcoordVertex[] = [
	New PosNormalTangentTexcoordVertex( -1.0,  1.0,  1.0,  0.0,  0.0,  1.0, 0,     0,     0 ),
	New PosNormalTangentTexcoordVertex(  1.0,  1.0,  1.0,  0.0,  0.0,  1.0, 0, $7fff,     0 ),
	New PosNormalTangentTexcoordVertex( -1.0, -1.0,  1.0,  0.0,  0.0,  1.0, 0,     0, $7fff ),
	New PosNormalTangentTexcoordVertex(  1.0, -1.0,  1.0,  0.0,  0.0,  1.0, 0, $7fff, $7fff ),
	New PosNormalTangentTexcoordVertex( -1.0,  1.0, -1.0,  0.0,  0.0, -1.0, 0,     0,     0 ),
	New PosNormalTangentTexcoordVertex(  1.0,  1.0, -1.0,  0.0,  0.0, -1.0, 0, $7fff,     0 ),
	New PosNormalTangentTexcoordVertex( -1.0, -1.0, -1.0,  0.0,  0.0, -1.0, 0,     0, $7fff ),
	New PosNormalTangentTexcoordVertex(  1.0, -1.0, -1.0,  0.0,  0.0, -1.0, 0, $7fff, $7fff ),
	New PosNormalTangentTexcoordVertex( -1.0,  1.0,  1.0,  0.0,  1.0,  0.0, 0,     0,     0 ),
	New PosNormalTangentTexcoordVertex(  1.0,  1.0,  1.0,  0.0,  1.0,  0.0, 0, $7fff,     0 ),
	New PosNormalTangentTexcoordVertex( -1.0,  1.0, -1.0,  0.0,  1.0,  0.0, 0,     0, $7fff ),
	New PosNormalTangentTexcoordVertex(  1.0,  1.0, -1.0,  0.0,  1.0,  0.0, 0, $7fff, $7fff ),
	New PosNormalTangentTexcoordVertex( -1.0, -1.0,  1.0,  0.0, -1.0,  0.0, 0,     0,     0 ),
	New PosNormalTangentTexcoordVertex(  1.0, -1.0,  1.0,  0.0, -1.0,  0.0, 0, $7fff,     0 ),
	New PosNormalTangentTexcoordVertex( -1.0, -1.0, -1.0,  0.0, -1.0,  0.0, 0,     0, $7fff ),
	New PosNormalTangentTexcoordVertex(  1.0, -1.0, -1.0,  0.0, -1.0,  0.0, 0, $7fff, $7fff ),
	New PosNormalTangentTexcoordVertex(  1.0, -1.0,  1.0,  1.0,  0.0,  0.0, 0,     0,     0 ),
	New PosNormalTangentTexcoordVertex(  1.0,  1.0,  1.0,  1.0,  0.0,  0.0, 0, $7fff,     0 ),
	New PosNormalTangentTexcoordVertex(  1.0, -1.0, -1.0,  1.0,  0.0,  0.0, 0,     0, $7fff ),
	New PosNormalTangentTexcoordVertex(  1.0,  1.0, -1.0,  1.0,  0.0,  0.0, 0, $7fff, $7fff ),
	New PosNormalTangentTexcoordVertex( -1.0, -1.0,  1.0, -1.0,  0.0,  0.0, 0,     0,     0 ),
	New PosNormalTangentTexcoordVertex( -1.0,  1.0,  1.0, -1.0,  0.0,  0.0, 0, $7fff,     0 ),
	New PosNormalTangentTexcoordVertex( -1.0, -1.0, -1.0, -1.0,  0.0,  0.0, 0,     0, $7fff ),
	New PosNormalTangentTexcoordVertex( -1.0,  1.0, -1.0, -1.0,  0.0,  0.0, 0, $7fff, $7fff )]

Global s_cubeIndices:Int[] = [
	 0,  2,  1,
	 1,  2,  3,
	 4,  5,  6,
	 5,  7,  6,

	 8, 10,  9,
	 9, 10, 11,
	12, 13, 14,
	13, 15, 14,

	16, 18, 17,
	17, 18, 19,
	20, 21, 22,
	21, 23, 22]

Class BumpExample Extends App

	Field m_vbh:BgfxVertexBufferHandle
	Field m_ibh:BgfxIndexBufferHandle

	Field sCubeVerticesBuffer:DataBuffer
	Field sCubeIndicesBuffer:DataBuffer

	Field s_texColor:BgfxUniformHandle
	Field s_texNormal:BgfxUniformHandle
	Field u_lightPosRadius:BgfxUniformHandle
	Field u_lightRgbInnerR:BgfxUniformHandle

	Field m_program:BgfxProgramHandle

	Field m_textureColor:BgfxTextureHandle
	Field m_textureNormal:BgfxTextureHandle

	Field m_numLights:Int

	Field bgfxCaps:BgfxCaps = New BgfxCaps()
	Field supported:Int[2]
	Field m_instancingSupported:Bool

'  	Field debug:Int = BGFX_DEBUG_NONE
	Field debug:Int = BGFX_DEBUG_TEXT
	Field m_timeOffset:Int

	Method MakeDataBuffers:Void()

		Local address:Int
		Local length:Int

		' s_cubeVertices to sCubeVerticesBuffer

		address = 0
		length = s_cubeVertices.Length()

		sCubeVerticesBuffer = New DataBuffer( length * 7 * 4 )
		For Local i:Int = 0 Until length

			sCubeVerticesBuffer.PokeFloat( address, s_cubeVertices[i].m_x ); address += 4
			sCubeVerticesBuffer.PokeFloat( address, s_cubeVertices[i].m_y ); address += 4
			sCubeVerticesBuffer.PokeFloat( address, s_cubeVertices[i].m_z ); address += 4

			sCubeVerticesBuffer.PokeInt( address, s_cubeVertices[i].m_normal ); address += 4
			sCubeVerticesBuffer.PokeInt( address, s_cubeVertices[i].m_tangent ); address += 4

			sCubeVerticesBuffer.PokeShort( address, s_cubeVertices[i].m_u ); address += 2
			sCubeVerticesBuffer.PokeShort( address, s_cubeVertices[i].m_v ); address += 2
		Next

		' s_cubeIndices to sCubeIndicesBuffer

		address = 0
		length = s_cubeIndices.Length()

		sCubeIndicesBuffer = New DataBuffer( length * 2 )
		For Local i:Int = 0 Until length
			sCubeIndicesBuffer.PokeShort( address, s_cubeIndices[i] ); address += 2
		Next
	End

	Method OnCreate:Int()

		SetUpdateRate(60)

		' Enable debug text.
		bgfxSetDebug(debug)

		' Set view 0 clear state.
		bgfxSetViewClear(0, BGFX_CLEAR_COLOR|BGFX_CLEAR_DEPTH, $303030ff, 1.0, 0)

		' Get renderer capabilities info.
		bgfxGetCaps(bgfxCaps)
		bgfxCaps.GetSupported(supported)
		m_instancingSupported = 0 <> (supported[1] & BGFX_CAPS_INSTANCING[1])

		' Create vertex stream declaration.
		PosNormalTangentTexcoordVertex.Init()

'  		calcTangents(s_cubeVertices
'  				, BX_COUNTOF(s_cubeVertices)
'  				, PosNormalTangentTexcoordVertex::ms_decl
'  				, s_cubeIndices
'  				, BX_COUNTOF(s_cubeIndices)
'  				);

		MakeDataBuffers()

		bgfxUtilsCalcTangents(sCubeVerticesBuffer,
				s_cubeVertices.Length(),
				PosNormalTangentTexcoordVertex.ms_decl,
				sCubeIndicesBuffer,
				s_cubeIndices.Length())

		' Create static vertex buffer.
		m_vbh = bgfxUtilsCreateVertexBuffer( bgfxUtilsMakeRef( sCubeVerticesBuffer ), PosNormalTangentTexcoordVertex.ms_decl )

		' Create static index buffer.
		m_ibh = bgfxUtilsCreateIndexBuffer( bgfxUtilsMakeRef( sCubeIndicesBuffer ) )

		' Create texture sampler uniforms.
		s_texColor  = bgfxUtilsCreateUniform("s_texColor",  BGFX_UNIFORM_TYPE_INT1)
		s_texNormal = bgfxUtilsCreateUniform("s_texNormal", BGFX_UNIFORM_TYPE_INT1)

		m_numLights = 4
		u_lightPosRadius = bgfxUtilsCreateUniform("u_lightPosRadius", BGFX_UNIFORM_TYPE_VEC4, m_numLights)
		u_lightRgbInnerR = bgfxUtilsCreateUniform("u_lightRgbInnerR", BGFX_UNIFORM_TYPE_VEC4, m_numLights)

		' Create program from shaders.
		If m_instancingSupported Then
			m_program = bgfxUtilsLoadProgram("vs_bump_instanced", "fs_bump")
		Else
			m_program = bgfxUtilsLoadProgram("vs_bump", "fs_bump")
		Endif

		' Load diffuse texture.
		m_textureColor = bgfxUtilsLoadTexture("textures/fieldstone-rgba.dds");

		' Load normal texture.
		m_textureNormal = bgfxUtilsLoadTexture("textures/fieldstone-n.dds");

		m_timeOffset = Millisecs()

		Return 0
	End

	Method OnUpdate:Int()
		Return 0
	End

	Method OnClose:Int()

		' Cleanup.
		bgfxDestroyIndexBuffer(m_ibh)
		bgfxDestroyVertexBuffer(m_vbh)
		bgfxDestroyProgram(m_program)
		bgfxDestroyTexture(m_textureColor)
		bgfxDestroyTexture(m_textureNormal)
		bgfxDestroyUniform(s_texColor)
		bgfxDestroyUniform(s_texNormal)
		bgfxDestroyUniform(u_lightPosRadius)
		bgfxDestroyUniform(u_lightRgbInnerR)

		' Shutdown bgfx.
		bgfxShutdown()
	End

	Field at:Float[]  = [ 0.0, 0.0,   0.0 ]
	Field eye:Float[] = [ 0.0, 0.0, -7.0 ]

'  	Field iden:Float[] = [
'  		1.0, 0.0, 0.0, 0.0,
'  		0.0, 1.0, 0.0, 0.0,
'  		0.0, 0.0, 1.0, 0.0,
'  		0.0, 0.0, 0.0, 1.0]

	Field view:Float[16]
	Field proj:Float[16]
	Field mtx:Float[16]

	Field lightPosRadius:Float[16]
	Field lightRgbInnerR:Float[] = [
		1.0, 0.7, 0.2, 0.8,
		0.7, 0.2, 1.0, 0.8,
		0.2, 1.0, 0.7, 0.8,
		1.0, 0.4, 0.2, 0.8]

	Field state:Int[2]

	Field idb := New BgfxInstanceDataBuffer()

	Method OnRender:Int()

		Local m_width:Int = DeviceWidth()
		Local m_height:Int = DeviceHeight()

		' Set view 0 default viewport.
		bgfxSetViewRect(0, 0, 0, m_width, m_height)

		' This dummy draw call is here to make sure that view 0 is cleared
		' if no other draw calls are submitted to view 0.
		bgfxTouch(0)

		Local time:Float = Float( (Millisecs() - m_timeOffset) * 0.001 ) ' / 1000.0 )

		' Set view and projection matrix for view 0.
		'{
			bxMtxLookAt(view, eye, at)

			bgfxGetCaps(bgfxCaps)
			bxMtxProj(proj, 60.0, Float(m_width) / Float(m_height), 0.1, 100.0, bgfxCaps.GetHomogeneousDepth())
			bgfxSetViewTransform(0, view, proj)

			' Set view 0 default viewport.
			bgfxSetViewRect(0, 0, 0, m_width, m_height)
		'}

		Local jj:Int = 0
		For Local ii:Int = 0 Until m_numLights
			lightPosRadius[jj + 0] = Sinr( (time * (0.1 + ii * 0.17) + ii * HALFPI * 1.37 ) ) * 3.0
			lightPosRadius[jj + 1] = Cosr( (time * (0.2 + ii * 0.29) + ii * HALFPI * 1.49 ) ) * 3.0
			lightPosRadius[jj + 2] = -2.5
			lightPosRadius[jj + 3] = 3.0
			jj += 4
		Next

		bgfxSetUniform(u_lightPosRadius, lightPosRadius, m_numLights)
		bgfxSetUniform(u_lightRgbInnerR, lightRgbInnerR, m_numLights)

		Const instanceStride:Int = 64
		Const numInstances:Int   = 3

		If m_instancingSupported Then

			' Write instance data for 3x3 cubes.
			For Local yy:Int = 0 Until 3
				If numInstances = bgfxGetAvailInstanceDataBuffer(numInstances, instanceStride) Then

					bgfxAllocInstanceDataBuffer(idb, numInstances, instanceStride)

					Local address:Int = 0

					For Local xx:Int = 0 Until 3

						bxMtxRotateXY(mtx, time * 0.023 + xx * 0.21, time * 0.03 + yy * 0.37)

						idb.PokeFloat(address, mtx[ 0]); address += 4
						idb.PokeFloat(address, mtx[ 1]); address += 4
						idb.PokeFloat(address, mtx[ 2]); address += 4
						idb.PokeFloat(address, mtx[ 3]); address += 4

						idb.PokeFloat(address, mtx[ 4]); address += 4
						idb.PokeFloat(address, mtx[ 5]); address += 4
						idb.PokeFloat(address, mtx[ 6]); address += 4
						idb.PokeFloat(address, mtx[ 7]); address += 4

						idb.PokeFloat(address, mtx[ 8]); address += 4
						idb.PokeFloat(address, mtx[ 9]); address += 4
						idb.PokeFloat(address, mtx[10]); address += 4
						idb.PokeFloat(address, mtx[11]); address += 4

						' idb.PokeFloat(address, mtx[12]); address += 4
						idb.PokeFloat(address, -3.0 + Float(xx) * 3.0); address += 4

						' idb.PokeFloat(address, mtx[13]); address += 4
						idb.PokeFloat(address, -3.0 + Float(yy) * 3.0); address += 4

						' idb.PokeFloat(address, mtx[14]); address += 4
						idb.PokeFloat(address, 0.0); address += 4

						idb.PokeFloat(address, mtx[15]); address += 4
					Next

					' Set instance data buffer.
					bgfxSetInstanceDataBuffer(idb, 0, numInstances)

					' Set vertex and index buffer.
					bgfxSetVertexBuffer(0, m_vbh)
					bgfxSetIndexBuffer(m_ibh)

					' Bind textures.
					bgfxSetTexture(0, s_texColor,  m_textureColor)
					bgfxSetTexture(1, s_texNormal, m_textureNormal)

					' Set render states.
					bgfxUtilsClear64Bit(state)
'  					bgfxUtilsSet64Bit(state, BGFX_STATE_WRITE_RGB)
					bgfxUtilsSet64Bit(state, BGFX_STATE_WRITE_R)
					bgfxUtilsSet64Bit(state, BGFX_STATE_WRITE_G)
					bgfxUtilsSet64Bit(state, BGFX_STATE_WRITE_B)
					bgfxUtilsSet64Bit(state, BGFX_STATE_WRITE_A)
					bgfxUtilsSet64Bit(state, BGFX_STATE_WRITE_Z)
					bgfxUtilsSet64Bit(state, BGFX_STATE_DEPTH_TEST_LESS)
					bgfxUtilsSet64Bit(state, BGFX_STATE_MSAA)
					bgfxSetState(state)

					' Submit primitive for rendering to view 0.
					bgfxSubmit(0, m_program)
				Endif
			Next

		Else

			For Local yy:Int = 0 Until 3
				For Local xx:Int = 0 Until 3

					bxMtxRotateXY(mtx, time * 0.023 + xx * 0.21, time * 0.03 + yy * 0.37)
					mtx[12] = -3.0 + Float(xx) * 3.0
					mtx[13] = -3.0 + Float(yy) * 3.0
					mtx[14] = 0.0

					' Set transform for draw call.
					bgfxSetTransform(mtx)

					' Set vertex and index buffer.
					bgfxSetVertexBuffer(0, m_vbh)
					bgfxSetIndexBuffer(m_ibh)

					' Bind textures.
					bgfxSetTexture(0, s_texColor,  m_textureColor)
					bgfxSetTexture(1, s_texNormal, m_textureNormal)

					' Set render states.
					bgfxUtilsClear64Bit(state)
'  					bgfxUtilsSet64Bit(state, BGFX_STATE_WRITE_RGB)
					bgfxUtilsSet64Bit(state, BGFX_STATE_WRITE_R)
					bgfxUtilsSet64Bit(state, BGFX_STATE_WRITE_G)
					bgfxUtilsSet64Bit(state, BGFX_STATE_WRITE_B)
					bgfxUtilsSet64Bit(state, BGFX_STATE_WRITE_A)
					bgfxUtilsSet64Bit(state, BGFX_STATE_WRITE_Z)
					bgfxUtilsSet64Bit(state, BGFX_STATE_DEPTH_TEST_LESS)
					bgfxUtilsSet64Bit(state, BGFX_STATE_MSAA)
					bgfxSetState(state)

					' Submit primitive for rendering to view 0.
					bgfxSubmit(0, m_program)
				Next
			Next

		Endif

		' Advance to next frame. Rendering thread will be kicked to
		' process submitted rendering primitives.
		'
		' bgfxFrame is done in the while loop of method void BBGlfwGame::Run() 
		' in file targets\glfw3_bgfx\modules\native\glfwgame.cpp
		' it is done after method RenderGame(), where glfwSwapBuffers used to be
		'
		' bgfxFrame() 

		Return 0
	End

End

Function Main:Int()
	Print "Title: 06-bump"
	Print "Description: Loading textures."
	New BumpExample()
	Return 0
End
