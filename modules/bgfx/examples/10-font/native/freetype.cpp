
class ft_library_object : public Object
{
public:
	FT_Library _library;

	ft_library_object()
	{
	}
	~ft_library_object()
	{
	}
};

class ft_size_metrics_object : public Object
{
public:
	FT_Size_Metrics * _metrics;

	ft_size_metrics_object()
	{
	}
	~ft_size_metrics_object()
	{
	}

	int XPpem()
	{
		return _metrics->x_ppem;
	}

	int YPpem()
	{
		return _metrics->y_ppem;
	}

	int XScale()
	{
		return _metrics->x_scale;
	}

	int YScale()
	{
		return _metrics->y_scale;
	}

	int Ascender()
	{
		return _metrics->ascender;
	}

	int Descender()
	{
		return _metrics->descender;
	}

	int Height()
	{
		return _metrics->height;
	}

	int MaxAdvance()
	{
		return _metrics->max_advance;
	}
};

class ft_size_object : public Object
{
public:
	FT_Size _size;

	ft_size_object()
	{
	}
	~ft_size_object()
	{
	}

	void Metrics( ft_size_metrics_object * metrics )
	{
		metrics->_metrics = &_size->metrics;
	}
};

class ft_glyphslot_object : public Object
{
public:
	FT_GlyphSlot _glyphSlot;

	ft_glyphslot_object()
	{
	}
	~ft_glyphslot_object()
	{
	}

	int AdvanceX()
	{
		return _glyphSlot->advance.x;
	}

	int AdvanceY()
	{
		return _glyphSlot->advance.y;
	}
};

class ft_face_object : public Object
{
public:
	FT_Face _face;

	ft_face_object()
	{
	}
	~ft_face_object()
	{
	}

	int FaceFlags()
	{
		return (int)_face->face_flags;
	}

	int UnderlinePosition()
	{
		return _face->underline_position;
	}

	int UnderlineThickness()
	{
		return _face->underline_thickness;
	}

	void Size( ft_size_object * size )
	{
		size->_size = _face->size;
	}

	void GlyphSlot( ft_glyphslot_object * glyphSlot )
	{
		glyphSlot->_glyphSlot = _face->glyph;
	}
};


class ft_bitmap_object : public Object
{
public:
	FT_Bitmap * _bitmap;

	ft_bitmap_object()
	{
	}
	~ft_bitmap_object()
	{
	}

	int Rows()        { return _bitmap->rows;         }
	int Width()       { return _bitmap->width;        }
	int Pitch()       { return _bitmap->pitch;        }
	int NumGrays()    { return _bitmap->num_grays;    }
	int PixelMode()   { return _bitmap->pixel_mode;   }
	int PaletteMode() { return _bitmap->palette_mode; }

	void PokeByte  ( int addr, int value   ) { *         (_bitmap->buffer + addr) = value; }
	void PokeShort ( int addr, int value   ) { *(short *)(_bitmap->buffer + addr) = value; }
	void PokeInt   ( int addr, int value   ) { *(int   *)(_bitmap->buffer + addr) = value; }
	void PokeFloat ( int addr, float value ) { *(float *)(_bitmap->buffer + addr) = value; }

	int   PeekByte  ( int addr ) { return *         (_bitmap->buffer + addr); }
	int   PeekShort ( int addr ) { return *(short *)(_bitmap->buffer + addr); }
	int   PeekInt   ( int addr ) { return *(int   *)(_bitmap->buffer + addr); }
	float PeekFloat ( int addr ) { return *(float *)(_bitmap->buffer + addr); }
};

class ft_bitmapglyph_object;

class ft_glyph_object : public Object
{
public:
	FT_Glyph _glyph;

	ft_glyph_object()
	{
	}
	~ft_glyph_object()
	{
	}

	void BitmapGlyph( ft_bitmapglyph_object * bitmapGlyph );
};

class ft_bitmapglyph_object : public Object
{
public:
	FT_BitmapGlyph _bitmapGlyph;

	ft_bitmapglyph_object()
	{
	}
	~ft_bitmapglyph_object()
	{
	}

	void Glyph( ft_glyph_object * glyph )
	{
		glyph->_glyph = &_bitmapGlyph->root;
	}

	int Left()
	{
		return _bitmapGlyph->left;
	}

	int Top()
	{
		return _bitmapGlyph->top;
	}

	void Bitmap( ft_bitmap_object * bitmap )
	{
		bitmap->_bitmap = &_bitmapGlyph->bitmap;
	}
};

void ft_glyph_object::BitmapGlyph( ft_bitmapglyph_object * bitmapGlyph )
{
	bitmapGlyph->_bitmapGlyph = (FT_BitmapGlyph)_glyph;
}

class ft_vector_object : public Object
{
public:
	FT_Vector * _vector;

	ft_vector_object()
	{
	}
	~ft_vector_object()
	{
	}
};

/*
// Function bgfxMakeRef:Void( _mem:BgfxMemory, _data:DataBuffer )="_bgfx_make_ref"
// Function bgfxMakeRef:Void( _mem:BgfxMemory, _data:DataBuffer, _size:Int )="_bgfx_make_ref"
// BGFX_C_API const bgfx_memory_t* bgfx_make_ref(const void* _data, uint32_t _size);
void _bgfx_make_ref( bgfx_memory_object * _mem, BBDataBuffer * _data, int _index, int _size )
{
	_mem->_mem = (bgfx_memory_t *)bgfx_make_ref( _data->ReadPointer(_index), _size );
	//printf ("_index=%d _size=%d\n", _index, _size);
}
void _bgfx_make_ref( bgfx_memory_object * _mem, BBDataBuffer * _data, int _size )
{
	_mem->_mem = (bgfx_memory_t *)bgfx_make_ref( _data->ReadPointer(0), _size );
	// printf ("_mem->_mem->size=%d\n", _mem->_mem->size);
}
void _bgfx_make_ref( bgfx_memory_object * _mem, BBDataBuffer * _data )
{
	_bgfx_make_ref( _mem, _data, _data->Length() );
}
*/

int _ft_init_freetype( ft_library_object * _library )
{
	return (int)FT_Init_FreeType( &_library->_library );
}

int _ft_new_memory_face( ft_library_object * _library, BBDataBuffer * _fileBase, int _fileSize, int _faceIndex, ft_face_object * _face )
{
	return (int)FT_New_Memory_Face( _library->_library, ( FT_Byte * )_fileBase->ReadPointer(0), _fileSize, _faceIndex, &_face->_face );
}

int _ft_select_charmap( ft_face_object * _face, int _encoding )
{
	return (int)FT_Select_Charmap( _face->_face, ( FT_Encoding )_encoding );
}

int _ft_set_pixel_sizes( ft_face_object * _face, int _pixelWidth, int _pixelHeight )
{
	return (int)FT_Set_Pixel_Sizes( _face->_face, _pixelWidth, _pixelHeight );
}

int _ft_done_face( ft_face_object * _face )
{
	return (int)FT_Done_Face( _face->_face );
}

int _ft_done_freetype( ft_library_object * _library )
{
	return (int)FT_Done_FreeType( _library->_library );
}

int _ft_mulfix( int _a, int _b )
{
	return FT_MulFix( _a, _b );
}

int _ft_get_char_index( ft_face_object * _face, int _charCode )
{
	return FT_Get_Char_Index( _face->_face, _charCode );
}

int _ft_load_glyph( ft_face_object * _face, int _glyphIndex, int _loadFlags )
{
	return FT_Load_Glyph( _face->_face, _glyphIndex, _loadFlags );
}

int _ft_get_glyph( ft_glyphslot_object * _glyphSlot, ft_glyph_object * _glyph )
{
	return FT_Get_Glyph( _glyphSlot->_glyphSlot, &_glyph->_glyph );
}

int _ft_glyph_to_bitmap( ft_glyph_object * _glyph, int _renderMode, int _destroy )
{
	return FT_Glyph_To_Bitmap( &_glyph->_glyph, ( FT_Render_Mode )_renderMode, 0, _destroy );
}
int _ft_glyph_to_bitmap( ft_glyph_object * _glyph, int _renderMode, ft_vector_object * _origin, int _destroy )
{
	return FT_Glyph_To_Bitmap( &_glyph->_glyph, ( FT_Render_Mode )_renderMode, _origin->_vector, _destroy );
}

void _ft_done_glyph( ft_glyph_object * _glyph )
{
	// printf("hello");
	FT_Done_Glyph( _glyph->_glyph );
}

int _sdf_build( BBDataBuffer * _out, int _outstride, float _maxdist, BBDataBuffer * _img, int _width, int _height, int _stride )
{
	return sdfBuild( ( unsigned char * )_out->WritePointer(0), _outstride, _maxdist, ( unsigned char * )_img->ReadPointer(0), _width, _height, _stride );
}













