
// class BgfxVertexDecl
// {
	// int hash;
	// int stride;
	// Array<int> offset;
	// Array<int> attributes;

	// void Set(bgfx_vertex_decl_t decl)
	// {
		// hash = decl.hash;
		// stride = decl.stride;
		// for ( int i = 0 ; i < BGFX_ATTRIB_COUNT ; i ++ )
		// {
			// offset[i] = decl.offset[i];
			// attributes[i] = decl.attributes[i];
		// }
	// }
// };

// void _bgfx_vertex_decl_begin( BgfxVertexDecl _decl, int _renderer )
// {
	// bgfx_vertex_decl_t decl;
	// bgfx_vertex_decl_begin( &decl, _renderer );
	// _decl.Set(decl);
// }

//-----------------------------------------------------------------------------
// simple utility function to convert 2 32-bit int to 64-bit int
//-----------------------------------------------------------------------------

uint64_t get_uint64_from_int32_array( Array<int> _int32 )
{
	return (( (uint64_t)_int32[0] ) << 32) | _int32[1];
}

void put_uint64_to_int32_array( uint64_t _int64, Array<int> _int32 )
{
	_int32[0] = (_int64 >> 32) & 0xffffffff;
	_int32[1] = _int64 & 0xffffffff;
}

//-----------------------------------------------------------------------------
// bgfx_callback_vtbl_t
//-----------------------------------------------------------------------------

void bgfx_callback_fatal(bgfx_callback_interface_t* _this, const char* _filePath, uint16_t _line, bgfx_fatal_t _code, const char* _str)
{
}

void bgfx_callback_trace_vargs(bgfx_callback_interface_t* _this, const char* _filePath, uint16_t _line, const char* _format, va_list _argList)
{
}

void bgfx_callback_profiler_begin(bgfx_callback_interface_t* _this, const char* _name, uint32_t _abgr, const char* _filePath, uint16_t _line)
{
}

void bgfx_callback_profiler_begin_literal(bgfx_callback_interface_t* _this, const char* _name, uint32_t _abgr, const char* _filePath, uint16_t _line)
{
}

void bgfx_callback_profiler_end(bgfx_callback_interface_t* _this)
{
}

uint32_t bgfx_callback_cache_read_size(bgfx_callback_interface_t* _this, uint64_t _id)
{
	// Return 0 if shader is not found.
	return 0;
}

bool bgfx_callback_cache_read(bgfx_callback_interface_t* _this, uint64_t _id, void* _data, uint32_t _size)
{
	// Shader is not found in cache, needs to be rebuilt.
	return false;
}

void bgfx_callback_cache_write(bgfx_callback_interface_t* _this, uint64_t _id, const void* _data, uint32_t _size)
{
}

void * _bgfx_screen_shot_pixels;
int _bgfx_screen_shot_x;
int _bgfx_screen_shot_y;
int _bgfx_screen_shot_width;
int _bgfx_screen_shot_height;
int _bgfx_screen_shot_offset;
int _bgfx_screen_shot_pitch;
bool _bgfx_screen_shot_done;

// bgfx_callback_screen_shot is hooked in glfwgame.cpp in method void BBGlfwGame::Run() during bgfxInit
void bgfx_callback_screen_shot(bgfx_callback_interface_t* _this, const char* _filePath, uint32_t _width, uint32_t _height, uint32_t _pitch, const void* _data, uint32_t _size, bool _yflip)
{
	printf("bgfx_callback_screen_shot\n");
	printf("_width=%d _height=%d _pitch=%d _size=%d _yflip=%d\n", _width, _height, _pitch, _size, _yflip);
	printf("x=%d y=%d width=%d height=%d offset=%d _pitch=%d\n", _bgfx_screen_shot_x, _bgfx_screen_shot_y, _bgfx_screen_shot_width, _bgfx_screen_shot_height, _bgfx_screen_shot_offset, _bgfx_screen_shot_pitch);

	unsigned char * _src = (unsigned char *)_data;
	unsigned char * _dst = (unsigned char *)_bgfx_screen_shot_pixels;

	for(int j=0 ; j < _bgfx_screen_shot_height ; j ++ )
	{
		for(int i=0 ; i < _bgfx_screen_shot_width ; i ++ )
		{
			int data_index = (_bgfx_screen_shot_y + j) * _pitch + (_bgfx_screen_shot_x + i) * 4;
			int pixel_index = ( (_bgfx_screen_shot_y + j) * _bgfx_screen_shot_pitch + (_bgfx_screen_shot_x + i) + _bgfx_screen_shot_offset) * 4;
			_dst[ pixel_index + 0 ] = _src[ data_index + 0 ];	// blue
			_dst[ pixel_index + 1 ] = _src[ data_index + 1 ];	// green
			_dst[ pixel_index + 2 ] = _src[ data_index + 2 ];	// red
			_dst[ pixel_index + 3 ] = _src[ data_index + 3 ];	// alpha
		}
	}

	// memcpy( _screen_shot_pixels, _data, _size );

	_bgfx_screen_shot_done = true;
}

void _bgfx_read_pixels( Array<int> pixels, int x, int y, int width, int height, int arrayOffset, int arrayPitch)
{
	printf("_bgfx_read_pixels\n");

	_bgfx_screen_shot_pixels = (void *)&pixels[0];
	_bgfx_screen_shot_x = x;
	_bgfx_screen_shot_y = y;
	_bgfx_screen_shot_width = width;
	_bgfx_screen_shot_height = height;
	_bgfx_screen_shot_offset = arrayOffset;
	_bgfx_screen_shot_pitch = arrayPitch;

	bgfx_frame(false);

	// flag for waiting until bgfx_callback_screen_shot is done
	_bgfx_screen_shot_done = false;

	bgfx_frame_buffer_handle_t fbh = BGFX_INVALID_HANDLE;
	bgfx_request_screen_shot(fbh, "temp");

	while (_bgfx_screen_shot_done == false)
	{
		// wait until bgfx_callback_screen_shot is done
		// bgfx_touch(0);	// should we do bgfx_touch(0)? it doesn't hurt to do it
		bgfx_frame(false);
	}
}

void bgfx_callback_capture_begin(bgfx_callback_interface_t* _this, uint32_t _width, uint32_t _height, uint32_t _pitch, bgfx_texture_format_t _format, bool _yflip)
{
}

void bgfx_callback_capture_end(bgfx_callback_interface_t* _this)
{
}

void bgfx_callback_capture_frame(bgfx_callback_interface_t* _this, const void* _data, uint32_t _size)
{
}

//-----------------------------------------------------------------------------
// classes
//-----------------------------------------------------------------------------

/*
#define INVALID_HANDLE UINT16_MAX

class bgfx_dynamic_index_buffer_handle_object : public Object
{
public:
	bgfx_dynamic_index_buffer_handle_t _handle;

	bgfx_dynamic_index_buffer_handle_object()
	{
	}
	~bgfx_dynamic_index_buffer_handle_object()
	{
	}
};

class bgfx_dynamic_vertex_buffer_handle_object : public Object
{
public:
	bgfx_dynamic_vertex_buffer_handle_t _handle;

	bgfx_dynamic_vertex_buffer_handle_object()
	{
	}
	~bgfx_dynamic_vertex_buffer_handle_object()
	{
	}
};

class bgfx_frame_buffer_handle_object : public Object
{
public:
	bgfx_frame_buffer_handle_t _handle;

	bgfx_frame_buffer_handle_object()
	{
	}
	~bgfx_frame_buffer_handle_object()
	{
	}

	void SetHandleToInvalid()
	{
		_handle.idx = INVALID_HANDLE;
	}

	bool IsValid()
	{
		return (_handle.idx != INVALID_HANDLE);
	}
};

// class bgfx_index_buffer_handle_object : public Object
// {
// public:
	// bgfx_index_buffer_handle_t _handle;
// };

class bgfx_index_buffer_handle_object : public Object
{
public:
	bgfx_index_buffer_handle_t _handle;

	bgfx_index_buffer_handle_object()
	{
	}
	~bgfx_index_buffer_handle_object()
	{
	}
};

class bgfx_indirect_buffer_handle_object : public Object
{
public:
	bgfx_indirect_buffer_handle_t _handle;

	bgfx_indirect_buffer_handle_object()
	{
	}
	~bgfx_indirect_buffer_handle_object()
	{
	}
};

class bgfx_occlusion_query_handle_object : public Object
{
public:
	bgfx_occlusion_query_handle_t _handle;

	bgfx_occlusion_query_handle_object()
	{
	}
	~bgfx_occlusion_query_handle_object()
	{
	}
};

// class bgfx_program_handle_object : public Object
// {
// public:
	// union
	// {
		// bgfx_program_handle_t c;
		// bgfx::ProgramHandle cpp;
	// } _handle;
// };

class bgfx_program_handle_object : public Object
{
public:
	union
	{
		bgfx_program_handle_t c;
		bgfx::ProgramHandle cpp;
	} _handle;

	// bgfx_program_handle_t _handle;

	bgfx_program_handle_object()
	{
	}
	~bgfx_program_handle_object()
	{
	}

	void SetHandleToInvalid()
	{
		_handle.cpp.idx = bgfx::kInvalidHandle;
	}

	bool IsValid()
	{
		return bgfx::kInvalidHandle != _handle.cpp.idx;
	}
};

class bgfx_shader_handle_object : public Object
{
public:
	bgfx_shader_handle_t _handle;

	bgfx_shader_handle_object()
	{
	}
	~bgfx_shader_handle_object()
	{
	}
};

class bgfx_texture_handle_object : public Object
{
public:
	bgfx_texture_handle_t _handle;

	bgfx_texture_handle_object()
	{
	}
	~bgfx_texture_handle_object()
	{
	}

	int GetHandle()
	{
		return _handle.idx;
	}

	void SetHandleToInvalid()
	{
		_handle.idx = bgfx::kInvalidHandle;
	}

	bool IsValid()
	{
		return bgfx::kInvalidHandle != _handle.idx;
	}
};

class bgfx_uniform_handle_object : public Object
{
public:
	bgfx_uniform_handle_t _handle;

	bgfx_uniform_handle_object()
	{
	}
	~bgfx_uniform_handle_object()
	{
	}
};

// class bgfx_vertex_buffer_handle_object : public Object
// {
// public:
	// bgfx_vertex_buffer_handle_t _handle;
// };

class bgfx_vertex_buffer_handle_object : public Object
{
public:
	bgfx_vertex_buffer_handle_t _handle;

	bgfx_vertex_buffer_handle_object()
	{
	}
	~bgfx_vertex_buffer_handle_object()
	{
	}
};

class bgfx_vertex_decl_handle_object : public Object
{
public:
	bgfx_vertex_decl_handle_t _handle;

	bgfx_vertex_decl_handle_object()
	{
	}
	~bgfx_vertex_decl_handle_object()
	{
	}
};
*/

class bgfx_memory_object : public Object
{
public:
	bgfx_memory_t * _mem;

	bgfx_memory_object()
	{
	}
	~bgfx_memory_object()
	{
	}

	void PokeByte( int addr, int value )
	{
		*(_mem->data + addr) = value;
	}

	void PokeShort( int addr, int value )
	{
		*(short *)(_mem->data + addr) = value;
	}

	void PokeInt( int addr, int value )
	{
		*(int *)(_mem->data + addr) = value;
	}

	void PokeFloat( int addr, float value )
	{
		*(float *)(_mem->data + addr) = value;
	}

	int PeekByte( int addr )
	{
		return *(_mem->data + addr);
	}

	int PeekShort( int addr )
	{
		return *(short *)(_mem->data + addr);
	}

	int PeekInt( int addr )
	{
		return *(int *)(_mem->data + addr);
	}

	float PeekFloat( int addr )
	{
		return *(float *)(_mem->data + addr);
	}

	void PokeS8( int addr, int value )
	{
		*(_mem->data + addr) = value;
	}

	void PokeS16( int addr, int value )
	{
		*(short *)(_mem->data + addr) = value;
	}

	void PokeS32( int addr, int value )
	{
		*(int *)(_mem->data + addr) = value;
	}

	void PokeF16( int addr, int value )
	{
		*(short *)(_mem->data + addr) = bx::halfFromFloat(value);
	}

	void PokeF32( int addr, float value )
	{
		*(float *)(_mem->data + addr) = value;
	}

	// float PeekF16( int addr )
	// {
		// return *(short *)(_mem->data + addr);
	// }

};

class bgfx_transform_object : public Object
{
public:
	bgfx_transform_t * _transform;

	bgfx_transform_object()
	{
	}
	~bgfx_transform_object()
	{
	}
};

// typedef uint16_t bgfx_view_id_t;

class bgfx_view_stats_object : public Object
{
public:
	bgfx_view_stats_t * _viewStats;

	bgfx_view_stats_object()
	{
	}
	~bgfx_view_stats_object()
	{
	}
};

class bgfx_encoder_stats_object : public Object
{
public:
	bgfx_encoder_stats_t * _encoderStats;

	bgfx_encoder_stats_object()
	{
	}
	~bgfx_encoder_stats_object()
	{
	}
};

class bgfx_stats_object : public Object
{
public:
	bgfx_stats_t * _stats;

	bgfx_stats_object()
	{
	}
	~bgfx_stats_object()
	{
	}
};

class bgfx_vertex_decl_object : public Object
{
public:
	bgfx_vertex_decl_t _decl;

	bgfx_vertex_decl_object()
	{
	}
	~bgfx_vertex_decl_object()
	{
	}

	int GetStride()
	{
		return _decl.stride;
	}

	void SetHash(int hash)
	{
		_decl.hash = hash;
	}

	void SetStride(int stride)
	{
		_decl.stride = stride;
	}

	void SetOffset(int index, int offset)
	{
		_decl.offset[index] = offset;
	}

	void SetAttrib(int index, int attrib)
	{
		_decl.attributes[index] = attrib;
	}
};

class bgfx_transient_index_buffer_object : public Object
{
public:
	bgfx_transient_index_buffer_t _tib;

	bgfx_transient_index_buffer_object()
	{
	}
	~bgfx_transient_index_buffer_object()
	{
	}

	void PokeByte( int addr, int value )
	{
		*(_tib.data + addr) = value;
	}

	void PokeShort( int addr, int value )
	{
		*(short *)(_tib.data + addr) = value;
	}

	void PokeInt( int addr, int value )
	{
		*(int *)(_tib.data + addr) = value;
	}

	void PokeFloat( int addr, float value )
	{
		*(float *)(_tib.data + addr) = value;
	}

	int PeekByte( int addr )
	{
		return *(_tib.data + addr);
	}

	int PeekShort( int addr )
	{
		return *(short *)(_tib.data + addr);
	}

	int PeekInt( int addr )
	{
		return *(int *)(_tib.data + addr);
	}

	float PeekFloat( int addr )
	{
		return *(float *)(_tib.data + addr);
	}
};

class bgfx_transient_vertex_buffer_object : public Object
{
public:
	bgfx_transient_vertex_buffer_t _tvb;

	bgfx_transient_vertex_buffer_object()
	{
	}
	~bgfx_transient_vertex_buffer_object()
	{
	}

	void PokeByte( int addr, int value )
	{
		*(_tvb.data + addr) = value;
	}

	void PokeShort( int addr, int value )
	{
		*(short *)(_tvb.data + addr) = value;
	}

	void PokeInt( int addr, int value )
	{
		*(int *)(_tvb.data + addr) = value;
	}

	void PokeFloat( int addr, float value )
	{
		*(float *)(_tvb.data + addr) = value;
	}

	int PeekByte( int addr )
	{
		return *(_tvb.data + addr);
	}

	int PeekShort( int addr )
	{
		return *(short *)(_tvb.data + addr);
	}

	int PeekInt( int addr )
	{
		return *(int *)(_tvb.data + addr);
	}

	float PeekFloat( int addr )
	{
		return *(float *)(_tvb.data + addr);
	}
};

class bgfx_instance_data_buffer_object : public Object
{
public:
	bgfx_instance_data_buffer_t _idb;

	bgfx_instance_data_buffer_object()
	{
	}
	~bgfx_instance_data_buffer_object()
	{
	}

	void PokeByte( int addr, int value )
	{
		*(_idb.data + addr) = value;
	}

	void PokeShort( int addr, int value )
	{
		*(short *)(_idb.data + addr) = value;
	}

	void PokeInt( int addr, int value )
	{
		*(int *)(_idb.data + addr) = value;
	}

	void PokeFloat( int addr, float value )
	{
		*(float *)(_idb.data + addr) = value;
	}

	int PeekByte( int addr )
	{
		return *(_idb.data + addr);
	}

	int PeekShort( int addr )
	{
		return *(short *)(_idb.data + addr);
	}

	int PeekInt( int addr )
	{
		return *(int *)(_idb.data + addr);
	}

	float PeekFloat( int addr )
	{
		return *(float *)(_idb.data + addr);
	}
};

class bgfx_texture_info_object : public Object
{
public:
	bgfx_texture_info_t _info;

	bgfx_texture_info_object()
	{
	}
	~bgfx_texture_info_object()
	{
	}

	int GetStorageSize()
	{
		return _info.storageSize;
	}
	int GetBitsPerPixel()
	{
		return _info.bitsPerPixel;
	}
};

class bgfx_uniform_info_object : public Object
{
public:
	bgfx_uniform_info_t * _info;

	bgfx_uniform_info_object()
	{
	}
	~bgfx_uniform_info_object()
	{
	}
};

class bgfx_attachment_object : public Object
{
public:
	bgfx_attachment_t * _attachment;

	bgfx_attachment_object()
	{
	}
	~bgfx_attachment_object()
	{
	}
};

// class bgfx_caps_gpu_object : public Object
// {
// public:
	// bgfx_caps_gpu_t * gpu;

	// bgfx_caps_gpu_object()
	// {
	// }
	// ~bgfx_caps_gpu_object()
	// {
	// }
// };

// class bgfx_caps_limits_object : public Object
// {
// public:
	// bgfx_caps_limits_t * limits;

	// bgfx_caps_limits_object()
	// {
	// }
	// ~bgfx_caps_limits_object()
	// {
	// }
// };

// class bgfx_caps_object : public Object
// {
// public:
	// const bgfx_caps_t * _caps;

	// virtual bool GetHomogeneousDepth()
	// {
		// return _caps->homogeneousDepth;
	// }
// };

class bgfx_caps_object : public Object
{
public:
	const bgfx_caps_t * _caps;

	bgfx_caps_object()
	{
	}

	~bgfx_caps_object()
	{
	}

	virtual void GetSupported( Array<int> supported )
	{
		put_uint64_to_int32_array( _caps->supported, supported );
	}

	virtual bool GetHomogeneousDepth()
	{
		return _caps->homogeneousDepth;
	}

	virtual void GetFormats( Array<int> formats )
	{
		for(int ii = 0; ii < BGFX_TEXTURE_FORMAT_COUNT; ii++)
		{
			formats[ ii ] = _caps->formats[ ii ];
		}
	}

	virtual bool GetOriginBottomLeft()
	{
		return _caps->originBottomLeft;
	}
};

// used by bgfx_init_t
// class bgfx_callback_interface_object : public Object
// {
// public:
	// bgfx_callback_interface_t * _callback;

	// bgfx_callback_interface_object()
	// {
	// }
	// ~bgfx_callback_interface_object()
	// {
	// }
// };

// used by bgfx_init_t
// class bgfx_callback_vtbl_object : public Object
// {
// public:
	// bgfx_callback_vtbl_t * _vtbl;

	// bgfx_callback_vtbl_object()
	// {
	// }
	// ~bgfx_callback_vtbl_object()
	// {
	// }
// };

// used by bgfx_init_t
// class bgfx_allocator_interface_object : public Object
// {
// public:
	// bgfx_allocator_interface_t _decl;

	// bgfx_allocator_interface_object()
	// {
	// }
	// ~bgfx_allocator_interface_object()
	// {
	// }
// };

// used by bgfx_init_t
// class bgfx_allocator_vtbl_object : public Object
// {
// public:
	// bgfx_allocator_vtbl_t _decl;

	// bgfx_allocator_vtbl_object()
	// {
	// }
	// ~bgfx_allocator_vtbl_object()
	// {
	// }
// };

// used by bgfx_init_t
// class bgfx_resolution_object : public Object
// {
// public:
	// bgfx_resolution_t * _resolution;

	// bgfx_resolution_object()
	// {
	// }
	// ~bgfx_resolution_object()
	// {
	// }
// };

// used by bgfx_init_t
// class bgfx_init_limits_object : public Object
// {
// public:
	// bgfx_init_limits_t * _limits;

	// bgfx_init_limits_object()
	// {
	// }
	// ~bgfx_init_limits_object()
	// {
	// }
// };

class bgfx_init_object : public Object
{
public:
	bgfx_init_t _init;

	bgfx_init_object()
	{
	}
	~bgfx_init_object()
	{
	}
};

class bgfx_encoder_object : public Object
{
public:
	struct bgfx_encoder_s * _encoder;

	bgfx_encoder_object()
	{
	}
	~bgfx_encoder_object()
	{
	}
};

class bgfx_native_window_handle_object : public Object
{
public:
	void * _nwh;

	bgfx_native_window_handle_object()
	{
	}
	~bgfx_native_window_handle_object()
	{
	}
};

//-----------------------------------------------------------------------------
// functions
//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
// TODO convert these to Cerberus
//-----------------------------------------------------------------------------

// bgfx_program_handle_object * _bgfx_utils_load_program( String _vsName, String _fsName )
// {
	// bgfx_program_handle_object * _handle = new bgfx_program_handle_object();
	// _handle->_handle.cpp = loadProgram( (const char *)_vsName.ToCString<char>(), (const char *)_fsName.ToCString<char>() );
	// return _handle;
// }

void _bx_mtx_look_at( Array<float> _result, Array<float> _eye, Array<float> _at )
{
	bx::mtxLookAt( &_result[0], &_eye[0], &_at[0], NULL );
}

void _bx_mtx_look_at( Array<float> _result, Array<float> _eye, Array<float> _at, Array<float> _up )
{
	bx::mtxLookAt( &_result[0], &_eye[0], &_at[0], &_up[0] );
}

void _bx_mtx_proj( Array<float> _result, float _eye, float _aspect, float _near, float _far, bool _oglNdc )
{
	bx::mtxProj( &_result[0], _eye, _aspect, _near, _far, _oglNdc );
}

void _bx_mtx_rotate_x_y( Array<float> _result, float _ax, float _ay )
{
	bx::mtxRotateXY( &_result[0], _ax, _ay );
}

void _bx_mtx_ortho( Array<float> _result, float _left, float _right, float _bottom, float _top, float _near, float _far, float _offset, bool _oglNdc )
{
	bx::mtxOrtho( &_result[0], _left, _right, _bottom, _top, _near, _far, _offset, _oglNdc );
}

void _bx_vec3_norm( Array<float> _result, Array<float> _a )
{
	bx::vec3Norm( &_result[0], &_a[0] );
}

void _bx_mtx_mul( Array<float> _result, Array<float> _a, Array<float> _b )
{
	bx::mtxMul( &_result[0], &_a[0], &_b[0] );
}

void _bx_mtx_inverse( Array<float> _result, Array<float> _a )
{
	bx::mtxInverse( &_result[0], &_a[0] );
}

void _bx_vec4_mul_mtx( Array<float> _result, Array<float> _vec, Array<float> _mat )
{
	bx::vec4MulMtx( &_result[0], &_vec[0], &_mat[0] );
}

int _bx_cnt_t_z( int _val )
{
	return bx::uint32_cnttz( (uint32_t)_val );
}

void _bx_mtx_s_r_t( Array<float> _result, float _sx, float _sy, float _sz, float _ax, float _ay, float _az, float _tx, float _ty, float _tz)
{
	bx::mtxSRT( &_result[0], _sx, _sy, _sz, _ax, _ay, _az, _tx, _ty, _tz );
}

void _bx_mtx_translate( Array<float> _result, float _tx, float _ty, float _tz )
{
	bx::mtxTranslate( &_result[0], _tx, _ty, _tz );
}

void _bx_vec3_mul_mtx( Array<float> _result, Array<float> _vec, Array<float> _mat )
{
	bx::vec3MulMtx( &_result[0], &_vec[0], &_mat[0] );
}

float _bx_square( float _a )
{
	return bx::square( _a );
}

void _bx_mtx_scale( Array<float> _result, float _sx, float _sy, float _sz )
{
	bx::mtxScale( &_result[0], _sx, _sy, _sz );
}

void _bx_vec3_cross( Array<float> _result, Array<float> _a, Array<float> _b )
{
	bx::vec3Cross( &_result[0], &_a[0], &_b[0] );
}

void _bx_vec3_move( Array<float> _result, Array<float> _a )
{
	bx::vec3Move( &_result[0], &_a[0] );
}

void _bx_vec3_mul( Array<float> _result, Array<float> _a, Array<float> _b )
{
	bx::vec3Mul( &_result[0], &_a[0], &_b[0] );
}

void _bx_vec3_mul( Array<float> _result, Array<float> _a, float _b )
{
	bx::vec3Mul( &_result[0], &_a[0], _b );
}

void _bx_vec3_add( Array<float> _result, Array<float> _a, Array<float> _b )
{
	bx::vec3Add( &_result[0], &_a[0], &_b[0] );
}

void _bx_vec3_add( Array<float> _result, Array<float> _a, float _b )
{
	bx::vec3Add( &_result[0], &_a[0], _b );
}

void _bx_vec3_sub( Array<float> _result, Array<float> _a, Array<float> _b )
{
	bx::vec3Sub( &_result[0], &_a[0], &_b[0] );
}

void _bx_vec3_sub( Array<float> _result, Array<float> _a, float _b )
{
	bx::vec3Sub( &_result[0], &_a[0], _b );
}

float _bx_vec3_dot( Array<float> _a, Array<float> _b )
{
	return bx::vec3Dot( &_a[0], &_b[0] );
}

void _bx_mtx_identity( Array<float> _result )
{
	bx::mtxIdentity( &_result[0] );
}

float _bx_to_rad( float _deg )
{
	return bx::toRad( _deg );
}

void _bx_mtx_transpose( Array<float> _result, Array<float> _a )
{
	bx::mtxTranspose( &_result[0], &_a[0] );
}

void _bx_vec3_mul_mtx_h( Array<float> _result, Array<float> _vec, Array<float> _mat )
{
	bx::vec3MulMtxH( &_result[0], &_vec[0], &_mat[0] );
}


void _calc_tangents(void* _vertices, uint16_t _numVertices, bgfx_vertex_decl_t * _decl, const uint16_t* _indices, uint32_t _numIndices)
{
	struct PosTexcoord
	{
		float m_x;
		float m_y;
		float m_z;
		float m_pad0;
		float m_u;
		float m_v;
		float m_pad1;
		float m_pad2;
	};

	float* tangents = new float[6*_numVertices];
	bx::memSet(tangents, 0, 6*_numVertices*sizeof(float) );

	PosTexcoord v0;
	PosTexcoord v1;
	PosTexcoord v2;

	for (uint32_t ii = 0, num = _numIndices/3; ii < num; ++ii)
	{
		const uint16_t* indices = &_indices[ii*3];
		uint32_t i0 = indices[0];
		uint32_t i1 = indices[1];
		uint32_t i2 = indices[2];

		bgfx_vertex_unpack(&v0.m_x, BGFX_ATTRIB_POSITION,  _decl, _vertices, i0);
		bgfx_vertex_unpack(&v0.m_u, BGFX_ATTRIB_TEXCOORD0, _decl, _vertices, i0);

		bgfx_vertex_unpack(&v1.m_x, BGFX_ATTRIB_POSITION,  _decl, _vertices, i1);
		bgfx_vertex_unpack(&v1.m_u, BGFX_ATTRIB_TEXCOORD0, _decl, _vertices, i1);

		bgfx_vertex_unpack(&v2.m_x, BGFX_ATTRIB_POSITION,  _decl, _vertices, i2);
		bgfx_vertex_unpack(&v2.m_u, BGFX_ATTRIB_TEXCOORD0, _decl, _vertices, i2);

		const float bax = v1.m_x - v0.m_x;
		const float bay = v1.m_y - v0.m_y;
		const float baz = v1.m_z - v0.m_z;
		const float bau = v1.m_u - v0.m_u;
		const float bav = v1.m_v - v0.m_v;

		const float cax = v2.m_x - v0.m_x;
		const float cay = v2.m_y - v0.m_y;
		const float caz = v2.m_z - v0.m_z;
		const float cau = v2.m_u - v0.m_u;
		const float cav = v2.m_v - v0.m_v;

		const float det = (bau * cav - bav * cau);
		const float invDet = 1.0f / det;

		const float tx = (bax * cav - cax * bav) * invDet;
		const float ty = (bay * cav - cay * bav) * invDet;
		const float tz = (baz * cav - caz * bav) * invDet;

		const float bx = (cax * bau - bax * cau) * invDet;
		const float by = (cay * bau - bay * cau) * invDet;
		const float bz = (caz * bau - baz * cau) * invDet;

		for (uint32_t jj = 0; jj < 3; ++jj)
		{
			float* tanu = &tangents[indices[jj]*6];
			float* tanv = &tanu[3];
			tanu[0] += tx;
			tanu[1] += ty;
			tanu[2] += tz;

			tanv[0] += bx;
			tanv[1] += by;
			tanv[2] += bz;
		}
	}

	for (uint32_t ii = 0; ii < _numVertices; ++ii)
	{
		const float* tanu = &tangents[ii*6];
		const float* tanv = &tangents[ii*6 + 3];

		float normal[4];
		bgfx_vertex_unpack(normal, BGFX_ATTRIB_NORMAL, _decl, _vertices, ii);
		float ndt = bx::vec3Dot(normal, tanu);

		float nxt[3];
		bx::vec3Cross(nxt, normal, tanu);

		float tmp[3];
		tmp[0] = tanu[0] - normal[0] * ndt;
		tmp[1] = tanu[1] - normal[1] * ndt;
		tmp[2] = tanu[2] - normal[2] * ndt;

		float tangent[4];
		bx::vec3Norm(tangent, tmp);

		tangent[3] = bx::vec3Dot(nxt, tanv) < 0.0f ? -1.0f : 1.0f;
		bgfx_vertex_pack(tangent, true, BGFX_ATTRIB_TANGENT, _decl, _vertices, ii);
	}

	delete [] tangents;
}

//Function bgfxUtilsCalcTangents:Void(_vertices:DataBuffer, _numVertices:Int, _decl:BgfxVertexDecl, _indices:DataBuffer, _numIndices)="_bgfx_utils_calc_tangents"
void _bgfx_utils_calc_tangents(BBDataBuffer * _vertices, int _numVertices,  bgfx_vertex_decl_object * _decl, BBDataBuffer * _indices, int _numIndices)
{
	_calc_tangents(_vertices->WritePointer(0), _numVertices, &_decl->_decl, (const uint16_t *)_indices->ReadPointer(0), _numIndices);
}

// this function _image_release_cb is used by _load_texture
static void _image_release_cb(void* _ptr, void* _userData)
{
	BX_UNUSED(_ptr);
	bimg::ImageContainer* imageContainer = (bimg::ImageContainer*)_userData;
	bimg::imageFree(imageContainer);
}

bx::AllocatorI* getDefaultAllocator()
{
	static bx::DefaultAllocator s_allocator;
	return &s_allocator;
}

/*
bx::AllocatorI* getAllocator()
{
	if (NULL == g_allocator)
	{
		g_allocator = getDefaultAllocator();
	}

	return g_allocator;
}
*/

//bgfx::TextureHandle loadTexture(bx::FileReaderI* _reader, const char* _filePath, uint32_t _flags, uint8_t _skip, bgfx::TextureInfo* _info, bimg::Orientation::Enum* _orientation)
bgfx_texture_handle_t _load_texture(BBDataBuffer * _dataBuffer, int _flags)
{
	// BX_UNUSED(_skip);
	bgfx_texture_handle_t handle = BGFX_INVALID_HANDLE;

	// uint32_t size;
	// void* data = load(_reader, entry::getAllocator(), _filePath, &size);
	// if (NULL != data)
	// {
		bimg::ImageContainer * imageContainer = bimg::imageParse( getDefaultAllocator(), _dataBuffer->ReadPointer(0), _dataBuffer->Length() ); // , BGFX_TEXTURE_FORMAT_COUNT, NULL );

		if ( NULL != imageContainer )
		{
/*
			if (NULL != _orientation)
			{
				*_orientation = imageContainer->m_orientation;
			}
			const bgfx_memory_t * mem = bgfx_make_ref(
					  imageContainer->m_data
					, imageContainer->m_size
					, _image_release_cb
					, imageContainer
					);
			unload(data);
*/

			const bgfx_memory_t * mem = bgfx_make_ref( imageContainer->m_data, imageContainer->m_size );

			if (imageContainer->m_cubeMap)
			{
				handle = bgfx_create_texture_cube(
					  uint16_t(imageContainer->m_width)
					, 1 < imageContainer->m_numMips
					, imageContainer->m_numLayers
					, bgfx_texture_format_t(imageContainer->m_format)
					, _flags
					, mem
					);
			}
			else if (1 < imageContainer->m_depth)
			{
				handle = bgfx_create_texture_3d(
					  uint16_t(imageContainer->m_width)
					, uint16_t(imageContainer->m_height)
					, uint16_t(imageContainer->m_depth)
					, 1 < imageContainer->m_numMips
					, bgfx_texture_format_t(imageContainer->m_format)
					, _flags
					, mem
					);
			}
			else if (bgfx::isTextureValid(0, false, imageContainer->m_numLayers, bgfx::TextureFormat::Enum(imageContainer->m_format), _flags) )
			{
				handle = bgfx_create_texture_2d(
					  uint16_t(imageContainer->m_width)
					, uint16_t(imageContainer->m_height)
					, 1 < imageContainer->m_numMips
					, imageContainer->m_numLayers
					,bgfx_texture_format_t(imageContainer->m_format)
					, _flags
					, mem
					);
			}
/*
			if (bgfx::isValid(handle) )
			{
				bgfx::setName(handle, _filePath);
			}

			if (NULL != _info)
			{
				bgfx::calcTextureSize(
					  *_info
					, uint16_t(imageContainer->m_width)
					, uint16_t(imageContainer->m_height)
					, uint16_t(imageContainer->m_depth)
					, imageContainer->m_cubeMap
					, 1 < imageContainer->m_numMips
					, imageContainer->m_numLayers
					, bgfx::TextureFormat::Enum(imageContainer->m_format)
					);
			}
*/
		}
	// }

	return handle;
}

int _bgfx_utils_load_texture( BBDataBuffer * _dataBuffer, int _flags )
{
	return (_load_texture(_dataBuffer, _flags)).idx;
}


//-----------------------------------------------------------------------------
// bgfx utils mesh
//-----------------------------------------------------------------------------

/* class bgfx_utils_mesh : public Object
{
public:
	Mesh * _mesh;

	bgfx_utils_mesh()
	{
	}
	~bgfx_utils_mesh()
	{
	}
};

// Function bgfxUtilsMeshLoad:Void(mesh:BgfxUtilsMesh, filePath:String)="_bgfx_utils_mesh_load"
void _bgfx_utils_mesh_load( bgfx_utils_mesh * _mesh, String _filePath )
{
	// examples\common\bgfx_utils.cpp
	// Mesh* meshLoad(const char* _filePath)
	_mesh->_mesh = meshLoad( _filePath.ToCString<char>() );
}

// Function bgfxUtilsMeshUnload:Void(mesh:BgfxUtilsMesh)="_bgfx_utils_mesh_unload"
void _bgfx_utils_mesh_unload( bgfx_utils_mesh * _mesh )
{
	// examples\common\bgfx_utils.cpp
	// void meshUnload(Mesh* _mesh)
	meshUnload( _mesh->_mesh );
}

// Function bgfxUtilsMeshSubmit:Void(mesh:BgfxUtilsMesh, _id:Int, _program:BgfxProgramHandle, _mtx:Float[], _state:Int[])="_bgfx_utils_mesh_submit"
void _bgfx_utils_mesh_submit( bgfx_utils_mesh * _mesh, int _id, bgfx_program_handle_object * _program, Array<float> _mtx, Array<int> _state )
{
	// examples\common\bgfx_utils.cpp
	// void meshSubmit(const Mesh* _mesh, bgfx::ViewId _id, bgfx::ProgramHandle _program, const float* _mtx, uint64_t _state)
	meshSubmit( _mesh->_mesh, _id, _program->_handle.cpp, &_mtx[0], get_uint64_from_int32_array( _state ) );
} */

//-----------------------------------------------------------------------------
// functions
//-----------------------------------------------------------------------------

// Function bgfxVertexDeclBegin:Void( _decl:BgfxVertexDecl, _renderer:Int=BGFX_RENDERER_TYPE_NOOP )="_bgfx_vertex_decl_begin"
// BGFX_C_API void bgfx_vertex_decl_begin(bgfx_vertex_decl_t* _decl, bgfx_renderer_type_t _renderer);
void _bgfx_vertex_decl_begin( bgfx_vertex_decl_object * _decl, int _renderer )
{
	bgfx_vertex_decl_begin( &_decl->_decl, (bgfx_renderer_type_t)_renderer );
}

// Function bgfxVertexDeclAdd:Void( _decl:BgfxVertexDecl, _attrib:Int, _num:Int, _type:Int, _normalize:Bool=False, _asInt:Bool=False )="_bgfx_vertex_decl_add"
// BGFX_C_API void bgfx_vertex_decl_add(bgfx_vertex_decl_t* _decl, bgfx_attrib_t _attrib, uint8_t _num, bgfx_attrib_type_t _type, bool _normalized, bool _asInt);
void _bgfx_vertex_decl_add( bgfx_vertex_decl_object * _decl, int _attrib, int _num, int _type, bool _normalize, bool _asInt )
{
	bgfx_vertex_decl_add( &_decl->_decl, (bgfx_attrib_t)_attrib, _num, (bgfx_attrib_type_t)_type, _normalize, _asInt );
}

// Function bgfxVertexDeclDecode:Void( _decl:BgfxVertexDecl, _attrib:Int,  _type:Int[], _normalized:Bool[], _asInt:Bool[])="_bgfx_vertex_decl_decode"
// BGFX_C_API void bgfx_vertex_decl_decode(const bgfx_vertex_decl_t* _decl, bgfx_attrib_t _attrib, uint8_t* _num, bgfx_attrib_type_t* _type, bool* _normalized, bool* _asInt);
// void _bgfx_vertex_decl_decode( const bgfx_vertex_decl_object * _decl, int _attrib, Array<int> _num, Array<int> _type, Array<bool> _normalized, Array<bool> _asInt )
void _bgfx_vertex_decl_decode( bgfx_vertex_decl_object * _decl, int _attrib, Array<int> _result )
{
	uint8_t _num;
	bgfx_attrib_type_t _type;
	bool _normalized;
	bool _asInt;

	bgfx_vertex_decl_decode( &_decl->_decl, (bgfx_attrib_t)_attrib, &_num, &_type, &_normalized, &_asInt );

	_result[0] = _num;
	_result[1] = (int)_type;
	_result[2] = (int)_normalized;
	_result[3] = (int)_asInt;
}

// Function bgfxVertexDeclHas:Bool( _decl:BgfxVertexDecl, _attrib:Int )="_bgfx_vertex_decl_has"
// BGFX_C_API bool bgfx_vertex_decl_has(const bgfx_vertex_decl_t* _decl, bgfx_attrib_t _attrib);
bool _bgfx_vertex_decl_has( bgfx_vertex_decl_object * _decl, int _attrib )
{
	return bgfx_vertex_decl_has( &_decl->_decl, (bgfx_attrib_t)_attrib );
}

// Function bgfxVertexDeclSkip:Void( _decl:BgfxVertexDecl, _num:Int )="_bgfx_vertex_decl_skip"
// BGFX_C_API void bgfx_vertex_decl_skip(bgfx_vertex_decl_t* _decl, uint8_t _num);
void _bgfx_vertex_decl_skip( bgfx_vertex_decl_object * _decl, int _num )
{
	bgfx_vertex_decl_skip( &_decl->_decl, _num );
}

// Function bgfxVertexDeclEnd:Void( _decl:BgfxVertexDecl )="_bgfx_vertex_decl_end"
// BGFX_C_API void bgfx_vertex_decl_end(bgfx_vertex_decl_t* _decl);
void _bgfx_vertex_decl_end( bgfx_vertex_decl_object * _decl )
{
	bgfx_vertex_decl_end( &_decl->_decl );
}

// Function bgfxVertexPack:Void( _input:Float[], _inputNormalized:Bool, _attr:Int, _decl:BgfxVertexDecl, _data:DataBuffer, _index:Int=0 )="_bgfx_vertex_pack"
// BGFX_C_API void bgfx_vertex_pack(const float _input[4], bool _inputNormalized, bgfx_attrib_t _attr, const bgfx_vertex_decl_t* _decl, void* _data, uint32_t _index);
void _bgfx_vertex_pack( Array<float> _input, bool _inputNormalized, int _attr, bgfx_vertex_decl_object * _decl, BBDataBuffer * _data, int _index )
{
	bgfx_vertex_pack( &_input[0], _inputNormalized, (bgfx_attrib_t)_attr, &_decl->_decl, _data->WritePointer(0), _index );
}

// Function bgfxVertexUnpack:Void( _output:Float[], _attr:Int, _decl:BgfxVertexDecl, _data:DataBuffer, _index:Int=0 )="_bgfx_vertex_unpack"
// BGFX_C_API void bgfx_vertex_unpack(float _output[4], bgfx_attrib_t _attr, const bgfx_vertex_decl_t* _decl, const void* _data, uint32_t _index);
void _bgfx_vertex_unpack( float _output[4], int _attr, bgfx_vertex_decl_object * _decl, BBDataBuffer * _data, int _index )
{
	bgfx_vertex_unpack( &_output[0], (bgfx_attrib_t)_attr, &_decl->_decl, _data->ReadPointer(0), _index );
}

// Function bgfxVertexConvert:Void( _destDecl:BgfxVertexDecl, _destData:DataBuffer, _srcDecl:BgfxVertexDecl, _srcData:DataBuffer, _num:Int=1 )="_bgfx_vertex_convert"
// BGFX_C_API void bgfx_vertex_convert(const bgfx_vertex_decl_t * _destDecl, void* _destData, const bgfx_vertex_decl_t* _srcDecl, const void* _srcData, uint32_t _num);
void _bgfx_vertex_convert( bgfx_vertex_decl_object * _destDecl, BBDataBuffer * _destData, bgfx_vertex_decl_object * _srcDecl, BBDataBuffer * _srcData, int _num )
{
	bgfx_vertex_convert( &_destDecl->_decl, _destData->WritePointer(0), &_srcDecl->_decl, _srcData->ReadPointer(0), _num );
}

// Function bgfxWeldVertices:Int( _output:DataBuffer, _decl:BgfxVertexDecl, _data:DataBuffer, _num:Int, _epsilon:Float=0.001 )="_bgfx_weld_vertices"
// BGFX_C_API uint16_t bgfx_weld_vertices(uint16_t* _output, const bgfx_vertex_decl_t* _decl, const void* _data, uint16_t _num, float _epsilon);
int _bgfx_weld_vertices( BBDataBuffer * _output, bgfx_vertex_decl_object * _decl, BBDataBuffer * _data, int _num, float _epsilon )
{
	bgfx_weld_vertices( (uint16_t *)_output->WritePointer(0), &_decl->_decl, _data->ReadPointer(0), _num, _epsilon );
}

// Function bgfxTopologyConvert:Int( _conversion:Int, _dst:DataBuffer, _dstSize:Int, _indices:DataBuffer, _numIndices:Int, _index32:Bool )="_bgfx_topology_convert"
// BGFX_C_API uint32_t bgfx_topology_convert(bgfx_topology_convert_t _conversion, void* _dst, uint32_t _dstSize, const void* _indices, uint32_t _numIndices, bool _index32);
int _bgfx_topology_convert( int _conversion, BBDataBuffer * _dst, int _dstSize, BBDataBuffer * _indices, int _numIndices, bool _index32 )
{
	bgfx_topology_convert( (bgfx_topology_convert_t)_conversion, _dst->WritePointer(0), _dstSize, _indices->ReadPointer(0), _numIndices, _index32 );
}

// Function bgfxTopologySortTriList:Void( _sort:Int, _dst:DataBuffer, _dstSize:Int, _dir:Float[], _pos:Float[], _vertices:DataBuffer, _stride:Int, _indices:DataBuffer, _numIndices:Int, _index32:Bool )="_intri_list"
// BGFX_C_API void bgfx_topology_sort_tri_list(bgfx_topology_sort_t _sort, void* _dst, uint32_t _dstSize, const float _dir[3], const float _pos[3], const void* _vertices, uint32_t _stride, const void* _indices, uint32_t _numIndices, bool _index32);
void _bgfx_topology_sort_tri_list( int _sort, BBDataBuffer * _dst, int _dstSize, Array<float> _dir, Array<float> _pos, BBDataBuffer * _vertices, int _stride, BBDataBuffer * _indices, int _numIndices, bool _index32 )
{
	bgfx_topology_sort_tri_list( (bgfx_topology_sort_t)_sort, _dst->WritePointer(0), _dstSize, &_dir[0], &_pos[0], _vertices->ReadPointer(0), _stride, _indices->ReadPointer(0), _numIndices, _index32 );
}

// Function bgfxGetSupportedRenderers:Int( _max:Int=0, _enum:Int[]=Null )="_bgfx_get_supported_renderers"
// Function bgfxGetSupportedRenderers:Int( _max:Int=0 )="_bgfx_get_supported_renderers"
// Function bgfxGetSupportedRenderers:Int( _max:Int, _enum:Int[] )="_bgfx_get_supported_renderers"
// BGFX_C_API uint8_t bgfx_get_supported_renderers(uint8_t _max, bgfx_renderer_type_t* _enum);
int _bgfx_get_supported_renderers( int _max )
{
	bgfx_get_supported_renderers( _max, NULL );
}
int _bgfx_get_supported_renderers( int _max, Array<int> _enum )
{
	bgfx_get_supported_renderers( _max, (bgfx_renderer_type_t *)&_enum[0] );
}

// Function bgfxGetRendererName:String( _type:Int )="_bgfx_get_renderer_name"
// BGFX_C_API const char* bgfx_get_renderer_name(bgfx_renderer_type_t _type);
String _bgfx_get_renderer_name( int _type )
{
	return String( bgfx_get_renderer_name( (bgfx_renderer_type_t)_type ) );
}

// Function bgfxInitCtor:Void( _init:BgfxInit )="_bgfx_init_ctor"
// BGFX_C_API void bgfx_init_ctor(bgfx_init_t* _init);
void _bgfx_init_ctor( bgfx_init_object * _init )
{
	bgfx_init_ctor( &_init->_init );
}

// Function bgfxInit:Bool( _init:BgfxInit )="_bgfx_init"
// BGFX_C_API bool bgfx_init(const bgfx_init_t* _init);
bool _bgfx_init( bgfx_init_object * _init )
{
	return bgfx_init( &_init->_init );
}

// Function bgfxShutdown:Void(  )="bgfx_shutdown"
// BGFX_C_API void bgfx_shutdown(void);
// void _bgfx_shutdown( void )
// {
// }

// Function bgfxReset:Void( _width:Int, _height:Int, _flags:Int=BGFX_RESET_NONE, _format:Int=BGFX_TEXTURE_FORMAT_COUNT )="bgfx_reset"
// BGFX_C_API void bgfx_reset(uint32_t _width, uint32_t _height, uint32_t _flags, bgfx_texture_format_t _format);
// void _bgfx_reset( int _width, int _height, int _flags, int _format )
// {
	// bgfx_reset( _width, _height, _flags, (bgfx_texture_format_t)_format );
// }

// Function bgfxBegin:Void( _encoder:BgfxEncoder, _forThread:Bool=False )="_bgfx_begin"
// BGFX_C_API struct bgfx_encoder_s* bgfx_begin(void);
void _bgfx_begin( bgfx_encoder_object * _encoder, bool _forThread )
{
	// _encoder->_encoder = bgfx_begin();
}

// Function bgfxEnd:Void( _encoder:BgfxEncoder )="_bgfx_end"
// BGFX_C_API void bgfx_end(struct bgfx_encoder_s* _encoder);
void _bgfx_end( bgfx_encoder_object * _encoder )
{
	// bgfx_end( _encoder->_encoder );
}

// Function bgfxFrame:Int( _capture:Bool=False )="bgfx_frame"
// BGFX_C_API uint32_t bgfx_frame(bool _capture);
// int _bgfx_frame( bool _capture )
// {
// }

// Function bgfxGetRendererType:Int(  )="bgfx_get_renderer_type"
// BGFX_C_API bgfx_renderer_type_t bgfx_get_renderer_type(void);
// int _bgfx_get_renderer_type( void )
// {
// }

// Function bgfxGetCaps:Void( _caps:BgfxCaps )="_bgfx_get_caps"
// BGFX_C_API const bgfx_caps_t* bgfx_get_caps(void);
void _bgfx_get_caps( bgfx_caps_object * _caps )
{
	_caps->_caps = bgfx_get_caps();
}

// Function bgfxGetStats:Void( _stats:BgfxStats )="_bgfx_get_stats"
// BGFX_C_API const bgfx_stats_t* bgfx_get_stats(void);
void _bgfx_get_stats( bgfx_stats_object * _stats )
{
	_stats->_stats = (bgfx_stats_t *)bgfx_get_stats();
}

// Function bgfxAlloc:Void( _mem:BgfxMemory, _size:Int )="_bgfx_alloc"
// BGFX_C_API const bgfx_memory_t* bgfx_alloc(uint32_t _size);
void _bgfx_alloc( bgfx_memory_object * _mem, int _size )
{
	_mem->_mem = (bgfx_memory_t *)bgfx_alloc( _size );
}

// Function bgfxCopy:Void( _mem:BgfxMemory, _data:DataBuffer )="_bgfx_copy"
// Function bgfxCopy:Void( _mem:BgfxMemory, _data:DataBuffer, _size:Int )="_bgfx_copy"
// BGFX_C_API const bgfx_memory_t* bgfx_copy(const void* _data, uint32_t _size);
void _bgfx_copy( bgfx_memory_object * _mem, BBDataBuffer * _data )
{
	_mem->_mem = (bgfx_memory_t *)bgfx_copy( _data->ReadPointer(0), _data->Length() );
}
void _bgfx_copy( bgfx_memory_object * _mem, BBDataBuffer * _data, int _size )
{
	_mem->_mem = (bgfx_memory_t *)bgfx_copy( _data->ReadPointer(0), _size );
}
void _bgfx_copy( bgfx_memory_object * _mem, BBDataBuffer * _data, int _index, int _size )
{
	_mem->_mem = (bgfx_memory_t *)bgfx_copy( _data->ReadPointer(_index), _size );
}

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

// this function requires a function pointer
// Function bgfxMakeRefRelease:Void( bgfx_memory_object * _mem, _data:DataBuffer, _size:Int, _releaseFn:BgfxReleaseFn=Null, _userData:DataBuffer=Null )="_bgfx_make_ref_release"
// BGFX_C_API const bgfx_memory_t* bgfx_make_ref_release(const void* _data, uint32_t _size, bgfx_release_fn_t _releaseFn, void* _userData);
// const bgfx_memory_object * bgfx_make_ref_release(const void* _data, int _size, bgfx_release_fn_t _releaseFn, void* _userData)
// {
// }

// Function bgfxSetDebug:Void( _debug:Int )="bgfx_set_debug"
// BGFX_C_API void bgfx_set_debug(uint32_t _debug);
// void _bgfx_set_debug( int _debug )
// {
// }

// Function bgfxDbgTextClear:Void( _attr:Int=0, _small:Bool=False )="bgfx_dbg_text_clear"
// BGFX_C_API void bgfx_dbg_text_clear(uint8_t _attr, bool _small);
// void _bgfx_dbg_text_clear( int _attr, bool _small )
// {
// }

// Function bgfxDbgTextPrintf:Void( _x:Int, _y:Int, _attr:Int, _format:String )="_bgfx_dbg_text_printf"
// BGFX_C_API void bgfx_dbg_text_printf(uint16_t _x, uint16_t _y, uint8_t _attr, const char* _format, ...);
void _bgfx_dbg_text_printf( int _x, int _y, int _attr, String _format )
{
	bgfx_dbg_text_printf( _x, _y, _attr, _format.ToCString<char>() );
}

// this C99 specific function
// Function bgfx_dbg_text_vprintf:Void(  )="_bgfx_dbg_text_vprintf"
// BGFX_C_API void bgfx_dbg_text_vprintf(uint16_t _x, uint16_t _y, uint8_t _attr, const char* _format, va_list _argList);
// void _bgfx_dbg_text_vprintf(int _x, int _y, int _attr, const char* _format, va_list _argList)
// {
// }

// Function bgfxDbgTextImage:Void( _x:Int, _y:Int, _width:Int, _height:Int, _data:DataBuffer, _pitch:Int )="_bgfx_dbg_text_image"
// BGFX_C_API void bgfx_dbg_text_image(uint16_t _x, uint16_t _y, uint16_t _width, uint16_t _height, const void* _data, uint16_t _pitch);
void _bgfx_dbg_text_image( int _x, int _y, int _width, int _height, BBDataBuffer * _data, int _pitch)
{
	bgfx_dbg_text_image( _x, _y, _width, _height, _data->ReadPointer(0), _pitch);
}

// Function bgfxCreateIndexBuffer:Void( _handle:BgfxIndexBufferHandle, _mem:BgfxMemory, _flags=BGFX_BUFFER_NONE )="_bgfx_create_index_buffer"
// BGFX_C_API bgfx_index_buffer_handle_t bgfx_create_index_buffer(const bgfx_memory_t* _mem, uint16_t _flags);
int _bgfx_create_index_buffer( bgfx_memory_object * _mem, int _flags )
{
	//printf("_handle->_handle.idx=%d\n", _handle->_handle.idx);
	return (bgfx_create_index_buffer( _mem->_mem, _flags )).idx;
}

// Function bgfxDestroyIndexBuffer:Void( _handle:BgfxIndexBufferHandle )="_bgfx_destroy_index_buffer"
// BGFX_C_API void bgfx_destroy_index_buffer(bgfx_index_buffer_handle_t _handle);
void _bgfx_destroy_index_buffer( uint16_t _handle )
{
	bgfx_destroy_index_buffer( *(bgfx_index_buffer_handle_t *)&_handle );
}

// Function bgfxCreateVertexBuffer:Void( _handle:BgfxVertexBufferHandle, _mem:BgfxMemory, _decl:BgfxVertexDecl, _flags=BGFX_BUFFER_NONE )="_bgfx_create_vertex_buffer"
// BGFX_C_API bgfx_vertex_buffer_handle_t bgfx_create_vertex_buffer(const bgfx_memory_t* _mem, const bgfx_vertex_decl_t* _decl, uint16_t _flags);
int _bgfx_create_vertex_buffer( bgfx_memory_object * _mem, bgfx_vertex_decl_object * _decl, int _flags )
{
	// printf("_handle->_handle.idx=%d\n", _handle->_handle.idx);
	return (bgfx_create_vertex_buffer( _mem->_mem, &_decl->_decl, _flags )).idx;
}

// Function bgfxDestroyVertexBuffer:Void( _handle:BgfxVertexBufferHandle )="_bgfx_destroy_vertex_buffer"
// BGFX_C_API void bgfx_destroy_vertex_buffer(bgfx_vertex_buffer_handle_t _handle);
void _bgfx_destroy_vertex_buffer( uint16_t _handle )
{
	bgfx_destroy_vertex_buffer( *(bgfx_vertex_buffer_handle_t *)&_handle );
}

// Function bgfxCreateDynamicIndexBuffer:Void( _handle:BgfxDynamicIndexBufferHandle, _num:Int, _flags:Int=BGFX_BUFFER_NONE )="_bgfx_create_dynamic_index_buffer"
// BGFX_C_API bgfx_dynamic_index_buffer_handle_t bgfx_create_dynamic_index_buffer(uint32_t _num, uint16_t _flags);
int _bgfx_create_dynamic_index_buffer( int _num, int _flags )
{
	return (bgfx_create_dynamic_index_buffer( _num, _flags )).idx;
}

// Function bgfxCreateDynamicIndexBufferMem:Void( _handle:BgfxDynamicIndexBufferHandle, _mem:BgfxMemory, _flags:Int=BGFX_BUFFER_NONE )="_bgfx_create_dynamic_index_buffer_mem"
// BGFX_C_API bgfx_dynamic_index_buffer_handle_t bgfx_create_dynamic_index_buffer_mem(const bgfx_memory_t* _mem, uint16_t _flags);
int _bgfx_create_dynamic_index_buffer_mem( bgfx_memory_object * _mem, int _flags )
{
	return (bgfx_create_dynamic_index_buffer_mem( _mem->_mem, _flags )).idx;
}

// Function bgfxUpdateDynamicIndexBuffer:Void( _handle:BgfxDynamicIndexBufferHandle, _startIndex:Int, _mem:BgfxMemory )="_bgfx_update_dynamic_index_buffer"
// BGFX_C_API void bgfx_update_dynamic_index_buffer(bgfx_dynamic_index_buffer_handle_t _handle, uint32_t _startIndex, const bgfx_memory_t* _mem);
void _bgfx_update_dynamic_index_buffer( uint16_t _handle, int _startIndex, bgfx_memory_object * _mem )
{
	bgfx_update_dynamic_index_buffer( *(bgfx_dynamic_index_buffer_handle_t *)&_handle, _startIndex, _mem->_mem );
}

// Function bgfxDestroyDynamicIndexBuffer:Void( _handle:BgfxDynamicIndexBufferHandle )="_bgfx_destroy_dynamic_index_buffer"
// BGFX_C_API void bgfx_destroy_dynamic_index_buffer(bgfx_dynamic_index_buffer_handle_t _handle);
void _bgfx_destroy_dynamic_index_buffer( uint16_t _handle )
{
	bgfx_destroy_dynamic_index_buffer( *(bgfx_dynamic_index_buffer_handle_t *)&_handle );
}

// Function bgfxCreateDynamicVertexBuffer:Void( _handle:BgfxDynamicVertexBufferHandle, _num:Int, _decl:BgfxVertexDecl, _flags:Int=BGFX_BUFFER_NONE )="_bgfx_create_dynamic_vertex_buffer"
// BGFX_C_API bgfx_dynamic_vertex_buffer_handle_t bgfx_create_dynamic_vertex_buffer(uint32_t _num, const bgfx_vertex_decl_t* _decl, uint16_t _flags);
int _bgfx_create_dynamic_vertex_buffer( int _num, bgfx_vertex_decl_object * _decl, int _flags )
{
	return (bgfx_create_dynamic_vertex_buffer( _num, &_decl->_decl, _flags )).idx;
}

// Function bgfxCreateDynamicVertexBufferMem:Void( _handle:BgfxDynamicVertexBufferHandle, _mem:BgfxMemory, _decl:BgfxVertexDecl, _flags:Int=BGFX_BUFFER_NONE )="_bgfx_create_dynamic_vertex_buffer_mem"
// BGFX_C_API bgfx_dynamic_vertex_buffer_handle_t bgfx_create_dynamic_vertex_buffer_mem(const bgfx_memory_t* _mem, const bgfx_vertex_decl_t* _decl, uint16_t _flags);
int _bgfx_create_dynamic_vertex_buffer_mem( bgfx_memory_object * _mem, bgfx_vertex_decl_object * _decl, int _flags )
{
	return (bgfx_create_dynamic_vertex_buffer_mem( _mem->_mem, &_decl->_decl, _flags )).idx;
}

// Function bgfxUpdateDynamicVertexBuffer:Void( _handle:BgfxDynamicVertexBufferHandle, _startVertex:Int, _mem:BgfxMemory )="_bgfx_update_dynamic_vertex_buffer"
// BGFX_C_API void bgfx_update_dynamic_vertex_buffer(bgfx_dynamic_vertex_buffer_handle_t _handle, uint32_t _startVertex, const bgfx_memory_t* _mem);
void _bgfx_update_dynamic_vertex_buffer( uint16_t _handle, int _startVertex, bgfx_memory_object * _mem )
{
	if (_mem->_mem == NULL)
	{
		printf("_mem->_mem is null\n");
	}
	else
	{
		bgfx_update_dynamic_vertex_buffer( *(bgfx_dynamic_vertex_buffer_handle_t *)&_handle, _startVertex, _mem->_mem );
	}
}

// Function bgfxDestroyDynamicVertexBuffer:Void( _handle:BgfxDynamicVertexBufferHandle )="_bgfx_destroy_dynamic_vertex_buffer"
// BGFX_C_API void bgfx_destroy_dynamic_vertex_buffer(bgfx_dynamic_vertex_buffer_handle_t _handle);
void _bgfx_destroy_dynamic_vertex_buffer( uint16_t _handle )
{
	bgfx_destroy_dynamic_vertex_buffer( *(bgfx_dynamic_vertex_buffer_handle_t *)&_handle );
}

// Function bgfxGetAvailTransientIndexBuffer:Int( _num:Int )="_bgfx_get_avail_transient_index_buffer"
// BGFX_C_API uint32_t bgfx_get_avail_transient_index_buffer(uint32_t _num);
// int _bgfx_get_avail_transient_index_buffer( int _num )
// {
// }

// Function bgfxGetAvailTransientVertexBuffer:Int( _num:Int, _decl:BgfxVertexDecl )="_bgfx_get_avail_transient_vertex_buffer"
// BGFX_C_API uint32_t bgfx_get_avail_transient_vertex_buffer(uint32_t _num, const bgfx_vertex_decl_t* _decl);
int _bgfx_get_avail_transient_vertex_buffer( int _num, bgfx_vertex_decl_object * _decl )
{
	return bgfx_get_avail_transient_vertex_buffer( _num, &_decl->_decl );
}

// Function bgfxGetAvailInstanceDataBuffer:Int( _num:Int, _stride:Int )="_bgfx_get_avail_instance_data_buffer"
// BGFX_C_API uint32_t bgfx_get_avail_instance_data_buffer(uint32_t _num, uint16_t _stride);
// int _bgfx_get_avail_instance_data_buffer( int _num, int _stride )
// {
// }

// Function bgfxAllocTransientIndexBuffer:Void( _tib:BgfxTransientIndexBuffer, _num:Int )="_bgfx_alloc_transient_index_buffer"
// BGFX_C_API void bgfx_alloc_transient_index_buffer(bgfx_transient_index_buffer_t* _tib, uint32_t _num);
void _bgfx_alloc_transient_index_buffer( bgfx_transient_index_buffer_object * _tib, int _num )
{
	bgfx_alloc_transient_index_buffer( &_tib->_tib, _num );
}

// Function bgfxAllocTransientVertexBuffer:Void( _tvb:BgfxTransientVertexBuffer, _num:Int, _decl:BgfxVertexDecl )="_bgfx_alloc_transient_vertex_buffer"
// BGFX_C_API void bgfx_alloc_transient_vertex_buffer(bgfx_transient_vertex_buffer_t* _tvb, uint32_t _num, const bgfx_vertex_decl_t* _decl);
void _bgfx_alloc_transient_vertex_buffer( bgfx_transient_vertex_buffer_object * _tvb, int _num, bgfx_vertex_decl_object * _decl )
{
	bgfx_alloc_transient_vertex_buffer( &_tvb->_tvb, _num, &_decl->_decl );
}

// Function bgfxAllocTransientBuffers:Bool( _tvb:BgfxTransientVertexBuffer, _decl:BgfxVertexDecl, _numVertices:Int, _tib:BgfxTransientIndexBuffer, _numIndices:Int )="_bgfx_alloc_transient_buffers"
// BGFX_C_API bool bgfx_alloc_transient_buffers(bgfx_transient_vertex_buffer_t* _tvb, const bgfx_vertex_decl_t* _decl, uint32_t _numVertices, bgfx_transient_index_buffer_t* _tib, uint32_t _numIndices);
bool _bgfx_alloc_transient_buffers( bgfx_transient_vertex_buffer_object * _tvb, bgfx_vertex_decl_object * _decl, int _numVertices, bgfx_transient_index_buffer_object * _tib, int _numIndices )
{
	return bgfx_alloc_transient_buffers( &_tvb->_tvb, &_decl->_decl, _numVertices, &_tib->_tib, _numIndices );
}

// Function bgfxAllocInstanceDataBuffer:Void( _idb:BgfxInstanceDataBuffer, _num:Int, _stride:Int )="_bgfx_alloc_instance_data_buffer"
// BGFX_C_API void bgfx_alloc_instance_data_buffer(bgfx_instance_data_buffer_t* _idb, uint32_t _num, uint16_t _stride);
void _bgfx_alloc_instance_data_buffer( bgfx_instance_data_buffer_object * _idb, int _num, int _stride )
{
	bgfx_alloc_instance_data_buffer( &_idb->_idb, _num, _stride );
}

// Function bgfxCreateIndirectBuffer:Void( _handle:BgfxIndirectBufferHandle, _num:Int )="_bgfx_create_indirect_buffer"
// BGFX_C_API bgfx_indirect_buffer_handle_t bgfx_create_indirect_buffer(uint32_t _num);
int _bgfx_create_indirect_buffer( int _num )
{
	return (bgfx_create_indirect_buffer( _num )).idx;
}

// Function bgfxDestroyIndirectBuffer:Void( _handle:BgfxIndirectBufferHandle )="_bgfx_destroy_indirect_buffer"
// BGFX_C_API void bgfx_destroy_indirect_buffer(bgfx_indirect_buffer_handle_t _handle);
void _bgfx_destroy_indirect_buffer( uint16_t _handle )
{
	bgfx_destroy_indirect_buffer( *(bgfx_indirect_buffer_handle_t *)&_handle );
}

// Function bgfxCreateShader:Void( _handle:BgfxShaderHandle, _mem:BgfxMemory )="_bgfx_create_shader"
// BGFX_C_API bgfx_shader_handle_t bgfx_create_shader(const bgfx_memory_t* _mem);
int _bgfx_create_shader( bgfx_memory_object * _mem )
{
	return (bgfx_create_shader( _mem->_mem )).idx;
}

// Function bgfxGetShaderUniforms:Int( _handle:BgfxShaderHandle, _uniforms:BgfxUniformHandle[]=Null, _max:Int=0 )="_bgfx_get_shader_uniforms"
// Function bgfxGetShaderUniforms:Int( _handle:BgfxShaderHandle )="_bgfx_get_shader_uniforms"
// Function bgfxGetShaderUniforms:Int( _handle:BgfxShaderHandle, _uniforms:BgfxUniformHandle[], _max:Int=0 )="_bgfx_get_shader_uniforms"
// BGFX_C_API uint16_t bgfx_get_shader_uniforms(bgfx_shader_handle_t _handle, bgfx_uniform_handle_t* _uniforms, uint16_t _max);
int _bgfx_get_shader_uniforms( uint16_t _handle )
{
	return bgfx_get_shader_uniforms( *(bgfx_shader_handle_t *)&_handle, NULL, 0 );
}
int _bgfx_get_shader_uniforms( uint16_t _handle, BBDataBuffer * _uniforms, int _max )
{
	return bgfx_get_shader_uniforms( *(bgfx_shader_handle_t *)&_handle, (bgfx_uniform_handle_t *)_uniforms->WritePointer(0), _max );
}

// Function bgfxGetUniformInfo:Void( _handle:BgfxUniformHandle, _info:BgfxUniformInfo[] )="_bgfx_get_uniform_info"
// BGFX_C_API void bgfx_get_uniform_info(bgfx_uniform_handle_t _handle, bgfx_uniform_info_t* _info);
void _bgfx_get_uniform_info( uint16_t _handle, bgfx_uniform_info_object * _info )
{
	bgfx_get_uniform_info( *(bgfx_uniform_handle_t *)&_handle, _info->_info );
}

// Function bgfxSetShaderName:Void( _handle:BgfxShaderHandle, _name:String, _len:Int=INT32_MAX )="_bgfx_set_shader_name"
// BGFX_C_API void bgfx_set_shader_name(bgfx_shader_handle_t _handle, const char* _name, int32_t _len);
void _bgfx_set_shader_name( uint16_t _handle, String _name, int _len )
{
	bgfx_set_shader_name( *(bgfx_shader_handle_t *)&_handle, _name.ToCString<char>(), _len );
}

// Function bgfxDestroySshader:Void( _handle:BgfxShaderHandle )="_bgfx_destroy_shader"
// BGFX_C_API void bgfx_destroy_shader(bgfx_shader_handle_t _handle);
void _bgfx_destroy_shader( uint16_t _handle )
{
	bgfx_destroy_shader( *(bgfx_shader_handle_t *)&_handle );
}

// Function bgfxCreateProgram:Void( _handle:BgfxProgramHandle, _vsh:BgfxShaderHandle, _fsh:BgfxShaderHandle, _destroyShaders:Bool=False )="_bgfx_create_program"
// BGFX_C_API bgfx_program_handle_t bgfx_create_program(bgfx_shader_handle_t _vsh, bgfx_shader_handle_t _fsh, bool _destroyShaders);
int _bgfx_create_program( uint16_t _vsh, uint16_t _fsh, bool _destroyShaders )
{
	return (bgfx_create_program( *(bgfx_shader_handle_t *)&_vsh, *(bgfx_shader_handle_t *)&_fsh, _destroyShaders )).idx;
}

// Function bgfxCreateComputeProgram:Void( _handle:BgfxProgramHandle, _csh:BgfxShaderHandle, _destroyShaders:Bool=False )="_bgfx_create_compute_program"
// BGFX_C_API bgfx_program_handle_t bgfx_create_compute_program(bgfx_shader_handle_t _csh, bool _destroyShaders);
int _bgfx_create_compute_program( uint16_t _csh, bool _destroyShaders )
{
	return (bgfx_create_compute_program( *(bgfx_shader_handle_t *)&_csh, _destroyShaders )).idx;
}

// Function bgfxDestroyProgram:Void( _handle:BgfxProgramHandle )="_bgfx_destroy_program"
// BGFX_C_API void bgfx_destroy_program(bgfx_program_handle_t _handle);
void _bgfx_destroy_program( uint16_t _handle )
{
	bgfx_destroy_program( *(bgfx_program_handle_t *)&_handle );
}

// Function bgfxIsTextureValid:Bool( _depth:Int, _cubeMap:Bool, _numLayers:Int, _format:Int, _flags:Int[] )="_bgfx_is_texture_valid"
// BGFX_C_API bool bgfx_is_texture_valid(uint16_t _depth, bool _cubeMap, uint16_t _numLayers, bgfx_texture_format_t _format, uint64_t _flags);
bool _bgfx_is_texture_valid( int _depth, bool _cubeMap, int _numLayers, int _format, Array<int> _flags )
{
	return bgfx_is_texture_valid( _depth, _cubeMap, _numLayers, (bgfx_texture_format_t)_format, get_uint64_from_int32_array( _flags ) );
}

// Function bgfxCalcTextureSize:Void( _info:BgfxTextureInfo, _width:Int, _height:Int, _depth:Int, _cubeMap:Bool, _hasMips:Bool, _numLayers:Int, _format:Int )="_bgfx_calc_texture_size"
// BGFX_C_API void bgfx_calc_texture_size(bgfx_texture_info_t* _info, uint16_t _width, uint16_t _height, uint16_t _depth, bool _cubeMap, bool _hasMips, uint16_t _numLayers, bgfx_texture_format_t _format);
void _bgfx_calc_texture_size( bgfx_texture_info_object * _info, int _width, int _height, int _depth, bool _cubeMap, bool _hasMips, int _numLayers, int _format )
{
	bgfx_calc_texture_size( &_info->_info, _width, _height, _depth, _cubeMap, _hasMips, _numLayers, (bgfx_texture_format_t)_format );
}

// Function bgfxCreateTexture:Void( _handle:BgfxTextureHandle, _mem:BgfxMemory, _flags:Int[]=BGFX_TEXTURE_NONE|BGFX_SAMPLER_NONE, _skip:Int=0, _info:BgfxTextureInfo=Null )="_bgfx_create_texture"
// Function bgfxCreateTexture:Void( _handle:BgfxTextureHandle, _mem:BgfxMemory )="_bgfx_create_texture"
// Function bgfxCreateTexture:Void( _handle:BgfxTextureHandle, _mem:BgfxMemory, _flags:Int[], _skip:Int=0, _info:BgfxTextureInfo=Null )="_bgfx_create_texture"
// BGFX_C_API bgfx_texture_handle_t bgfx_create_texture(const bgfx_memory_t* _mem, uint64_t _flags, uint8_t _skip, bgfx_texture_info_t* _info);
int _bgfx_create_texture( bgfx_memory_object * _mem )
{
	return (bgfx_create_texture( _mem->_mem, BGFX_TEXTURE_NONE|BGFX_SAMPLER_NONE, 0, NULL )).idx;
}
int _bgfx_create_texture( bgfx_memory_object * _mem, Array<int> _flags, int _skip, bgfx_texture_info_object * _info )
{
	return (bgfx_create_texture( _mem->_mem, get_uint64_from_int32_array( _flags ), _skip, &_info->_info )).idx;
}

// Function bgfxCreateTexture2d:Void( _handle:BgfxTextureHandle, _width:Int, _height:Int, _hasMips:Bool, _numLayers:Int, _format:Int, _flags:Int[]=BGFX_TEXTURE_NONE|BGFX_SAMPLER_NONE, _mem:BgfxMemory=Null )="_bgfx_create_texture_2d"
// Function bgfxCreateTexture2d:Void( _handle:BgfxTextureHandle, _width:Int, _height:Int, _hasMips:Bool, _numLayers:Int, _format:Int )="_bgfx_create_texture_2d"
// Function bgfxCreateTexture2d:Void( _handle:BgfxTextureHandle, _width:Int, _height:Int, _hasMips:Bool, _numLayers:Int, _format:Int, _flags:Int[], _mem:BgfxMemory=Null )="_bgfx_create_texture_2d"
// BGFX_C_API bgfx_texture_handle_t bgfx_create_texture_2d(uint16_t _width, uint16_t _height, bool _hasMips, uint16_t _numLayers, bgfx_texture_format_t _format, uint64_t _flags, const bgfx_memory_t* _mem);
int _bgfx_create_texture_2d( int _width, int _height, bool _hasMips, int _numLayers, int _format )
{
	return (bgfx_create_texture_2d( _width, _height, _hasMips, _numLayers, (bgfx_texture_format_t)_format, BGFX_TEXTURE_NONE|BGFX_SAMPLER_NONE, NULL )).idx;
}
int _bgfx_create_texture_2d( int _width, int _height, bool _hasMips, int _numLayers, int _format, Array<int> _flags )
{
	return (bgfx_create_texture_2d( _width, _height, _hasMips, _numLayers, (bgfx_texture_format_t)_format, get_uint64_from_int32_array( _flags ), NULL )).idx;
}
int _bgfx_create_texture_2d( int _width, int _height, bool _hasMips, int _numLayers, int _format, Array<int> _flags, bgfx_memory_object * _mem )
{
	return (bgfx_create_texture_2d( _width, _height, _hasMips, _numLayers, (bgfx_texture_format_t)_format, get_uint64_from_int32_array( _flags ), _mem->_mem )).idx;
}

// Function bgfxCreateTexture2dScaled:Void( _handle:BgfxTextureHandle, _ratio:Int, _hasMips:Bool, _numLayers:Int, _format:Int, _flags:Int[]=BGFX_TEXTURE_NONE|BGFX_SAMPLER_NONE )="_bgfx_create_texture_2d_scaled"
// Function bgfxCreateTexture2dScaled:Void( _handle:BgfxTextureHandle, _ratio:Int, _hasMips:Bool, _numLayers:Int, _format:Int )="_bgfx_create_texture_2d_scaled"
// Function bgfxCreateTexture2dScaled:Void( _handle:BgfxTextureHandle, _ratio:Int, _hasMips:Bool, _numLayers:Int, _format:Int, _flags:Int[] )="_bgfx_create_texture_2d_scaled"
// BGFX_C_API bgfx_texture_handle_t bgfx_create_texture_2d_scaled(bgfx_backbuffer_ratio_t _ratio, bool _hasMips, uint16_t _numLayers, bgfx_texture_format_t _format, uint64_t _flags);
int _bgfx_create_texture_2d_scaled( int _ratio, bool _hasMips, int _numLayers, int _format )
{
	return (bgfx_create_texture_2d_scaled( (bgfx_backbuffer_ratio_t)_ratio, _hasMips, _numLayers, (bgfx_texture_format_t)_format, BGFX_TEXTURE_NONE|BGFX_SAMPLER_NONE )).idx;
}
int _bgfx_create_texture_2d_scaled( int _ratio, bool _hasMips, int _numLayers, int _format, Array<int> _flags )
{
	return (bgfx_create_texture_2d_scaled( (bgfx_backbuffer_ratio_t)_ratio, _hasMips, _numLayers, (bgfx_texture_format_t)_format, get_uint64_from_int32_array( _flags ) )).idx;
}

// Function bgfxCreateTexture3d:Void( _handle:BgfxTextureHandle, _width:Int, _height:Int, _depth:Int, _hasMips:Bool, _format:Int, _flags:Int[]=BGFX_TEXTURE_NONE|BGFX_SAMPLER_NONE, _mem:BgfxMemory=Null )="_bgfx_create_texture_3d"
// Function bgfxCreateTexture3d:Void( _handle:BgfxTextureHandle, _width:Int, _height:Int, _depth:Int, _hasMips:Bool, _format:Int )="_bgfx_create_texture_3d"
// Function bgfxCreateTexture3d:Void( _handle:BgfxTextureHandle, _width:Int, _height:Int, _depth:Int, _hasMips:Bool, _format:Int, _flags:Int[], _mem:BgfxMemory=Null )="_bgfx_create_texture_3d"
// BGFX_C_API bgfx_texture_handle_t bgfx_create_texture_3d(uint16_t _width, uint16_t _height, uint16_t _depth, bool _hasMips, bgfx_texture_format_t _format, uint64_t _flags, const bgfx_memory_t* _mem);
int _bgfx_create_texture_3d( int _width, int _height, int _depth, bool _hasMips, int _format )
{
	return (bgfx_create_texture_3d( _width, _height, _depth, _hasMips, (bgfx_texture_format_t)_format, BGFX_TEXTURE_NONE|BGFX_SAMPLER_NONE, NULL )).idx;
}
int _bgfx_create_texture_3d( int _width, int _height, int _depth, bool _hasMips, int _format, Array<int> _flags )
{
	return (bgfx_create_texture_3d( _width, _height, _depth, _hasMips, (bgfx_texture_format_t)_format, get_uint64_from_int32_array( _flags ), NULL )).idx;
}
int _bgfx_create_texture_3d( int _width, int _height, int _depth, bool _hasMips, int _format, Array<int> _flags, bgfx_memory_object * _mem )
{
	return (bgfx_create_texture_3d( _width, _height, _depth, _hasMips, (bgfx_texture_format_t)_format, get_uint64_from_int32_array( _flags ), _mem->_mem )).idx;
}

// Function bgfxCreateTextureCube:Void( _handle:BgfxTextureHandle, _size:Int, _hasMips:Bool, _numLayers:Int, _format:Int, _flags:Int[]=BGFX_TEXTURE_NONE|BGFX_SAMPLER_NONE, _mem:BgfxMemory=Null )="_bgfx_create_texture_cube"
// Function bgfxCreateTextureCube:Void( _handle:BgfxTextureHandle, _size:Int, _hasMips:Bool, _numLayers:Int, _format:Int )="_bgfx_create_texture_cube"
// Function bgfxCreateTextureCube:Void( _handle:BgfxTextureHandle, _size:Int, _hasMips:Bool, _numLayers:Int, _format:Int, _flags:Int[], _mem:BgfxMemory=Null )="_bgfx_create_texture_cube"
// BGFX_C_API bgfx_texture_handle_t bgfx_create_texture_cube(uint16_t _size, bool _hasMips, uint16_t _numLayers, bgfx_texture_format_t _format, uint64_t _flags, const bgfx_memory_t* _mem);
int _bgfx_create_texture_cube( int _size, bool _hasMips, int _numLayers, int _format )
{
	return (bgfx_create_texture_cube( _size, _hasMips, _numLayers, (bgfx_texture_format_t)_format, BGFX_TEXTURE_NONE|BGFX_SAMPLER_NONE, NULL )).idx;
}
int _bgfx_create_texture_cube( int _size, bool _hasMips, int _numLayers, int _format, Array<int> _flags )
{
	return (bgfx_create_texture_cube( _size, _hasMips, _numLayers, (bgfx_texture_format_t)_format, get_uint64_from_int32_array( _flags ), NULL )).idx;
}
int _bgfx_create_texture_cube( int _size, bool _hasMips, int _numLayers, int _format, Array<int> _flags, bgfx_memory_object * _mem )
{
	return (bgfx_create_texture_cube( _size, _hasMips, _numLayers, (bgfx_texture_format_t)_format, get_uint64_from_int32_array( _flags ), _mem->_mem )).idx;
}

// Function bgfxUpdateTexture2d:Void( _handle:BgfxTextureHandle, _layer:Int, _mip:Int, _x:Int, _y:Int, _width:Int, _height:Int, _mem:BgfxMemory, _pitch:Int=UINT16_MAX )="_bgfx_update_texture_2d"
// BGFX_C_API void bgfx_update_texture_2d(bgfx_texture_handle_t _handle, uint16_t _layer, uint8_t _mip, uint16_t _x, uint16_t _y, uint16_t _width, uint16_t _height, const bgfx_memory_t* _mem, uint16_t _pitch);
void _bgfx_update_texture_2d( uint16_t _handle, int _layer, int _mip, int _x, int _y, int _width, int _height, bgfx_memory_object * _mem, int _pitch )
{
	bgfx_update_texture_2d( *(bgfx_texture_handle_t *)&_handle, _layer, _mip, _x, _y, _width, _height, _mem->_mem, _pitch );
}

// Function bgfxUpdateTexture3d:Void( _handle:BgfxTextureHandle, _mip:Int, _x:Int, _y:Int, _z:Int, _width:Int, _height:Int, _depth:Int, _mem:BgfxMemory )="_bgfx_update_texture_3d"
// BGFX_C_API void bgfx_update_texture_3d(bgfx_texture_handle_t _handle, uint8_t _mip, uint16_t _x, uint16_t _y, uint16_t _z, uint16_t _width, uint16_t _height, uint16_t _depth, const bgfx_memory_t* _mem);
void _bgfx_update_texture_3d( uint16_t _handle, int _mip, int _x, int _y, int _z, int _width, int _height, int _depth, bgfx_memory_object * _mem )
{
	bgfx_update_texture_3d( *(bgfx_texture_handle_t *)&_handle, _mip, _x, _y, _z, _width, _height, _depth, _mem->_mem );
}

// Function bgfxUpdateTextureCube:Void( _handle:BgfxTextureHandle, _layer:Int, _side:Int, _mip:Int, _x:Int, _y:Int, _width:Int, _height:Int, _mem:BgfxMemory, _pitch:Int=UINT16_MAX )="_bgfx_update_texture_cube"
// BGFX_C_API void bgfx_update_texture_cube(bgfx_texture_handle_t _handle, uint16_t _layer, uint8_t _side, uint8_t _mip, uint16_t _x, uint16_t _y, uint16_t _width, uint16_t _height, const bgfx_memory_t* _mem, uint16_t _pitch);
void _bgfx_update_texture_cube( uint16_t _handle, int _layer, int _side, int _mip, int _x, int _y, int _width, int _height, bgfx_memory_object * _mem, int _pitch )
{
	bgfx_update_texture_cube( *(bgfx_texture_handle_t *)&_handle, _layer, _side, _mip, _x, _y, _width, _height, _mem->_mem, _pitch );
}

// Function bgfxReadTexture:Int( _handle:BgfxTextureHandle, _data:DataBuffer, _mip:Int=0 )="_bgfx_read_texture"
// BGFX_C_API uint32_t bgfx_read_texture(bgfx_texture_handle_t _handle, void* _data, uint8_t _mip);
int _bgfx_read_texture( uint16_t _handle, BBDataBuffer * _data, int _mip )
{
	return bgfx_read_texture( *(bgfx_texture_handle_t *)&_handle, _data->WritePointer(0), _mip );
}

// Function bgfxSetTextureName:Void( _handle:BgfxTextureHandle, _name:String, _len:Int=INT32_MAX )="_bgfx_set_texture_name"
// BGFX_C_API void bgfx_set_texture_name(bgfx_texture_handle_t _handle, const char* _name, int32_t _len);
void _bgfx_set_texture_name( uint16_t _handle, String _name, int _len )
{
	bgfx_set_texture_name( *(bgfx_texture_handle_t *)&_handle, _name.ToCString<char>(), _len );
}

// void * bgfx_get_direct_access_ptr( bgfx_texture_handle_object * _handle )
// {
// }

// Function bgfxDestroyTexture:Void( _handle:BgfxTextureHandle )="_bgfx_destroy_texture"
// BGFX_C_API void bgfx_destroy_texture(bgfx_texture_handle_t _handle);
void _bgfx_destroy_texture( uint16_t _handle )
{
	bgfx_destroy_texture( *(bgfx_texture_handle_t *)&_handle );
}

// Function bgfxCreateFrameBuffer:Void( _handle:BgfxFrameBufferHandle, _width:Int, _height:Int, _format:Int, _textureFlags:Int[]=BGFX_SAMPLER_U_CLAMP|BGFX_SAMPLER_V_CLAMP )="_bgfx_create_frame_buffer"
// Function bgfxCreateFrameBuffer:Void( _handle:BgfxFrameBufferHandle, _width:Int, _height:Int, _format:Int )="_bgfx_create_frame_buffer"
// Function bgfxCreateFrameBuffer:Void( _handle:BgfxFrameBufferHandle, _width:Int, _height:Int, _format:Int, _textureFlags:Int[] )="_bgfx_create_frame_buffer"
// BGFX_C_API bgfx_frame_buffer_handle_t bgfx_create_frame_buffer(uint16_t _width, uint16_t _height, bgfx_texture_format_t _format, uint64_t _textureFlags);
int _bgfx_create_frame_buffer( int _width, int _height, int _format )
{
	return (bgfx_create_frame_buffer( _width, _height, (bgfx_texture_format_t)_format, BGFX_SAMPLER_U_CLAMP|BGFX_SAMPLER_V_CLAMP )).idx;
}
int _bgfx_create_frame_buffer( int _width, int _height, int _format, Array<int> _textureFlags )
{
	return (bgfx_create_frame_buffer( _width, _height, (bgfx_texture_format_t)_format, get_uint64_from_int32_array( _textureFlags ) )).idx;
}

// Function bgfxCreateFrameBufferScaled:Void( _handle:BgfxFrameBufferHandle, _ratio:Int, _format:Int, _textureFlags:Int[]=BGFX_SAMPLER_U_CLAMP|BGFX_SAMPLER_V_CLAMP )="_bgfx_create_frame_buffer_scaled"
// Function bgfxCreateFrameBufferScaled:Void( _handle:BgfxFrameBufferHandle, _ratio:Int, _format:Int )="_bgfx_create_frame_buffer_scaled"
// Function bgfxCreateFrameBufferScaled:Void( _handle:BgfxFrameBufferHandle, _ratio:Int, _format:Int, _textureFlags:Int[] )="_bgfx_create_frame_buffer_scaled"
// BGFX_C_API bgfx_frame_buffer_handle_t bgfx_create_frame_buffer_scaled(bgfx_backbuffer_ratio_t _ratio, bgfx_texture_format_t _format, uint64_t _textureFlags);
int _bgfx_create_frame_buffer_scaled( int _ratio, int _format )
{
	return (bgfx_create_frame_buffer_scaled( (bgfx_backbuffer_ratio_t)_ratio, (bgfx_texture_format_t)_format, BGFX_SAMPLER_U_CLAMP|BGFX_SAMPLER_V_CLAMP )).idx;
}
int _bgfx_create_frame_buffer_scaled( int _ratio, int _format, Array<int> _textureFlags )
{
	return (bgfx_create_frame_buffer_scaled( (bgfx_backbuffer_ratio_t)_ratio, (bgfx_texture_format_t)_format, get_uint64_from_int32_array( _textureFlags ) )).idx;
}

// Function bgfxCreateFrameBufferFromHandles:Void( _handle:BgfxFrameBufferHandle, _num:Int, _handles:BgfxTextureHandle[], _destroyTextures:Bool=False )="_bgfx_create_frame_buffer_from_handles"
// BGFX_C_API bgfx_frame_buffer_handle_t bgfx_create_frame_buffer_from_handles(uint8_t _num, const bgfx_texture_handle_t* _handles, bool _destroyTextures);
int _bgfx_create_frame_buffer_from_handles( int _num, BBDataBuffer * _handles, bool _destroyTextures )
{
	return (bgfx_create_frame_buffer_from_handles( _num, (bgfx_texture_handle_t *)_handles->ReadPointer(0), _destroyTextures )).idx;
}
//int _bgfx_create_frame_buffer_from_handles( int _num, Array<int> _handles, bool _destroyTextures )
//{
//	bgfx_texture_handle_t handles[2];
//	handles[0] = _handles[0];
//	handles[1] = _handles[1];
//	return (bgfx_create_frame_buffer_from_handles( _num, handles, _destroyTextures )).idx;
//}

// Function bgfxCreateFrameBufferFromAttachment:Void( _handle:BgfxFrameBufferHandle, _num:Int, _attachment:BgfxAttachment[], _destroyTextures:Bool=False )="_bgfx_create_frame_buffer_from_attachment"
// BGFX_C_API bgfx_frame_buffer_handle_t bgfx_create_frame_buffer_from_attachment(uint8_t _num, const bgfx_attachment_t* _attachment, bool _destroyTextures);
int _bgfx_create_frame_buffer_from_attachment( int _num, bgfx_attachment_object * _attachment, bool _destroyTextures )
{
	return (bgfx_create_frame_buffer_from_attachment( _num, _attachment->_attachment, _destroyTextures )).idx;
}

// Function bgfxCreateFrameBufferFromNwh:Void( _handle:BgfxFrameBufferHandle, _nwh:DataBuffer, _width:Int, _height:Int, _format:Int=BGFX_TEXTURE_FORMAT_COUNT, _depthFormat:Int=BGFX_TEXTURE_FORMAT_COUNT )="_bgfx_create_frame_buffer_from_nwh"
// BGFX_C_API bgfx_frame_buffer_handle_t bgfx_create_frame_buffer_from_nwh(void* _nwh, uint16_t _width, uint16_t _height, bgfx_texture_format_t _format, bgfx_texture_format_t _depthFormat);
int _bgfx_create_frame_buffer_from_nwh( bgfx_native_window_handle_object * _nwh, int _width, int _height, int _format, int _depthFormat )
{
	return (bgfx_create_frame_buffer_from_nwh( _nwh->_nwh, _width, _height, (bgfx_texture_format_t)_format, (bgfx_texture_format_t)_depthFormat )).idx;
}

// Function bgfxGetTexture:Void( _texture:BgfxTextureHandle, _handle:BgfxFrameBufferHandle, _attachment:Int=0 )="_bgfx_get_texture"
// BGFX_C_API bgfx_texture_handle_t bgfx_get_texture(bgfx_frame_buffer_handle_t _handle, uint8_t _attachment);
int _bgfx_get_texture( uint16_t _handle, int _attachment)
{
	return (bgfx_get_texture( *(bgfx_frame_buffer_handle_t *)&_handle, _attachment )).idx;
}

// Function bgfxDestroyFrameBuffer:Void( _handle:BgfxFrameBufferHandle )="_bgfx_destroy_frame_buffer"
// BGFX_C_API void bgfx_destroy_frame_buffer(bgfx_frame_buffer_handle_t _handle);
void _bgfx_destroy_frame_buffer( uint16_t _handle )
{
	bgfx_destroy_frame_buffer( *(bgfx_frame_buffer_handle_t *)&_handle );
}

// Function bgfxCreateUniform:Void( _handle:BgfxUniformHandle, _name:String, _type:Int, _num:Int=1 )="_bgfx_create_uniform"
// BGFX_C_API bgfx_uniform_handle_t bgfx_create_uniform(const char* _name, bgfx_uniform_type_t _type, uint16_t _num);
int _bgfx_create_uniform( String _name, int _type, int _num )
{
	return (bgfx_create_uniform( _name.ToCString<char>(), (bgfx_uniform_type_t)_type, _num )).idx;
}

// Function bgfxDestroyUniform:Void( _handle:BgfxUniformHandle )="_bgfx_destroy_uniform"
// BGFX_C_API void bgfx_destroy_uniform(bgfx_uniform_handle_t _handle);
void _bgfx_destroy_uniform( uint16_t _handle )
{
	bgfx_destroy_uniform( *(bgfx_uniform_handle_t *)&_handle );
}

// Function bgfxCreateOcclusionQuery:Void( _handle:BgfxOcclusionQueryHandle )="_bgfx_create_occlusion_query"
// BGFX_C_API bgfx_occlusion_query_handle_t bgfx_create_occlusion_query(void);
int _bgfx_create_occlusion_query()
{
	return (bgfx_create_occlusion_query()).idx;
}

// Function bgfxGetResult:Int( _handle:BgfxOcclusionQueryHandle, _result:Int[]=Null )="_bgfx_get_result"
// Function bgfxGetResult:Int( _handle:BgfxOcclusionQueryHandle )="_bgfx_get_result"
// Function bgfxGetResult:Int( _handle:BgfxOcclusionQueryHandle, _result:Int[] )="_bgfx_get_result"
// BGFX_C_API bgfx_occlusion_query_result_t bgfx_get_result(bgfx_occlusion_query_handle_t _handle, int32_t* _result);
int _bgfx_get_result( uint16_t _handle )
{
	return bgfx_get_result( *(bgfx_occlusion_query_handle_t *)&_handle, NULL );
}
int _bgfx_get_result( uint16_t _handle, Array<int> _result)
{
	return bgfx_get_result( *(bgfx_occlusion_query_handle_t *)&_handle, &_result[0] );
}

// Function bgfxDestroyOcclusionQuery:Void( _handle:BgfxOcclusionQueryHandle )="_bgfx_destroy_occlusion_query"
// BGFX_C_API void bgfx_destroy_occlusion_query(bgfx_occlusion_query_handle_t _handle);
void _bgfx_destroy_occlusion_query( uint16_t _handle )
{
	bgfx_destroy_occlusion_query( *(bgfx_occlusion_query_handle_t *)&_handle );
}

// Function bgfxSetPaletteColor:Void( _index:Int, _rgba:Int )="_bgfx_set_palette_color"
// Function bgfxSetPaletteColor:Void( _index:Int, _r:Float, _g:Float, _b:Float, _a:Float )="_bgfx_set_palette_color"
// Function bgfxSetPaletteColor:Void( _index:Int, _rgba:Float[] )="_bgfx_set_palette_color"
// BGFX_C_API void bgfx_set_palette_color(uint8_t _index, const float _rgba[4]);
void _bgfx_set_palette_color( int _index, Array<float> _rgba )
{
	bgfx_set_palette_color( _index, &_rgba[0] );
}

// Function bgfxSetViewName:Void( _id:Int, _name:String )="_bgfx_set_view_name"
// BGFX_C_API void bgfx_set_view_name(bgfx_view_id_t _id, const char* _name);
void _bgfx_set_view_name( int _id, String _name )
{
	bgfx_set_view_name( (bgfx_view_id_t)_id, _name.ToCString<char>() );
}

// Function bgfxSetViewRect:Void( _id:Int, _x:Int, _y:Int, _width:Int, _height:Int )="bgfx_set_view_rect"
// BGFX_C_API void bgfx_set_view_rect(bgfx_view_id_t _id, uint16_t _x, uint16_t _y, uint16_t _width, uint16_t _height);
// void _bgfx_set_view_rect( int _id, int _x, int _y, int _width, int _height )
// {
	// bgfx_set_view_rect( (bgfx_view_id_t)_id, _x, _y, _width, _height );
// }

// Function bgfxSetViewRectAuto:Void( _id:Int, _x:Int, _y:Int, _ratio:Int )="_bgfx_set_view_rect_auto"
// BGFX_C_API void bgfx_set_view_rect_auto(bgfx_view_id_t _id, uint16_t _x, uint16_t _y, bgfx_backbuffer_ratio_t _ratio);
void _bgfx_set_view_rect_auto( int _id, int _x, int _y, int _ratio )
{
	bgfx_set_view_rect_auto( (bgfx_view_id_t)_id, _x, _y, (bgfx_backbuffer_ratio_t)_ratio );
}

// Function bgfxSetViewScissor:Void( _id:Int, _x:Int=0, _y:Int=0, _width:Int=0, _height:Int=0 )="_bgfx_set_view_scissor"
// BGFX_C_API void bgfx_set_view_scissor(bgfx_view_id_t _id, uint16_t _x, uint16_t _y, uint16_t _width, uint16_t _height);
// void _bgfx_set_view_scissor( int _id, int _x, int _y, int _width, int _height )
// {
	// bgfx_set_view_scissor( (bgfx_view_id_t)_id, _x, _y, _width, _height );
// }

// Function bgfxSetViewClear:Void( _id:Int, _flags:Int, _rgba:Int=$000000ff, _depth:Float=1.0, _stencil:Int=0 )="bgfx_set_view_clear"
// BGFX_C_API void bgfx_set_view_clear(bgfx_view_id_t _id, uint16_t _flags, uint32_t _rgba, float _depth, uint8_t _stencil);
// void _bgfx_set_view_clear( int _id, int _flags, int _rgba, float _depth, int _stencil )
// {
	// bgfx_set_view_clear( (bgfx_view_id_t)_id, _flags, _rgba, _depth, _stencil );
// }

// Function bgfxSetViewClearMrt:Void( _id:Int, _flags:Int, _depth:Float, _stencil:Int, _0:Int=UINT8_MAX, _1:Int=UINT8_MAX, _2:Int=UINT8_MAX, _3:Int=UINT8_MAX, _4:Int=UINT8_MAX, _5:Int=UINT8_MAX, _6:Int=UINT8_MAX, _7:Int=UINT8_MAX )="_bgfx_set_view_clear_mrt"
// BGFX_C_API void bgfx_set_view_clear_mrt(bgfx_view_id_t _id, uint16_t _flags, float _depth, uint8_t _stencil, uint8_t _0, uint8_t _1, uint8_t _2, uint8_t _3, uint8_t _4, uint8_t _5, uint8_t _6, uint8_t _7);
// void _bgfx_set_view_clear_mrt( int _id, int _flags, float _depth, int _stencil, int _0, int _1, int _2, int _3, int _4, int _5, int _6, int _7 )
// {
	// bgfx_set_view_clear_mrt( (bgfx_view_id_t)_id, _flags, _depth, _stencil, _0, _1, _2, _3, _4, _5, _6, _7 );
// }

// Function bgfxSetViewMode:Void( _id:Int, _mode:Int=BGFX_VIEW_MODE_DEFAULT )="_bgfx_set_view_mode"
// BGFX_C_API void bgfx_set_view_mode(bgfx_view_id_t _id, bgfx_view_mode_t _mode);
void _bgfx_set_view_mode( int _id, int _mode )
{
	bgfx_set_view_mode( (bgfx_view_id_t)_id, (bgfx_view_mode_t)_mode );
}

// Function bgfxSetViewFrameBuffer:Void( _id:Int, _handle:BgfxFrameBufferHandle )="_bgfx_set_view_frame_buffer"
// BGFX_C_API void bgfx_set_view_frame_buffer(bgfx_view_id_t _id, bgfx_frame_buffer_handle_t _handle);
void _bgfx_set_view_frame_buffer( int _id, uint16_t _handle )
{
	bgfx_set_view_frame_buffer( (bgfx_view_id_t)_id, *(bgfx_frame_buffer_handle_t *)&_handle );
}

// Function bgfxSetViewTransform:Void( _id:Int, _view:Float[], _proj:Float[] )="_bgfx_set_view_transform"
// BGFX_C_API void bgfx_set_view_transform(bgfx_view_id_t _id, const void* _view, const void* _proj);
// void _bgfx_set_view_transform( int _id, const void * _view, const void * _proj )
void _bgfx_set_view_transform( int _id, Array<float> _view, Array<float> _proj )
{
	bgfx_set_view_transform( (bgfx_view_id_t)_id, &_view[0], &_proj[0] );
}
void _bgfx_set_view_transform_view( int _id, Array<float> _view )
{
	bgfx_set_view_transform( (bgfx_view_id_t)_id, &_view[0], NULL );
}
void _bgfx_set_view_transform_proj( int _id, Array<float> _proj )
{
	bgfx_set_view_transform( (bgfx_view_id_t)_id, NULL, &_proj[0] );
}

// Function bgfxSetViewTransformStereo:Void( _id:Int, _view:Float[], _projL:Float[], _flags:Int=BGFX_VIEW_STEREO, _projR:Float[]=Null )="_bgfx_set_view_transform_stereo"
// Function bgfxSetViewTransformStereo:Void( _id:Int, _view:Float[], _projL:Float[], _flags:Int=BGFX_VIEW_STEREO )="_bgfx_set_view_transform_stereo"
// Function bgfxSetViewTransformStereo:Void( _id:Int, _view:Float[], _projL:Float[], _flags:Int, _projR:Float[] )="_bgfx_set_view_transform_stereo"
// BGFX_C_API void bgfx_set_view_transform_stereo(bgfx_view_id_t _id, const void* _view, const void* _projL, uint8_t _flags, const void* _projR);
void _bgfx_set_view_transform_stereo( int _id, Array<float> _view, Array<float> _projL, int _flags )
{
	bgfx_set_view_transform_stereo( (bgfx_view_id_t)_id, &_view[0], &_projL[0], _flags, NULL );
}
void _bgfx_set_view_transform_stereo( int _id, Array<float> _view, Array<float> _projL, int _flags, Array<float> _projR )
{
	bgfx_set_view_transform_stereo( (bgfx_view_id_t)_id, &_view[0], &_projL[0], _flags, &_projR[0] );
}

// Function bgfxSetViewOrder:Void( _id:Int, _num:Int=UINT16_MAX, _order/_remap:Int[]=Null )="_bgfx_set_view_order"
// Function bgfxSetViewOrder:Void( _id:Int, _num:Int=UINT16_MAX )="_bgfx_set_view_order"
// Function bgfxSetViewOrder:Void( _id:Int, _num:Int, _order:Int[] )="_bgfx_set_view_order"
// BGFX_C_API void bgfx_set_view_order(bgfx_view_id_t _id, uint16_t _num, const bgfx_view_id_t* _order);
void _bgfx_set_view_order( int _id, int _num )
{
	bgfx_set_view_order( (bgfx_view_id_t)_id, _num, NULL );
}
void _bgfx_set_view_order( int _id, int _num, BBDataBuffer * _order )
{
	bgfx_set_view_order( (bgfx_view_id_t)_id, _num, (bgfx_view_id_t *)_order->ReadPointer(0) );
}

// Function bgfxResetView:Void( _id:Int )="_bgfx_reset_view"
// BGFX_C_API void bgfx_reset_view(bgfx_view_id_t _id);
// void _bgfx_reset_view( int _id )
// {
	// bgfx_reset_view( (bgfx_view_id_t)_id );
// }

// Function bgfxSetMarker:Void( _marker:String )="_bgfx_set_marker"
// BGFX_C_API void bgfx_set_marker(const char* _marker);
void _bgfx_set_marker( String _marker )
{
	bgfx_set_marker( _marker.ToCString<char>() );
}

// Function bgfxSetState:Void( _state:Int[], _rgba:Int=0 )="_bgfx_set_state"
// BGFX_C_API void bgfx_set_state(uint64_t _state, uint32_t _rgba);
// void _bgfx_set_state( uint64_t _state, int _rgba )
void _bgfx_set_state( Array<int> _state, int _rgba )
{
	bgfx_set_state( get_uint64_from_int32_array( _state ), _rgba );
	/* bgfx_set_state( 0
				| BGFX_STATE_WRITE_R
				| BGFX_STATE_WRITE_G
				| BGFX_STATE_WRITE_B
				| BGFX_STATE_WRITE_A
				| BGFX_STATE_WRITE_Z
				| BGFX_STATE_DEPTH_TEST_LESS
				| BGFX_STATE_CULL_CW
				| BGFX_STATE_MSAA
				| BGFX_STATE_PT_TRISTRIP, _rgba ); */
}

// Function bgfxSetCondition:Void( _handle:BgfxOcclusionQueryHandle, _visible:Bool )="_bgfx_set_condition"
// BGFX_C_API void bgfx_set_condition(bgfx_occlusion_query_handle_t _handle, bool _visible);
void _bgfx_set_condition( uint16_t _handle, bool _visible )
{
	bgfx_set_condition( *(bgfx_occlusion_query_handle_t *)&_handle, _visible );
}

// Function bgfxSetStencil:Void( _fstencil:Int, _bstencil:Int=BGFX_STENCIL_NONE )="bgfx_set_stencil"
// BGFX_C_API void bgfx_set_stencil(uint32_t _fstencil, uint32_t _bstencil);
// void _bgfx_set_stencil( int _fstencil, int _bstencil )
// {
// }

// Function bgfxSetScissor:Int( _x:Int, _y:Int, _width:Int, _height:Int )="bgfx_set_scissor"
// BGFX_C_API uint16_t bgfx_set_scissor(uint16_t _x, uint16_t _y, uint16_t _width, uint16_t _height);
// int _bgfx_set_scissor( int _x, int _y, int _width, int _height )
// {
// }

// Function bgfxSetScissorCached:Void( _cache:Int=UINT16_MAX )="_bgfx_set_scissor_cached"
// BGFX_C_API void bgfx_set_scissor_cached(uint16_t _cache);
// void _bgfx_set_scissor_cached( int _cache )
// {
// }

// Function bgfxSetTransform:Int( _mtx:Float[], _num:Int=1 )="_bgfx_set_transform"
// BGFX_C_API uint32_t bgfx_set_transform(const void* _mtx, uint16_t _num);
// int _bgfx_set_transform( const void * _mtx, int _num )
int _bgfx_set_transform( Array<float> _mtx, int _num )
{
	return bgfx_set_transform( &_mtx[0], _num );
}
int _bgfx_set_transform_null()
{
	return bgfx_set_transform( NULL, 1 );
}

// Function bgfxAllocTransform:Int( _transform:BgfxTransform, _num:Int )="_bgfx_alloc_transform"
// BGFX_C_API uint32_t bgfx_alloc_transform(bgfx_transform_t* _transform, uint16_t _num);
int _bgfx_alloc_transform( bgfx_transform_object * _transform, int _num )
{
	return bgfx_alloc_transform( _transform->_transform, _num );
}

// Function bgfxSetTransformCached:Void( _cache:Int, _num:Int=1 )="bgfx_set_transform_cached"
// BGFX_C_API void bgfx_set_transform_cached(uint32_t _cache, uint16_t _num);
// void _bgfx_set_transform_cached( int _cache, int _num )
// {
// }

// Function bgfxSetUniform:Void( _handle:BgfxUniformHandle, _value:Float[], _num:Int=1 )="_bgfx_set_uniform"
// BGFX_C_API void bgfx_set_uniform(bgfx_uniform_handle_t _handle, const void* _value, uint16_t _num);
void _bgfx_set_uniform( uint16_t _handle, int _value, int _num )
{
	bgfx_set_uniform( *(bgfx_uniform_handle_t *)&_handle, &_value, _num );
}
void _bgfx_set_uniform( uint16_t _handle, Array<int> _value, int _num )
{
	bgfx_set_uniform( *(bgfx_uniform_handle_t *)&_handle, &_value[0], _num );
}
void _bgfx_set_uniform( uint16_t _handle, float _value, int _num )
{
	bgfx_set_uniform( *(bgfx_uniform_handle_t *)&_handle, &_value, _num );
}
void _bgfx_set_uniform( uint16_t _handle, Array<float> _value, int _num )
{
	bgfx_set_uniform( *(bgfx_uniform_handle_t *)&_handle, &_value[0], _num );
}

// Function bgfxSetIndexBuffer:Void( _handle:BgfxIndexBufferHandle )="_bgfx_set_index_buffer"
// Function bgfxSetIndexBuffer:Void( _handle:BgfxIndexBufferHandle, _firstIndex:Int, _numIndices:Int )="_bgfx_set_index_buffer"
// BGFX_C_API void bgfx_set_index_buffer(bgfx_index_buffer_handle_t _handle, uint32_t _firstIndex, uint32_t _numIndices);
void _bgfx_set_index_buffer( uint16_t _handle )
{
	bgfx_set_index_buffer( *(bgfx_index_buffer_handle_t *)&_handle, 0, UINT32_MAX );
}
void _bgfx_set_index_buffer( uint16_t _handle, int _firstIndex, int _numIndices )
{
	bgfx_set_index_buffer( *(bgfx_index_buffer_handle_t *)&_handle, _firstIndex, _numIndices );
}

// Function bgfxSetDynamicIndexBuffer:Void( _handle:BgfxDynamicIndexBufferHandle )="_bgfx_set_dynamic_index_buffer"
// Function bgfxSetDynamicIndexBuffer:Void( _handle:BgfxDynamicIndexBufferHandle, _firstIndex:Int, _numIndices:Int )="_bgfx_set_dynamic_index_buffer"
// BGFX_C_API void bgfx_set_dynamic_index_buffer(bgfx_dynamic_index_buffer_handle_t _handle, uint32_t _firstIndex, uint32_t _numIndices);
void _bgfx_set_dynamic_index_buffer( uint16_t _handle )
{
	bgfx_set_dynamic_index_buffer( *(bgfx_dynamic_index_buffer_handle_t *)&_handle, 0, UINT32_MAX );
}
void _bgfx_set_dynamic_index_buffer( uint16_t _handle, int _firstIndex, int _numIndices )
{
	bgfx_set_dynamic_index_buffer( *(bgfx_dynamic_index_buffer_handle_t *)&_handle, _firstIndex, _numIndices );
}
void _bgfx_reset_dynamic_index_buffer( )
{
	// bgfx_set_dynamic_index_buffer( 0, 0, UINT32_MAX );
}

// Function bgfxSetTransientIndexBuffer:Void( _tib:BgfxTransientIndexBuffer )="_bgfx_set_transient_index_buffer"
// Function bgfxSetTransientIndexBuffer:Void( _tib:BgfxTransientIndexBuffer, _firstIndex:Int, _numIndices:Int )="_bgfx_set_transient_index_buffer"
// BGFX_C_API void bgfx_set_transient_index_buffer(const bgfx_transient_index_buffer_t* _tib, uint32_t _firstIndex, uint32_t _numIndices);
void _bgfx_set_transient_index_buffer( bgfx_transient_index_buffer_object * _tib )
{
	bgfx_set_transient_index_buffer( &_tib->_tib, 0, UINT32_MAX );
}
void _bgfx_set_transient_index_buffer( bgfx_transient_index_buffer_object * _tib, int _firstIndex, int _numIndices )
{
	bgfx_set_transient_index_buffer( &_tib->_tib, _firstIndex, _numIndices );
}

// Function bgfxSetVertexBuffer:Void( _stream:Int, _handle:BgfxVertexBufferHandle )="_bgfx_set_vertex_buffer"
// Function bgfxSetVertexBuffer:Void( _stream:Int, _handle:BgfxVertexBufferHandle, _startVertex:Int, _numVertices:Int )="_bgfx_set_vertex_buffer"
// BGFX_C_API void bgfx_set_vertex_buffer(uint8_t _stream, bgfx_vertex_buffer_handle_t _handle, uint32_t _startVertex, uint32_t _numVertices);
void _bgfx_set_vertex_buffer( int _stream, uint16_t _handle )
{
	bgfx_set_vertex_buffer( _stream, *(bgfx_vertex_buffer_handle_t *)&_handle, 0, UINT32_MAX );
}
void _bgfx_set_vertex_buffer( int _stream, uint16_t _handle, int _startVertex, int _numVertices )
{
	bgfx_set_vertex_buffer( _stream, *(bgfx_vertex_buffer_handle_t *)&_handle, _startVertex, _numVertices );
}

// Function bgfxSetDynamicVertexBuffer:Void( _stream:Int, _handle:BgfxDynamicVertexBufferHandle )="_bgfx_set_dynamic_vertex_buffer"
// Function bgfxSetDynamicVertexBuffer:Void( _stream:Int, _handle:BgfxDynamicVertexBufferHandle, _startVertex:Int, _numVertices:Int )="_bgfx_set_dynamic_vertex_buffer"
// BGFX_C_API void bgfx_set_dynamic_vertex_buffer(uint8_t _stream, bgfx_dynamic_vertex_buffer_handle_t _handle, uint32_t _startVertex, uint32_t _numVertices);
void _bgfx_set_dynamic_vertex_buffer( int _stream, uint16_t _handle )
{
	bgfx_set_dynamic_vertex_buffer( _stream, *(bgfx_dynamic_vertex_buffer_handle_t *)&_handle, 0, UINT32_MAX );
}
void _bgfx_set_dynamic_vertex_buffer( int _stream, uint16_t _handle, int _startVertex, int _numVertices )
{
	bgfx_set_dynamic_vertex_buffer( _stream, *(bgfx_dynamic_vertex_buffer_handle_t *)&_handle, _startVertex, _numVertices );
}

// Function bgfxSetTransientVertexBuffer:Void( _stream:Int, _tvb:BgfxTransientVertexBuffer )="_bgfx_set_transient_vertex_buffer"
// Function bgfxSetTransientVertexBuffer:Void( _stream:Int, _tvb:BgfxTransientVertexBuffer, _startVertex:Int, _numVertices:Int )="_bgfx_set_transient_vertex_buffer"
// BGFX_C_API void bgfx_set_transient_vertex_buffer(uint8_t _stream, const bgfx_transient_vertex_buffer_t* _tvb, uint32_t _startVertex, uint32_t _numVertices);
void _bgfx_set_transient_vertex_buffer( int _stream, const bgfx_transient_vertex_buffer_object * _tvb )
{
	bgfx_set_transient_vertex_buffer( _stream, &_tvb->_tvb, 0, UINT32_MAX );
}
void _bgfx_set_transient_vertex_buffer( int _stream, const bgfx_transient_vertex_buffer_object * _tvb, int _startVertex, int _numVertices )
{
	bgfx_set_transient_vertex_buffer( _stream, &_tvb->_tvb, _startVertex, _numVertices );
}

// Function bgfxSetVertexCount:Void( _numVertices:Int )="_bgfx_set_vertex_count"
// BGFX_C_API void bgfx_set_vertex_count(uint32_t _numVertices);
// void _bgfx_set_vertex_count( int _numVertices )
// {
// }

// Function bgfxSetInstanceDataBuffer:Void( _idb:BgfxInstanceDataBuffer )="_bgfx_set_instance_data_buffer"
// Function bgfxSetInstanceDataBuffer:Void( _idb:BgfxInstanceDataBuffer, _start:Int, _num:Int )="_bgfx_set_instance_data_buffer"
// BGFX_C_API void bgfx_set_instance_data_buffer(const bgfx_instance_data_buffer_t* _idb, uint32_t _start, uint32_t _num);
void _bgfx_set_instance_data_buffer( bgfx_instance_data_buffer_object * _idb )
{
	bgfx_set_instance_data_buffer( &_idb->_idb, 0, UINT32_MAX );
}
void _bgfx_set_instance_data_buffer( bgfx_instance_data_buffer_object * _idb, int _start, int _num )
{
	bgfx_set_instance_data_buffer( &_idb->_idb, _start, _num );
}

// Function bgfxSetInstanceDataFromVertexBuffer:Void( _handle:BgfxVertexBufferHandle, _start:Int, _num:Int )="_bgfx_set_instance_data_from_vertex_buffer"
// BGFX_C_API void bgfx_set_instance_data_from_vertex_buffer(bgfx_vertex_buffer_handle_t _handle, uint32_t _startVertex, uint32_t _num);
void _bgfx_set_instance_data_from_vertex_buffer( uint16_t _handle, int _start, int _num )
{
	bgfx_set_instance_data_from_vertex_buffer( *(bgfx_vertex_buffer_handle_t *)&_handle, _start, _num );
}

// Function bgfxSetInstanceDataFromDynamicVertexBuffer:Void( _handle:BgfxDynamicVertexBufferHandle, _start:Int, _num:Int )="_bgfx_set_instance_data_from_dynamic_vertex_buffer"
// BGFX_C_API void bgfx_set_instance_data_from_dynamic_vertex_buffer(bgfx_dynamic_vertex_buffer_handle_t _handle, uint32_t _startVertex, uint32_t _num);
void _bgfx_set_instance_data_from_dynamic_vertex_buffer( uint16_t _handle, int _start, int _num )
{
	bgfx_set_instance_data_from_dynamic_vertex_buffer( *(bgfx_dynamic_vertex_buffer_handle_t *)&_handle, _start, _num );
}

// Function bgfxSetInstanceCount:Void( _numInstances:Int )="_bgfx_set_instance_count"
// BGFX_C_API void bgfx_set_instance_count(uint32_t _numInstances);
// void _bgfx_set_instance_count( int _numInstances )
// {
// }

// Function bgfxSetTexture:Void( _stage:Int, _sampler:BgfxUniformHandle, _handle:BgfxTextureHandle, _flags:Int=UINT32_MAX )="_bgfx_set_texture"
// BGFX_C_API void bgfx_set_texture(uint8_t _stage, bgfx_uniform_handle_t _sampler, bgfx_texture_handle_t _handle, uint32_t _flags);
void _bgfx_set_texture( int _stage, uint16_t _sampler, uint16_t _handle )
{
	bgfx_set_texture( _stage, *(bgfx_uniform_handle_t *)&_sampler, *(bgfx_texture_handle_t *)&_handle, UINT32_MAX );
}
void _bgfx_set_texture( int _stage, uint16_t _sampler, uint16_t _handle, int _flags )
{
	bgfx_set_texture( _stage, *(bgfx_uniform_handle_t *)&_sampler, *(bgfx_texture_handle_t *)&_handle, _flags );
}

// Function bgfxTouch:Void( _id:Int )="bgfx_touch"
// BGFX_C_API void bgfx_touch(bgfx_view_id_t _id);
// void _bgfx_touch( int _id )
// {
	// bgfx_touch( (bgfx_view_id_t)_id );
// }

// Function bgfxSubmit:Void( _id:Int, _program:BgfxProgramHandle, _depth:Int=0, _preserveState:Bool=False )="_bgfx_submit"
// BGFX_C_API void bgfx_submit(bgfx_view_id_t _id, bgfx_program_handle_t _handle, int32_t _depth, bool _preserveState);
void _bgfx_submit( int _id, uint16_t _handle, int _depth, bool _preserveState )
{
	bgfx_submit( (bgfx_view_id_t)_id, *(bgfx_program_handle_t *)&_handle, _depth, _preserveState );
}

// Function bgfxSubmitOcclusionQuery:Void( _id:Int, _program:BgfxProgramHandle, _occlusionQuery:BgfxOcclusionQueryHandle, _depth:Int=0, _preserveState:Bool=False )="_bgfx_submit_occlusion_query"
// BGFX_C_API void bgfx_submit_occlusion_query(bgfx_view_id_t _id, bgfx_program_handle_t _program, bgfx_occlusion_query_handle_t _occlusionQuery, int32_t _depth, bool _preserveState);
void _bgfx_submit_occlusion_query( int _id, uint16_t _program, uint16_t _occlusionQuery, int _depth, bool _preserveState )
{
	bgfx_submit_occlusion_query( (bgfx_view_id_t)_id, *(bgfx_program_handle_t *)&_program, *(bgfx_occlusion_query_handle_t *)&_occlusionQuery, _depth, _preserveState );
}

// Function bgfxSubmitIndirect:Void( _id:Int, _handle:BgfxProgramHandle, _indirectHandle:BgfxIndirectBufferHandle, _start:Int=0, _num:Int=1, _depth:Int=0, _preserveState:Bool=False )="_bgfx_submit_indirect"
// BGFX_C_API void bgfx_submit_indirect(bgfx_view_id_t _id, bgfx_program_handle_t _handle, bgfx_indirect_buffer_handle_t _indirectHandle, uint16_t _start, uint16_t _num, int32_t _depth, bool _preserveState);
void _bgfx_submit_indirect( int _id, uint16_t _handle, uint16_t _indirectHandle, int _start, int _num, int _depth, bool _preserveState )
{
	bgfx_submit_indirect( (bgfx_view_id_t)_id, *(bgfx_program_handle_t *)&_handle, *(bgfx_indirect_buffer_handle_t *)&_indirectHandle, _start, _num, _depth, _preserveState );
}

// Function bgfxSetImage:Void( _stage:Int, _handle:BgfxTextureHandle, _mip:Int, _access:Int, _format:Int=BGFX_TEXTURE_FORMAT_COUNT )="_bgfx_set_image"
// BGFX_C_API void bgfx_set_image(uint8_t _stage, bgfx_texture_handle_t _handle, uint8_t _mip, bgfx_access_t _access, bgfx_texture_format_t _format);
void _bgfx_set_image( int _stage, uint16_t _handle, int _mip, int _access, int _format )
{
	bgfx_set_image( _stage, *(bgfx_texture_handle_t *)&_handle, _mip, (bgfx_access_t)_access, (bgfx_texture_format_t)_format );
}

// Function bgfxSetComputeIndexBuffer:Void( _stage:Int, _handle:BgfxIndexBufferHandle, _access:Int )="_bgfx_set_compute_index_buffer"
// BGFX_C_API void bgfx_set_compute_index_buffer(uint8_t _stage, bgfx_index_buffer_handle_t _handle, bgfx_access_t _access);
void _bgfx_set_compute_index_buffer( int _stage, uint16_t _handle, int _access )
{
	bgfx_set_compute_index_buffer( _stage, *(bgfx_index_buffer_handle_t *)&_handle, (bgfx_access_t)_access );
}

// Function bgfxSetComputeVertexBuffer:Void( _stage:Int, _handle:BgfxVertexBufferHandle, _access:Int )="_bgfx_set_compute_vertex_buffer"
// BGFX_C_API void bgfx_set_compute_vertex_buffer(uint8_t _stage, bgfx_vertex_buffer_handle_t _handle, bgfx_access_t _access);
void _bgfx_set_compute_vertex_buffer( int _stage, uint16_t _handle, int _access )
{
	bgfx_set_compute_vertex_buffer( _stage, *(bgfx_vertex_buffer_handle_t *)&_handle, (bgfx_access_t)_access );
}

// Function bgfxSetComputeDynamicIndexBuffer:Void( _stage:Int, _handle:BgfxDynamicIndexBufferHandle, _access:Int )="_bgfx_set_compute_dynamic_index_buffer"
// BGFX_C_API void bgfx_set_compute_dynamic_index_buffer(uint8_t _stage, bgfx_dynamic_index_buffer_handle_t _handle, bgfx_access_t _access);
void _bgfx_set_compute_dynamic_index_buffer( int _stage, uint16_t _handle, int _access )
{
	bgfx_set_compute_dynamic_index_buffer( _stage, *(bgfx_dynamic_index_buffer_handle_t *)&_handle, (bgfx_access_t)_access );
}

// Function bgfxSetComputeDynamicVertexBuffer:Void( _stage:Int, _handle:BgfxDynamicVertexBufferHandle, _access:Int )="_bgfx_set_compute_dynamic_vertex_buffer"
// BGFX_C_API void bgfx_set_compute_dynamic_vertex_buffer(uint8_t _stage, bgfx_dynamic_vertex_buffer_handle_t _handle, bgfx_access_t _access);
void _bgfx_set_compute_dynamic_vertex_buffer( int _stage, uint16_t _handle, int _access )
{
	bgfx_set_compute_dynamic_vertex_buffer( _stage, *(bgfx_dynamic_vertex_buffer_handle_t *)&_handle, (bgfx_access_t)_access );
}

// Function bgfxSetComputeIndirectBuffer:Void( _stage:Int, _handle:BgfxIndirectBufferHandle, _access:Int )="_bgfx_set_compute_indirect_buffer"
// BGFX_C_API void bgfx_set_compute_indirect_buffer(uint8_t _stage, bgfx_indirect_buffer_handle_t _handle, bgfx_access_t _access);
void _bgfx_set_compute_indirect_buffer( int _stage, uint16_t _handle, int _access )
{
	bgfx_set_compute_indirect_buffer( _stage, *(bgfx_indirect_buffer_handle_t *)&_handle, (bgfx_access_t)_access );
}

// Function bgfxDispatch:Void( _id:Int, _handle:BgfxProgramHandle, _numX:Int=1, _numY:Int=1, _numZ:Int=1, _flags:Int=BGFX_SUBMIT_EYE_FIRST )="_bgfx_dispatch"
// BGFX_C_API void bgfx_dispatch(bgfx_view_id_t _id, bgfx_program_handle_t _handle, uint32_t _numX, uint32_t _numY, uint32_t _numZ, uint8_t _flags);
void _bgfx_dispatch( int _id, uint16_t _handle, int _numX, int _numY, int _numZ, int _flags )
{
	bgfx_dispatch( (bgfx_view_id_t)_id, *(bgfx_program_handle_t *)&_handle, _numX, _numY, _numZ, _flags );
}

// Function bgfxDispatchIndirect:Void( _id:Int, _handle:BgfxProgramHandle, _indirectHandle:BgfxIndirectBufferHandle, _start:Int=0, _num:Int=1, _flags:Int=BGFX_SUBMIT_EYE_FIRST )="_bgfx_dispatch_indirect"
// BGFX_C_API void bgfx_dispatch_indirect(bgfx_view_id_t _id, bgfx_program_handle_t _handle, bgfx_indirect_buffer_handle_t _indirectHandle, uint16_t _start, uint16_t _num, uint8_t _flags);
void _bgfx_dispatch_indirect( int _id, uint16_t _handle, uint16_t _indirectHandle, int _start, int _num, int _flags )
{
	bgfx_dispatch_indirect( (bgfx_view_id_t)_id, *(bgfx_program_handle_t *)&_handle, *(bgfx_indirect_buffer_handle_t *)&_indirectHandle, _start, _num, _flags );
}

// Function bgfxDiscard:Void(  )="_bgfx_discard"
// BGFX_C_API void bgfx_discard(void);
// void _bgfx_discard( void )
// {
// }

// Function bgfxBlit:Void( _id:Int, _dst:BgfxTextureHandle, _dstX:Int, _dstY:Int, _src:BgfxTextureHandle, _srcX:Int=0, _srcY:Int=0, _width:Int=UINT16_MAX, _height:Int=UINT16_MAX )="_bgfx_blit"
// Function bgfxBlit:Void( _id:Int, _dst:BgfxTextureHandle, _dstMip:Int, _dstX:Int, _dstY:Int, _dstZ:Int, _src:BgfxTextureHandle, _srcMip:Int=0, _srcX:Int=0, _srcY:Int=0, _srcZ:Int=0, _width:Int=UINT16_MAX, _height:Int=UINT16_MAX, _depth:Int=UINT16_MAX )="_bgfx_blit"
// BGFX_C_API void bgfx_blit(bgfx_view_id_t _id, bgfx_texture_handle_t _dst, uint8_t _dstMip, uint16_t _dstX, uint16_t _dstY, uint16_t _dstZ, bgfx_texture_handle_t _src, uint8_t _srcMip, uint16_t _srcX, uint16_t _srcY, uint16_t _srcZ, uint16_t _width, uint16_t _height, uint16_t _depth);
void _bgfx_blit( int _id, uint16_t _dst, int _dstX, int _dstY, uint16_t _src, int _srcX, int _srcY, int _width, int _height )
{
	bgfx_blit( (bgfx_view_id_t)_id, *(bgfx_texture_handle_t *)&_dst, 0, _dstX, _dstY, 0, *(bgfx_texture_handle_t *)&_src, 0, _srcX, _srcY, 0, _width, _height, 0 );
}
void _bgfx_blit( int _id, uint16_t _dst, int _dstMip, int _dstX, int _dstY, int _dstZ, uint16_t _src, int _srcMip, int _srcX, int _srcY, int _srcZ, int _width, int _height, int _depth )
{
	bgfx_blit( (bgfx_view_id_t)_id, *(bgfx_texture_handle_t *)&_dst, _dstMip, _dstX, _dstY, _dstZ, *(bgfx_texture_handle_t *)&_src, _srcMip, _srcX, _srcY, _srcZ, _width, _height, _depth );
}

// Function bgfxEncoderSetMarker:Void( _encoder:BgfxEncoder, _marker:String )="_bgfx_encoder_set_marker"
// BGFX_C_API void bgfx_encoder_set_marker(struct bgfx_encoder_s* _encoder, const char* _marker);
void _bgfx_encoder_set_marker( bgfx_encoder_object * _encoder, String _marker )
{
	bgfx_encoder_set_marker( _encoder->_encoder, _marker.ToCString<char>() );
}

// Function bgfxEncoderSetState:Void( _encoder:BgfxEncoder, _state:Int[], _rgba:Int=0 )="_bgfx_encoder_set_state"
// BGFX_C_API void bgfx_encoder_set_state(struct bgfx_encoder_s* _encoder, uint64_t _state, uint32_t _rgba);
void _bgfx_encoder_set_state( bgfx_encoder_object * _encoder, Array<int> _state, int _rgba )
{
	bgfx_encoder_set_state( _encoder->_encoder, get_uint64_from_int32_array( _state ), _rgba );
}

// Function bgfxEncoderSetCondition:Void( _encoder:BgfxEncoder, _handle:BgfxOcclusionQueryHandle, _visible:Bool )="_bgfx_encoder_set_condition"
// BGFX_C_API void bgfx_encoder_set_condition(struct bgfx_encoder_s* _encoder, bgfx_occlusion_query_handle_t _handle, bool _visible);
void _bgfx_encoder_set_condition( bgfx_encoder_object * _encoder, uint16_t _handle, bool _visible )
{
	bgfx_encoder_set_condition( _encoder->_encoder, *(bgfx_occlusion_query_handle_t *)&_handle, _visible );
}

// Function bgfxEncoderSetStencil:Void( _encoder:BgfxEncoder, _fstencil:Int, _bstencil:Int=BGFX_STENCIL_NONE )="_bgfx_encoder_set_stencil"
// BGFX_C_API void bgfx_encoder_set_stencil(struct bgfx_encoder_s* _encoder, uint32_t _fstencil, uint32_t _bstencil);
void _bgfx_encoder_set_stencil( bgfx_encoder_object * _encoder, int _fstencil, int _bstencil )
{
	bgfx_encoder_set_stencil( _encoder->_encoder, _fstencil, _bstencil );
}

// Function bgfxEncoderSetScissor:Int( _encoder:BgfxEncoder, _x:Int, _y:Int, _width:Int, _height:Int )="_bgfx_encoder_set_scissor"
// BGFX_C_API uint16_t bgfx_encoder_set_scissor(struct bgfx_encoder_s* _encoder, uint16_t _x, uint16_t _y, uint16_t _width, uint16_t _height);
int _bgfx_encoder_set_scissor( bgfx_encoder_object * _encoder, int _x, int _y, int _width, int _height )
{
	bgfx_encoder_set_scissor( _encoder->_encoder, _x, _y, _width, _height );
}

// Function bgfxEncoderSetScissorCached:Void( _encoder:BgfxEncoder, _cache:Int=UINT16_MAX )="_bgfx_encoder_set_scissor_cached"
// BGFX_C_API void bgfx_encoder_set_scissor_cached(struct bgfx_encoder_s* _encoder, uint16_t _cache);
void _bgfx_encoder_set_scissor_cached( bgfx_encoder_object * _encoder, int _cache )
{
	bgfx_encoder_set_scissor_cached( _encoder->_encoder, _cache );
}

// Function bgfxEncoderSetTransform:Int( _encoder:BgfxEncoder, _mtx:Float[], _num:Int=1 )="_bgfx_encoder_set_transform"
// BGFX_C_API uint32_t bgfx_encoder_set_transform(struct bgfx_encoder_s* _encoder, const void* _mtx, uint16_t _num);
int _bgfx_encoder_set_transform( bgfx_encoder_object * _encoder, Array<float> _mtx, int _num )
{
	bgfx_encoder_set_transform( _encoder->_encoder, &_mtx[0], _num );
}

// Function bgfxEncoderAllocTransform:Int( _encoder:BgfxEncoder, _transform:BgfxTransform, _num:Int )="_bgfx_encoder_alloc_transform"
// BGFX_C_API uint32_t bgfx_encoder_alloc_transform(struct bgfx_encoder_s* _encoder, bgfx_transform_t* _transform, uint16_t _num);
int _bgfx_encoder_alloc_transform( bgfx_encoder_object * _encoder, bgfx_transform_object * _transform, int _num )
{
	bgfx_encoder_alloc_transform( _encoder->_encoder, _transform->_transform, _num );
}

// Function bgfxEncoderSetTransformCached:Void( _encoder:BgfxEncoder, _cache:Int, _num:Int=1 )="_bgfx_encoder_set_transform_cached"
// BGFX_C_API void bgfx_encoder_set_transform_cached(struct bgfx_encoder_s* _encoder, uint32_t _cache, uint16_t _num);
void _bgfx_encoder_set_transform_cached( bgfx_encoder_object * _encoder, int _cache, int _num )
{
	bgfx_encoder_set_transform_cached( _encoder->_encoder, _cache, _num );
}

// Function bgfxEncoderSetUniform:Void( _encoder:BgfxEncoder, _handle:BgfxUniformHandle, _value:Float[], _num:Int=1 )="_bgfx_encoder_set_uniform"
// BGFX_C_API void bgfx_encoder_set_uniform(struct bgfx_encoder_s* _encoder, bgfx_uniform_handle_t _handle, const void* _value, uint16_t _num);
void _bgfx_encoder_set_uniform( bgfx_encoder_object * _encoder, uint16_t _handle, Array<float> _value, int _num )
{
	bgfx_encoder_set_uniform( _encoder->_encoder, *(bgfx_uniform_handle_t *)&_handle, &_value[0], _num );
}

// Function bgfxEncoderSetIndexBuffer:Void( _encoder:BgfxEncoder, _handle:BgfxIndexBufferHandle )="_bgfx_encoder_set_index_buffer"
// Function bgfxEncoderSetIndexBuffer:Void( _encoder:BgfxEncoder, _handle:BgfxIndexBufferHandle, _firstIndex:Int, _numIndices:Int )="_bgfx_encoder_set_index_buffer"
// BGFX_C_API void bgfx_encoder_set_index_buffer(struct bgfx_encoder_s* _encoder, bgfx_index_buffer_handle_t _handle, uint32_t _firstIndex, uint32_t _numIndices);
void _bgfx_encoder_set_index_buffer( bgfx_encoder_object * _encoder, uint16_t _handle )
{
	bgfx_encoder_set_index_buffer( _encoder->_encoder, *(bgfx_index_buffer_handle_t *)&_handle, 0, UINT32_MAX );
}
void _bgfx_encoder_set_index_buffer( bgfx_encoder_object * _encoder, uint16_t _handle, int _firstIndex, int _numIndices )
{
	bgfx_encoder_set_index_buffer( _encoder->_encoder, *(bgfx_index_buffer_handle_t *)&_handle, _firstIndex, _numIndices );
}

// Function bgfxEncoderSetDynamicIndexBuffer:Void( _encoder:BgfxEncoder, _handle:BgfxDynamicIndexBufferHandle )="_bgfx_encoder_set_dynamic_index_buffer"
// Function bgfxEncoderSetDynamicIndexBuffer:Void( _encoder:BgfxEncoder, _handle:BgfxDynamicIndexBufferHandle, _firstIndex:Int, _numIndices:Int )="_bgfx_encoder_set_dynamic_index_buffer"
// BGFX_C_API void bgfx_encoder_set_dynamic_index_buffer(struct bgfx_encoder_s* _encoder, bgfx_dynamic_index_buffer_handle_t _handle, uint32_t _firstIndex, uint32_t _numIndices);
void _bgfx_encoder_set_dynamic_index_buffer( bgfx_encoder_object * _encoder, uint16_t _handle )
{
	bgfx_encoder_set_dynamic_index_buffer( _encoder->_encoder, *(bgfx_dynamic_index_buffer_handle_t *)&_handle, 0, UINT32_MAX );
}
void _bgfx_encoder_set_dynamic_index_buffer( bgfx_encoder_object * _encoder, uint16_t _handle, int _firstIndex, int _numIndices )
{
	bgfx_encoder_set_dynamic_index_buffer( _encoder->_encoder, *(bgfx_dynamic_index_buffer_handle_t *)&_handle, _firstIndex, _numIndices );
}

// Function bgfxEncoderSetTransientIndexBuffer:Void( _encoder:BgfxEncoder, _tib:BgfxTransientIndexBuffer )="_bgfx_encoder_set_transient_index_buffer"
// Function bgfxEncoderSetTransientIndexBuffer:Void( _encoder:BgfxEncoder, _tib:BgfxTransientIndexBuffer, _firstIndex:Int, _numIndices:Int )="_bgfx_encoder_set_transient_index_buffer"
// BGFX_C_API void bgfx_encoder_set_transient_index_buffer(struct bgfx_encoder_s* _encoder, const bgfx_transient_index_buffer_t* _tib, uint32_t _firstIndex, uint32_t _numIndices);
void _bgfx_encoder_set_transient_index_buffer( bgfx_encoder_object * _encoder, const bgfx_transient_index_buffer_object * _tib )
{
	bgfx_encoder_set_transient_index_buffer( _encoder->_encoder, &_tib->_tib, 0, UINT32_MAX );
}
void _bgfx_encoder_set_transient_index_buffer( bgfx_encoder_object * _encoder, const bgfx_transient_index_buffer_object * _tib, int _firstIndex, int _numIndices )
{
	bgfx_encoder_set_transient_index_buffer( _encoder->_encoder, &_tib->_tib, _firstIndex, _numIndices );
}

// Function bgfxEncoderSetVertexBuffer:Void( _encoder:BgfxEncoder, _stream:Int, _handle:BgfxVertexBufferHandle )="_bgfx_encoder_set_vertex_buffer"
// Function bgfxEncoderSetVertexBuffer:Void( _encoder:BgfxEncoder, _stream:Int, _handle:BgfxVertexBufferHandle, _startVertex:Int, _numVertices:Int )="_bgfx_encoder_set_vertex_buffer"
// BGFX_C_API void bgfx_encoder_set_vertex_buffer(struct bgfx_encoder_s* _encoder, uint8_t _stream, bgfx_vertex_buffer_handle_t _handle, uint32_t _startVertex, uint32_t _numVertices);
void _bgfx_encoder_set_vertex_buffer( bgfx_encoder_object * _encoder, int _stream, uint16_t _handle )
{
	bgfx_encoder_set_vertex_buffer( _encoder->_encoder, _stream, *(bgfx_vertex_buffer_handle_t *)&_handle, 0, UINT32_MAX );
}
void _bgfx_encoder_set_vertex_buffer( bgfx_encoder_object * _encoder, int _stream, uint16_t _handle, int _startVertex, int _numVertices )
{
	bgfx_encoder_set_vertex_buffer( _encoder->_encoder, _stream, *(bgfx_vertex_buffer_handle_t *)&_handle, _startVertex, _numVertices );
}

// Function bgfxEncoderSetDynamicVertexBuffer:Void( _encoder:BgfxEncoder, _stream:Int, _handle:BgfxDynamicVertexBufferHandle )="_bgfx_encoder_set_dynamic_vertex_buffer"
// Function bgfxEncoderSetDynamicVertexBuffer:Void( _encoder:BgfxEncoder, _stream:Int, _handle:BgfxDynamicVertexBufferHandle, _startVertex:Int, _numVertices:Int )="_bgfx_encoder_set_dynamic_vertex_buffer"
// BGFX_C_API void bgfx_encoder_set_dynamic_vertex_buffer(struct bgfx_encoder_s* _encoder, uint8_t _stream, bgfx_dynamic_vertex_buffer_handle_t _handle, uint32_t _startVertex, uint32_t _numVertices);
void _bgfx_encoder_set_dynamic_vertex_buffer( bgfx_encoder_object * _encoder, int _stream, uint16_t _handle )
{
	bgfx_encoder_set_dynamic_vertex_buffer( _encoder->_encoder, _stream, *(bgfx_dynamic_vertex_buffer_handle_t *)&_handle, 0, UINT32_MAX );
}
void _bgfx_encoder_set_dynamic_vertex_buffer( bgfx_encoder_object * _encoder, int _stream, uint16_t _handle, int _startVertex, int _numVertices )
{
	bgfx_encoder_set_dynamic_vertex_buffer( _encoder->_encoder, _stream, *(bgfx_dynamic_vertex_buffer_handle_t *)&_handle, _startVertex, _numVertices );
}

// Function bgfxEncoderSetTransientVertexBuffer:Void( _encoder:BgfxEncoder, _encoder:Int, _tvb:BgfxTransientVertexBuffer )="_bgfx_encoder_set_transient_vertex_buffer"
// Function bgfxEncoderSetTransientVertexBuffer:Void( _encoder:BgfxEncoder, _encoder:Int, _tvb:BgfxTransientVertexBuffer, _startVertex:Int, _numVertices:Int )="_bgfx_encoder_set_transient_vertex_buffer"
// BGFX_C_API void bgfx_encoder_set_transient_vertex_buffer(struct bgfx_encoder_s* _encoder, uint8_t _stream, const bgfx_transient_vertex_buffer_t* _tvb, uint32_t _startVertex, uint32_t _numVertices);
void _bgfx_encoder_set_transient_vertex_buffer( bgfx_encoder_object * _encoder, int _stream, bgfx_transient_vertex_buffer_object * _tvb )
{
	bgfx_encoder_set_transient_vertex_buffer( _encoder->_encoder, _stream, &_tvb->_tvb, 0, UINT32_MAX );
}
void _bgfx_encoder_set_transient_vertex_buffer( bgfx_encoder_object * _encoder, int _stream, bgfx_transient_vertex_buffer_object * _tvb, int _startVertex, int _numVertices )
{
	bgfx_encoder_set_transient_vertex_buffer( _encoder->_encoder, _stream, &_tvb->_tvb, _startVertex, _numVertices );
}

// Function bgfxEncoderSetVertexCount:Void( _encoder:BgfxEncoder, _numVertices:Int )="_bgfx_encoder_set_vertex_count"
// BGFX_C_API void bgfx_encoder_set_vertex_count(struct bgfx_encoder_s* _encoder, uint32_t _numVertices);
void _bgfx_encoder_set_vertex_count( bgfx_encoder_object * _encoder, int _numVertices )
{
	bgfx_encoder_set_vertex_count( _encoder->_encoder, _numVertices );
}

// Function bgfxEncoderSetInstanceDataBuffer:Void( _encoder:BgfxEncoder, _idb:BgfxInstanceDataBuffer )="_bgfx_encoder_set_instance_data_buffer"
// Function bgfxEncoderSetInstanceDataBuffer:Void( _encoder:BgfxEncoder, _idb:BgfxInstanceDataBuffer, _start:Int, _num:Int )="_bgfx_encoder_set_instance_data_buffer"
// BGFX_C_API void bgfx_encoder_set_instance_data_buffer(struct bgfx_encoder_s* _encoder, const bgfx_instance_data_buffer_t* _idb, uint32_t _start, uint32_t _num);
void _bgfx_encoder_set_instance_data_buffer( bgfx_encoder_object * _encoder, bgfx_instance_data_buffer_object * _idb )
{
	bgfx_encoder_set_instance_data_buffer( _encoder->_encoder, &_idb->_idb, 0, UINT32_MAX );
}
void _bgfx_encoder_set_instance_data_buffer( bgfx_encoder_object * _encoder, bgfx_instance_data_buffer_object * _idb, int _start, int _num )
{
	bgfx_encoder_set_instance_data_buffer( _encoder->_encoder, &_idb->_idb, _start, _num );
}

// Function bgfxEncoderSetInstanceDataFromVertexBuffer:Void( _encoder:BgfxEncoder, _handle:BgfxVertexBufferHandle, _start:Int, _num:Int )="_bgfx_encoder_set_instance_data_from_vertex_buffer"
// BGFX_C_API void bgfx_encoder_set_instance_data_from_vertex_buffer(struct bgfx_encoder_s* _encoder, bgfx_vertex_buffer_handle_t _handle, uint32_t _startVertex, uint32_t _num);
void _bgfx_encoder_set_instance_data_from_vertex_buffer( bgfx_encoder_object * _encoder, uint16_t _handle, int _start, int _num )
{
	bgfx_encoder_set_instance_data_from_vertex_buffer( _encoder->_encoder, *(bgfx_vertex_buffer_handle_t *)&_handle, _start, _num );
}

// Function bgfxEncoderSetInstanceDataFromDynamicVertexBuffer:Void( _encoder:BgfxEncoder, _handle:BgfxDynamicVertexBufferHandle, _start:Int, _num:Int )="_bgfx_encoder_set_instance_data_from_dynamic_vertex_buffer"
// BGFX_C_API void bgfx_encoder_set_instance_data_from_dynamic_vertex_buffer(struct bgfx_encoder_s* _encoder, bgfx_dynamic_vertex_buffer_handle_t _handle, uint32_t _startVertex, uint32_t _num);
void _bgfx_encoder_set_instance_data_from_dynamic_vertex_buffer( bgfx_encoder_object * _encoder, uint16_t _handle, int _start, int _num )
{
	bgfx_encoder_set_instance_data_from_dynamic_vertex_buffer( _encoder->_encoder, *(bgfx_dynamic_vertex_buffer_handle_t *)&_handle, _start, _num );
}

// Function bgfxEncoderSetInstanceCount:Void( _encoder:BgfxEncoder, _numInstances:Int )="_bgfx_encoder_set_instance_count"
void _bgfx_encoder_set_instance_count( bgfx_encoder_object * _encoder, uint32_t _numInstances )
{
	// bgfx_encoder_( _encoder->_encoder, );
	printf("TODO _bgfx_encoder_set_instance_count\n");
}

// Function bgfxEncoderSetTexture:Void( _encoder:BgfxEncoder, _stage:Int, _sampler:BgfxUniformHandle, _handle:BgfxTextureHandle, _flags:Int=UINT32_MAX )="_bgfx_encoder_set_texture"
// BGFX_C_API void bgfx_encoder_set_texture(struct bgfx_encoder_s* _encoder, uint8_t _stage, bgfx_uniform_handle_t _sampler, bgfx_texture_handle_t _handle, uint32_t _flags);
void _bgfx_encoder_set_texture( bgfx_encoder_object * _encoder, int _stage, uint16_t _sampler, uint16_t _handle, int _flags )
{
	bgfx_encoder_set_texture( _encoder->_encoder, _stage, *(bgfx_uniform_handle_t *)&_sampler, *(bgfx_texture_handle_t *)&_handle, _flags );
}

// Function bgfxEncoderTouch:Void( _encoder:BgfxEncoder, _id:Int )="_bgfx_encoder_touch"
// BGFX_C_API void bgfx_encoder_touch(struct bgfx_encoder_s* _encoder, bgfx_view_id_t _id);
void _bgfx_encoder_touch( bgfx_encoder_object * _encoder, int _id )
{
	bgfx_encoder_touch( _encoder->_encoder, (bgfx_view_id_t)_id );
}

// Function bgfxEncoderSubmit:Void( _encoder:BgfxEncoder, _id:Int, _handle:BgfxProgramHandle, _depth:Int=0, _preserveState:Bool=False )="_bgfx_encoder_submit"
// BGFX_C_API void bgfx_encoder_submit(struct bgfx_encoder_s* _encoder, bgfx_view_id_t _id, bgfx_program_handle_t _handle, int32_t _depth, bool _preserveState);
void _bgfx_encoder_submit( bgfx_encoder_object * _encoder, int _id, uint16_t _handle, int _depth, bool _preserveState )
{
	bgfx_encoder_submit( _encoder->_encoder, (bgfx_view_id_t)_id, *(bgfx_program_handle_t *)&_handle, _depth, _preserveState );
}

// Function bgfxEncoderSubmitOcclusionQuery:Void( _encoder:BgfxEncoder, _id:Int, _program:BgfxProgramHandle, _occlusionQuery:BgfxOcclusionQueryHandle, _depth:Int=0, _preserveState:Bool=False )="_bgfx_encoder_submit_occlusion_query"
// BGFX_C_API void bgfx_encoder_submit_occlusion_query(struct bgfx_encoder_s* _encoder, bgfx_view_id_t _id, bgfx_program_handle_t _program, bgfx_occlusion_query_handle_t _occlusionQuery, int32_t _depth, bool _preserveState);
void _bgfx_encoder_submit_occlusion_query( bgfx_encoder_object * _encoder, int _id, uint16_t _program, uint16_t _occlusionQuery, int _depth, bool _preserveState )
{
	bgfx_encoder_submit_occlusion_query( _encoder->_encoder, (bgfx_view_id_t)_id, *(bgfx_program_handle_t *)&_program, *(bgfx_occlusion_query_handle_t *)&_occlusionQuery, _depth, _preserveState );
}

// Function bgfxEncoderSubmitIndirect:Void( _encoder:BgfxEncoder, _id:Int, _handle:BgfxProgramHandle, _indirectHandle:BgfxIndirectBufferHandle, _start:Int=0, _num:Int=1, _depth:Int=0, _preserveState:Bool=False )="_bgfx_encoder_submit_indirect"
// BGFX_C_API void bgfx_encoder_submit_indirect(struct bgfx_encoder_s* _encoder, bgfx_view_id_t _id, bgfx_program_handle_t _handle, bgfx_indirect_buffer_handle_t _indirectHandle, uint16_t _start, uint16_t _num, int32_t _depth, bool _preserveState);
void _bgfx_encoder_submit_indirect( bgfx_encoder_object * _encoder, int _id, uint16_t _handle, uint16_t _indirectHandle, int _start, int _num, int _depth, bool _preserveState )
{
	bgfx_encoder_submit_indirect( _encoder->_encoder, (bgfx_view_id_t)_id, *(bgfx_program_handle_t *)&_handle, *(bgfx_indirect_buffer_handle_t *)&_indirectHandle, _start, _num, _depth, _preserveState );
}

// Function bgfxEncoderSetImage:Void( _encoder:BgfxEncoder, _stage:Int, _handle:BgfxTextureHandle, _mip:Int, _access:Int, _format:Int=BGFX_TEXTURE_FORMAT_COUNT )="_bgfx_encoder_set_image"
// BGFX_C_API void bgfx_encoder_set_image(struct bgfx_encoder_s* _encoder, uint8_t _stage, bgfx_texture_handle_t _handle, uint8_t _mip, bgfx_access_t _access, bgfx_texture_format_t _format);
void _bgfx_encoder_set_image( bgfx_encoder_object * _encoder, int _stage, uint16_t _handle, int _mip, int _access, int _format )
{
	bgfx_encoder_set_image( _encoder->_encoder, _stage, *(bgfx_texture_handle_t *)&_handle, _mip, (bgfx_access_t)_access, (bgfx_texture_format_t)_format );
}

// Function bgfxEncoderSetComputeIndexBuffer:Void( _encoder:BgfxEncoder, _stage:Int, _handle:BgfxIndexBufferHandle, _access:Int )="_bgfx_encoder_set_compute_index_buffer"
// BGFX_C_API void bgfx_encoder_set_compute_index_buffer(struct bgfx_encoder_s* _encoder, uint8_t _stage, bgfx_index_buffer_handle_t _handle, bgfx_access_t _access);
void _bgfx_encoder_set_compute_index_buffer( bgfx_encoder_object * _encoder, int _stage, uint16_t _handle, int _access )
{
	bgfx_encoder_set_compute_index_buffer( _encoder->_encoder, _stage, *(bgfx_index_buffer_handle_t *)&_handle, (bgfx_access_t)_access );
}

// Function bgfxEncoderSetComputeVertexBuffer:Void( _encoder:BgfxEncoder, _stage:Int, _handle:BgfxVertexBufferHandle, _access:Int )="_bgfx_encoder_set_compute_vertex_buffer"
// BGFX_C_API void bgfx_encoder_set_compute_vertex_buffer(struct bgfx_encoder_s* _encoder, uint8_t _stage, bgfx_vertex_buffer_handle_t _handle, bgfx_access_t _access);
void _bgfx_encoder_set_compute_vertex_buffer( bgfx_encoder_object * _encoder, int _stage, uint16_t _handle, int _access )
{
	bgfx_encoder_set_compute_vertex_buffer( _encoder->_encoder, _stage, *(bgfx_vertex_buffer_handle_t *)&_handle, (bgfx_access_t)_access );
}

// Function bgfxEncoderSetComputeDynamicIndexBuffer:Void( _encoder:BgfxEncoder, _stage:Int, _handle:BgfxDynamicIndexBufferHandle, _access:Int )="_bgfx_encoder_set_compute_dynamic_index_buffer"
// BGFX_C_API void bgfx_encoder_set_compute_dynamic_index_buffer(struct bgfx_encoder_s* _encoder, uint8_t _stage, bgfx_dynamic_index_buffer_handle_t _handle, bgfx_access_t _access);
void _bgfx_encoder_set_compute_dynamic_index_buffer( bgfx_encoder_object * _encoder, int _stage, uint16_t _handle, int _access )
{
	bgfx_encoder_set_compute_dynamic_index_buffer( _encoder->_encoder, _stage, *(bgfx_dynamic_index_buffer_handle_t *)&_handle, (bgfx_access_t)_access );
}

// Function bgfxEncoderSetComputeDynamicVertexBuffer:Void( _encoder:BgfxEncoder, _stage:Int, _handle:BgfxDynamicVertexBufferHandle, _access:Int )="_bgfx_encoder_set_compute_dynamic_vertex_buffer"
// BGFX_C_API void bgfx_encoder_set_compute_dynamic_vertex_buffer(struct bgfx_encoder_s* _encoder, uint8_t _stage, bgfx_dynamic_vertex_buffer_handle_t _handle, bgfx_access_t _access);
void _bgfx_encoder_set_compute_dynamic_vertex_buffer( bgfx_encoder_object * _encoder, int _stage, uint16_t _handle, int _access )
{
	bgfx_encoder_set_compute_dynamic_vertex_buffer( _encoder->_encoder, _stage, *(bgfx_dynamic_vertex_buffer_handle_t *)&_handle, (bgfx_access_t)_access );
}

// Function bgfxEncoderSetComputeIndirectBuffer:Void( _encoder:BgfxEncoder, _stage:Int, _handle:BgfxIndirectBufferHandle, _access:Int )="_bgfx_encoder_set_compute_indirect_buffer"
// BGFX_C_API void bgfx_encoder_set_compute_indirect_buffer(struct bgfx_encoder_s* _encoder, uint8_t _stage, bgfx_indirect_buffer_handle_t _handle, bgfx_access_t _access);
void _bgfx_encoder_set_compute_indirect_buffer( bgfx_encoder_object * _encoder, int _stage, uint16_t _handle, int _access )
{
	bgfx_encoder_set_compute_indirect_buffer( _encoder->_encoder, _stage, *(bgfx_indirect_buffer_handle_t *)&_handle, (bgfx_access_t)_access );
}

// Function bgfxEncoderDispatch:Void( _encoder:BgfxEncoder, _id:Int, _handle:BgfxProgramHandle, _numX:Int=1, _numY:Int=1, _numZ:Int=1, _flags:Int=BGFX_SUBMIT_EYE_FIRST )="_bgfx_encoder_dispatch"
// BGFX_C_API void bgfx_encoder_dispatch(struct bgfx_encoder_s* _encoder, bgfx_view_id_t _id, bgfx_program_handle_t _handle, uint32_t _numX, uint32_t _numY, uint32_t _numZ, uint8_t _flags);
void _bgfx_encoder_dispatch( bgfx_encoder_object * _encoder, int _id, uint16_t _handle, int _numX, int _numY, int _numZ, int _flags )
{
	bgfx_encoder_dispatch( _encoder->_encoder, (bgfx_view_id_t)_id, *(bgfx_program_handle_t *)&_handle, _numX, _numY, _numZ, _flags );
}

// Function bgfxEncoderDispatchIndirect:Void( _encoder:BgfxEncoder, _id:Int, _handle:BgfxProgramHandle, _indirectHandle:BgfxIndirectBufferHandle, _start:Int=0, _num:Int=1, _flags:Int=BGFX_SUBMIT_EYE_FIRST )="_bgfx_encoder_dispatch_indirect"
// BGFX_C_API void bgfx_encoder_dispatch_indirect(struct bgfx_encoder_s* _encoder, bgfx_view_id_t _id, bgfx_program_handle_t _handle, bgfx_indirect_buffer_handle_t _indirectHandle, uint16_t _start, uint16_t _num, uint8_t _flags);
void _bgfx_encoder_dispatch_indirect( bgfx_encoder_object * _encoder, int _id, uint16_t _handle, uint16_t _indirectHandle, int _start, int _num, int _flags )
{
	bgfx_encoder_dispatch_indirect( _encoder->_encoder, (bgfx_view_id_t)_id, *(bgfx_program_handle_t *)&_handle, *(bgfx_indirect_buffer_handle_t *)&_indirectHandle, _start, _num, _flags );
}

// Function bgfxEncoderDiscard:Void( _encoder:BgfxEncoder )="_bgfx_encoder_discard"
// BGFX_C_API void bgfx_encoder_discard(struct bgfx_encoder_s* _encoder);
void _bgfx_encoder_discard( bgfx_encoder_object * _encoder )
{
	bgfx_encoder_discard( _encoder->_encoder );
}

// Function bgfxEncoderBlit:Void( _encoder:BgfxEncoder, _id:Int, _dst:BgfxTextureHandle, _dstX:Int, _dstY:Int, _src:BgfxTextureHandle, _srcX:Int=0, _srcY:Int=0, _width:Int=UINT16_MAX, _height:Int=UINT16_MAX )="_bgfx_encoder_blit"
// Function bgfxEncoderBlit:Void( _encoder:BgfxEncoder, _id:Int, _dst:BgfxTextureHandle, _dstMip:Int, _dstX:Int, _dstY:Int, _dstZ:Int, _src:BgfxTextureHandle, _srcMip:Int=0, _srcX:Int=0, _srcY:Int=0, _srcZ:Int=0, _width:Int=UINT16_MAX, _height:Int=UINT16_MAX, _depth:Int=UINT16_MAX )="_bgfx_encoder_blit"
// BGFX_C_API void bgfx_encoder_blit(struct bgfx_encoder_s* _encoder, bgfx_view_id_t _id, bgfx_texture_handle_t _dst, uint8_t _dstMip, uint16_t _dstX, uint16_t _dstY, uint16_t _dstZ, bgfx_texture_handle_t _src, uint8_t _srcMip, uint16_t _srcX, uint16_t _srcY, uint16_t _srcZ, uint16_t _width, uint16_t _height, uint16_t _depth);
void _bgfx_encoder_blit( bgfx_encoder_object * _encoder, int _id, uint16_t _dst, int _dstX, int _dstY, uint16_t _src, int _srcX, int _srcY, int _width, int _height )
{
	bgfx_encoder_blit( _encoder->_encoder, (bgfx_view_id_t)_id, *(bgfx_texture_handle_t *)&_dst, 0, _dstX, _dstY, 0, *(bgfx_texture_handle_t *)&_src, 0, _srcX, _srcY, 0, _width, _height, 0 );
}
void _bgfx_encoder_blit( bgfx_encoder_object * _encoder, int _id, uint16_t _dst, int _dstMip, int _dstX, int _dstY, int _dstZ, uint16_t _src, int _srcMip, int _srcX, int _srcY, int _srcZ, int _width, int _height, int _depth )
{
	bgfx_encoder_blit( _encoder->_encoder, (bgfx_view_id_t)_id, *(bgfx_texture_handle_t *)&_dst, _dstMip, _dstX, _dstY, _dstZ, *(bgfx_texture_handle_t *)&_src, _srcMip, _srcX, _srcY, _srcZ, _width, _height, _depth );
}

// Function bgfxRequestScreenShot:Void( _handle:BgfxFrameBufferHandle, _filePath:String )="_bgfx_request_screen_shot"
// BGFX_C_API void bgfx_request_screen_shot(bgfx_frame_buffer_handle_t _handle, const char* _filePath);
void _bgfx_request_screen_shot( uint16_t _handle, String _filePath )
{
	bgfx_request_screen_shot( *(bgfx_frame_buffer_handle_t *)&_handle, _filePath.ToCString<char>() );
}

// direct copy from opengl.gles20.cxs
BBDataBuffer *BBLoadImageData( BBDataBuffer *buf,String path,Array<int> info ){

	int width,height,depth;
	unsigned char *data=BBGlfwGame::GlfwGame()->LoadImageData( path,&width,&height,&depth );
	if( !data || depth<1 || depth>4 ) return 0;
	
	int size=width*height;
	
	if( !buf->_New( size*4 ) ) return 0;
	
	unsigned char *src=data,*dst=(unsigned char*)buf->WritePointer();
	int i;
	
	switch( depth ){
	case 1:for( i=0;i<size;++i ){ *dst++=*src;*dst++=*src;*dst++=*src++;*dst++=255; } break;
	case 2:for( i=0;i<size;++i ){ *dst++=*src;*dst++=*src;*dst++=*src++;*dst++=*src++; } break;
	case 3:for( i=0;i<size;++i ){ *dst++=*src++;*dst++=*src++;*dst++=*src++;*dst++=255; } break;
	case 4:for( i=0;i<size;++i ){ *dst++=*src++;*dst++=*src++;*dst++=*src++;*dst++=*src++; } break;
	}
	
	if( info.Length()>0 ) info[0]=width;
	if( info.Length()>1 ) info[1]=height;
	
	free( data );
	
	return buf;
}
