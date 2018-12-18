
#If TARGET="html5"
	Import graphicsgles20
#Else
	Import graphicsbgfx
#Endif

Import brl.databuffer

'***** Image *****

Class Image

	Const MidHandle:Int = 1
	Const XPadding:Int = 2
	Const YPadding:Int = 4
	Const XYPadding:Int = XPadding | YPadding
	Global DefaultFlags:Int = 0

	Const Filter:=Texture.Filter
	Const Mipmap:=Texture.Mipmap
	Const Managed:=Texture.Managed
	
	Method New( width:Int,height:Int,alignX:Float=.5,alignY:Float=.5,flags:Int=Image.Filter )
		Print "Image width=" + width + " height=" + height
		flags&=_flagsMask
		Local texture:=New Texture( width,height,4,flags|Texture.ClampST|Texture.RenderTarget )
		_material=New Material( fastShader )
'  		_material=New Material( mojo1Shader )
		_material.SetTexture "ColorTexture",texture
		texture.Release()
		_width=width
		_height=height
		SetAlign alignX,alignY
	End
	
	Method New( image:Image,x:Int,y:Int,width:Int,height:Int,alignX:Float=.5,alignY:Float=.5 )
		_material=image._material
		_x=image._x+x
		_y=image._y+y
		_width=width
		_height=height
		SetAlign alignX,alignY
	End
	
	Method New( material:Material,alignX:Float=.5,alignY:Float=.5 )
		Local texture:=material.ColorTexture
		If Not texture Error "Material has no ColorTexture"
		_material=material
		_width=_material.Width
		_height=_material.Height
		SetAlign alignX,alignY
	End

	Method New( material:Material,x:Int,y:Int,width:Int,height:Int,alignX:Float=.5,alignY:Float=.5 )
		Local texture:=material.ColorTexture
		If Not texture Error "Material has no ColorTexture"
		_material=material
		_x=x
		_y=y
		_width=width
		_height=height
		SetAlign alignX,alignY
	End

	Method Discard:Void()
		If _material _material.Release
		_material=Null
	End
	
	Method Material:Material() Property
		Return _material
	End
	
	Method X0:Float() Property
		Return _x0
	End
	
	Method Y0:Float() Property
		Return _y0
	End
	
	Method X1:Float() Property
		Return _x1
	End
	
	Method Y1:Float() Property
		Return _y1
	End
	
	Method Width:Int() Property
		Return _width
	End
	
	Method Height:Int() Property
		Return _height
	End
	
	Method HandleXf:Float() Property
		Return -_x0/(_x1-_x0)
	End
	
	Method HandleYf:Float() Property
		Return -_y0/(_y1-_y0)
	End

	Method HandleX:Float() Property
'  		Return HandleXf * _width
		Return _handleWidth
	End
	
	Method HandleY:Float() Property
'  		Return HandleYf * _height
		Return _handleHeight
	End
	
	Method WritePixels:Void( x:Int,y:Int,width:Int,height:Int,data:DataBuffer,dataOffset:Int=0,dataPitch:Int=0 )
		_material.ColorTexture.WritePixels( x+_x,y+_y,width,height,data,dataOffset,dataPitch )
	End

	Method WritePixels:Void( pixels:Int[], x:Int, y:Int, width:Int, height:Int, arrayOffset:Int=0, arrayPitch:Int=0, frame:Int=0 )

		' TODO frame

		Local address:Int = 0

		Local length:Int = pixels.Length()
		Local data:DataBuffer = New DataBuffer( length * 4 )
		
		For Local i:Int = 0 Until length
			Local pixel:Int = pixels[ i ]
			Local alpha:Int = (pixel & $ff000000)
			Local red:Int = (pixel & $00ff0000) Shr 16
			Local green:Int = (pixel & $0000ff00)
			Local blue:Int = (pixel & $000000ff) Shl 16
			Local rgba:Int = alpha | blue | green | red
			data.PokeInt( address, rgba )
			address += 4
		Next

		WritePixels( x, y, width, height, data, arrayOffset*4, arrayPitch*4 )

		data.Discard()
	End

	Method SetAlign:Void( alignX:Float, alignY:Float)

		_handleWidth = alignX * _width
		_handleHeight = alignY * _height

		_x0=Float(_width)*-alignX
		_x1=Float(_width)*(1-alignX)
		_y0=Float(_height)*-alignY
		_y1=Float(_height)*(1-alignY)

		_s0=Float(_x)/Float(_material.Width)
		_t0=Float(_y)/Float(_material.Height)
		_s1=Float(_x+_width)/Float(_material.Width)
		_t1=Float(_y+_height)/Float(_material.Height)

		If _frameCount <= 1 Then
			_frames0[0]=_s0
			_framet0[0]=_t0
			_frames1[0]=_s1
			_framet1[0]=_t1
		Else
			For Local frame:Int = 0 Until _frameCount
				Local frameX:Int = frame Mod _frameCountX
				Local frameY:Int = frame / _frameCountX
				_frames0[ frame ] = Float(_x + frameX * _frameWidth)  / Float(_material.Width)
				_framet0[ frame ] = Float(_y + frameY * _frameHeight) / Float(_material.Height)
				_frames1[ frame ] = Float(_x + _width  + frameX * _frameWidth)  / Float(_material.Width)
				_framet1[ frame ] = Float(_y + _height + frameY * _frameHeight) / Float(_material.Height)
			Next
		Endif

	End

'  	Method SetHandle:Void( xhandle:Float,yhandle:Float )
	Method SetHandle:Void( tx:Float,ty:Float )
		SetAlign( tx / _width, ty / _height )
	End
	
	Method SetShadowCaster:Void( shadowCaster:ShadowCaster )
		_caster=shadowCaster
	End
	
	Method ShadowCaster:ShadowCaster() Property
		Return _caster
	End
	
	Method Loading:Bool()
		Return _material.Loading()
	End
	
	Function ImagesLoading:Bool()
		Return Texture.TexturesLoading>0
	End
	
	Function SetFlagsMask:Void( mask:Int )
		_flagsMask=mask
	End
	
	Function FlagsMask:Int()
		Return _flagsMask
	End
	
	Function Load:Image( path:String,xhandle:Float=.5,yhandle:Float=.5,flags:Int=Image.Filter|Image.Mipmap,shader:Shader=Null )
		flags&=_flagsMask
	
		Local material:=.Material.Load( path,flags|Texture.ClampST,shader )
		If Not material 
			DebugLog ("Error - Unable to load image: " + path)
			Return Null
		Endif

		Return New Image( material,xhandle,yhandle )
	End
	
	Function LoadFrames:Image[]( path:String,numFrames:Int,padded:Bool=False,xhandle:Float=.5,yhandle:Float=.5,flags:Int=Image.Filter|Image.Mipmap,shader:Shader=Null )
		flags&=_flagsMask
	
		Local material:=.Material.Load( path,flags|Texture.ClampST,shader )
		If Not material 
			DebugLog ("Error - Unable to load image frames: " + path)
			Return []
		Endif
		
		Local cellWidth:=material.Width/numFrames,cellHeight:=material.Height
		
		Local x:=0,width:=cellWidth
		If padded x+=1;width-=2
		
		Local frames:=New Image[numFrames]
		
		For Local i:=0 Until numFrames
			frames[i]=New Image( material,i*cellWidth+x,0,width,cellHeight,xhandle,yhandle )
		Next
		
		Return frames
	End

'  	Method InitMojo1Image:Void( frameCount:Int, mojo1Flags:Int, xhandle:Float, yhandle:Float )
'  
'  		' default frame count is 1
'  		If frameCount <= 0 Then
'  			frameCount = 1
'  		Endif
'  
'  		_frameCount = frameCount
'  		_width /= frameCount
'  		_frameWidth = _width
'  
'  		_frames0 = New Float[ _frameCount ]
'  		_frames1 = New Float[ _frameCount ]
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
'  			_frames0[ frame ]=Float(_x+frame*_frameWidth)/Float(_material.Width)
'  			_frames1[ frame ]=Float(_x+_width+frame*_frameWidth)/Float(_material.Width)
'  		Next
'  	End

	Method InitMojo1Image:Void( frameWidth:Int, frameHeight:Int, frameCount:Int, mojo1Flags:Int, alignX:Float, alignY:Float )

		_mojo1Flags = mojo1Flags

		_frameCountX = _width / frameWidth
'  		_frameCountY = _height / frameHeight

		' default frame count is 1
		If frameCount <= 0 Then frameCount = 1
		If _frameCountX <= 0 Then _frameCountX = 1
'  		If _frameCountY < 0 Then _frameCountY = 1

		_frameCount = frameCount

		_width = frameWidth
		_height = frameHeight

		_frameWidth = frameWidth
		_frameHeight = frameHeight

		If _frameCount > 1 Then
			_frames0 = _frames0.Resize( _frameCount ) ' New Float[ _frameCount ]
			_framet0 = _framet0.Resize( _frameCount ) ' New Float[ _frameCount ]
			_frames1 = _frames1.Resize( _frameCount ) ' New Float[ _frameCount ]
			_framet1 = _framet1.Resize( _frameCount ) ' New Float[ _frameCount ]
		Endif

		If mojo1Flags & XPadding Then
			_x += 1
			_width -= 2
		Endif

		If mojo1Flags & YPadding Then
			_y += 1
			_height -= 2
		Endif

		SetAlign( alignX, alignY )
	End

	Method GrabImage:Image( x:Int, y:Int, width:Int, height:Int, frameCount:Int=1, mojo1Flags:Int=DefaultFlags )

		Local xhandle:Float = 0.0
		Local yhandle:Float = 0.0

		If mojo1Flags & MidHandle Then
			xhandle = 0.5
			yhandle = 0.5
		Endif

		width *= frameCount

'  		Return (New Image).Init( surface,x,y,width,height,nframes,flags,Self,frames[0].x,frames[0].y,Self.width,Self.height )
		Local result:Image = New Image( Self, x, y, width, height, xhandle, yhandle )

		result.InitMojo1Image( result._width / frameCount, result._height, frameCount, mojo1Flags, xhandle, yhandle )

		Return result
	End

	Function CreateMojo1:Image( width:Int, height:Int, frameCount:Int=1, mojo1Flags:Int=Image.DefaultFlags )

		Local xhandle:Float = 0.0
		Local yhandle:Float = 0.0

		If mojo1Flags & MidHandle Then
			xhandle = 0.5
			yhandle = 0.5
		Endif

		Local result:Image = New Image( width, height, xhandle, yhandle )

		result.InitMojo1Image( result._width / frameCount, result._height, frameCount, mojo1Flags, xhandle, yhandle )

		Return result
	End

	Function LoadMojo1:Image( path:String, frameCount:Int=1, mojo1Flags:Int=DefaultFlags, flags:Int=Image.Filter|Image.Mipmap, shader:Shader=Null )

		flags&=_flagsMask

		Local material:=.Material.Load( path,flags|Texture.ClampST,shader )
		If Not material 
			DebugLog ("Error - Unable to load image: " + path)
			Return Null
		Endif

		Local xhandle:Float = 0.0
		Local yhandle:Float = 0.0

		If mojo1Flags & MidHandle Then
			xhandle = 0.5
			yhandle = 0.5
		Endif

		Local result:Image = New Image( material, xhandle, yhandle )

		result.InitMojo1Image( result._width / frameCount, result._height, frameCount, mojo1Flags, xhandle, yhandle )

		Return result
	End

	Function LoadMojo1:Image( path:String, frameWidth:Int, frameHeight:Int, frameCount:Int, mojo1Flags:Int=Image.DefaultFlags, flags:Int=Image.Filter|Image.Mipmap, shader:Shader=Null )

		flags&=_flagsMask

		Local material:=.Material.Load( path,flags|Texture.ClampST,shader )
		If Not material 
			DebugLog ("Error - Unable to load image: " + path)
			Return Null
		Endif

		Local xhandle:Float = 0.0
		Local yhandle:Float = 0.0

		If mojo1Flags & MidHandle Then
			xhandle = 0.5
			yhandle = 0.5
		Endif

		Local result:Image = New Image( material, xhandle, yhandle )

		result.InitMojo1Image( frameWidth, frameHeight, frameCount, mojo1Flags, xhandle, yhandle )

		Return result
	End

	Method Frames:Int()
		Return _frameCount
	End

	Method Flags:Int()
		Return _mojo1Flags
	End

'  	Private
	
	Global _flagsMask:=Filter|Mipmap|Managed
	
	Field _material:Material
	Field _x:Int,_y:Int,_width:Int,_height:Int
	Field _x0:Float=-1,_y0:Float=-1,_x1:Float=1,_y1:Float=1
	Field _s0:Float=0 ,_t0:Float=0 ,_s1:Float=1,_t1:Float=1

	Field _frameCount:Int=1,_frameCountX:Int=1 ' ,_frameCountY:Int=1
	Field _frameWidth:Int,_frameHeight:Int
	Field _frames0:Float[1],_frames1:Float[1]
	Field _framet0:Float[1],_framet1:Float[1]
	Field _handleWidth:Float, _handleHeight:Float
	Field _mojo1Flags:Int

	Field _caster:ShadowCaster

'	Method SetFrame:Void( x0:Float,y0:Float,x1:Float,y1:Float,s0:Float,t0:Float,s1:Float,t1:Float )
'		_x0=x0;_y0=y0;_x1=x1;_y1=y1
'		_s0=s0;_t0=t0;_s1=s1;_t1=t1
'	End
	
End
