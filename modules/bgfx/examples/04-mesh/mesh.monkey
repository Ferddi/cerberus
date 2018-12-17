
' using DrawText to draw some bgfx debug text
'  Import mojo1bgfx

' remove DrawText codes and use these minimal imports
Import mojo.app
Import bgfx

'  Class PosColorTexCoord0Vertex
'  
'  '  	Field m_x:Float
'  '  	Field m_y:Float
'  '  	Field m_z:Float
'  '  
'  '  	Field m_abgr:Int
'  '  
'  '  	Field m_u:Float
'  '  	Field m_v:Float
'  '  
'  '  	Method New(m_x:Float, m_y:Float, m_z:Float, m_abgr:Int, m_u:Float, m_v:Float)
'  '  
'  '  		Self.m_x = m_x
'  '  		Self.m_y = m_y
'  '  		Self.m_z = m_z
'  '  
'  '  		Self.m_abgr = m_abgr
'  '  
'  '  		Self.m_u = m_u
'  '  		Self.m_v = m_v
'  '  	End
'  
'  	Global ms_decl:BgfxVertexDecl = New BgfxVertexDecl()
'  
'  	Function Init:Void()
'  		bgfxVertexDeclBegin( ms_decl )
'  		bgfxVertexDeclAdd( ms_decl, BGFX_ATTRIB_POSITION, 3, BGFX_ATTRIB_TYPE_FLOAT )
'  		bgfxVertexDeclAdd( ms_decl, BGFX_ATTRIB_COLOR0, 4, BGFX_ATTRIB_TYPE_UINT8, True )
'  		bgfxVertexDeclAdd( ms_decl, BGFX_ATTRIB_TEXCOORD0, 2, BGFX_ATTRIB_TYPE_FLOAT )
'  		bgfxVertexDeclEnd( ms_decl )
'  	End
'  End

'-------------------------------------------------------------------------------
' move these to bgfx utils
'-------------------------------------------------------------------------------

Class BgfxUtilsAabb
	Field m_min:Float[3]
	Field m_max:Float[3]
End

Class BgfxUtilsObb
	Field m_mtx:Float[16]
End

Class BgfxUtilsSphere
	Field m_center:Float[3]
	Field m_radius:Float
End

Class BgfxUtilsPrimitive

	Field m_startIndex:Int
	Field m_numIndices:Int
	Field m_startVertex:Int
	Field m_numVertices:Int

	Field m_sphere:BgfxUtilsSphere = New BgfxUtilsSphere()
	Field m_aabb:BgfxUtilsAabb = New BgfxUtilsAabb()
	Field m_obb:BgfxUtilsObb = New BgfxUtilsObb()
End

Class BgfxUtilsGroup

	Field m_vbMem:BgfxMemory = New BgfxMemory()
	Field m_ibMem:BgfxMemory = New BgfxMemory()

	Field m_vbh:BgfxVertexBufferHandle = New BgfxVertexBufferHandle()
	Field m_ibh:BgfxIndexBufferHandle = New BgfxIndexBufferHandle()

	Field m_sphere:BgfxUtilsSphere = New BgfxUtilsSphere()
	Field m_aabb:BgfxUtilsAabb = New BgfxUtilsAabb()
	Field m_obb:BgfxUtilsObb = New BgfxUtilsObb()
	Field m_prims:Stack<BgfxUtilsPrimitive> = New Stack<BgfxUtilsPrimitive>()
End

Class BgfxUtilsMesh
	Field m_decl:BgfxVertexDecl = New BgfxVertexDecl()
	Field m_groups:Stack<BgfxUtilsGroup> = New Stack<BgfxUtilsGroup>()
End

Const BGFX_CHUNK_MAGIC_VB:Int = $01204256
Const BGFX_CHUNK_MAGIC_IB:Int = $00204249
Const BGFX_CHUNK_MAGIC_IBC:Int = $00434249
Const BGFX_CHUNK_MAGIC_PRI:Int = $00495250

Function bgfxUtilsReadSphere:Int(buffer:DataBuffer, address:Int, sphere:BgfxUtilsSphere)

	sphere.m_center[0] = buffer.PeekFloat(address); address += 4
	sphere.m_center[1] = buffer.PeekFloat(address); address += 4
	sphere.m_center[2] = buffer.PeekFloat(address); address += 4

	sphere.m_radius = buffer.PeekFloat(address); address += 4

	' Print "cx=" + sphere.m_center[0] + " cy=" + sphere.m_center[1] + " cz=" + sphere.m_center[2] + " radius=" + sphere.m_radius

	Return address
End

Function bgfxUtilsReadAabb:Int(buffer:DataBuffer, address:Int, aabb:BgfxUtilsAabb)

	aabb.m_min[0] = buffer.PeekFloat(address); address += 4
	aabb.m_min[1] = buffer.PeekFloat(address); address += 4
	aabb.m_min[2] = buffer.PeekFloat(address); address += 4

	aabb.m_max[0] = buffer.PeekFloat(address); address += 4
	aabb.m_max[1] = buffer.PeekFloat(address); address += 4
	aabb.m_max[2] = buffer.PeekFloat(address); address += 4

	' Print "minx=" + aabb.m_min[0] + " miny=" + aabb.m_min[1] + " minz=" + aabb.m_min[2]
	' Print "maxx=" + aabb.m_max[0] + " maxy=" + aabb.m_max[1] + " maxz=" + aabb.m_max[2]

	Return address
End

Function bgfxUtilsReadObb:Int(buffer:DataBuffer, address:Int, obb:BgfxUtilsObb)

	For Local ii:Int = 0 Until 16
		obb.m_mtx[ii] = buffer.PeekFloat(address); address += 4
		' Print "ii= " + ii + " mtx=" + obb.m_mtx[ii]
	Next

	Return address
End

Function bgfxUtilsReadVertexDecl:Int(buffer:DataBuffer, address:Int, decl:BgfxVertexDecl)

	' bgfx\src\vertexdecl.cpp
	' int32_t read(bx::ReaderI* _reader, VertexDecl& _decl, bx::Error* _err)

	Local numAttrs:Int = buffer.PeekByte(address); address += 1
	Local stride:Int = buffer.PeekShort(address); address += 2

	bgfxVertexDeclBegin( decl )

	Print "numAttrs=" + numAttrs + " stride=" + stride

	For Local ii:Int = 0 Until numAttrs

		Local offset:Int = buffer.PeekShort(address); address += 2

		Local attribId:Int = buffer.PeekShort(address); address += 2
		Local attr:Int = BGFX_ATTRIB_COUNT

		Select attribId
		Case $0001
			attr = BGFX_ATTRIB_POSITION
		Case $0002
			attr = BGFX_ATTRIB_NORMAL
		Case $0003
			attr = BGFX_ATTRIB_TANGENT
		Case $0004
			attr = BGFX_ATTRIB_BITANGENT
		Case $0005
			attr = BGFX_ATTRIB_COLOR0
		Case $0006
			attr = BGFX_ATTRIB_COLOR1
		Case $0018
			attr = BGFX_ATTRIB_COLOR2
		Case $0019
			attr = BGFX_ATTRIB_COLOR3
		Case $000e
			attr = BGFX_ATTRIB_INDICES
		Case $000f
			attr = BGFX_ATTRIB_WEIGHT
		Case $0010
			attr = BGFX_ATTRIB_TEXCOORD0
		Case $0011
			attr = BGFX_ATTRIB_TEXCOORD1
		Case $0012
			attr = BGFX_ATTRIB_TEXCOORD2
		Case $0013
			attr = BGFX_ATTRIB_TEXCOORD3
		Case $0014
			attr = BGFX_ATTRIB_TEXCOORD4
		Case $0015
			attr = BGFX_ATTRIB_TEXCOORD5
		Case $0016
			attr = BGFX_ATTRIB_TEXCOORD6
		Case $0017
			attr = BGFX_ATTRIB_TEXCOORD7
		End

		Local num:Int = buffer.PeekByte(address); address += 1

		Local attribTypeId:Int = buffer.PeekShort(address); address += 2
		Local type:Int = BGFX_ATTRIB_TYPE_COUNT

		Select attribTypeId
		Case $0001
			type = BGFX_ATTRIB_TYPE_UINT8
		Case $0005
			type = BGFX_ATTRIB_TYPE_UINT10
		Case $0002
			type = BGFX_ATTRIB_TYPE_INT16
		Case $0003
			type = BGFX_ATTRIB_TYPE_HALF
		Case $0004
			type = BGFX_ATTRIB_TYPE_FLOAT
		End

		Local normalizedByte:Int = buffer.PeekByte(address); address += 1
		Local normalized:Bool = False; If normalizedByte = 1 Then normalized = True

		Local asIntByte:Int = buffer.PeekByte(address); address += 1
		Local asInt:Bool = False; If asIntByte = 1 Then asInt = True

		' Print "offset=" + offset + " attribId=" + attribId + " num=" + num + " attribTypeId=" + attribTypeId + " normalized=" + normalizedByte + " asInt=" + asIntByte

		If attr <> BGFX_ATTRIB_COUNT And type <> BGFX_ATTRIB_TYPE_COUNT Then
			bgfxVertexDeclAdd( decl, attr, num, type, normalized, asInt )
			decl.SetOffset(attr, offset)
		Endif

	Next

	bgfxVertexDeclEnd( decl )
	decl.SetStride(stride)

	Return address
End

Function bgfxUtilsMeshLoad:BgfxUtilsMesh(_filePath:String)

	Local buffer:DataBuffer = DataBuffer.Load("cerberus://data/" + _filePath)

	Local address:Int = 0
	Local length:Int = buffer.Length()

	Local mesh:BgfxUtilsMesh = New BgfxUtilsMesh()
	Local group:BgfxUtilsGroup = New BgfxUtilsGroup()

'  	mesh.m_groups.Push(group)

	' Print "length=" + length

	While address < length

		Local chunk:Int = buffer.PeekInt(address); address += 4

		Select chunk

		Case BGFX_CHUNK_MAGIC_VB
			address = bgfxUtilsReadSphere(buffer, address, group.m_sphere)
			address = bgfxUtilsReadAabb(buffer, address, group.m_aabb)
			address = bgfxUtilsReadObb(buffer, address, group.m_obb)

			address = bgfxUtilsReadVertexDecl(buffer, address, mesh.m_decl)

			Local stride:Int = mesh.m_decl.GetStride()
			Local numVertices:Int = buffer.PeekShort(address); address += 2
			If numVertices < 0 Then numVertices = $10000 + numVertices
			Local size:Int = numVertices * stride

			' Print "stride=" + stride + " numVertices=" + numVertices + " size=" + size

			bgfxAlloc(group.m_vbMem, size)
			bgfxCopy(group.m_vbMem, buffer, address, size)
			address += size

			bgfxCreateVertexBuffer(group.m_vbh, group.m_vbMem, mesh.m_decl)

		Case BGFX_CHUNK_MAGIC_IB
			Local numIndices:Int = buffer.PeekInt(address); address += 4
			Local size:Int = numIndices * 2

			bgfxAlloc(group.m_ibMem, size)
			bgfxCopy(group.m_ibMem, buffer, address, size); address += size

			bgfxCreateIndexBuffer(group.m_ibh, group.m_ibMem)

		Case BGFX_CHUNK_MAGIC_IBC
			Print "TODO BGFX_CHUNK_MAGIC_IBC"

		Case BGFX_CHUNK_MAGIC_PRI
			Local len:Int = buffer.PeekShort(address); address += 2
			Local material:String = buffer.PeekString(address, len); address += len
			' Print "material=" + material

			Local num:Int = buffer.PeekShort(address); address += 2

			For Local ii:Int = 0 Until num

				len = buffer.PeekShort(address); address += 2
				Local name:String = buffer.PeekString(address, len); address += len
				' Print "name=" + name

				Local prim:BgfxUtilsPrimitive = New BgfxUtilsPrimitive()
				prim.m_startIndex = buffer.PeekInt(address); address += 4
				prim.m_numIndices = buffer.PeekInt(address); address += 4
				prim.m_startVertex = buffer.PeekInt(address); address += 4
				prim.m_numVertices = buffer.PeekInt(address); address += 4

				address = bgfxUtilsReadSphere(buffer, address, prim.m_sphere)
				address = bgfxUtilsReadAabb(buffer, address, prim.m_aabb)
				address = bgfxUtilsReadObb(buffer, address, prim.m_obb)

				group.m_prims.Push(prim)
			Next

			mesh.m_groups.Push(group)
			group = New BgfxUtilsGroup()

		Default
			Print "chunk=" + chunk + " address=" + address
			Return Null
		End

	Wend

	Return mesh
End

Function bgfxUtilsMeshUnload:Void(_mesh:BgfxUtilsMesh)
	' TODO
End

Function bgfxUtilsMeshSubmit:Void(_mesh:BgfxUtilsMesh, _id:Int, _program:BgfxProgramHandle, _mtx:Float[], _state:Int[]=BGFX_STATE_MASK)

	If _state[0] = BGFX_STATE_MASK[0] And _state[1] = BGFX_STATE_MASK[1] Then

		bgfxUtilsClear64Bit(_state)
		bgfxUtilsSet64Bit(_state, BGFX_STATE_WRITE_RGB)
		bgfxUtilsSet64Bit(_state, BGFX_STATE_WRITE_A)
		bgfxUtilsSet64Bit(_state, BGFX_STATE_WRITE_Z)
		bgfxUtilsSet64Bit(_state, BGFX_STATE_DEPTH_TEST_LESS)
		bgfxUtilsSet64Bit(_state, BGFX_STATE_CULL_CCW)
		bgfxUtilsSet64Bit(_state, BGFX_STATE_MSAA)
	Endif

	bgfxSetTransform(_mtx)
	bgfxSetState(_state)

	Local groups:Stack<BgfxUtilsGroup> = _mesh.m_groups
	Local length:Int = groups.Length()

	For Local ii:Int = 0 Until length

		Local group:BgfxUtilsGroup = groups.Get(ii)

		bgfxSetIndexBuffer(group.m_ibh)
		bgfxSetVertexBuffer(0, group.m_vbh)
		bgfxSubmit(_id, _program, 0, ii <> length -1)

'  		Local _preserveState:Bool = False; If ii <> length -1 Then _preserveState = True
'  		bgfxSubmit(_id, _program, 0, _preserveState)
	Next
End

'-------------------------------------------------------------------------------
' move these to bgfx utils
'-------------------------------------------------------------------------------

Class MeshExample Extends App

	Field debug:Int = BGFX_DEBUG_NONE
'  	Field debug:Int = BGFX_DEBUG_TEXT

	Field m_timeOffset:Int
	Field m_mesh:BgfxUtilsMesh
	Field m_program:BgfxProgramHandle
	Field u_time:BgfxUniformHandle = New BgfxUniformHandle()

	Method OnCreate:Int()

		SetUpdateRate(60)

		' Enable debug text.
		bgfxSetDebug(debug)

		' Set view 0 clear state.
		bgfxSetViewClear(0, BGFX_CLEAR_COLOR|BGFX_CLEAR_DEPTH, $303030ff, 1.0, 0)

		bgfxCreateUniform(u_time, "u_time", BGFX_UNIFORM_TYPE_VEC4)

		' Create program from shaders.
		m_program = bgfxUtilsLoadProgram("vs_mesh", "fs_mesh")

		m_mesh = bgfxUtilsMeshLoad("meshes/bunny.bin")

		m_timeOffset = Millisecs()

		Return 0
	End

	Method OnUpdate:Int()
		Return 0
	End

	Field at:Float[]  = [ 0.0, 1.0,  0.0 ]
	Field eye:Float[] = [ 0.0, 1.0, -2.5 ]

	Field bgfxCaps:BgfxCaps = New BgfxCaps()

'  	Field iden:Float[] = [
'  		1.0, 0.0, 0.0, 0.0,
'  		0.0, 1.0, 0.0, 0.0,
'  		0.0, 0.0, 1.0, 0.0,
'  		0.0, 0.0, 0.0, 1.0]

	Field time:Float[4]

	Field view:Float[16]
	Field proj:Float[16]

	Field mtx:Float[16]

	Method OnRender:Int()

		Local m_width:Int = DeviceWidth()
		Local m_height:Int = DeviceHeight()

		' Set view 0 default viewport.
		bgfxSetViewRect(0, 0, 0, m_width, m_height)

		' This dummy draw call is here to make sure that view 0 is cleared
		' if no other draw calls are submitted to view 0.
		bgfxTouch(0)

		time[0] = Float( (Millisecs() - m_timeOffset) * 0.001 ) ' / 1000.0 )
		bgfxSetUniform(u_time, time)

		' Set view and projection matrix for view 0.
		'{
			bxMtxLookAt(view, eye, at)

			bgfxGetCaps(bgfxCaps)
			bxMtxProj(proj, 60.0, Float(m_width) / Float(m_height), 0.1, 100.0, bgfxCaps.GetHomogeneousDepth())
			bgfxSetViewTransform(0, view, proj)

			' Set view 0 default viewport.
			bgfxSetViewRect(0, 0, 0, m_width, m_height)
		'}

		bxMtxRotateXY(mtx, 0.0, time[0] * 0.37)

		bgfxUtilsMeshSubmit(m_mesh, 0, m_program, mtx)

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
	New MeshExample()
	Return 0
End
