
Private

'#TEXT_FILES+="*.txt|*.xml|*.json|*.glsl"
#TEXT_FILES+="*.glsl"

'  Import mojo.app
Import opengl.gles20
Import brl.filepath
Import glslparser
Import math3d
Import glutil

Import graphicsfont
Import graphicsimage
Import wrapper

Import "data/mojo2_font.png"
Import "data/mojo2_program.glsl"
Import "data/mojo2_mojo1shader.glsl"
Import "data/mojo2_fastshader.glsl"
Import "data/mojo2_bumpshader.glsl"
Import "data/mojo2_matteshader.glsl"
Import "data/mojo2_shadowshader.glsl"
Import "data/mojo2_lightmapshader.glsl"

Const VBO_USAGE:=GL_STREAM_DRAW
Const VBO_ORPHANING_ENABLED:=False'True

#If TARGET="glfw" Or TARGET="android" Or TARGET="html5" Or CONFIG="debug"
Const GraphicsCanCrash:=True
#Else
Const GraphicsCanCrash:=False
#Endif

#If TARGET="glfw"
	Extern
		Global graphicsSeq:Int="glfwGraphicsSeq"
	Private
#Else If TARGET="android"
	Extern
		Global graphicsSeq:Int="gxtkGraphics.seq"
	Private
#Else If TARGET="html5"
	Extern
		Global graphicsSeq:Int="webglGraphicsSeq"
	Private
#Else
	Global graphicsSeq:Int=1
#Endif

Public

'-------------------------------------------------------------------------------
' init, begin and end render (before and after OnRender)
'-------------------------------------------------------------------------------

'  Global _activeCanvas:Canvas
'  
'  Function InitMojo1Bgfx:Void( )
'  	#If TARGET="html5"
'  		' using mojo 2 gles20
'  		_activeCanvas = New Canvas( )
'  	#Else
'  		' using mojo 2 bgfx
'  		_activeCanvas = New Canvas( 0 )
'  	#Endif
'  End

' this is called from mojo.app.cxs function RenderGame
Function BeginRenderMojo1Bgfx:Void()

'  	renderDevice=device
'  	context.matrixSp=0
'  	SetMatrix 1,0,0,1,0,0
'  	SetColor 255,255,255
'  	SetAlpha 1
'  	SetBlend 0
'  	SetScissor 0,0,DeviceWidth,DeviceHeight

	ResetCanvas()
	_canvasStack.Clear()

	_activeCanvas._matSp = 0
	_activeCanvas.ResetMatrix()
	_activeCanvas.SetColor(1, 1, 1)
	_activeCanvas.SetAlpha(1)
	_activeCanvas.SetBlendMode(0+1)
	_activeCanvas.SetScissor(0, 0, DeviceWidth, DeviceHeight)
End

' this is called from mojo.app.cxs function RenderGame
Function EndRenderMojo1Bgfx:Void()
'  	Print "End Render Mojo2"
	_activeCanvas.Flush()
End

Const MAX_LIGHTS:=4
Const BYTES_PER_VERTEX:=28

'can really be anything <64K (due to 16bit indices) but this keeps total VBO size<64K, and making it bigger doesn't seem to improve performance much.
Const MAX_VERTICES:=65536/BYTES_PER_VERTEX	

Const MAX_QUADS:=MAX_VERTICES/4
Const MAX_QUAD_INDICES:=MAX_QUADS*6
Const PRIM_VBO_SIZE:=MAX_VERTICES*BYTES_PER_VERTEX

Global tmpi:Int[16]
Global tmpf:Float[16]
Global defaultFbo:Int

Global tmpMat2d:Float[6]
Global tmpMat3d:Float[16]
Global tmpMat3d2:Float[16]

Global mainShader:String

Global mojo1Shader:Shader
Global fastShader:Shader
Global bumpShader:Shader
Global matteShader:Shader
Global shadowShader:Shader
Global lightMapShader:Shader

Global defaultFont:Font
Global defaultShader:Shader

Global freeOps:=New Stack<DrawOp>
Global nullOp:=New DrawOp

'shader params
Global rs_projMatrix:=Mat4New()
Global rs_modelViewMatrix:=Mat4New()
Global rs_modelViewProjMatrix:=Mat4New()
Global rs_clipPosScale:=[1.0,1.0,1.0,1.0]
Global rs_globalColor:=[1.0,1.0,1.0,1.0]
Global rs_numLights:Int
Global rs_fogColor:=[0.0,0.0,0.0,0.0]
Global rs_ambientLight:=[0.0,0.0,0.0,1.0]
Global rs_lightColors:Float[MAX_LIGHTS*4]
Global rs_lightVectors:Float[MAX_LIGHTS*4]
Global rs_shadowTexture:Texture
Global rs_program:GLProgram
Global rs_material:Material
Global rs_blend:Int=-1
Global rs_vbo:Int
Global rs_ibo:Int

Function IsPow2:Bool( sz:Int )
	Return (sz & (sz-1))=0
End

Class LightData
	Field type:Int=0
	Field color:Float[]=[1.0,1.0,1.0,1.0]
	Field position:Float[]=[0.0,0.0,-10.0]
	Field range:Float=10
	'
	Field vector:Float[]=[0.0,0.0,-10.0,1.0]
	Field tvector:Float[4]
End

Global flipYMatrix:=Mat4New()

Global vbosSeq:Int

Function InitVbos:Void()
	If vbosSeq=graphicsSeq Return
	vbosSeq=graphicsSeq

'	Print "InitVbos()"

	rs_vbo=glCreateBuffer()
	glBindBuffer GL_ARRAY_BUFFER,rs_vbo
	glBufferData GL_ARRAY_BUFFER,PRIM_VBO_SIZE,Null,VBO_USAGE
	glEnableVertexAttribArray 0 ; glVertexAttribPointer 0,2,GL_FLOAT,False,BYTES_PER_VERTEX,0
	glEnableVertexAttribArray 1 ; glVertexAttribPointer 1,2,GL_FLOAT,False,BYTES_PER_VERTEX,8
	glEnableVertexAttribArray 2 ; glVertexAttribPointer 2,2,GL_FLOAT,False,BYTES_PER_VERTEX,16
	glEnableVertexAttribArray 3 ; glVertexAttribPointer 3,4,GL_UNSIGNED_BYTE,True,BYTES_PER_VERTEX,24
	
	rs_ibo=glCreateBuffer()
	glBindBuffer GL_ELEMENT_ARRAY_BUFFER,rs_ibo
	Local idxs:=New DataBuffer( MAX_QUAD_INDICES*4*2,True )
	For Local j:=0 Until 4
		Local k:=j*MAX_QUAD_INDICES*2
		For Local i:=0 Until MAX_QUADS
			idxs.PokeShort i*12+k+0,i*4+j+0
			idxs.PokeShort i*12+k+2,i*4+j+1
			idxs.PokeShort i*12+k+4,i*4+j+2
			idxs.PokeShort i*12+k+6,i*4+j+0
			idxs.PokeShort i*12+k+8,i*4+j+2
			idxs.PokeShort i*12+k+10,i*4+j+3
		Next
	Next
	glBufferData GL_ELEMENT_ARRAY_BUFFER,idxs.Length,idxs,GL_STATIC_DRAW
	idxs.Discard
End

Global inited:Bool

Function InitMojo2:Void()
	If inited Return
	inited=True
	
	InitVbos
	
	glGetIntegerv GL_FRAMEBUFFER_BINDING,tmpi
	defaultFbo=tmpi[0]
	
	mainShader=LoadString( "cerberus://data/mojo2_program.glsl" )
	
	mojo1Shader=New Shader( LoadString( "cerberus://data/mojo2_mojo1shader.glsl" ) )
	fastShader=New Shader( LoadString( "cerberus://data/mojo2_fastshader.glsl" ) )
	bumpShader=New BumpShader( LoadString( "cerberus://data/mojo2_bumpshader.glsl" ) )
	matteShader=New MatteShader( LoadString( "cerberus://data/mojo2_matteshader.glsl" ) )
	shadowShader=New Shader( LoadString( "cerberus://data/mojo2_shadowshader.glsl" ) )
	lightMapShader=New Shader( LoadString( "cerberus://data/mojo2_lightmapshader.glsl" ) )
	defaultShader=bumpShader
	
	defaultFont=Font.Load( "cerberus://data/mojo2_font.png",32,96,True )'9,13,1,0,7,13,32,96 )
	If Not defaultFont Error "Can't load default font"
	
	flipYMatrix[5]=-1
End

Class RefCounted

	Method Retain:Void()
		If _refs<=0 Error "Internal error"
		_refs+=1
	End
	
	Method Release:Void()
		If _refs<=0 Error "Internal error"
		_refs-=1
		If _refs Return
		_refs=-1
		Destroy
	End
	
	Method Destroy:Void() Abstract
	
Private

	Field _refs:=1
End

Function KludgePath:String( path:String )
	If path.StartsWith( "." ) Or path.StartsWith( "/" ) Return path
	Local i:=path.Find( ":/" )
	If i<>-1 And path.Find("/")=i+1 Return path
	Return "cerberus://data/"+path
End

Public

Function CrashGraphics:Void()
	If GraphicsCanCrash graphicsSeq+=1
End

'***** Texture *****

Class Texture Extends RefCounted

	'flags
	Const Filter:=1
	Const Mipmap:=2
	Const ClampS:=4
	Const ClampT:=8
	Const ClampST:=12
	Const RenderTarget:=16
	Const Managed:=256

	Method New( width:Int,height:Int,format:Int,flags:Int )
		Init width,height,format,flags
		
		If _flags & Managed
			Local data:=New DataBuffer( width*height*4 )
			For Local i:=0 Until width*height*4 Step 4
				data.PokeInt i,$ffff00ff
			Next
			_data=data
		Endif
'		Print "Created texture"
	End
	
	Method Destroy:Void()
'		Print "Destroying texture"
		If _seq=graphicsSeq 
			If _glTexture glDeleteTexture _glTexture
			If _glFramebuffer glDeleteFramebuffer _glFramebuffer
		Endif
		_glTexture=0
		_glFramebuffer=0
	End
	
	Method Validate:Void()
		If _seq=graphicsSeq Return
		Init
		If _data LoadData _data
	End
	
	Method Width:Int() Property
		Return _width
	End
	
	Method Height:Int() Property
		Return _height
	End
	
	Method Format:Int() Property
		Return _format
	End
	
	Method Flags:Int() Property
		Return _flags
	End
	
	Method WritePixels:Void( x:Int,y:Int,width:Int,height:Int,data:DataBuffer,dataOffset:Int=0,dataPitch:Int=0 )

		glPushTexture2d GLTexture
	
		If Not dataPitch Or dataPitch=width*4
		
			glTexSubImage2D GL_TEXTURE_2D,0,x,y,width,height,GL_RGBA,GL_UNSIGNED_BYTE,data,dataOffset
			
		Else
			For Local iy:=0 Until height
				glTexSubImage2D GL_TEXTURE_2D,0,x,y+iy,width,1,GL_RGBA,GL_UNSIGNED_BYTE,data,dataOffset+iy*dataPitch
			Next
		Endif
		
		glPopTexture2d
		
		If _flags & Managed
		
			Local texPitch:=_width*4
			If Not dataPitch dataPitch=width*4
			
			For Local iy:=0 Until height
				data.CopyBytes( dataOffset+iy*dataPitch,DataBuffer( _data ),(y+iy)*texPitch+x*4,width*4 )
			Next
			
		Endif

	End
	
	Method UpdateMipmaps:Void()
		If Not (_flags & Mipmap) Return
		
		If _seq<>graphicsSeq Return 	'we're boned!

		glPushTexture2d GLTexture

		glGenerateMipmap GL_TEXTURE_2D
		
		glPopTexture2d
	End
	
	Method Loading:Bool() Property
		#If TARGET="html5"
			Return GLTextureLoading( _glTexture )
		#Else
			Return False
		#Endif
	End
	
	Method GLTexture:Int() Property
		Validate
		Return _glTexture
	End
	
	Method GLFramebuffer:Int() Property
		Validate
		Return _glFramebuffer
	End		
	
	Function TexturesLoading:Int()
		#If TARGET="html5"
			Return GLTexturesLoading()
		#Else
			Return 0
		#Endif
	End
	
	Function Load:Texture( path:String,format:Int=4,flags:Int=Filter|Mipmap|ClampST )
	
		Local info:Int[2]
		
#If TARGET="glfw" Or TARGET="ios"

		Local data:=LoadImageData( KludgePath( path ),info )		'data is a databuffer

		If data		
			For Local i:=0 Until data.Length Step 4
				Local t:=data.PeekInt( i )
				Local a:=(t Shr 24 & 255)
				Local b:=(t Shr 16 & 255)*a/255
				Local g:=(t Shr 8 & 255)*a/255
				Local r:=(t & 255)*a/255
				data.PokeInt i,a Shl 24 | b Shl 16 | g Shl 8 | r
			Next
		Endif
#Else
		Local data:=LoadStaticTexImage( KludgePath( path ),info )	'data is an Image/Bitmap
#Endif

		If Not data 
'			Print "Texture.Load - LoadImageData failed: path="+path
			Return Null
		Endif
		
		Local tex:=New Texture( info[0],info[1],format,flags,data )
		
#If TARGET="glfw" Or TARGET="ios"
		If Not tex._data data.Discard
#Endif		

		Return tex
	End
	
	Function Color:Texture( color:Int )
		Local tex:=_colors.Get( color )
		If tex Return tex
		Local data:=New DataBuffer( 4 )
		data.PokeInt 0,color
		tex=New Texture( 1,1,4,ClampST,data )
#If TARGET="glfw" Or TARGET="ios"
		If Not tex._data data.Discard
#Endif		
		_colors.Set color,tex
		Return tex
	End
	
	Function Black:Texture()
		If Not _black _black=Color( $ff000000 )
		Return _black
	End
	
	Function White:Texture()
		If Not _white _white=Color( $ffffffff )
		Return _white
	End
	
	Function Magenta:Texture()
		If Not _magenta _magenta=Color( $ffff00ff )
		Return _magenta
	End
	
	Function Flat:Texture()
		If Not _flat _flat=Color( $ff888888 )
		Return _flat
	End
	
	Private
	
	Global _colors:=New IntMap<Texture>
	Global _black:Texture
	Global _white:Texture
	Global _magenta:Texture
	Global _flat:Texture
	
	Field _seq:Int
	Field _width:Int
	Field _height:Int
	Field _format:Int
	Field _flags:Int
	Field _data:Object
	Field _glTexture:Int
	Field _glFramebuffer:Int
	
	Method New( width:Int,height:Int,format:Int,flags:Int,data:Object )
		Init width,height,format,flags
		
		LoadData data
		
		If GraphicsCanCrash
			_data=data
		Endif
	End
	
	Method Init:Void( width:Int,height:Int,format:Int,flags:Int )
		InitMojo2

		'TODO: more tex formats
		If format<>4 Error "Invalid texture format: "+format

		#If TARGET<>"glfw"
			'can't mipmap NPOT textures on gles20
			If Not IsPow2( width ) Or Not IsPow2( height ) flags&=~Mipmap
		#Endif
		
		If Not GraphicsCanCrash
			_flags&=~Managed
		Endif
	
		_width=width
		_height=height
		_format=format
		_flags=flags
		
		Init
	End
	
	Method Init:Void()
	
		_seq=graphicsSeq
	
		_glTexture=glCreateTexture()
		
		glPushTexture2d _glTexture
		
		If _flags & Filter
			glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR
		Else
			glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST
		Endif
		If (_flags & Mipmap) And (_flags & Filter)
			glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_LINEAR
		Else If _flags & Mipmap
			glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST_MIPMAP_NEAREST
		Else If _flags & Filter
			glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR
		Else
			glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST
		Endif

		If _flags & ClampS glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE
		If _flags & ClampT glTexParameteri GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE

		glTexImage2D GL_TEXTURE_2D,0,GL_RGBA,_width,_height,0,GL_RGBA,GL_UNSIGNED_BYTE,Null

		glPopTexture2d
		
		If _flags & RenderTarget
		
			_glFramebuffer=glCreateFramebuffer()
			
			glPushFramebuffer _glFramebuffer
			
			glBindFramebuffer GL_FRAMEBUFFER,_glFramebuffer
			glFramebufferTexture2D GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D,_glTexture,0
			
			If glCheckFramebufferStatus( GL_FRAMEBUFFER )<>GL_FRAMEBUFFER_COMPLETE Error "Incomplete framebuffer"
			
			glPopFramebuffer
		Endif
		
	End
	
	Method LoadData:Void( data:Object )
		glPushTexture2d GLTexture
		
#If TARGET="glfw" Or TARGET="ios"
		glTexImage2D GL_TEXTURE_2D,0,GL_RGBA,_width,_height,0,GL_RGBA,GL_UNSIGNED_BYTE,DataBuffer( data )
#Else
		If DataBuffer( data )
			glTexImage2D GL_TEXTURE_2D,0,GL_RGBA,_width,_height,0,GL_RGBA,GL_UNSIGNED_BYTE,DataBuffer( data )
		Else
			glTexImage2D GL_TEXTURE_2D,0,GL_RGBA,GL_RGBA,GL_UNSIGNED_BYTE,data
		Endif
#Endif
		glPopTexture2d
		
		UpdateMipmaps
	End
	
End

'***** Shader ****

Private

Class GLUniform
	Field name:String
	Field location:Int
	Field size:Int
	Field type:Int
	
	Method New( name:String,location:Int,size:Int,type:Int )
		Self.name=name
		Self.location=location
		Self.size=size
		Self.type=type
	End
	
End

Class GLProgram
	Field program:Int
	'material uniforms
	Field matuniforms:GLUniform[]
	'hard coded uniform locations
	Field mvpMatrix:Int
	Field mvMatrix:Int
	Field clipPosScale:Int
	Field globalColor:int
	Field ambientLight:Int
	Field fogColor:int
	Field lightColors:Int
	Field lightVectors:Int
	Field shadowTexture:Int
	
	Method New( program:Int,matuniforms:GLUniform[] )
		Self.program=program
		Self.matuniforms=matuniforms
		mvpMatrix=glGetUniformLocation( program,"ModelViewProjectionMatrix" )
		mvMatrix=glGetUniformLocation( program,"ModelViewMatrix" )
		clipPosScale=glGetUniformLocation( program,"ClipPosScale" )
		globalColor=glGetUniformLocation( program,"GlobalColor" )
		fogColor=glGetUniformLocation( program,"FogColor" )
		ambientLight=glGetUniformLocation( program,"AmbientLight" )
		lightColors=glGetUniformLocation( program,"LightColors" )
		lightVectors=glGetUniformLocation( program,"LightVectors" )
		shadowTexture=glGetUniformLocation( program,"ShadowTexture" )
		
	End
	
	Method Bind:Void()
	
		glUseProgram program
		
		If mvpMatrix<>-1 glUniformMatrix4fv mvpMatrix,1,False,rs_modelViewProjMatrix
		If mvMatrix<>-1 glUniformMatrix4fv mvMatrix,1,False,rs_modelViewMatrix
		If clipPosScale<>-1 glUniform4fv clipPosScale,1,rs_clipPosScale
		If globalColor<>-1 glUniform4fv globalColor,1,rs_globalColor
		If fogColor<>-1 glUniform4fv fogColor,1,rs_fogColor
		If ambientLight<>-1 glUniform4fv ambientLight,1,rs_ambientLight
		If lightColors<>-1 glUniform4fv lightColors,rs_numLights,rs_lightColors
		If lightVectors<>-1 glUniform4fv lightVectors,rs_numLights,rs_lightVectors

		glActiveTexture GL_TEXTURE0+7
		If shadowTexture<>-1 And rs_shadowTexture
			glBindTexture GL_TEXTURE_2D,rs_shadowTexture.GLTexture
			glUniform1i shadowTexture,7
		Else
			glBindTexture GL_TEXTURE_2D,Texture.White().GLTexture
		End
		glActiveTexture GL_TEXTURE0
	End
	
End

Public

Class Shader

	Method New( source:String )
		Build source
	End
	
	Method DefaultMaterial:Material()
		If Not _defaultMaterial _defaultMaterial=New Material( Self )
		Return _defaultMaterial
	End

	Function Mojo1Shader:Shader()
		Return mojo1Shader
	End

	Function FastShader:Shader()
		Return fastShader
	End
	
	Function BumpShader:Shader()
		Return bumpShader
	End
	
	Function MatteShader:Shader()
		Return matteShader
	End
	
	Function ShadowShader:Shader()
		Return shadowShader
	End
	
	Function LightMapShader:Shader()
		Return lightMapShader
	End
	
	Function DefaultShader:Shader()
		Return defaultShader
	End
	
	Function SetDefaultShader:Void( shader:Shader )
		If Not shader shader=bumpShader
		defaultShader=shader
	End
	
	Protected
	
	Method Build:Void( source:String )
		_source=source
		Build
	End
	
	Method OnInitMaterial:Void( material:Material )
		material.SetTexture "ColorTexture",Texture.White()
	End
	
	Method OnLoadMaterial:Material( material:Material,path:String,texFlags:Int )
		Local texture:=Texture.Load( path,4,texFlags )
		If Not texture Return Null
		material.SetTexture "ColorTexture",texture
		If texture texture.Release
		Return material
	End
	
	Private
	
	Const MAX_FLAGS:=8
	
	Field _seq:Int
	Field _source:String
	
	Field _vsource:String
	Field _fsource:String
	Field _uniforms:=New StringSet
	
	Field _glPrograms:GLProgram[MAX_LIGHTS+1]
	
	Field _defaultMaterial:Material
	
	Method Bind:Void()	
		Local program:=GLProgram()
		
		If program=rs_program Return

		rs_program=program
		rs_material=Null
		
		program.Bind
	End
	
	Method GLProgram:GLProgram() Property
	
		If _seq<>graphicsSeq 
			_seq=graphicsSeq
			rs_program=Null
			Build
		Endif
		
		Return _glPrograms[rs_numLights]
	End
	
	Method Build:GLProgram( numLights:Int )
	
		Local defs:=""
		defs+="#define NUM_LIGHTS "+numLights+"~n"
		
		Local vshader:=glCompile( GL_VERTEX_SHADER,defs+_vsource )
		Local fshader:=glCompile( GL_FRAGMENT_SHADER,defs+_fsource )
		
		Local program:=glCreateProgram()
		glAttachShader program,vshader
		glAttachShader program,fshader
		glDeleteShader vshader
		glDeleteShader fshader
		
		glBindAttribLocation program,0,"Position"
		glBindAttribLocation program,1,"Texcoord0"
		glBindAttribLocation program,2,"Tangent"
		glBindAttribLocation program,3,"Color"
		
		glLink program
		
		'enumerate program uniforms	
		Local matuniforms:=New Stack<GLUniform>
		Local size:Int[1],type:Int[1],name:String[1]
		glGetProgramiv program,GL_ACTIVE_UNIFORMS,tmpi
		For Local i:=0 Until tmpi[0]

			glGetActiveUniform program,i,size,type,name
			
			If _uniforms.Contains( name[0] )
			
				Local location:=glGetUniformLocation( program,name[0] )
				If location=-1 Continue  'IE fix...
				
				matuniforms.Push New GLUniform( name[0],location,size[0],type[0] )
				
'				Print "New GLUniform: name="+name[0]+", location="+location+", size="+size[0]+", type="+type[0]
			Endif
		Next
		
		Return New GLProgram( program,matuniforms.ToArray() )
	
	End
	
	Method Build:Void()
		InitMojo2
		
		Local p:=New GlslParser( _source )
		
		Local vars:=New StringSet
		
		While p.Toke
		
			If p.CParse( "uniform" )
				'uniform decl
				Local ty:=p.ParseType()
				Local id:=p.ParseIdent()
				p.Parse ";"
				_uniforms.Insert id
'				Print "uniform "+ty+" "+id+";"
				Continue
			Endif
			
			Local id:=p.CParseIdent()
			If id
				If id.StartsWith( "gl_" )
					vars.Insert "B3D_"+id.ToUpper()
				Else If id.StartsWith( "b3d_" ) 
					vars.Insert id.ToUpper()
				Endif
				Continue
			Endif
			
			p.Bump
		Wend
		
		Local vardefs:=""
		For Local var:=Eachin vars
			vardefs+="#define "+var+" 1~n"
		Next
		
'		Print "Vardefs:";Print vardefs
		
		Local source:=mainShader
		Local i0:=source.Find( "//@vertex" )
		If i0=-1 Error "Can't find //@vertex chunk"
		Local i1:=source.Find( "//@fragment" )
		If i1=-1 Error "Can't find //@fragment chunk"
		
		Local header:=vardefs+source[..i0]
		_vsource=header+source[i0..i1]
		_fsource=header+source[i1..].Replace( "${SHADER}",_source )
		
		For Local numLights:=0 To MAX_LIGHTS
		
			_glPrograms[numLights]=Build( numLights )

			If numLights Or vars.Contains( "B3D_DIFFUSE" ) Or vars.Contains( "B3D_SPECULAR" ) Continue
			
			For Local i:=1 To MAX_LIGHTS
				_glPrograms[i]=_glPrograms[0]
			Next
			
			Exit
			
		Next
		
		
	End
	
End

Class BumpShader Extends Shader

	Method New( source:String )
		Super.New( source )
	End

	Protected
	
	Method OnInitMaterial:Void( material:Material )
		material.SetTexture "ColorTexture",Texture.White()
		material.SetTexture "SpecularTexture",Texture.Black()
		material.SetTexture "NormalTexture",Texture.Flat()
		material.SetVector "AmbientColor",[1.0,1.0,1.0,1.0]
		material.SetScalar "Roughness",1.0
	End
	
	Method OnLoadMaterial:Material( material:Material,path:String,texFlags:Int )
	
		Local format:=4
	
		Local ext:=ExtractExt( path )
		If ext path=StripExt( path ) Else ext="png"
		
		Local colorTex:=Texture.Load( path+"."+ext,format,texFlags )
		If Not colorTex colorTex=Texture.Load( path+"_d."+ext,format,texFlags )
		If Not colorTex colorTex=Texture.Load( path+"_diff."+ext,format,texFlags )
		If Not colorTex colorTex=Texture.Load( path+"_diffuse."+ext,format,texFlags )
		
		Local specularTex:=Texture.Load( path+"_s."+ext,format,texFlags )
		If Not specularTex specularTex=Texture.Load( path+"_spec."+ext,format,texFlags )
		If Not specularTex specularTex=Texture.Load( path+"_specular."+ext,format,texFlags )
		If Not specularTex specularTex=Texture.Load( path+"_SPECULAR."+ext,format,texFlags )
		
		Local normalTex:=Texture.Load( path+"_n."+ext,format,texFlags )
		If Not normalTex normalTex=Texture.Load( path+"_norm."+ext,format,texFlags )
		If Not normalTex normalTex=Texture.Load( path+"_normal."+ext,format,texFlags )
		If Not normalTex normalTex=Texture.Load( path+"_NORMALS."+ext,format,texFlags )
		
		If Not colorTex And Not specularTex And Not normalTex Return Null
		
		material.SetTexture "ColorTexture",colorTex
		material.SetTexture "SpecularTexture",specularTex
		material.SetTexture "NormalTexture",normalTex
		
		If specularTex Or normalTex
			material.SetVector "AmbientColor",[0.0,0.0,0.0,1.0]
			material.SetScalar "Roughness",.5
		Endif
		
		If colorTex colorTex.Release
		If specularTex specularTex.Release
		If normalTex normalTex.Release
		
		Return material
	End
	
End	

Class MatteShader Extends Shader

	Method New( source:String )
		Super.New( source )
	End
	
	Protected
	
	Method OnInitMaterial:Void( material:Material )
		material.SetTexture "ColorTexture",Texture.White()
		material.SetVector "AmbientColor",[0.0,0.0,0.0,1.0]
		material.SetScalar "Roughness",1.0
	End
	
End

'***** Material *****

Class Material Extends RefCounted

	Method New( shader:Shader=Null )
		InitMojo2
		
		If Not shader shader=defaultShader
		_shader=shader
		_shader.OnInitMaterial( Self )
		_inited=True
	End
	
	Method Discard:Void()
		Super.Release()
	End
	
	Method Destroy:Void()
		For Local tex:=Eachin _textures
			tex.Value.Release
		Next
	End
	
	Method Shader:Shader() Property
		Return _shader
	End
	
	Method ColorTexture:Texture() Property
		Return _colorTexture
	End
	
	Method Width:Int() Property
		If _colorTexture Return _colorTexture._width
		Return 0
	End
	
	Method Height:Int() Property
		If _colorTexture Return _colorTexture._height
		Return 0
	End
	
	Method SetScalar:Void( param:String,scalar:Float )
		If _inited And Not _scalars.Contains( param ) Return
		_scalars.Set param,scalar
	End
	
	Method GetScalar:Float( param:String,defValue:Float=1.0 )
		If Not _scalars.Contains( param ) Return defValue
		Return _scalars.Get( param )
	End
	
	Method SetVector:Void( param:String,vector:Float[] )
		If _inited And Not _vectors.Contains( param ) Return
		_vectors.Set param,vector
	End
	
	Method GetVector:Float[]( param:String,defValue:Float[]=[1.0,1.0,1.0,1.0] )
		If Not _vectors.Contains( param ) Return defValue
		Return _vectors.Get( param )
	End
	
	Method SetTexture:Void( param:String,texture:Texture )
		If Not texture Return
		If _inited And Not _textures.Contains( param ) Return
		
		Local old:=_textures.Get( param )
		texture.Retain
		_textures.Set param,texture
		If old old.Release
		
		If param="ColorTexture" _colorTexture=texture
		
	End
	
	Method GetTexture:Texture( param:String,defValue:Texture=Null )
		If Not _textures.Contains( param ) Return defValue
		Return _textures.Get( param )
	End
	
	Method Loading:Bool()
		#If TARGET="html5"
			For Local it:=Eachin _textures
				If it.Value.Loading Return True
			Next
		#Endif
		Return False
	End
	
	Function Load:Material( path:String,texFlags:Int,shader:Shader )
	
		Local material:=New Material( shader )

		material=material.Shader.OnLoadMaterial( material,path,texFlags )
		
		Return material
	End
	
	Private
	
	Field _shader:Shader
	Field _colorTexture:Texture
	Field _scalars:=New StringMap<Float>
	Field _vectors:=New StringMap<Float[]>
	Field _textures:=New StringMap<Texture>
	Field _inited:Bool
	
	Method Bind:Bool()
	
		_shader.Bind
		
		If rs_material=Self Return True
		
		rs_material=Self
	
		Local texid:=0
		
		For Local u:=Eachin rs_program.matuniforms
			Select u.type
			Case GL_FLOAT
				glUniform1f u.location,GetScalar( u.name )
			Case GL_FLOAT_VEC4
				glUniform4fv u.location,1,GetVector( u.name )
			Case GL_SAMPLER_2D
				Local tex:=GetTexture( u.name )
				If tex.Loading
					rs_material=Null 
					Exit
				Endif
				glActiveTexture GL_TEXTURE0+texid
				glBindTexture GL_TEXTURE_2D,tex.GLTexture
				glUniform1i u.location,texid
				texid+=1
			Default
				Error "Unsupported uniform type: name="+u.name+", location="+u.location+", size="+u.size+", type="+u.type
			End
		Next
		
'		For Local i:=texid Until 8
'			glActiveTexture GL_TEXTURE0+i
'			glBindTexture GL_TEXTURE_2D,Texture.White().GLTexture
'		Next

		If texid glActiveTexture GL_TEXTURE0
		
		Return rs_material=Self
	End
	
End

'***** ShaderCaster *****

Class ShadowCaster

	Method New()
	End

	Method New( verts:Float[],type:Int )
		_verts=verts
		_type=type
	End
	
	Method SetVertices:Void( vertices:Float[] )
		_verts=vertices
	End
	
	Method Vertices:Float[]() Property
		Return _verts
	End
	
	Method SetType:Void( type:Int )
		_type=type
	End
	
	Method Type:Int() Property
		Return _type
	End
	
	Private
	
	Field _verts:Float[]
	Field _type:Int
	
End

'***** Image *****

'  Class Image
'  
'  	Const MidHandle:Int = 1
'  	Const XPadding:Int = 2
'  	Const YPadding:Int = 4
'  	Const XYPadding:Int = XPadding | YPadding
'  	Global DefaultFlags:Int = 0
'  
'  	Const Filter:=Texture.Filter
'  	Const Mipmap:=Texture.Mipmap
'  	Const Managed:=Texture.Managed
'  	
'  	Method New( width:Int,height:Int,xhandle:Float=.5,yhandle:Float=.5,flags:Int=Image.Filter )
'  		flags&=_flagsMask
'  		Local texture:=New Texture( width,height,4,flags|Texture.ClampST|Texture.RenderTarget )
'  		_material=New Material( fastShader )
'  		_material.SetTexture "ColorTexture",texture
'  		texture.Release()
'  		_width=width
'  		_height=height
'  		SetHandle xhandle,yhandle
'  	End
'  	
'  	Method New( image:Image,x:Int,y:Int,width:Int,height:Int,xhandle:Float=.5,yhandle:Float=.5 )
'  		_material=image._material
'  		_x=image._x+x
'  		_y=image._y+y
'  		_width=width
'  		_height=height
'  		SetHandle xhandle,yhandle
'  	End
'  	
'  	Method New( material:Material,xhandle:Float=.5,yhandle:Float=.5 )
'  		Local texture:=material.ColorTexture
'  		If Not texture Error "Material has no ColorTexture"
'  		_material=material
'  		_width=_material.Width
'  		_height=_material.Height
'  		SetHandle xhandle,yhandle
'  	End
'  
'  	Method New( material:Material,x:Int,y:Int,width:Int,height:Int,xhandle:Float=.5,yhandle:Float=.5 )
'  		Local texture:=material.ColorTexture
'  		If Not texture Error "Material has no ColorTexture"
'  		_material=material
'  		_x=x
'  		_y=y
'  		_width=width
'  		_height=height
'  		SetHandle xhandle,yhandle
'  	End
'  
'  	Method Discard:Void()
'  		If _material _material.Release
'  		_material=Null
'  	End
'  	
'  	Method Material:Material() Property
'  		Return _material
'  	End
'  	
'  	Method X0:Float() Property
'  		Return _x0
'  	End
'  	
'  	Method Y0:Float() Property
'  		Return _y0
'  	End
'  	
'  	Method X1:Float() Property
'  		Return _x1
'  	End
'  	
'  	Method Y1:Float() Property
'  		Return _y1
'  	End
'  	
'  	Method Width:Int() Property
'  		Return _width
'  	End
'  	
'  	Method Height:Int() Property
'  		Return _height
'  	End
'  	
'  	Method HandleX:Float() Property
'  		Return -_x0/(_x1-_x0)
'  	End
'  	
'  	Method HandleY:Float() Property
'  		Return -_y0/(_y1-_y0)
'  	End
'  	
'  	Method WritePixels:Void( x:Int,y:Int,width:Int,height:Int,data:DataBuffer,dataOffset:Int=0,dataPitch:Int=0 )
'  		_material.ColorTexture.WritePixels( x+_x,y+_y,width,height,data,dataOffset,dataPitch )
'  	End
'  	
'  	Method SetHandle:Void( xhandle:Float,yhandle:Float )
'  		_x0=Float(_width)*-xhandle
'  		_x1=Float(_width)*(1-xhandle)
'  		_y0=Float(_height)*-yhandle
'  		_y1=Float(_height)*(1-yhandle)
'  		_s0=Float(_x)/Float(_material.Width)
'  		_t0=Float(_y)/Float(_material.Height)
'  		_s1=Float(_x+_width)/Float(_material.Width)
'  		_t1=Float(_y+_height)/Float(_material.Height)
'  	End
'  	
'  	Method SetShadowCaster:Void( shadowCaster:ShadowCaster )
'  		_caster=shadowCaster
'  	End
'  	
'  	Method ShadowCaster:ShadowCaster() Property
'  		Return _caster
'  	End
'  	
'  	Method Loading:Bool()
'  		Return _material.Loading()
'  	End
'  	
'  	Function ImagesLoading:Bool()
'  		Return Texture.TexturesLoading>0
'  	End
'  	
'  	Function SetFlagsMask:Void( mask:Int )
'  		_flagsMask=mask
'  	End
'  	
'  	Function FlagsMask:Int()
'  		Return _flagsMask
'  	End
'  	
'  	Function Load:Image( path:String,xhandle:Float=.5,yhandle:Float=.5,flags:Int=Image.Filter|Image.Mipmap,shader:Shader=Null )
'  		flags&=_flagsMask
'  	
'  		Local material:=.Material.Load( path,flags|Texture.ClampST,shader )
'  		If Not material 
'  			DebugLog ("Error - Unable to load image: " + path)
'  			Return Null
'  		Endif
'  
'  		Return New Image( material,xhandle,yhandle )
'  	End
'  	
'  	Function LoadFrames:Image[]( path:String,numFrames:Int,padded:Bool=False,xhandle:Float=.5,yhandle:Float=.5,flags:Int=Image.Filter|Image.Mipmap,shader:Shader=Null )
'  		flags&=_flagsMask
'  	
'  		Local material:=.Material.Load( path,flags|Texture.ClampST,shader )
'  		If Not material 
'  			DebugLog ("Error - Unable to load image frames: " + path)
'  			Return []
'  		Endif
'  		
'  		Local cellWidth:=material.Width/numFrames,cellHeight:=material.Height
'  		
'  		Local x:=0,width:=cellWidth
'  		If padded x+=1;width-=2
'  		
'  		Local frames:=New Image[numFrames]
'  		
'  		For Local i:=0 Until numFrames
'  			frames[i]=New Image( material,i*cellWidth+x,0,width,cellHeight,xhandle,yhandle )
'  		Next
'  		
'  		Return frames
'  	End
'  	
'  	Private
'  	
'  	Global _flagsMask:=Filter|Mipmap|Managed
'  	
'  	Field _material:Material
'  	Field _x:Int,_y:Int,_width:Int,_height:Int
'  	Field _x0:Float=-1,_y0:Float=-1,_x1:Float=1,_y1:Float=1
'  	Field _s0:Float=0 ,_t0:Float=0 ,_s1:Float=1,_t1:Float=1
'  
'  	Field _caster:ShadowCaster
'  	
'  '	Method SetFrame:Void( x0:Float,y0:Float,x1:Float,y1:Float,s0:Float,t0:Float,s1:Float,t1:Float )
'  '		_x0=x0;_y0=y0;_x1=x1;_y1=y1
'  '		_s0=s0;_t0=t0;_s1=s1;_t1=t1
'  '	End
'  	
'  End

'  Class Image
'  
'  	Const MidHandle:Int = 1
'  	Const XPadding:Int = 2
'  	Const YPadding:Int = 4
'  	Const XYPadding:Int = XPadding | YPadding
'  	Global DefaultFlags:Int = 0
'  
'  	Const Filter:=Texture.Filter
'  	Const Mipmap:=Texture.Mipmap
'  	Const Managed:=Texture.Managed
'  	
'  	Method New( width:Int,height:Int,xhandle:Float=.5,yhandle:Float=.5,flags:Int=Image.Filter )
'  		Print "Image width=" + width + " height=" + height
'  		flags&=_flagsMask
'  		Local texture:=New Texture( width,height,4,flags|Texture.ClampST|Texture.RenderTarget )
'  		_material=New Material( fastShader )
'  '  		_material=New Material( mojo1Shader )
'  		_material.SetTexture "ColorTexture",texture
'  		texture.Release()
'  		_width=width
'  		_height=height
'  		SetHandlef xhandle,yhandle
'  	End
'  	
'  	Method New( image:Image,x:Int,y:Int,width:Int,height:Int,xhandle:Float=.5,yhandle:Float=.5 )
'  		_material=image._material
'  		_x=image._x+x
'  		_y=image._y+y
'  		_width=width
'  		_height=height
'  		SetHandlef xhandle,yhandle
'  	End
'  	
'  	Method New( material:Material,xhandle:Float=.5,yhandle:Float=.5 )
'  		Local texture:=material.ColorTexture
'  		If Not texture Error "Material has no ColorTexture"
'  		_material=material
'  		_width=_material.Width
'  		_height=_material.Height
'  		SetHandlef xhandle,yhandle
'  	End
'  
'  	Method New( material:Material,x:Int,y:Int,width:Int,height:Int,xhandle:Float=.5,yhandle:Float=.5 )
'  		Local texture:=material.ColorTexture
'  		If Not texture Error "Material has no ColorTexture"
'  		_material=material
'  		_x=x
'  		_y=y
'  		_width=width
'  		_height=height
'  		SetHandlef xhandle,yhandle
'  	End
'  
'  	Method Discard:Void()
'  		If _material _material.Release
'  		_material=Null
'  	End
'  	
'  	Method Material:Material() Property
'  		Return _material
'  	End
'  	
'  	Method X0:Float() Property
'  		Return _x0
'  	End
'  	
'  	Method Y0:Float() Property
'  		Return _y0
'  	End
'  	
'  	Method X1:Float() Property
'  		Return _x1
'  	End
'  	
'  	Method Y1:Float() Property
'  		Return _y1
'  	End
'  	
'  	Method Width:Int() Property
'  		Return _width
'  	End
'  	
'  	Method Height:Int() Property
'  		Return _height
'  	End
'  	
'  	Method HandleXf:Float() Property
'  		Return -_x0/(_x1-_x0)
'  	End
'  	
'  	Method HandleYf:Float() Property
'  		Return -_y0/(_y1-_y0)
'  	End
'  
'  	Method HandleX:Float() Property
'  		Return HandleXf * _width
'  	End
'  	
'  	Method HandleY:Float() Property
'  		Return HandleYf * _height
'  	End
'  	
'  	Method WritePixels:Void( x:Int,y:Int,width:Int,height:Int,data:DataBuffer,dataOffset:Int=0,dataPitch:Int=0 )
'  		_material.ColorTexture.WritePixels( x+_x,y+_y,width,height,data,dataOffset,dataPitch )
'  	End
'  
'  	Method WritePixels:Void( pixels:Int[], x:Int, y:Int, width:Int, height:Int, arrayOffset:Int=0, arrayPitch:Int=0, frame:Int=0 )
'  
'  		' TODO frame
'  
'  		Local address:Int = 0
'  
'  		Local length:Int = pixels.Length()
'  		Local data:DataBuffer = New DataBuffer( length * 4 )
'  		
'  		For Local i:Int = 0 Until length
'  			Local pixel:Int = pixels[ i ]
'  			Local alpha:Int = (pixel & $ff000000)
'  			Local red:Int = (pixel & $00ff0000) Shr 16
'  			Local green:Int = (pixel & $0000ff00)
'  			Local blue:Int = (pixel & $000000ff) Shl 16
'  			Local rgba:Int = alpha | blue | green | red
'  			data.PokeInt( address, rgba )
'  			address += 4
'  		Next
'  
'  		WritePixels( x, y, width, height, data, arrayOffset*4, arrayPitch*4 )
'  
'  		data.Discard()
'  	End
'  
'  	Method SetHandlef:Void( xhandle:Float,yhandle:Float )
'  		_x0=Float(_width)*-xhandle
'  		_x1=Float(_width)*(1-xhandle)
'  		_y0=Float(_height)*-yhandle
'  		_y1=Float(_height)*(1-yhandle)
'  		_s0=Float(_x)/Float(_material.Width)
'  		_t0=Float(_y)/Float(_material.Height)
'  		_s1=Float(_x+_width)/Float(_material.Width)
'  		_t1=Float(_y+_height)/Float(_material.Height)
'  	End
'  
'  '  	Method SetHandle:Void( xhandle:Float,yhandle:Float )
'  	Method SetHandle:Void( tx:Float,ty:Float )
'  		SetHandlef( tx / _width, ty / _height )
'  	End
'  	
'  	Method SetShadowCaster:Void( shadowCaster:ShadowCaster )
'  		_caster=shadowCaster
'  	End
'  	
'  	Method ShadowCaster:ShadowCaster() Property
'  		Return _caster
'  	End
'  	
'  	Method Loading:Bool()
'  		Return _material.Loading()
'  	End
'  	
'  	Function ImagesLoading:Bool()
'  		Return Texture.TexturesLoading>0
'  	End
'  	
'  	Function SetFlagsMask:Void( mask:Int )
'  		_flagsMask=mask
'  	End
'  	
'  	Function FlagsMask:Int()
'  		Return _flagsMask
'  	End
'  	
'  	Function Load:Image( path:String,xhandle:Float=.5,yhandle:Float=.5,flags:Int=Image.Filter|Image.Mipmap,shader:Shader=Null )
'  		flags&=_flagsMask
'  	
'  		Local material:=.Material.Load( path,flags|Texture.ClampST,shader )
'  		If Not material 
'  			DebugLog ("Error - Unable to load image: " + path)
'  			Return Null
'  		Endif
'  
'  		Return New Image( material,xhandle,yhandle )
'  	End
'  	
'  	Function LoadFrames:Image[]( path:String,numFrames:Int,padded:Bool=False,xhandle:Float=.5,yhandle:Float=.5,flags:Int=Image.Filter|Image.Mipmap,shader:Shader=Null )
'  		flags&=_flagsMask
'  	
'  		Local material:=.Material.Load( path,flags|Texture.ClampST,shader )
'  		If Not material 
'  			DebugLog ("Error - Unable to load image frames: " + path)
'  			Return []
'  		Endif
'  		
'  		Local cellWidth:=material.Width/numFrames,cellHeight:=material.Height
'  		
'  		Local x:=0,width:=cellWidth
'  		If padded x+=1;width-=2
'  		
'  		Local frames:=New Image[numFrames]
'  		
'  		For Local i:=0 Until numFrames
'  			frames[i]=New Image( material,i*cellWidth+x,0,width,cellHeight,xhandle,yhandle )
'  		Next
'  		
'  		Return frames
'  	End
'  
'  '  	Method InitMojo1Image:Void( frameCount:Int, mojo1Flags:Int, xhandle:Float, yhandle:Float )
'  '  
'  '  		' default frame count is 1
'  '  		If frameCount <= 0 Then
'  '  			frameCount = 1
'  '  		Endif
'  '  
'  '  		_frameCount = frameCount
'  '  		_width /= frameCount
'  '  		_frameWidth = _width
'  '  
'  '  		_frames0 = New Float[ _frameCount ]
'  '  		_frames1 = New Float[ _frameCount ]
'  '  
'  '  		If mojo1Flags & XPadding Then
'  '  			_x += 1
'  '  			_width -= 2
'  '  		Endif
'  '  
'  '  		If mojo1Flags & YPadding Then
'  '  			_y += 1
'  '  			_height -= 2
'  '  		Endif
'  '  
'  '  		SetHandlef( xhandle, yhandle )
'  '  
'  '  		For Local frame:Int = 0 Until _frameCount
'  '  			_frames0[ frame ]=Float(_x+frame*_frameWidth)/Float(_material.Width)
'  '  			_frames1[ frame ]=Float(_x+_width+frame*_frameWidth)/Float(_material.Width)
'  '  		Next
'  '  	End
'  
'  	Method InitMojo1Image:Void( frameWidth:Int, frameHeight:Int, frameCount:Int, mojo1Flags:Int, xhandle:Float, yhandle:Float )
'  
'  		_mojo1Flags = mojo1Flags
'  
'  		_frameCountX = _width / frameWidth
'  '  		_frameCountY = _height / frameHeight
'  
'  		' default frame count is 1
'  		If frameCount <= 0 Then frameCount = 1
'  		If _frameCountX <= 0 Then _frameCountX = 1
'  '  		If _frameCountY < 0 Then _frameCountY = 1
'  
'  		_frameCount = frameCount
'  
'  		_width = frameWidth
'  		_height = frameHeight
'  
'  		_frameWidth = frameWidth
'  		_frameHeight = frameHeight
'  
'  
'  		_frames0 = New Float[ _frameCount ]
'  		_framet0 = New Float[ _frameCount ]
'  		_frames1 = New Float[ _frameCount ]
'  		_framet1 = New Float[ _frameCount ]
'  
'  		If mojo1Flags & XPadding Then
'  			_x += 1
'  			_width -= 2
'  		Endif
'  
'  		If mojo1Flags & YPadding Then
'  			_y += 1
'  			_height -= 2
'  		Endif
'  
'  		SetHandlef( xhandle, yhandle )
'  
'  		For Local frame:Int = 0 Until _frameCount
'  
'  			Local frameX:Int = frame Mod _frameCountX
'  			Local frameY:Int = frame / _frameCountX
'  
'  			_frames0[ frame ] = Float(_x + frameX * _frameWidth)  / Float(_material.Width)
'  			_framet0[ frame ] = Float(_y + frameY * _frameHeight) / Float(_material.Height)
'  
'  			_frames1[ frame ] = Float(_x + _width  + frameX * _frameWidth)  / Float(_material.Width)
'  			_framet1[ frame ] = Float(_y + _height + frameY * _frameHeight) / Float(_material.Height)
'  		Next
'  	End
'  
'  	Method GrabImage:Image( x:Int, y:Int, width:Int, height:Int, frameCount:Int=1, mojo1Flags:Int=DefaultFlags )
'  
'  		Local xhandle:Float = 0.0
'  		Local yhandle:Float = 0.0
'  
'  		If mojo1Flags & MidHandle Then
'  			xhandle = 0.5
'  			yhandle = 0.5
'  		Endif
'  
'  		width *= frameCount
'  
'  '  		Return (New Image).Init( surface,x,y,width,height,nframes,flags,Self,frames[0].x,frames[0].y,Self.width,Self.height )
'  		Local result:Image = New Image( Self, x, y, width, height, xhandle, yhandle )
'  
'  		result.InitMojo1Image( result._width / frameCount, result._height, frameCount, mojo1Flags, xhandle, yhandle )
'  
'  		Return result
'  	End
'  
'  	Function CreateMojo1:Image( width:Int, height:Int, frameCount:Int=1, mojo1Flags:Int=Image.DefaultFlags )
'  
'  		Local xhandle:Float = 0.0
'  		Local yhandle:Float = 0.0
'  
'  		If mojo1Flags & MidHandle Then
'  			xhandle = 0.5
'  			yhandle = 0.5
'  		Endif
'  
'  		Local result:Image = New Image( width, height, xhandle, yhandle )
'  
'  		result.InitMojo1Image( result._width / frameCount, result._height, frameCount, mojo1Flags, xhandle, yhandle )
'  
'  		Return result
'  	End
'  
'  	Function LoadMojo1:Image( path:String, frameCount:Int=1, mojo1Flags:Int=DefaultFlags, flags:Int=Image.Filter|Image.Mipmap, shader:Shader=Null )
'  
'  		flags&=_flagsMask
'  
'  		Local material:=.Material.Load( path,flags|Texture.ClampST,shader )
'  		If Not material 
'  			DebugLog ("Error - Unable to load image: " + path)
'  			Return Null
'  		Endif
'  
'  		Local xhandle:Float = 0.0
'  		Local yhandle:Float = 0.0
'  
'  		If mojo1Flags & MidHandle Then
'  			xhandle = 0.5
'  			yhandle = 0.5
'  		Endif
'  
'  		Local result:Image = New Image( material, xhandle, yhandle )
'  
'  		result.InitMojo1Image( result._width / frameCount, result._height, frameCount, mojo1Flags, xhandle, yhandle )
'  
'  		Return result
'  	End
'  
'  	Function LoadMojo1:Image( path:String, frameWidth:Int, frameHeight:Int, frameCount:Int, mojo1Flags:Int=Image.DefaultFlags, flags:Int=Image.Filter|Image.Mipmap, shader:Shader=Null )
'  
'  		flags&=_flagsMask
'  
'  		Local material:=.Material.Load( path,flags|Texture.ClampST,shader )
'  		If Not material 
'  			DebugLog ("Error - Unable to load image: " + path)
'  			Return Null
'  		Endif
'  
'  		Local xhandle:Float = 0.0
'  		Local yhandle:Float = 0.0
'  
'  		If mojo1Flags & MidHandle Then
'  			xhandle = 0.5
'  			yhandle = 0.5
'  		Endif
'  
'  		Local result:Image = New Image( material, xhandle, yhandle )
'  
'  		result.InitMojo1Image( frameWidth, frameHeight, frameCount, mojo1Flags, xhandle, yhandle )
'  
'  		Return result
'  	End
'  
'  	Method Frames:Int()
'  		Return _frameCount
'  	End
'  
'  	Method Flags:Int()
'  		Return _mojo1Flags
'  	End
'  
'  	Private
'  	
'  	Global _flagsMask:=Filter|Mipmap|Managed
'  	
'  	Field _material:Material
'  	Field _x:Int,_y:Int,_width:Int,_height:Int
'  	Field _x0:Float=-1,_y0:Float=-1,_x1:Float=1,_y1:Float=1
'  	Field _s0:Float=0 ,_t0:Float=0 ,_s1:Float=1,_t1:Float=1
'  
'  	Field _frameCount:Int=1,_frameCountX:Int=1 ' ,_frameCountY:Int=1
'  	Field _frameWidth:Int,_frameHeight:Int
'  	Field _frames0:Float[],_frames1:Float[]
'  	Field _framet0:Float[],_framet1:Float[]
'  	Field _mojo1Flags:Int
'  
'  	Field _caster:ShadowCaster
'  
'  '	Method SetFrame:Void( x0:Float,y0:Float,x1:Float,y1:Float,s0:Float,t0:Float,s1:Float,t1:Float )
'  '		_x0=x0;_y0=y0;_x1=x1;_y1=y1
'  '		_s0=s0;_t0=t0;_s1=s1;_t1=t1
'  '	End
'  	
'  End

'  '***** Font *****
'  
'  Class Glyph
'  	Field id:Int
'  	Field page:Int
'  	
'  	Field x:Int
'  	Field y:Int
'  	Field width:Int
'  	Field height:Int
'  	Field advance:Int
'  	Field xoff:Int
'  	Field yoff:Int
'  	
'  	Method New( page:Int,id:Int,x:Int,y:Int,width:Int,height:Int,advance:Int )
'  		Self.page=page
'  		Self.id=id
'  		Self.x=x
'  		Self.y=y
'  		Self.width=width
'  		Self.height=height
'  		Self.advance=advance
'  		Self.xoff = 0
'  		Self.yoff = 0
'  	End
'  End
'  
'  Class Font
'  
'  	Method New( pages:Image[], pageCount:Int, chars:IntMap<Glyph>,  firstChar:Int,height:Float )
'  		Self._pages = pages
'  		Self._pageCount = pageCount
'  		Self._firstChar=firstChar
'  		Self._height=height
'  		Self._charMap = chars 
'  	End
'  
'  	Method GetGlyph:Glyph( char:Int )
'  		Return Self._charMap.Get(char)
'  	End
'  	
'  	Method TextWidth:Float( text:String )
'  		Local w:=0.0
'  		For Local char:=Eachin text
'  			Local glyph:=GetGlyph( char )
'  			If Not glyph Continue
'  			w+=glyph.advance
'  		Next
'  		Return w
'  	End
'  
'  	Method TextHeight:Float( text:String )
'  		Return _height
'  	End
'  	
'  	Function Load:Font( path:String,firstChar:Int,numChars:Int,padded:Bool )
'  'Print("Font load-> "+path)
'  		Local image:=Image.Load( path )
'  '	If image=Null
'  '	Print("Image = NULL")
'  '	Endif
'  		Local _pages:Image[] = New Image[1]
'  		_pages[0] = image
'  		Local _charMap:IntMap<Glyph> = New IntMap<Glyph> 
'  		
'  		Local _pageCount:Int = 1
'  		If Not image Return Null
'  		
'  		Local cellWidth:=image.Width/numChars
'  		Local cellHeight:=image.Height
'  		Local glyphX:=0,glyphY:=0,glyphWidth:=cellWidth,glyphHeight:=cellHeight
'  		If padded glyphX+=1;glyphY+=1;glyphWidth-=2;glyphHeight-=2
'  
'  		Local w:=image.Width/cellWidth
'  		Local h:=image.Height/cellHeight
'  'Print(w+":"+h+"         "+image.Width+":"+image.Height+"         "+cellWidth+":"+cellHeight)
'  		For Local i:=0 Until numChars
'  			Local y:=i / w
'  			Local x:=i Mod w
'  			Local glyph:=New Glyph( 0,firstChar+i,x*cellWidth+glyphX,y*cellHeight+glyphY,glyphWidth,glyphHeight,glyphWidth )
'  			_charMap.Add(firstChar+i, glyph)
'  		Next
'  		
'  		Return New Font( _pages , _pageCount, _charMap, firstChar,glyphHeight )
'  	End
'  	
'  	Function Load:Font( path:String,cellWidth:Int,cellHeight:Int,glyphX:Int,glyphY:Int,glyphWidth:Int,glyphHeight:Int,firstChar:Int,numChars:Int )
'  		Local image:=Image.Load( path )
'  		Local _pages:Image[] = New Image[1]
'  		_pages[0] = image
'  		Local _charMap:IntMap<Glyph> = New IntMap<Glyph> 
'  		
'  		Local _pageCount:Int = 1
'  		If Not image Return Null
'  
'  		Local w:=image.Width/cellWidth
'  		Local h:=image.Height/cellHeight
'  
'  		For Local i:=0 Until numChars
'  			Local y:=i / w
'  			Local x:=i Mod w
'  			Local glyph:=New Glyph( 0,firstChar+i,x*cellWidth+glyphX,y*cellHeight+glyphY,glyphWidth,glyphHeight,glyphWidth )
'  			_charMap.Add(firstChar+i, glyph)
'  		Next
'  		
'  		Return New Font( _pages , _pageCount, _charMap ,firstChar,glyphHeight )
'  	End
'  
'  	'------------------------------------------
'  	Function Load:Font(url:String)
'  		Local iniText:String
'  		Local pageNum:Int = 0
'  		Local idnum:Int = 0
'  		Local tmpChar:Glyph = Null
'  		Local plLen:Int
'  		Local lines:String[]
'  
'      	Local filename:String
'      	Local lineHeight:Int
'  
'  		Local _pages:Image[]
'  		Local _charMap:IntMap<Glyph> = New IntMap<Glyph> 
'  		Local _pageCount:Int
'  		
'  		Local path:String = ""
'  				
'  		If url.Find("/") > -1 Then
'  			Local pl:= url.Split("/")
'  			plLen = pl.Length()
'  			For Local pi:= 0 To (plLen-2)
'  				path = path + pl[pi]+"/"
'  			Next
'  		Endif
'  		Local ts:String = url.ToLower()
'  		If (ts.Find(".txt") > 0) Then
'  			iniText = app.LoadString(url)
'  		Else
'  			iniText = app.LoadString(url+".txt")
'  		Endif
'  
'  		lines = iniText.Split(String.FromChar(13)+String.FromChar(10))
'  		If lines.Length() < 2 then
'  			lines = iniText.Split(String.FromChar(10))
'  		Endif
'  
'  		For Local line := Eachin lines
'  		
'  			line = line.Trim()
'  			If line.StartsWith("info") Or line = "" Then Continue
'  			If line.StartsWith("padding") Then Continue
'  			If line.StartsWith("common") Then 
'  				Local commondata:= line.Split(String.FromChar(32)) 
'  				For Local common:= Eachin commondata
'  					' Maximum Line height
'  					If common.StartsWith("lineHeight=") Then
'  						Local lnh$[] = common.Split("=")
'  						lnh[1] = lnh[1].Trim()
'  						lineHeight = Int(lnh[1])
'  					Endif
'  					' Number of bitmap font images
'  					If common.StartsWith("pages=") Then
'  						Local lnh$[] = common.Split("=")
'  						lnh[1] = lnh[1].Trim()
'  						_pageCount = Int(lnh[1])
'  						_pages = New Image[_pageCount]
'  					Endif
'  				Next
'  			Endif
'  			
'  			' Loading the bitmap font images
'  			If line.StartsWith("page") Then
'  				Local pagedata := line.Split(String.FromChar(32)) 
'  				For Local data := Eachin pagedata
'  					If data.StartsWith("file=") Then
'  						Local fn$[] = data.Split("=")
'  						fn[1] = fn[1].Trim()
'  						filename = fn[1]
'  						If filename[0] = 34 Then
'  							filename = filename[1..(filename.Length()-1)]
'  						Endif
'  						filename = path+filename.Trim()
'  
'  						_pages[pageNum] = Image.Load(filename)
'  #If CONFIG="debug"
'  						If _pages[pageNum] = Null Then Error("~n~nError in file graphics.cxs, Method Font.Load:Font(url:String)~n~nCan not load page image: "+filename)
'  #End
'  						pageNum = pageNum + 1
'  					Endif
'  				Next
'  			Endif
'  			
'  			If line.StartsWith("chars") Then Continue
'  
'  			If line.StartsWith("char") Then
'  			  tmpChar = New Glyph
'  				Local linedata:= line.Split(String.FromChar(32))
'  				For Local data:= Eachin linedata
'  					If data.StartsWith("id=") Then
'  						Local idc$[] = data.Split("=")
'  						idc[1] = idc[1].Trim()
'  						tmpChar.id = Int(idc[1])
'  					Endif
'  					If data.StartsWith("x=") Then
'  						Local xc$[] = data.Split("=")
'  						xc[1] = xc[1].Trim()
'  						tmpChar.x = Int(xc[1])
'  					Endif
'  					If data.StartsWith("y=") Then
'  						Local yc$[] = data.Split("=")
'  						yc[1] = yc[1].Trim()
'  						tmpChar.y = Int(yc[1])
'  					Endif
'  					If data.StartsWith("width=") Then
'  						Local wc$[] = data.Split("=")
'  						wc[1] = wc[1].Trim()
'  						tmpChar.width = Int(wc[1])
'  					Endif
'  					If data.StartsWith("height=") Then
'  						Local hc$[] = data.Split("=")
'  						hc[1] = hc[1].Trim()
'  						tmpChar.height = Int(hc[1])
'  					Endif
'  					If data.StartsWith("xoffset=") Then
'  						Local xoc$[] = data.Split("=")
'  						xoc[1] = xoc[1].Trim()
'  						tmpChar.xoff = Int(xoc[1])
'  					Endif
'  					If data.StartsWith("yoffset=") Then
'  						Local yoc$[] = data.Split("=")
'  						yoc[1] = yoc[1].Trim()
'  						tmpChar.yoff = Int(yoc[1])
'  					Endif
'  					If data.StartsWith("xadvance=") Then
'  						Local advc$[] = data.Split("=")
'  						advc[1] = advc[1].Trim()
'  						tmpChar.advance = Int(advc[1])
'  					Endif
'  					If data.StartsWith("page=") Then
'  						Local advc$[] = data.Split("=")
'  						advc[1] = advc[1].Trim()
'  						tmpChar.page = Int(advc[1])
'  					Endif
'  				Next
'  				_charMap.Add(tmpChar.id, tmpChar)
'  			Endif
'  			Continue
'  		Next
'  		Return New Font( _pages , _pageCount, _charMap ,-1 ,lineHeight )
'  	End
'  	'-----------------------------
'  	Private
'  
'      Field _pages:Image[]    
'      Field _pageCount:Int
'  	Field _firstChar:Int
'  	Field _height:Float
'  	Field _charMap:IntMap<Glyph> = New IntMap<Glyph> 
'  End

'***** DrawList *****

Class DrawOp
'	Field shader:Shader
	Field material:Material
	Field blend:Int
	Field order:Int
	Field count:Int
End

Class BlendMode
	Const Opaque:=0
	Const Alpha:=1
	Const Additive:=2
	Const Multiply:=3
	Const Multiply2:= 4
	Const Alpha2:= 5
	Const Opaque2:= 6
	Const AlphaStamp:= 7	
End

Class DrawList

	Method New()
		InitMojo2
		
		SetFont Null
		SetDefaultMaterial fastShader.DefaultMaterial
'  		SetDefaultMaterial mojo1Shader.DefaultMaterial
	End
	
	Method SetBlendMode:Void( blend:Int )
		_blend=blend
	End
	
	Method BlendMode:Int() Property
		Return _blend
	End
	
	Method SetColor:Void( r:Float,g:Float,b:Float )
		_color[0]=r
		_color[1]=g
		_color[2]=b
		_pmcolor=Int(_alpha) Shl 24 | Int(_color[2]*_alpha) Shl 16 | Int(_color[1]*_alpha) Shl 8 | Int(_color[0]*_alpha)
	End
	
	Method SetColor:Void( r:Float,g:Float,b:Float,a:Float )
		_color[0]=r
		_color[1]=g
		_color[2]=b
		_color[3]=a
		_alpha=a*255
		_pmcolor=Int(_alpha) Shl 24 | Int(_color[2]*_alpha) Shl 16 | Int(_color[1]*_alpha) Shl 8 | Int(_color[0]*_alpha)
	End
	
	Method SetAlpha:Void( a:Float )
		_color[3]=a
		_alpha=a*255
		_pmcolor=Int(_alpha) Shl 24 | Int(_color[2]*_alpha) Shl 16 | Int(_color[1]*_alpha) Shl 8 | Int(_color[0]*_alpha)
	End
	
	Method Color:Float[]() Property
		Return [_color[0],_color[1],_color[2],_color[3]]
	End
	
	Method GetColor:Void( color:Float[] )
		color[0]=_color[0]
		color[1]=_color[1]
		color[2]=_color[2]
		If color.Length>3 color[3]=_color[3]
	End
	
	Method Alpha:Float() Property
		Return _color[3]
	End
	
	Method ResetMatrix:Void()
		_ix=1;_iy=0
		_jx=0;_jy=1
		_tx=0;_ty=0
	End
	
	Method SetMatrix:Void( ix:Float,iy:Float,jx:Float,jy:Float,tx:Float,ty:Float )
		_ix=ix;_iy=iy
		_jx=jx;_jy=jy
		_tx=tx;_ty=ty
	End
	
	Method GetMatrix:Void( matrix:Float[] )
		matrix[0]=_ix
		matrix[1]=_iy
		matrix[2]=_jx
		matrix[3]=_jy
		matrix[4]=_tx
		matrix[5]=_ty
	End
	
	Method Transform:Void( ix:Float,iy:Float,jx:Float,jy:Float,tx:Float,ty:Float )
		Local ix2:=ix*_ix+iy*_jx,iy2:=ix*_iy+iy*_jy
		Local jx2:=jx*_ix+jy*_jx,jy2:=jx*_iy+jy*_jy
		Local tx2:=tx*_ix+ty*_jx+_tx,ty2:=tx*_iy+ty*_jy+_ty
		SetMatrix ix2,iy2,jx2,jy2,tx2,ty2
	End

	Method Translate:Void( tx:Float,ty:Float )
		Transform 1,0,0,1,tx,ty
	End
	
	Method Rotate( rz:Float )
		Transform Cos( rz ),-Sin( rz ),Sin( rz ),Cos( rz ),0,0
	End
	
	Method Scale:Void( sx:Float,sy:Float )
		Transform sx,0,0,sy,0,0
	End
	
	Method TranslateRotate:Void( tx:Float,ty:Float,rz:Float )
		Translate tx,ty
		Rotate rz
	End
	
	Method RotateScale:Void( rz:Float,sx:Float,sy:Float )
		Rotate rz
		Scale sx,sy
	End
	
	Method TranslateScale:Void( tx:Float,ty:Float,sx:Float,sy:Float )
		Translate tx,ty
		Scale sx,sy
	End
	
	Method TranslateRotateScale:Void( tx:Float,ty:Float,rz:Float,sx:Float,sy:Float )
		Translate tx,ty
		Rotate rz
		Scale sx,sy
	End

	Method SetMatrixStackCapacity:Void( capacity:Int )
		_matStack=_matStack.Resize( capacity*6 )
		_matSp=0
	End
	
	Method MatrixStackCapacity:Int()
		Return _matStack.Length/6
	End
	
	Method PushMatrix:Void()
		_matStack[_matSp+0]=_ix;_matStack[_matSp+1]=_iy
		_matStack[_matSp+2]=_jx;_matStack[_matSp+3]=_jy
		_matStack[_matSp+4]=_tx;_matStack[_matSp+5]=_ty
		_matSp+=6 ; If _matSp>=_matStack.Length _matSp-=_matStack.Length
	End
	
	Method PopMatrix:Void()
		_matSp-=6 ; If _matSp<0 _matSp+=_matStack.Length
		_ix=_matStack[_matSp+0];_iy=_matStack[_matSp+1]
		_jx=_matStack[_matSp+2];_jy=_matStack[_matSp+3]
		_tx=_matStack[_matSp+4];_ty=_matStack[_matSp+5]
	End
	
	Method SetFont:Void( font:Font )
		If Not font font=defaultFont
		_font=font
	End
	
	Method Font:Font() Property
		Return _font
	End
	
	Method SetDefaultMaterial:Void( material:Material )
		_defaultMaterial=material
	End
	
	Method DefaultMaterial:Material() Property
		Return _defaultMaterial
	End
	
	Method DrawPoint:Void( x0:Float,y0:Float,material:Material=Null,s0:Float=0,t0:Float=0 )
		BeginPrim material,1
		PrimVert x0+.5,y0+.5,s0,t0
	End
	
	Method DrawLine:Void( x0:Float,y0:Float,x1:Float,y1:Float,material:Material=Null,s0:Float=0,t0:Float=0,s1:Float=1,t1:Float=0 )
		BeginPrim material,2
		PrimVert x0+.5,y0+.5,s0,t0
		PrimVert x1+.5,y1+.5,s1,t1
	End
	
	Method DrawTriangle:Void( x0:Float,y0:Float,x1:Float,y1:Float,x2:Float,y2:Float,material:Material=Null,s0:Float=.5,t0:Float=0,s1:Float=1,t1:Float=1,s2:Float=0,t2:Float=1 )
		BeginPrim material,3
		PrimVert x0,y0,s0,t0
		PrimVert x1,y1,s1,t1
		PrimVert x2,y2,s2,t2
	End
	
	Method DrawQuad:Void( x0:Float,y0:Float,x1:Float,y1:Float,x2:Float,y2:Float,x3:Float,y3:Float,material:Material=Null,s0:Float=.5,t0:Float=0,s1:Float=1,t1:Float=1,s2:Float=0,t2:Float=1 )
		BeginPrim material,4
		PrimVert x0,y0,s0,t0
		PrimVert x1,y1,s1,t1
		PrimVert x2,y2,s2,t2
		PrimVert x3,y3,s2,t2
	End
	
	Method DrawOval:Void( x:Float,y:Float,width:Float,height:Float,material:Material=Null )
		Local xr:=width/2.0,yr:=height/2.0
		
		Local dx_x:=xr*_ix,dx_y:=xr*_iy,dy_x:=yr*_jx,dy_y:=yr*_jy
		Local dx:=Sqrt( dx_x*dx_x+dx_y*dx_y ),dy:=Sqrt( dy_x*dy_x+dy_y*dy_y )

		Local n:=Int( dx+dy )
		If n<12 
			n=12 
		Else If n>MAX_VERTICES
			n=MAX_VERTICES
		Else
			n&=~3
		Endif
		
		Local x0:=x+xr,y0:=y+yr
		
		BeginPrim material,n
		
		For Local i:=0 Until n
			Local th:=i*360.0/n
			Local px:=x0+Cos( th ) * xr
			Local py:=y0+Sin( th ) * yr
			PrimVert px,py,0,0
		Next
	End
	
	Method DrawEllipse:Void( x:Float,y:Float,xr:Float,yr:Float,material:Material=Null )
		DrawOval x-xr,y-yr,xr*2,yr*2,material
	End
	
	Method DrawCircle:Void( x:Float,y:Float,r:Float,material:Material=Null )
		DrawOval x-r,y-r,r*2,r*2,material
	End
	
	Method DrawPoly:Void( vertices:Float[],material:Material=Null )
	
		Local n:=vertices.Length/2
		If n<3 Or n>MAX_VERTICES Return
	
		BeginPrim material,n

		For Local i:=0 Until n
			PrimVert vertices[i*2],vertices[i*2+1],0,0
		Next
	End
	
	Method DrawPrimitives:Void( order:Int,count:Int,vertices:Float[],material:Material=Null )
	
		BeginPrims material,order,count
		Local p:=0
		For Local i:=0 Until count
			For Local j:=0 Until order
				PrimVert vertices[p],vertices[p+1],0,0
				p+=2
			Next
		Next
	End
	
	Method DrawPrimitives:Void( order:Int,count:Int,vertices:Float[],texcoords:Float[],material:Material=Null )
	
		BeginPrims material,order,count
		Local p:=0
		For Local i:=0 Until count
			For Local j:=0 Until order
				PrimVert vertices[p],vertices[p+1],texcoords[p],texcoords[p+1]
				p+=2
			Next
		Next
	End

' 20180218, Holzchopf - ADDED drawing primitives with individual vertex color
	Method DrawPrimitives:Void( order:Int,count:Int,vertices:Float[],texcoords:Float[],vertcols:Int[],material:Material=Null )
		' save current color for later
		Local tmpcolor := _pmcolor
		' draw primitives
		BeginPrims material,order,count
		Local p:=0
		For Local i:=0 Until count
			For Local j:=0 Until order
				' write vertex color
				_pmcolor = vertcols[i*order+j]
				' write vertex data
				PrimVert vertices[p],vertices[p+1],texcoords[p],texcoords[p+1]
				p+=2
			Next
		Next
		' restoree color
		_pmcolor = tmpcolor
	End
	
	Method DrawIndexedPrimitives:Void( order:Int,count:Int,vertices:Float[],indices:Int[],material:Material=Null )
	
		BeginPrims material,order,count
		Local p:=0
		For Local i:=0 Until count
			For Local j:=0 Until order
				Local k:=indices[p+j]*2
				PrimVert vertices[k],vertices[k+1],0,0
			Next
			p+=order
		Next
	
	End
	
	Method DrawIndexedPrimitives:Void( order:Int,count:Int,vertices:Float[],texcoords:Float[],indices:Int[],material:Material=Null )
	
		BeginPrims material,order,count
		Local p:=0
		For Local i:=0 Until count
			For Local j:=0 Until order
				Local k:=indices[p+j]*2
				PrimVert vertices[k],vertices[k+1],texcoords[k],texcoords[k+1]
			Next
			p+=order
		Next
	
	End
	
' 20180218, Holzchopf - ADDED drawing primitives with individual vertex color
	Method DrawIndexedPrimitives:Void( order:Int,count:Int,vertices:Float[],texcoords:Float[],vertcols:Int[],indices:Int[],material:Material=Null )
		' save current color for later
		Local tmpcolor := _pmcolor
		' draw primitives
		BeginPrims material,order,count
		Local p:=0
		Local v:Int		' vertex index
		Local k:Int		' index in vertices array
		For Local i:=0 Until count
			For Local j:=0 Until order
				' index
				v = indices[p+j]
				k = v*2
				' write vertex color
				_pmcolor = vertcols[v]
				' write vertex data
				PrimVert vertices[k],vertices[k+1],texcoords[k],texcoords[k+1]
			Next
			p+=order
		Next
		' restoree color
		_pmcolor = tmpcolor
	End
	
	Method DrawRect:Void( x0:Float,y0:Float,width:Float,height:Float,material:Material=Null,s0:Float=0,t0:Float=0,s1:Float=1,t1:Float=1 )
'Print("DrawRect1")
		Local x1:=x0+width,y1:=y0+height
		BeginPrim material,4
		PrimVert x0,y0,s0,t0
		PrimVert x1,y0,s1,t0
		PrimVert x1,y1,s1,t1
		PrimVert x0,y1,s0,t1
	End
	
	Method DrawRect:Void( x0:Float,y0:Float,width:Float,height:Float,image:Image )
'Print("DrawRect2")
		DrawRect x0,y0,width,height,image._material,image._s0,image._t0,image._s1,image._t1
	End
	
	Method DrawRect:Void( x:Float,y:Float,image:Image,sourceX:Int,sourceY:Int,sourceWidth:Int,sourceHeight:Int )
'Print("DrawRect3       "+sourceWidth+":"+sourceHeight+"         "+sourceX+":"+sourceY+"         "+sourceWidth+":"+sourceHeight)
		DrawRect( x,y,sourceWidth,sourceHeight,image,sourceX,sourceY,sourceWidth,sourceHeight )
	End
	
	Method DrawRect:Void( x0:Float,y0:Float,width:Float,height:Float,image:Image,sourceX:Int,sourceY:Int,sourceWidth:Int,sourceHeight:Int )
'Print("DrawRect4       "+image._material.Width+":"+image._material.Height+"         "+width+":"+height)
		Local material:=image._material
'If material = Null
'Print("material = null")
'Endif
		Local s0:=Float(image._x+sourceX)/Float(material.Width)
		Local t0:=Float(image._y+sourceY)/Float(material.Height)
		Local s1:=Float(image._x+sourceX+sourceWidth)/Float(material.Width)
		Local t1:=Float(image._y+sourceY+sourceHeight)/Float(material.Height)
'DebugStop
'Print ("DrawRect4       "+s0+":"+t0+":"+s1+":"+t1)		
		DrawRect x0,y0,width,height,material,s0,t0,s1,t1
	End
	
	'gradient rect - kinda hacky, but doesn't slow anything else down
	Method DrawGradientRect:Void( x0:Float,y0:Float,width:Float,height:Float,r0:Float,g0:Float,b0:Float,a0:Float,r1:Float,g1:Float,b1:Float,a1:Float,axis:Int )
	
		r0*=_color[0];g0*=_color[1];b0*=_color[2];a0*=_alpha
		r1*=_color[0];g1*=_color[1];b1*=_color[2];a1*=_alpha
		
		Local pm0:=Int( a0 ) Shl 24 | Int( b0*a0 ) Shl 16 | Int( g0*a0 ) Shl 8 | Int( r0*a0 )
		Local pm1:=Int( a1 ) Shl 24 | Int( b1*a0 ) Shl 16 | Int( g1*a0 ) Shl 8 | Int( r1*a0 )
		
		Local x1:=x0+width,y1:=y0+height,s0:=0.0,t0:=0.0,s1:=1.0,t1:=1.0
		
		BeginPrim Null,4

		Local pmcolor:=_pmcolor
		
		BeginPrim Null,4
		
		Select axis
		Case 0	'left->right
			_pmcolor=pm0
			PrimVert x0,y0,s0,t0
			_pmcolor=pm1
			PrimVert x1,y0,s1,t0
			PrimVert x1,y1,s1,t1
			_pmcolor=pm0
			PrimVert x0,y1,s0,t1
		Default	'top->bottom
			_pmcolor=pm0
			PrimVert x0,y0,s0,t0
			PrimVert x1,y0,s1,t0
			_pmcolor=pm1
			PrimVert x1,y1,s1,t1
			PrimVert x0,y1,s0,t1
		End
		
		_pmcolor=pmcolor
	End
	
	Method DrawImage:Void( image:Image,frame:Int=0 )

		Local s0:Float = image._frames0[ frame ]
		Local t0:Float = image._framet0[ frame ]
		Local s1:Float = image._frames1[ frame ]
		Local t1:Float = image._framet1[ frame ]

		BeginPrim image._material,4
		PrimVert image._x0,image._y0,s0,t0
		PrimVert image._x1,image._y0,s1,t0
		PrimVert image._x1,image._y1,s1,t1
		PrimVert image._x0,image._y1,s0,t1
		If image._caster AddShadowCaster image._caster

		#rem
		BeginPrim image._material,4
		PrimVert image._x0,image._y0,image._s0,image._t0
		PrimVert image._x1,image._y0,image._s1,image._t0
		PrimVert image._x1,image._y1,image._s1,image._t1
		PrimVert image._x0,image._y1,image._s0,image._t1
		If image._caster AddShadowCaster image._caster
		#end
	End
	
	Method DrawImage:Void( image:Image,tx:Float,ty:Float,frame:Int=0 )
		PushMatrix
		Translate tx,ty
		DrawImage image,frame
		PopMatrix
		#rem
		BeginPrim image._material,4
		PrimVert image._x0 + tx,image._y0 + ty,image._s0,image._t0
		PrimVert image._x1 + tx,image._y0 + ty,image._s1,image._t0
		PrimVert image._x1 + tx,image._y1 + ty,image._s1,image._t1
		PrimVert image._x0 + tx,image._y1 + ty,image._s0,image._t1
		#end
	End

'  	Method DrawImage:Void( image:Image,tx:Float,ty:Float,rz:Float,frame:Int=0 )
'  		PushMatrix
'  		TranslateRotate tx,ty,rz
'  		DrawImage image,frame
'  		PopMatrix
'  		#rem
'  		Local ix:=Cos( rz ),iy:=-Sin( rz )
'  		Local jx:=Sin( rz ),jy:= Cos( rz )
'  		Local x0:=image._x0,y0:=image._y0
'  		Local x1:=image._x1,y1:=image._y1
'  		BeginPrim image._material,4
'  		PrimVert x0 * ix + y0 * jx + tx,x0 * iy + y0 * jy + ty,image._s0,image._t0
'  		PrimVert x1 * ix + y0 * jx + tx,x1 * iy + y0 * jy + ty,image._s1,image._t0
'  		PrimVert x1 * ix + y1 * jx + tx,x1 * iy + y1 * jy + ty,image._s1,image._t1
'  		PrimVert x0 * ix + y1 * jx + tx,x0 * iy + y1 * jy + ty,image._s0,image._t1
'  		#end
'  	End

	Method DrawImage:Void( image:Image,tx:Float,ty:Float,rz:Float,sx:Float,sy:Float,frame:Int=0 )
		PushMatrix
		TranslateRotateScale tx,ty,rz,sx,sy
		DrawImage image,frame
		PopMatrix
		#rem		
		Local ix:=Cos( rz ),iy:=-Sin( rz )
		Local jx:=Sin( rz ),jy:= Cos( rz )
		Local x0:=image._x0 * sx,y0:=image._y0 * sy
		Local x1:=image._x1 * sx,y1:=image._y1 * sy
		BeginPrim image._material,4
		PrimVert x0 * ix + y0 * jx + tx,x0 * iy + y0 * jy + ty,image._s0,image._t0
		PrimVert x1 * ix + y0 * jx + tx,x1 * iy + y0 * jy + ty,image._s1,image._t0
		PrimVert x1 * ix + y1 * jx + tx,x1 * iy + y1 * jy + ty,image._s1,image._t1
		PrimVert x0 * ix + y1 * jx + tx,x0 * iy + y1 * jy + ty,image._s0,image._t1
		#end
	End

	Method DrawImageAlign:Void( image:Image, sourceX:Int, sourceY:Int, sourceWidth:Int, sourceHeight:Int, alignX:Float, alignY:Float, frame:Int=0 )

		Local material:Material = image._material

		Local frameX:Int = frame Mod image._frameCountX
		Local frameY:Int = frame / image._frameCountX

		Local x0:Float = sourceWidth * -alignX
		Local x1:Float = sourceWidth * (1-alignX)
		Local y0:Float = sourceHeight * -alignY
		Local y1:Float = sourceHeight * (1-alignY)

		Local s0:Float = Float(image._x+sourceX+frameX*image._frameWidth)/Float(material.Width)
		Local t0:Float = Float(image._y+sourceY+frameY*image._frameHeight)/Float(material.Height)
		Local s1:Float = Float(image._x+sourceX+sourceWidth+frameX*image._frameWidth)/Float(material.Width)
		Local t1:Float = Float(image._y+sourceY+sourceHeight+frameY*image._frameHeight)/Float(material.Height)

		BeginPrim image._material,4
		PrimVert x0,y0,s0,t0
		PrimVert x1,y0,s1,t0
		PrimVert x1,y1,s1,t1
		PrimVert x0,y1,s0,t1

		If image._caster AddShadowCaster image._caster
	End

	Method DrawImageHandle:Void( image:Image, sourceX:Int, sourceY:Int, sourceWidth:Int, sourceHeight:Int, handleX:Float, handleY:Float, frame:Int=0 )
		DrawImageAlign(image, sourceX, sourceY, sourceWidth, sourceHeight, handleX / sourceWidth, handleY / sourceHeight, frame)
	End

	Method DrawImageRect:Void( image:Image, sourceX:Int, sourceY:Int, sourceWidth:Int, sourceHeight:Int, frame:Int=0 )
		DrawImageHandle(image, sourceX, sourceY, sourceWidth, sourceHeight, image.HandleX(), image.HandleY(), frame)
	End

'  	Method DrawImageRect:Void( image:Image, sourceX:Int, sourceY:Int, sourceWidth:Int, sourceHeight:Int, frame:Int=0 )
'  
'  		Local material:Material = image._material
'  
'  		Local frameX:Int = frame Mod image._frameCountX
'  		Local frameY:Int = frame / image._frameCountX
'  
'  '  		Local xhandle:Float = image.HandleXf()
'  '  		Local yhandle:Float = image.HandleYf()
'  		Local xhandle:Float = image.HandleX() / sourceWidth
'  		Local yhandle:Float = image.HandleY() / sourceHeight
'  
'  		Local x0:Float = sourceWidth * -xhandle
'  		Local x1:Float = sourceWidth * (1-xhandle)
'  		Local y0:Float = sourceHeight * -yhandle
'  		Local y1:Float = sourceHeight * (1-yhandle)
'  
'  		Local s0:Float = Float(image._x+sourceX+frameX*image._frameWidth)/Float(material.Width)
'  		Local t0:Float = Float(image._y+sourceY+frameY*image._frameHeight)/Float(material.Height)
'  		Local s1:Float = Float(image._x+sourceX+sourceWidth+frameX*image._frameWidth)/Float(material.Width)
'  		Local t1:Float = Float(image._y+sourceY+sourceHeight+frameY*image._frameHeight)/Float(material.Height)
'  
'  		BeginPrim image._material,4
'  		PrimVert x0,y0,s0,t0
'  		PrimVert x1,y0,s1,t0
'  		PrimVert x1,y1,s1,t1
'  		PrimVert x0,y1,s0,t1
'  		If image._caster AddShadowCaster image._caster
'  	End

	Method DrawImageRect:Void( image:Image, tx:Float, ty:Float, sourceX:Int, sourceY:Int, sourceWidth:Int, sourceHeight:Int, frame:Int=0 )
		PushMatrix
		Translate tx,ty
		DrawImageRect image,sourceX,sourceY,sourceWidth,sourceHeight,frame
		PopMatrix
	End

	Method DrawImageRect:Void( image:Image, tx:Float, ty:Float, sourceX:Int, sourceY:Int, sourceWidth:Int, sourceHeight:Int, rz:Float, sx:Float, sy:Float, frame:Int=0 )
		PushMatrix
		TranslateRotateScale tx,ty,rz,sx,sy
		DrawImageRect image,sourceX,sourceY,sourceWidth,sourceHeight,frame
		PopMatrix

'  		Local material:Material = image._material
'  
'  		Local frameX:Int = frame Mod image._frameCountX
'  		Local frameY:Int = frame / image._frameCountX
'  
'  		Local xhandle:Float = image.HandleX() / sourceWidth
'  		Local yhandle:Float = image.HandleY() / sourceHeight
'  
'  		Print "xhandle=" + xhandle + " yhandle=" + yhandle
'  
'  		Local x0:Float = sourceWidth * -xhandle * sx
'  		Local x1:Float = sourceWidth * (1-xhandle) * sx
'  		Local y0:Float = sourceHeight * -yhandle * sy
'  		Local y1:Float = sourceHeight * (1-yhandle) * sy
'  
'  		Local s0:Float = Float(image._x+sourceX+frameX*image._frameWidth)/Float(material.Width)
'  		Local t0:Float = Float(image._y+sourceY+frameY*image._frameHeight)/Float(material.Height)
'  		Local s1:Float = Float(image._x+sourceX+sourceWidth+frameX*image._frameWidth)/Float(material.Width)
'  		Local t1:Float = Float(image._y+sourceY+sourceHeight+frameY*image._frameHeight)/Float(material.Height)
'  
'  		BeginPrim image._material,4
'  		PrimVert x0,y0,s0,t0
'  		PrimVert x1,y0,s1,t0
'  		PrimVert x1,y1,s1,t1
'  		PrimVert x0,y1,s0,t1
'  
'  		Local ix:=Cos( rz ),iy:=-Sin( rz )
'  		Local jx:=Sin( rz ),jy:= Cos( rz )
'  '  		Local x0:=image._x0 * sx,y0:=image._y0 * sy
'  '  		Local x1:=image._x1 * sx,y1:=image._y1 * sy
'  		BeginPrim image._material,4
'  		PrimVert x0 * ix + y0 * jx + tx,x0 * iy + y0 * jy + ty, s0, t0
'  		PrimVert x1 * ix + y0 * jx + tx,x1 * iy + y0 * jy + ty, s1, t0
'  		PrimVert x1 * ix + y1 * jx + tx,x1 * iy + y1 * jy + ty, s1, t1
'  		PrimVert x0 * ix + y1 * jx + tx,x0 * iy + y1 * jy + ty, s0, t1
	End

	Method DrawImageHandle:Void( image:Image, tx:Float, ty:Float, sourceX:Int, sourceY:Int, sourceWidth:Int, sourceHeight:Int, handleX:Float, handleY:Float, frame:Int=0 )
		PushMatrix
		Translate tx,ty
		DrawImageHandle image,sourceX,sourceY,sourceWidth,sourceHeight,handleX,handleY,frame
		PopMatrix
	End

	Method DrawImageHandle:Void( image:Image, tx:Float, ty:Float, sourceX:Int, sourceY:Int, sourceWidth:Int, sourceHeight:Int, rz:Float, sx:Float, sy:Float, handleX:Float, handleY:Float, frame:Int=0 )
		PushMatrix
		TranslateRotateScale tx,ty,rz,sx,sy
		DrawImageHandle image,sourceX,sourceY,sourceWidth,sourceHeight,handleX,handleY,frame
		PopMatrix
	End

	Method DrawImageAlign:Void( image:Image, tx:Float, ty:Float, sourceX:Int, sourceY:Int, sourceWidth:Int, sourceHeight:Int, alignX:Float, alignY:Float, frame:Int=0 )
		PushMatrix
		Translate tx,ty
		DrawImageHandle image,sourceX,sourceY,sourceWidth,sourceHeight,alignX,alignY,frame
		PopMatrix
	End

	Method DrawImageAlign:Void( image:Image, tx:Float, ty:Float, sourceX:Int, sourceY:Int, sourceWidth:Int, sourceHeight:Int, rz:Float, sx:Float, sy:Float, alignX:Float, alignY:Float, frame:Int=0 )
		PushMatrix
		TranslateRotateScale tx,ty,rz,sx,sy
		DrawImageHandle image,sourceX,sourceY,sourceWidth,sourceHeight,alignX,alignY,frame
		PopMatrix
	End

	Method DrawImage9P:Void( image:Image,tx:Float,ty:Float, patchSize:Int,rz:Float,scaleX:Float,scaleY:Float )
		Local patchS2 = patchSize * 2.0
		Local tsX# = ((image.Width*scaleX)-patchS2) / ((image.Width-patchS2))
		Local tsY# = ((image.Height*scaleY)-patchS2) / ((image.Height-patchS2))

		PushMatrix
		TranslateRotate tx,ty,rz

		Local xo2:Float
		xo2 = - image.Width*image.HandleX*scaleX
		Local yo2:Float
		yo2 =  - image.Height*image.HandleY*scaleY
		
		'TopLeft
		DrawRect(0+xo2 , 0+yo2 , image, 0, 0, patchSize, patchSize )
		'TopMid
		DrawRect(patchSize +xo2 , 0 +yo2, image.Width*scaleX - patchSize - patchSize, patchSize, image, patchSize, 0, image.Width - patchSize - patchSize, patchSize )
		'TopRight
		DrawRect(image.Width*scaleX - patchSize +xo2 , 0 +yo2, image, image.Width - patchSize, 0, patchSize, patchSize )
		
		'MiddleLeft
		DrawRect(0 +xo2 , patchSize +yo2, patchSize, image.Height*scaleY - patchSize - patchSize, image, 0, patchSize, patchSize, image.Height -patchSize - patchSize )
		'MiddleMid
		DrawRect(patchSize +xo2 , patchSize +yo2, image.Width*scaleX -patchSize - patchSize, image.Height*scaleY - patchSize - patchSize,image, patchSize , patchSize, image.Width - patchSize - patchSize, image.Height - patchSize - patchSize )
		'MiddleRight
		DrawRect(image.Width*scaleX - patchSize +xo2 , patchSize +yo2, patchSize, image.Height*scaleY - patchSize - patchSize, image, image.Width - patchSize, patchSize, patchSize,  image.Height -patchSize - patchSize )
		
		'BottomLeft
		DrawRect(0 +xo2 , image.Height*scaleY - patchSize +yo2, image, 0, image.Height - patchSize, patchSize, patchSize )
		'BottomMid
		DrawRect(patchSize +xo2 , image.Height*scaleY - patchSize +yo2, image.Width*scaleX-patchSize-patchSize, patchSize, image, patchSize, image.Height - patchSize, image.Width - patchSize - patchSize, patchSize )
		'BottomRight
		DrawRect(image.Width*scaleX - patchSize +xo2 , image.Height*scaleY - patchSize +yo2, image, image.Width - patchSize, image.Height - patchSize, patchSize, patchSize )

		PopMatrix
	End
	
'  	Method DrawText:Void( text:String,x:Float,y:Float,xhandle:Float=0,yhandle:Float=0 )
'  
'  		x -= _font.TextWidth( text )  * xhandle
'  		y -= _font.TextHeight( text ) * yhandle
'  
'  		Local _kernings:Int[] = _font._kernings
'  		Local _pages:Image[] = _font._pages
'  		Local _charMap:IntMap<Glyph> = _font._charMap
'  
'  		If _kernings Then
'  
'  			Local first:Int = text[0]
'  			Local second:Int = first
'  
'  			' draw the first character
'  			Local tmpChar:Glyph = _charMap.Get(first)
'  			If tmpChar Then
'  				DrawRect( x + tmpChar.xoff, y + tmpChar.yoff, _pages[tmpChar.page], tmpChar.x, tmpChar.y, tmpChar.width, tmpChar.height )
'  				x += tmpChar.advance
'  			Endif
'  
'  			' For Local char:Int = Eachin text
'  			Local length:Int = text.Length()
'  			For Local charIndex:Int = 1 Until length
'  				Local char:Int = text[ charIndex ]
'  				first = second; second = char
'  				Local tmpChar:Glyph = _charMap.Get( char )
'  				If Not tmpChar Then Continue
'  				x += _kernings[(first Shl 8) + second]
'  				DrawRect( x + tmpChar.xoff, y + tmpChar.yoff, _pages[tmpChar.page], tmpChar.x, tmpChar.y, tmpChar.width, tmpChar.height )
'  				x += tmpChar.advance
'  			Next
'  		Else
'  
'  			For Local char:Int = Eachin text
'  				Local tmpChar:Glyph = _charMap.Get(char)
'  				If Not tmpChar Then
'  					' Print("no tmpchar")			
'  					Continue
'  				Endif
'  				'If _font._pages[tmpChar.page]=Null
'  				'Print("no _font._pages")			
'  				'Endif			
'  				'Print ("char="+(char)+"   "+ tmpChar.width+":"+ tmpChar.height+"("+tmpChar.page+")")			
'  				DrawRect( x + tmpChar.xoff, y + tmpChar.yoff, _pages[tmpChar.page], tmpChar.x, tmpChar.y, tmpChar.width, tmpChar.height )
'  				x += tmpChar.advance
'  			Next
'  
'  		Endif
'  	End
'  
'  	Method DrawText:Void( textLines:String[],x:Float,y:Float,xhandle:Float=0,yhandle:Float=0 )
'  
'  		Local linesCount:Int = textLines.Length()
'  		Local currX:Float = x
'  
'  		y -= _font.TextHeight( "" ) * yhandle * linesCount
'  
'  		Local _kernings:Int[] = _font._kernings
'  		Local _pages:Image[] = _font._pages
'  		Local _charMap:IntMap<Glyph> = _font._charMap
'  
'  		If _kernings Then
'  
'  			For Local _y:Int = 1 To linesCount
'  
'  				Local text:String = textLines[_y-1]
'  				x-=_font.TextWidth( text )*xhandle
'  
'  				Local first:Int = text[0]
'  				Local second:Int = first
'  
'  				' draw the first character
'  				Local tmpChar:Glyph = _charMap.Get(first)
'  				If tmpChar Then
'  					DrawRect( x + tmpChar.xoff, y + tmpChar.yoff, _pages[tmpChar.page], tmpChar.x, tmpChar.y, tmpChar.width, tmpChar.height )
'  					x += tmpChar.advance
'  				Endif
'  
'  				Local length:Int = text.Length()
'  				For Local charIndex:Int = 1 Until length
'  					Local char:Int = text[ charIndex ]
'  					first = second; second = char
'  					Local tmpChar:Glyph = _charMap.Get( char )
'  					If Not tmpChar Then Continue
'  					x += _kernings[(first Shl 8) + second]
'  					DrawRect( x + tmpChar.xoff, y + tmpChar.yoff, _pages[tmpChar.page], tmpChar.x, tmpChar.y, tmpChar.width, tmpChar.height )
'  					x += tmpChar.advance
'  				Next
'  
'  				y += _font.TextHeight( text )
'  				x = currX 
'  			Next
'  
'  		Else
'  
'  			For Local _y:Int = 1 To linesCount
'  
'  				Local text:String = textLines[_y-1]
'  				x-=_font.TextWidth( text )*xhandle
'  
'  				For Local char:Int = Eachin text
'  					Local tmpChar:Glyph = _charMap.Get(char)
'  					If Not tmpChar Then Continue
'  					DrawRect( x + tmpChar.xoff, y + tmpChar.yoff, _pages[tmpChar.page], tmpChar.x, tmpChar.y, tmpChar.width, tmpChar.height )
'  					x += tmpChar.advance
'  				Next
'  
'  				y += _font.TextHeight( text )
'  				x = currX 
'  			Next
'  
'  		Endif
'  	End

	Method DrawShadow:Bool( lx:Float,ly:Float,x0:Float,y0:Float,x1:Float,y1:Float )
	
		Local ext:=1024
	
		Local dx:=x1-x0,dy:=y1-y0
		Local d0:=Sqrt( dx*dx+dy*dy )
		Local nx:=-dy/d0,ny:=dx/d0
		Local pd:=-(x0*nx+y0*ny)
		
		Local d:=lx*nx+ly*ny+pd
		If d<0 Return False

		Local x2:=x1-lx,y2:=y1-ly
		Local d2:=ext/Sqrt( x2*x2+y2*y2 )
		x2=lx+x2*ext;y2=ly+y2*ext
		
		Local x3:=x0-lx,y3:=y0-ly
		Local d3:=ext/Sqrt( x3*x3+y3*y3 )
		x3=lx+x3*ext;y3=ly+y3*ext
		
		Local x4:=(x2+x3)/2-lx,y4:=(y2+y3)/2-ly
		Local d4:=ext/Sqrt( x4*x4+y4*y4 )
		x4=lx+x4*ext;y4=ly+y4*ext
		
		DrawTriangle x0,y0,x4,y4,x3,y3
		DrawTriangle x0,y0,x1,y1,x4,y4
		DrawTriangle x1,y1,x2,y2,x4,y4
		
		Return True
	End
	
	Method DrawShadows:Void( x0:Float,y0:Float,drawList:DrawList )
	
		Local lx:= x0 * _ix + y0 * _jx + _tx
		Local ly:= x0 * _iy + y0 * _jy + _ty

		Local verts:=drawList._casterVerts.Data,v0:=0
		
		For Local i:=0 Until drawList._casters.Length
		
			Local caster:=drawList._casters.Get( i )
			Local n:=caster._verts.Length
			
			Select caster._type
			Case 0	'closed loop
				Local x0:=verts[v0+n-2]
				Local y0:=verts[v0+n-1]
				For Local i:=0 Until n-1 Step 2
					Local x1:=verts[v0+i]
					Local y1:=verts[v0+i+1]
					DrawShadow( lx,ly,x0,y0,x1,y1 )
					x0=x1
					y0=y1
				Next
			Case 1	'open loop
			Case 2	'edge soup
			End
			
			v0+=n
		Next
		
	End
	
	Method AddShadowCaster:Void( caster:ShadowCaster )
		_casters.Push caster
		Local verts:=caster._verts
		For 	Local i:=0 Until verts.Length-1 Step 2
			Local x0:=verts[i]
			Local y0:=verts[i+1]
			_casterVerts.Push x0*_ix+y0*_jx+_tx
			_casterVerts.Push x0*_iy+y0*_jy+_ty
		Next
	End
	
	Method AddShadowCaster:Void( caster:ShadowCaster,tx:Float,ty:Float )
		PushMatrix
		Translate tx,ty
		AddShadowCaster caster
		PopMatrix
	End
	
	Method AddShadowCaster:Void( caster:ShadowCaster,tx:Float,ty:Float,rz:Float )
		PushMatrix
		TranslateRotate tx,ty,rz
		AddShadowCaster caster
		PopMatrix
	End
	
	Method AddShadowCaster:Void( caster:ShadowCaster,tx:Float,ty:Float,rz:Float,sx:Float,sy:Float )
		PushMatrix
		TranslateRotateScale tx,ty,rz,sx,sy
		AddShadowCaster caster
		PopMatrix
	End
	
	Method IsEmpty:Bool() Property
		Return _next=0
	End
	
	Method Compact:Void()
		If _data.Length=_next Return
		Local data:=New DataBuffer( _next,True )
		_data.CopyBytes 0,data,0,_next
		_data.Discard
		_data=data
	End
	
	Method Render:Void( op:DrawOp,index:Int,count:Int )
	
		If Not op.material.Bind() Return
		
		If op.blend<>rs_blend
			rs_blend=op.blend
			Select rs_blend
			Case .BlendMode.Opaque
				glDisable GL_BLEND
			Case .BlendMode.Alpha
				glEnable GL_BLEND
				glBlendFunc GL_ONE,GL_ONE_MINUS_SRC_ALPHA
			Case .BlendMode.Additive
				glEnable GL_BLEND
				glBlendFunc GL_ONE,GL_ONE
			Case .BlendMode.Multiply
				glEnable GL_BLEND
				glBlendFunc GL_DST_COLOR,GL_ONE_MINUS_SRC_ALPHA
			Case .BlendMode.Multiply2
				glEnable GL_BLEND
				glBlendFunc GL_DST_COLOR,GL_ZERO
			Case.BlendMode.Alpha2
				glEnable(GL_BLEND)
				glBlendFuncSeparate(GL_ZERO, GL_ONE, GL_ONE, GL_ZERO)
			Case.BlendMode.Opaque2
				glEnable(GL_BLEND)
				glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
			Case.BlendMode.AlphaStamp
				glEnable(GL_BLEND)
				glBlendFuncSeparate(GL_ZERO, GL_SRC_ALPHA, GL_ONE, GL_ZERO)
				glBlendEquation(GL_FUNC_ADD)
			End
		End
		
		Select op.order
		Case 1
			glDrawArrays GL_POINTS,index,count
		Case 2
			glDrawArrays GL_LINES,index,count
		Case 3
			glDrawArrays GL_TRIANGLES,index,count
		Case 4
			glDrawElements GL_TRIANGLES,count/4*6,GL_UNSIGNED_SHORT,(index/4*6 + (index&3)*MAX_QUAD_INDICES)*2
		Default
			Local j:=0
			While j<count
				glDrawArrays GL_TRIANGLE_FAN,index+j,op.order
				j+=op.order
			Wend
		End

	End
	
	Method Render:Void()
		If Not _next Return
		
		Local offset:=0,opid:=0,ops:=_ops.Data,length:=_ops.Length
		
		While offset<_next
		
			Local size:=_next-offset,lastop:=length
			
			If size>PRIM_VBO_SIZE
			
				size=0
				lastop=opid
				While lastop<length
					Local op:=ops[lastop]
					Local n:=op.count*BYTES_PER_VERTEX
					If size+n>PRIM_VBO_SIZE Exit
					size+=n
					lastop+=1
				Wend
				
				If Not size
					Local op:=ops[opid]
					Local count:=op.count
					While count
						Local n:=count
						If n>MAX_VERTICES n=MAX_VERTICES/op.order*op.order
						Local size:=n*BYTES_PER_VERTEX
						
						If VBO_ORPHANING_ENABLED glBufferData GL_ARRAY_BUFFER,PRIM_VBO_SIZE,Null,VBO_USAGE
						glBufferSubData GL_ARRAY_BUFFER,0,size,_data,offset
						
						Render op,0,n
						
						offset+=size
						count-=n
					Wend
					opid+=1
					Continue
				Endif
				
			Endif
			
			If VBO_ORPHANING_ENABLED glBufferData GL_ARRAY_BUFFER,PRIM_VBO_SIZE,Null,VBO_USAGE
			glBufferSubData GL_ARRAY_BUFFER,0,size,_data,offset
			
			Local index:=0
			While opid<lastop
				Local op:=ops[opid]
				Render op,index,op.count
				index+=op.count
				opid+=1
			Wend
			offset+=size
			
		Wend
		
		glGetError
		
	End
	
	Method Reset:Void()
		_next=0
		
		Local data:=_ops.Data
		For Local i:=0 Until _ops.Length
			data[i].material=Null
			freeOps.Push data[i]
		Next
		_ops.Clear
		_op=nullOp
		
		_casters.Clear
		_casterVerts.Clear
	End
	
	Method Flush:Void()
		Render
		Reset
	End
	
' 20180220, Holzchopf - ADDED premultiplying and reordering function for colors
	' Converts color from argb to abgr and premultiplies rgb
	' Returns abgr color
	Function PremultiplyArgb2Abgr:Int(color:Int)
		Local a:Int, r:Int, g:Int, b:Int
		Local fa:Float
		' extract color components
		a = (color Shr 24) & $ff
		r = (color Shr 16) & $ff
		g = (color Shr 08) & $ff
		b = (color       ) & $ff
		' premultiply
		fa = Float(a) / 255.0
		r *= fa
		g *= fa
		b *= fa
		' reorder
		Return (a Shl 24) | (b Shl 16) | (g Shl 08) | r
	End

	' Converts all colors from argb to abgr and premultiplies rgb
	Function PremultiplyArgb2Abgr:Void(colors:Int[])
		For Local i:Int = 0 Until colors.Length
			colors[i] = PremultiplyArgb2Abgr( colors[i] )
		Next
	End
	
	Protected

	Field _blend:=1
	Field _alpha:=255.0
	Field _color:=[1.0,1.0,1.0,1.0]
	Field _pmcolor:Int=$ffffffff
	Field _ix:Float=1,_iy:Float
	Field _jx:Float,_jy:Float=1
	Field _tx:Float,_ty:Float
	Field _matStack:Float[64*6]
	Field _matSp:Int
	Field _font:Font
	Field _defaultMaterial:Material

	' viewId in gles20 does nothing
	Field _viewId:Int
	
	Private
	
	Field _data:DataBuffer=New DataBuffer( 4096,True )
	Field _next:=0
	
	Field _op:=nullOp
	Field _ops:=New Stack<DrawOp>
	Field _casters:=New Stack<ShadowCaster>
	Field _casterVerts:=New FloatStack

	Method BeginPrim:Void( material:Material,order:Int ) Final
	
		If Not material material=_defaultMaterial
		
		If _next+order*BYTES_PER_VERTEX>_data.Length
'			Print "Resizing data"
			Local newsize:=Max( _data.Length+_data.Length/2,_next+order*BYTES_PER_VERTEX )
			Local data:=New DataBuffer( newsize,True )
			_data.CopyBytes 0,data,0,_next
			_data.Discard
			_data=data
		Endif
	
		If material=_op.material And _blend=_op.blend And order=_op.order
			_op.count+=order
			Return
		Endif
		
		If freeOps.Length _op=freeOps.Pop() Else _op=New DrawOp
		
		_ops.Push _op
		_op.material=material
		_op.blend=_blend
		_op.order=order
		_op.count=order
	End
	
	Method BeginPrims:Void( material:Material,order:Int,count:Int ) Final
	
		If Not material material=_defaultMaterial
		
		count*=order
		
		If _next+count*BYTES_PER_VERTEX>_data.Length
'			Print "Resizing data"
			Local newsize:=Max( _data.Length+_data.Length/2,_next+count*BYTES_PER_VERTEX )
			Local data:=New DataBuffer( newsize,True )
			_data.CopyBytes 0,data,0,_next
			_data.Discard
			_data=data
		Endif
	
		If material=_op.material And _blend=_op.blend And order=_op.order
			_op.count+=count
			Return
		Endif
		
		If freeOps.Length _op=freeOps.Pop() Else _op=New DrawOp
		
		_ops.Push _op
		_op.material=material
		_op.blend=_blend
		_op.order=order
		_op.count=count
	end
	
	Method PrimVert:Void( x0:Float,y0:Float,s0:Float,t0:Float ) Final
		_data.PokeFloat _next+0, x0 * _ix + y0 * _jx + _tx
		_data.PokeFloat _next+4, x0 * _iy + y0 * _jy + _ty
		_data.PokeFloat _next+8, s0
		_data.PokeFloat _next+12,t0
		_data.PokeFloat _next+16,_ix
		_data.PokeFloat _next+20,_iy
		_data.PokeInt   _next+24,_pmcolor
		_next+=BYTES_PER_VERTEX
	End
	
End

'***** Canvas *****

Class Canvas Extends DrawList

	Const ViewModeDefault:Int = 0
	Const ViewModeSequential:Int = 1
	Const ViewModeDepthAscending:Int = 2
	Const ViewModeDepthDescending:Int = 3

	Const MaxLights:=MAX_LIGHTS

	Method New( viewId:Int, target:Object=Null )

		' viewId in gles20 does nothing
		_viewId = viewId

		Init
		SetRenderTarget target
		SetViewport 0,0,_width,_height
		SetProjection2d 0,_width,0,_height
	End
	
	Method Discard:Void()
	End

	Method SetViewMode:Void( viewMode:Int )
		' do nothing in gles20
		' bgfxSetViewMode( _viewId, viewMode )
	End

	Method SetViewId:Void( viewId:Int )
		' viewId in gles20 does nothing
		_viewId = viewId
	End

	Method GetViewId:Int( )
		' viewId in gles20 does nothing
		Return _viewId
	End

	Method SetRenderTarget:Void( target:Object )

		FlushPrims
		
		If Not target
		
			_image=Null
			_texture=Null
			_width=DeviceWidth
			_height=DeviceHeight
			_twidth=_width
			_theight=_height
		
		Else If Image( target )
		
			_image=Image( target )
			_texture=_image.Material.ColorTexture
			If Not (_texture.Flags & Texture.RenderTarget) Error "Texture is not a render target texture"
			_width=_image.Width
			_height=_image.Height
			_twidth=_texture.Width
			_theight=_texture.Height
			
		Else If Texture( target )
		
			_image=Null
			_texture=Texture( target )
			If Not (_texture.Flags & Texture.RenderTarget) Error "Texture is not a render target texture"
			_width=_texture.Width
			_height=_texture.Height
			_twidth=_texture.Width
			_theight=_texture.Height
			
		Else
		
			Error "RenderTarget object must an Image, a Texture or Null"
			
		Endif
		
		_dirty=-1
		
	End

	Method RenderTarget:Object() Property
		If _image Return _image Else Return _texture
	End
	
	Method Width:Int() Property
		Return _width
	End
	
	Method Height:Int() Property
		Return _height
	End
	
	Method SetColorMask:Void( r:Bool,g:Bool,b:Bool,a:Bool )
		FlushPrims
		_colorMask[0]=r
		_colorMask[1]=g
		_colorMask[2]=b
		_colorMask[3]=a
		_dirty|=DIRTY_COLORMASK
	End
	
	Method ColorMask:Bool[]() Property
		Return _colorMask
	End
	
	Method SetViewport:Void( x:Int,y:Int,w:Int,h:Int )
		FlushPrims
		_viewport[0]=x
		_viewport[1]=y
		_viewport[2]=w
		_viewport[3]=h
		_dirty|=DIRTY_VIEWPORT
	End
	
	Method Viewport:Int[]() Property
		Return _viewport
	End
	
	Method SetScissor:Void( x:Int,y:Int,w:Int,h:Int )
		FlushPrims
		_scissor[0]=x
		_scissor[1]=y
		_scissor[2]=w
		_scissor[3]=h
		_dirty|=DIRTY_VIEWPORT
	End
	
	Method Scissor:Int[]() Property
		Return _scissor
	End
	
	' for compatibility with mojo 1
	Method Scissorf:Float[]() Property
		Return [ Float(_scissor[0]), Float(_scissor[1]), Float(_scissor[2]), Float(_scissor[3]) ]
	End

	' for compatibility with mojo 1
	Method Scissorf:Void( scissor:Float[] )
		scissor[0] = _scissor[0]
		scissor[1] = _scissor[1]
		scissor[2] = _scissor[2]
		scissor[3] = _scissor[3]
	End

	Method SetProjectionMatrix:Void( projMatrix:Float[] )
		FlushPrims
		If projMatrix
			Mat4Copy projMatrix,_projMatrix
		Else
			Mat4Init _projMatrix
		Endif
		_dirty|=DIRTY_SHADER
	End
	
	Method SetProjection2d:Void( left:Float,right:Float,top:Float,bottom:Float,znear:Float=-1,zfar:Float=1 )
		FlushPrims
		Mat4Ortho left,right,top,bottom,znear,zfar,_projMatrix
		_dirty|=DIRTY_SHADER
	End
	
	Method ProjectionMatrix:Float[]() Property
		Return _projMatrix
	End
	
	Method SetViewMatrix:Void( viewMatrix:Float[] )
		FlushPrims
		If viewMatrix
			Mat4Copy viewMatrix,_viewMatrix
		Else
			Mat4Init _viewMatrix
		End
		_dirty|=DIRTY_SHADER
	End
	
	Method ViewMatrix:Float[]() Property
		Return _viewMatrix
	End
	
	Method SetModelMatrix:Void( modelMatrix:Float[] )
		FlushPrims
		If modelMatrix
			Mat4Copy modelMatrix,_modelMatrix
		Else
			Mat4Init _modelMatrix
		Endif
		_dirty|=DIRTY_SHADER
	End
	
	Method ModelMatrix:Float[]() Property
		Return _modelMatrix
	End

	Method SetAmbientLight:Void( r:Float,g:Float,b:Float,a:Float=1 )
		FlushPrims
		_ambientLight[0]=r
		_ambientLight[1]=g
		_ambientLight[2]=b
		_ambientLight[3]=a
		_dirty|=DIRTY_SHADER
	End
	
	Method AmbientLight:Float[]() Property
		Return _ambientLight
	End
	
	Method SetFogColor:Void( r:Float,g:Float,b:Float,a:Float )
		FlushPrims
		_fogColor[0]=r
		_fogColor[1]=g
		_fogColor[2]=b
		_fogColor[3]=a
		_dirty|=DIRTY_SHADER
	End
	
	Method FogColor:Float[]() Property
		Return _fogColor
	End
	
	Method SetLightType:Void( index:Int,type:Int )
		FlushPrims
		Local light:=_lights[index]
		light.type=type
		_dirty|=DIRTY_SHADER
	End
	
	Method GetLightType:Int( index:Int )
		Return _lights[index].type
	End
	
	Method SetLightColor:Void( index:Int,r:Float,g:Float,b:Float,a:Float=1 )
		FlushPrims
		Local light:=_lights[index]
		light.color[0]=r
		light.color[1]=g
		light.color[2]=b
		light.color[3]=a
		_dirty|=DIRTY_SHADER
	End
	
	Method GetLightColor:Float[]( index:Int )
		Return _lights[index].color
	End
	
	Method SetLightPosition:Void( index:Int,x:Float,y:Float,z:Float )
		FlushPrims
		Local light:=_lights[index]
		light.position[0]=x
		light.position[1]=y
		light.position[2]=z
		light.vector[0]=x
		light.vector[1]=y
		light.vector[2]=z
		_dirty|=DIRTY_SHADER
	End
	
	Method GetLightPosition:Float[]( index:Int )
		Return _lights[index].position
	End
	
	Method SetLightRange:Void( index:Int,range:Float )
		FlushPrims
		Local light:=_lights[index]
		light.range=range
		_dirty|=DIRTY_SHADER
	End
	
	Method GetLightRange:Float( index:Int )
		Return _lights[index].range
	End
	
	Method SetShadowMap:Void( image:Image )
		FlushPrims
		_shadowMap=image
		_dirty|=DIRTY_SHADER
	End
	
	Method ShadowMap:Image() Property
		Return _shadowMap
	End
	
	Method SetLineWidth:Void( lineWidth:Float )
		FlushPrims
		_lineWidth=lineWidth
		_dirty|=DIRTY_LINEWIDTH
	End
	
	Method LineWidth:Float() Property
		Return _lineWidth
	End
	
	Method Clear:Void( r:Float=0,g:Float=0,b:Float=0,a:Float=1 )
		FlushPrims
		Validate
		If _clsScissor
			glEnable GL_SCISSOR_TEST
			glScissor _vpx,_vpy,_vpw,_vph
		Endif
		glClearColor r,g,b,a
		glClear GL_COLOR_BUFFER_BIT
		If _clsScissor glDisable GL_SCISSOR_TEST
	End
	
	Method ReadPixels:Void( x:Int,y:Int,width:Int,height:Int,data:DataBuffer,dataOffset:Int=0,dataPitch:Int=0 )
	
		FlushPrims
		
		If Not dataPitch Or dataPitch=width*4
			glReadPixels x,y,width,height,GL_RGBA,GL_UNSIGNED_BYTE,data,dataOffset
		Else
			For Local iy:=0 Until height
				glReadPixels x,y+iy,width,1,GL_RGBA,GL_UNSIGNED_BYTE,data,dataOffset+dataPitch*iy
			Next
		Endif

	End

	Method RenderDrawList:Void( drawbuf:DrawList )
	
		Local fast:=_ix=1 And _iy=0 And _jx=0 And _jy=1 And _tx=0 And _ty=0 And _color[0]=1 And _color[1]=1 And _color[2]=1 And _color[3]=1
		
		If fast
			FlushPrims
			Validate
			drawbuf.Render
			Return
		Endif
		
		tmpMat3d[0]=_ix
		tmpMat3d[1]=_iy
		tmpMat3d[4]=_jx
		tmpMat3d[5]=_jy
		tmpMat3d[12]=_tx
		tmpMat3d[13]=_ty
		tmpMat3d[10]=1
		tmpMat3d[15]=1
		
		Mat4Multiply _modelMatrix,tmpMat3d,tmpMat3d2
		
		FlushPrims
		
		Local tmp:=_modelMatrix
		_modelMatrix=tmpMat3d2
		rs_globalColor[0]=_color[0]*_color[3]
		rs_globalColor[1]=_color[1]*_color[3]
		rs_globalColor[2]=_color[2]*_color[3]
		rs_globalColor[3]=_color[3]
		_dirty|=DIRTY_SHADER
		
		Validate
		drawbuf.Render
		
		_modelMatrix=tmp
		rs_globalColor[0]=1
		rs_globalColor[1]=1
		rs_globalColor[2]=1
		rs_globalColor[3]=1
		_dirty|=DIRTY_SHADER
	End
	
	Method RenderDrawList:Void( drawList:DrawList,tx:Float,ty:Float,rz:Float=0,sx:Float=1,sy:Float=1 )
		Super.PushMatrix
		Super.TranslateRotateScale tx,ty,rz,sx,sy
		RenderDrawList( drawList )
		Super.PopMatrix
	End

#rem	
	Method RenderDrawListEx:Void( drawbuf:DrawList,tx:Float=0,ty:Float=0,rz:Float=0,sx:Float=1,sy:Float=1 )
	
		Super.PushMatrix
		Super.TranslateRotateScale tx,ty,rz,sx,sy
		Super.GetMatrix tmpMat2d
		Super.PopMatrix
		
		tmpMat3d[0]=tmpMat2d[0]
		tmpMat3d[1]=tmpMat2d[1]
		tmpMat3d[4]=tmpMat2d[2]
		tmpMat3d[5]=tmpMat2d[3]
		tmpMat3d[12]=tmpMat2d[4]
		tmpMat3d[13]=tmpMat2d[5]
		tmpMat3d[10]=1
		tmpMat3d[15]=1
		
		Local tmp:=_modelMatrix
		
		Mat4Multiply tmp,tmpMat3d,tmpMat3d2
		
		FlushPrims
		
		_modelMatrix=tmpMat3d2
		_dirty|=DIRTY_SHADER
		
		Validate
		drawbuf.Render
		
		_modelMatrix=tmp
		_dirty|=DIRTY_SHADER
	End
#end

	Method Flush:Void()
		FlushPrims
		
		If Not _texture Return
		
		If _texture._flags & Texture.Managed
			Validate

			glDisable GL_SCISSOR_TEST
			glViewport 0,0,_twidth,_theight
			
			If _width=_twidth And _height=_theight
				glReadPixels 0,0,_twidth,_theight,GL_RGBA,GL_UNSIGNED_BYTE,DataBuffer( _texture._data )
			Else
				For Local y:=0 Until _height
					glReadPixels _image._x,_image._y+y,_width,1,GL_RGBA,GL_UNSIGNED_BYTE,DataBuffer( _texture._data ),(_image._y+y) * (_twidth*4) + (_image._x*4)
				Next
			Endif

			_dirty|=DIRTY_VIEWPORT
		Endif

		_texture.UpdateMipmaps
	End
	
	Global _tformInvProj:Float[16]
	Global _tformT:Float[]=[0.0,0.0,-1.0,1.0]
	Global _tformP:Float[4]
	
	Method TransformCoords:Void( coords_in:Float[],coords_out:Float[],mode:Int=0 )
	
		Mat4Inverse _projMatrix,_tformInvProj

		Select mode
		Case 0
			_tformT[0]=(coords_in[0]-_viewport[0])/_viewport[2]*2-1
			_tformT[1]=(coords_in[1]-_viewport[1])/_viewport[3]*2-1
			Mat4Transform _tformInvProj,_tformT,_tformP
			_tformP[0]/=_tformP[3];_tformP[1]/=_tformP[3];_tformP[2]/=_tformP[3];_tformP[3]=1
			coords_out[0]=_tformP[0]
			coords_out[1]=_tformP[1]
			If coords_out.Length>2 coords_out[2]=_tformP[2]
		Default
			Error "Invalid TransformCoords mode"
		End
	End
	
	Private

	Const DIRTY_RENDERTARGET:=1
	Const DIRTY_VIEWPORT:=2
	Const DIRTY_SHADER:=4
	Const DIRTY_LINEWIDTH:=8
	Const DIRTY_COLORMASK:=16
		
	Field _seq:Int
	Field _dirty:Int=-1
	Field _image:Image
	Field _texture:Texture	
	Field _width:Int
	Field _height:Int
	Field _twidth:Int
	Field _theight:Int
	Field _shadowMap:Image
	Field _colorMask:=[True,True,True,True]
	Field _viewport:=[0,0,640,480]
	Field _scissor:=[0,0,10000,10000]
	Field _vpx:Int,_vpy:Int,_vpw:Int,_vph:Int
	Field _scx:Int,_scy:Int,_scw:Int,_sch:Int
	Field _clsScissor:Bool
	Field _projMatrix:=Mat4New()
	Field _invProjMatrix:=Mat4New()
	Field _viewMatrix:=Mat4New()
	Field _modelMatrix:=Mat4New()
	Field _ambientLight:=[0.0,0.0,0.0,1.0]
	Field _fogColor:=[0.0,0.0,0.0,0.0]
	Field _lights:LightData[4]
	Field _lineWidth:Float=1

	Global _active:Canvas
	
	Method Init:Void()
		_dirty=-1
		For Local i:=0 Until MAX_LIGHTS
			_lights[i]=New LightData
		Next
	End

	Method FlushPrims:Void()
		If Super.IsEmpty Return
		Validate
		Super.Flush
	End
	
	Method Validate:Void()
		If _seq<>graphicsSeq	
			_seq=graphicsSeq
			InitVbos
			If Not _texture
				_width=DeviceWidth
				_height=DeviceHeight
				_twidth=_width
				_theight=_height
			Endif
			_dirty=-1
		Endif
	
		If _active=Self
			If Not _dirty Return
		Else
			If _active _active.Flush
			_active=Self
			_dirty=-1
		Endif

'		_dirty=-1
		
		If _dirty & DIRTY_RENDERTARGET

			If _texture
				glBindFramebuffer GL_FRAMEBUFFER,_texture.GLFramebuffer()
			Else
				glBindFramebuffer GL_FRAMEBUFFER,defaultFbo
			Endif
		End
		
		If _dirty & DIRTY_VIEWPORT
		
			If Not _texture
				_width=DeviceWidth
				_height=DeviceHeight
				_twidth=_width
				_theight=_height
			Endif
		
			_vpx=_viewport[0];_vpy=_viewport[1];_vpw=_viewport[2];_vph=_viewport[3]
			If _image
				_vpx+=_image._x
				_vpy+=_image._y
			Endif
			
			_scx=_scissor[0];_scy=_scissor[1];_scw=_scissor[2];_sch=_scissor[3]
			
			If _scx<0 _scx=0 Else If _scx>_vpw _scx=_vpw
			If _scw<0 _scw=0 Else If _scx+_scw>_vpw _scw=_vpw-_scx
			
			If _scy<0 _scy=0 Else If _scy>_vph _scy=_vph
			If _sch<0 _sch=0 Else If _scy+_sch>_vph _sch=_vph-_scy
			
			_scx+=_vpx;_scy+=_vpy
		
			If Not _texture
				_vpy=_theight-_vpy-_vph
				_scy=_theight-_scy-_sch
			Endif
			
			glViewport _vpx,_vpy,_vpw,_vph
			
			If _scx<>_vpx Or _scy<>_vpy Or _scw<>_vpw Or _sch<>_vph
				glEnable GL_SCISSOR_TEST
				glScissor _scx,_scy,_scw,_sch
				_clsScissor=False
			Else
				glDisable GL_SCISSOR_TEST
				_clsScissor=(_scx<>0 Or _scy<>0 Or _vpw<>_twidth Or _vph<>_theight)
			Endif
			
		Endif
		
		If _dirty & DIRTY_SHADER
		
			rs_program=Null
			
			If _texture
				rs_clipPosScale[1]=1
				Mat4Copy _projMatrix,rs_projMatrix
			Else
				rs_clipPosScale[1]=-1
				Mat4Multiply flipYMatrix,_projMatrix,rs_projMatrix
			Endif
			
			Mat4Multiply _viewMatrix,_modelMatrix,rs_modelViewMatrix
			Mat4Multiply rs_projMatrix,rs_modelViewMatrix,rs_modelViewProjMatrix
			Vec4Copy _ambientLight,rs_ambientLight
			Vec4Copy _fogColor,rs_fogColor
			
			rs_numLights=0
			For Local i:=0 Until MAX_LIGHTS

				Local light:=_lights[i]
				If Not light.type Continue
				
				Mat4Transform _viewMatrix,light.vector,light.tvector
				
				rs_lightColors[rs_numLights*4+0]=light.color[0]
				rs_lightColors[rs_numLights*4+1]=light.color[1]
				rs_lightColors[rs_numLights*4+2]=light.color[2]
				rs_lightColors[rs_numLights*4+3]=light.color[3]
				
				rs_lightVectors[rs_numLights*4+0]=light.tvector[0]
				rs_lightVectors[rs_numLights*4+1]=light.tvector[1]
				rs_lightVectors[rs_numLights*4+2]=light.tvector[2]
				rs_lightVectors[rs_numLights*4+3]=light.range

				rs_numLights+=1
			Next
			
			If _shadowMap
				rs_shadowTexture=_shadowMap._material._colorTexture
			Else 
				rs_shadowTexture=Null
			Endif
			
			rs_blend=-1

		End
		
		If _dirty & DIRTY_LINEWIDTH
			glLineWidth _lineWidth
		Endif
		
		If _dirty & DIRTY_COLORMASK
			glColorMask _colorMask[0],_colorMask[1],_colorMask[2],_colorMask[3]
		End
		
		_dirty=0
	End
	
End
