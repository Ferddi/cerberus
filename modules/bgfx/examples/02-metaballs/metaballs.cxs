
' using DrawText to draw some bgfx debug text
Import mojo1bgfx

' remove DrawText codes and use these minimal imports
'  Import mojo.app
'  Import bgfx

Class PosNormalColorVertex

'  	Field m_pos:Float[3]
'  	Field m_normal:Float[3]
'  	Field m_abgr:Int
'  
'  	Method New(m_x:Float, m_y:Float, m_z:Float, m_nx:Float, m_ny:Float, m_nz:Float, m_abgr:Int)
'  
'  		Self.m_pos[0] = m_x
'  		Self.m_pos[1] = m_y
'  		Self.m_pos[2] = m_z
'  
'  		Self.m_normal[0] = m_nx
'  		Self.m_normal[1] = m_ny
'  		Self.m_normal[2] = m_nz
'  
'  		Self.m_abgr = m_abgr
'  	End
'  
'  	Method New(m_pos:Float[], m_normal:Float[], m_abgr:Int)
'  
'  		Self.m_pos[0] = m_pos[0]
'  		Self.m_pos[1] = m_pos[1]
'  		Self.m_pos[2] = m_pos[2]
'  
'  		Self.m_normal[0] = m_normal[0]
'  		Self.m_normal[1] = m_normal[1]
'  		Self.m_normal[2] = m_normal[2]
'  
'  		Self.m_abgr = m_abgr
'  	End

	Global ms_decl:BgfxVertexDecl = New BgfxVertexDecl()

	Function Init:Void()
		bgfxVertexDeclBegin( ms_decl )
		bgfxVertexDeclAdd( ms_decl, BGFX_ATTRIB_POSITION, 3, BGFX_ATTRIB_TYPE_FLOAT )
		bgfxVertexDeclAdd( ms_decl, BGFX_ATTRIB_NORMAL, 3, BGFX_ATTRIB_TYPE_FLOAT )
		bgfxVertexDeclAdd( ms_decl, BGFX_ATTRIB_COLOR0, 4, BGFX_ATTRIB_TYPE_UINT8, True )
		bgfxVertexDeclEnd( ms_decl )
	End
End

Class Grid

	Method New()
		Self.m_val = 0.0
		Self.m_normal[0] = 0.0
		Self.m_normal[1] = 0.0
		Self.m_normal[2] = 0.0
	End

	Field m_val:Float
	Field m_normal:Float[3]
End

' Triangulation tables taken from:
' http://paulbourke.net/geometry/polygonise/

Global s_edges:Int[] = [
	$000, $109, $203, $30a, $406, $50f, $605, $70c,
	$80c, $905, $a0f, $b06, $c0a, $d03, $e09, $f00,
	$190, $099, $393, $29a, $596, $49f, $795, $69c,
	$99c, $895, $b9f, $a96, $d9a, $c93, $f99, $e90,
	$230, $339, $033, $13a, $636, $73f, $435, $53c,
	$a3c, $b35, $83f, $936, $e3a, $f33, $c39, $d30,
	$3a0, $2a9, $1a3, $0aa, $7a6, $6af, $5a5, $4ac,
	$bac, $aa5, $9af, $8a6, $faa, $ea3, $da9, $ca0,
	$460, $569, $663, $76a, $66 , $16f, $265, $36c,
	$c6c, $d65, $e6f, $f66, $86a, $963, $a69, $b60,
	$5f0, $4f9, $7f3, $6fa, $1f6, $0ff, $3f5, $2fc,
	$dfc, $cf5, $fff, $ef6, $9fa, $8f3, $bf9, $af0,
	$650, $759, $453, $55a, $256, $35f, $055, $15c,
	$e5c, $f55, $c5f, $d56, $a5a, $b53, $859, $950,
	$7c0, $6c9, $5c3, $4ca, $3c6, $2cf, $1c5, $0cc,
	$fcc, $ec5, $dcf, $cc6, $bca, $ac3, $9c9, $8c0,
	$8c0, $9c9, $ac3, $bca, $cc6, $dcf, $ec5, $fcc,
	$0cc, $1c5, $2cf, $3c6, $4ca, $5c3, $6c9, $7c0,
	$950, $859, $b53, $a5a, $d56, $c5f, $f55, $e5c,
	$15c, $55 , $35f, $256, $55a, $453, $759, $650,
	$af0, $bf9, $8f3, $9fa, $ef6, $fff, $cf5, $dfc,
	$2fc, $3f5, $0ff, $1f6, $6fa, $7f3, $4f9, $5f0,
	$b60, $a69, $963, $86a, $f66, $e6f, $d65, $c6c,
	$36c, $265, $16f, $066, $76a, $663, $569, $460,
	$ca0, $da9, $ea3, $faa, $8a6, $9af, $aa5, $bac,
	$4ac, $5a5, $6af, $7a6, $0aa, $1a3, $2a9, $3a0,
	$d30, $c39, $f33, $e3a, $936, $83f, $b35, $a3c,
	$53c, $435, $73f, $636, $13a, $033, $339, $230,
	$e90, $f99, $c93, $d9a, $a96, $b9f, $895, $99c,
	$69c, $795, $49f, $596, $29a, $393, $099, $190,
	$f00, $e09, $d03, $c0a, $b06, $a0f, $905, $80c,
	$70c, $605, $50f, $406, $30a, $203, $109, $000]

' static const int8_t s_indices[256][16] =
Global s_indices:Int[][] = [
	[  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   0,  8,  3, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   0,  1,  9, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   1,  8,  3,  9,  8,  1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   1,  2, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   0,  8,  3,  1,  2, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   9,  2, 10,  0,  2,  9, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   2,  8,  3,  2, 10,  8, 10,  9,  8, -1, -1, -1, -1, -1, -1, -1 ],
	[   3, 11,  2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   0, 11,  2,  8, 11,  0, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   1,  9,  0,  2,  3, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   1, 11,  2,  1,  9, 11,  9,  8, 11, -1, -1, -1, -1, -1, -1, -1 ],
	[   3, 10,  1, 11, 10,  3, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   0, 10,  1,  0,  8, 10,  8, 11, 10, -1, -1, -1, -1, -1, -1, -1 ],
	[   3,  9,  0,  3, 11,  9, 11, 10,  9, -1, -1, -1, -1, -1, -1, -1 ],
	[   9,  8, 10, 10,  8, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   4,  7,  8, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   4,  3,  0,  7,  3,  4, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   0,  1,  9,  8,  4,  7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   4,  1,  9,  4,  7,  1,  7,  3,  1, -1, -1, -1, -1, -1, -1, -1 ],
	[   1,  2, 10,  8,  4,  7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   3,  4,  7,  3,  0,  4,  1,  2, 10, -1, -1, -1, -1, -1, -1, -1 ],
	[   9,  2, 10,  9,  0,  2,  8,  4,  7, -1, -1, -1, -1, -1, -1, -1 ],
	[   2, 10,  9,  2,  9,  7,  2,  7,  3,  7,  9,  4, -1, -1, -1, -1 ],
	[   8,  4,  7,  3, 11,  2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[  11,  4,  7, 11,  2,  4,  2,  0,  4, -1, -1, -1, -1, -1, -1, -1 ],
	[   9,  0,  1,  8,  4,  7,  2,  3, 11, -1, -1, -1, -1, -1, -1, -1 ],
	[   4,  7, 11,  9,  4, 11,  9, 11,  2,  9,  2,  1, -1, -1, -1, -1 ],
	[   3, 10,  1,  3, 11, 10,  7,  8,  4, -1, -1, -1, -1, -1, -1, -1 ],
	[   1, 11, 10,  1,  4, 11,  1,  0,  4,  7, 11,  4, -1, -1, -1, -1 ],
	[   4,  7,  8,  9,  0, 11,  9, 11, 10, 11,  0,  3, -1, -1, -1, -1 ],
	[   4,  7, 11,  4, 11,  9,  9, 11, 10, -1, -1, -1, -1, -1, -1, -1 ],
	[   9,  5,  4, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   9,  5,  4,  0,  8,  3, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   0,  5,  4,  1,  5,  0, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   8,  5,  4,  8,  3,  5,  3,  1,  5, -1, -1, -1, -1, -1, -1, -1 ],
	[   1,  2, 10,  9,  5,  4, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   3,  0,  8,  1,  2, 10,  4,  9,  5, -1, -1, -1, -1, -1, -1, -1 ],
	[   5,  2, 10,  5,  4,  2,  4,  0,  2, -1, -1, -1, -1, -1, -1, -1 ],
	[   2, 10,  5,  3,  2,  5,  3,  5,  4,  3,  4,  8, -1, -1, -1, -1 ],
	[   9,  5,  4,  2,  3, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   0, 11,  2,  0,  8, 11,  4,  9,  5, -1, -1, -1, -1, -1, -1, -1 ],
	[   0,  5,  4,  0,  1,  5,  2,  3, 11, -1, -1, -1, -1, -1, -1, -1 ],
	[   2,  1,  5,  2,  5,  8,  2,  8, 11,  4,  8,  5, -1, -1, -1, -1 ],
	[  10,  3, 11, 10,  1,  3,  9,  5,  4, -1, -1, -1, -1, -1, -1, -1 ],
	[   4,  9,  5,  0,  8,  1,  8, 10,  1,  8, 11, 10, -1, -1, -1, -1 ],
	[   5,  4,  0,  5,  0, 11,  5, 11, 10, 11,  0,  3, -1, -1, -1, -1 ],
	[   5,  4,  8,  5,  8, 10, 10,  8, 11, -1, -1, -1, -1, -1, -1, -1 ],
	[   9,  7,  8,  5,  7,  9, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   9,  3,  0,  9,  5,  3,  5,  7,  3, -1, -1, -1, -1, -1, -1, -1 ],
	[   0,  7,  8,  0,  1,  7,  1,  5,  7, -1, -1, -1, -1, -1, -1, -1 ],
	[   1,  5,  3,  3,  5,  7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   9,  7,  8,  9,  5,  7, 10,  1,  2, -1, -1, -1, -1, -1, -1, -1 ],
	[  10,  1,  2,  9,  5,  0,  5,  3,  0,  5,  7,  3, -1, -1, -1, -1 ],
	[   8,  0,  2,  8,  2,  5,  8,  5,  7, 10,  5,  2, -1, -1, -1, -1 ],
	[   2, 10,  5,  2,  5,  3,  3,  5,  7, -1, -1, -1, -1, -1, -1, -1 ],
	[   7,  9,  5,  7,  8,  9,  3, 11,  2, -1, -1, -1, -1, -1, -1, -1 ],
	[   9,  5,  7,  9,  7,  2,  9,  2,  0,  2,  7, 11, -1, -1, -1, -1 ],
	[   2,  3, 11,  0,  1,  8,  1,  7,  8,  1,  5,  7, -1, -1, -1, -1 ],
	[  11,  2,  1, 11,  1,  7,  7,  1,  5, -1, -1, -1, -1, -1, -1, -1 ],
	[   9,  5,  8,  8,  5,  7, 10,  1,  3, 10,  3, 11, -1, -1, -1, -1 ],
	[   5,  7,  0,  5,  0,  9,  7, 11,  0,  1,  0, 10, 11, 10,  0, -1 ],
	[  11, 10,  0, 11,  0,  3, 10,  5,  0,  8,  0,  7,  5,  7,  0, -1 ],
	[  11, 10,  5,  7, 11,  5, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[  10,  6,  5, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   0,  8,  3,  5, 10,  6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   9,  0,  1,  5, 10,  6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   1,  8,  3,  1,  9,  8,  5, 10,  6, -1, -1, -1, -1, -1, -1, -1 ],
	[   1,  6,  5,  2,  6,  1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   1,  6,  5,  1,  2,  6,  3,  0,  8, -1, -1, -1, -1, -1, -1, -1 ],
	[   9,  6,  5,  9,  0,  6,  0,  2,  6, -1, -1, -1, -1, -1, -1, -1 ],
	[   5,  9,  8,  5,  8,  2,  5,  2,  6,  3,  2,  8, -1, -1, -1, -1 ],
	[   2,  3, 11, 10,  6,  5, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[  11,  0,  8, 11,  2,  0, 10,  6,  5, -1, -1, -1, -1, -1, -1, -1 ],
	[   0,  1,  9,  2,  3, 11,  5, 10,  6, -1, -1, -1, -1, -1, -1, -1 ],
	[   5, 10,  6,  1,  9,  2,  9, 11,  2,  9,  8, 11, -1, -1, -1, -1 ],
	[   6,  3, 11,  6,  5,  3,  5,  1,  3, -1, -1, -1, -1, -1, -1, -1 ],
	[   0,  8, 11,  0, 11,  5,  0,  5,  1,  5, 11,  6, -1, -1, -1, -1 ],
	[   3, 11,  6,  0,  3,  6,  0,  6,  5,  0,  5,  9, -1, -1, -1, -1 ],
	[   6,  5,  9,  6,  9, 11, 11,  9,  8, -1, -1, -1, -1, -1, -1, -1 ],
	[   5, 10,  6,  4,  7,  8, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   4,  3,  0,  4,  7,  3,  6,  5, 10, -1, -1, -1, -1, -1, -1, -1 ],
	[   1,  9,  0,  5, 10,  6,  8,  4,  7, -1, -1, -1, -1, -1, -1, -1 ],
	[  10,  6,  5,  1,  9,  7,  1,  7,  3,  7,  9,  4, -1, -1, -1, -1 ],
	[   6,  1,  2,  6,  5,  1,  4,  7,  8, -1, -1, -1, -1, -1, -1, -1 ],
	[   1,  2,  5,  5,  2,  6,  3,  0,  4,  3,  4,  7, -1, -1, -1, -1 ],
	[   8,  4,  7,  9,  0,  5,  0,  6,  5,  0,  2,  6, -1, -1, -1, -1 ],
	[   7,  3,  9,  7,  9,  4,  3,  2,  9,  5,  9,  6,  2,  6,  9, -1 ],
	[   3, 11,  2,  7,  8,  4, 10,  6,  5, -1, -1, -1, -1, -1, -1, -1 ],
	[   5, 10,  6,  4,  7,  2,  4,  2,  0,  2,  7, 11, -1, -1, -1, -1 ],
	[   0,  1,  9,  4,  7,  8,  2,  3, 11,  5, 10,  6, -1, -1, -1, -1 ],
	[   9,  2,  1,  9, 11,  2,  9,  4, 11,  7, 11,  4,  5, 10,  6, -1 ],
	[   8,  4,  7,  3, 11,  5,  3,  5,  1,  5, 11,  6, -1, -1, -1, -1 ],
	[   5,  1, 11,  5, 11,  6,  1,  0, 11,  7, 11,  4,  0,  4, 11, -1 ],
	[   0,  5,  9,  0,  6,  5,  0,  3,  6, 11,  6,  3,  8,  4,  7, -1 ],
	[   6,  5,  9,  6,  9, 11,  4,  7,  9,  7, 11,  9, -1, -1, -1, -1 ],
	[  10,  4,  9,  6,  4, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   4, 10,  6,  4,  9, 10,  0,  8,  3, -1, -1, -1, -1, -1, -1, -1 ],
	[  10,  0,  1, 10,  6,  0,  6,  4,  0, -1, -1, -1, -1, -1, -1, -1 ],
	[   8,  3,  1,  8,  1,  6,  8,  6,  4,  6,  1, 10, -1, -1, -1, -1 ],
	[   1,  4,  9,  1,  2,  4,  2,  6,  4, -1, -1, -1, -1, -1, -1, -1 ],
	[   3,  0,  8,  1,  2,  9,  2,  4,  9,  2,  6,  4, -1, -1, -1, -1 ],
	[   0,  2,  4,  4,  2,  6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   8,  3,  2,  8,  2,  4,  4,  2,  6, -1, -1, -1, -1, -1, -1, -1 ],
	[  10,  4,  9, 10,  6,  4, 11,  2,  3, -1, -1, -1, -1, -1, -1, -1 ],
	[   0,  8,  2,  2,  8, 11,  4,  9, 10,  4, 10,  6, -1, -1, -1, -1 ],
	[   3, 11,  2,  0,  1,  6,  0,  6,  4,  6,  1, 10, -1, -1, -1, -1 ],
	[   6,  4,  1,  6,  1, 10,  4,  8,  1,  2,  1, 11,  8, 11,  1, -1 ],
	[   9,  6,  4,  9,  3,  6,  9,  1,  3, 11,  6,  3, -1, -1, -1, -1 ],
	[   8, 11,  1,  8,  1,  0, 11,  6,  1,  9,  1,  4,  6,  4,  1, -1 ],
	[   3, 11,  6,  3,  6,  0,  0,  6,  4, -1, -1, -1, -1, -1, -1, -1 ],
	[   6,  4,  8, 11,  6,  8, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   7, 10,  6,  7,  8, 10,  8,  9, 10, -1, -1, -1, -1, -1, -1, -1 ],
	[   0,  7,  3,  0, 10,  7,  0,  9, 10,  6,  7, 10, -1, -1, -1, -1 ],
	[  10,  6,  7,  1, 10,  7,  1,  7,  8,  1,  8,  0, -1, -1, -1, -1 ],
	[  10,  6,  7, 10,  7,  1,  1,  7,  3, -1, -1, -1, -1, -1, -1, -1 ],
	[   1,  2,  6,  1,  6,  8,  1,  8,  9,  8,  6,  7, -1, -1, -1, -1 ],
	[   2,  6,  9,  2,  9,  1,  6,  7,  9,  0,  9,  3,  7,  3,  9, -1 ],
	[   7,  8,  0,  7,  0,  6,  6,  0,  2, -1, -1, -1, -1, -1, -1, -1 ],
	[   7,  3,  2,  6,  7,  2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   2,  3, 11, 10,  6,  8, 10,  8,  9,  8,  6,  7, -1, -1, -1, -1 ],
	[   2,  0,  7,  2,  7, 11,  0,  9,  7,  6,  7, 10,  9, 10,  7, -1 ],
	[   1,  8,  0,  1,  7,  8,  1, 10,  7,  6,  7, 10,  2,  3, 11, -1 ],
	[  11,  2,  1, 11,  1,  7, 10,  6,  1,  6,  7,  1, -1, -1, -1, -1 ],
	[   8,  9,  6,  8,  6,  7,  9,  1,  6, 11,  6,  3,  1,  3,  6, -1 ],
	[   0,  9,  1, 11,  6,  7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   7,  8,  0,  7,  0,  6,  3, 11,  0, 11,  6,  0, -1, -1, -1, -1 ],
	[   7, 11,  6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   7,  6, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   3,  0,  8, 11,  7,  6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   0,  1,  9, 11,  7,  6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   8,  1,  9,  8,  3,  1, 11,  7,  6, -1, -1, -1, -1, -1, -1, -1 ],
	[  10,  1,  2,  6, 11,  7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   1,  2, 10,  3,  0,  8,  6, 11,  7, -1, -1, -1, -1, -1, -1, -1 ],
	[   2,  9,  0,  2, 10,  9,  6, 11,  7, -1, -1, -1, -1, -1, -1, -1 ],
	[   6, 11,  7,  2, 10,  3, 10,  8,  3, 10,  9,  8, -1, -1, -1, -1 ],
	[   7,  2,  3,  6,  2,  7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   7,  0,  8,  7,  6,  0,  6,  2,  0, -1, -1, -1, -1, -1, -1, -1 ],
	[   2,  7,  6,  2,  3,  7,  0,  1,  9, -1, -1, -1, -1, -1, -1, -1 ],
	[   1,  6,  2,  1,  8,  6,  1,  9,  8,  8,  7,  6, -1, -1, -1, -1 ],
	[  10,  7,  6, 10,  1,  7,  1,  3,  7, -1, -1, -1, -1, -1, -1, -1 ],
	[  10,  7,  6,  1,  7, 10,  1,  8,  7,  1,  0,  8, -1, -1, -1, -1 ],
	[   0,  3,  7,  0,  7, 10,  0, 10,  9,  6, 10,  7, -1, -1, -1, -1 ],
	[   7,  6, 10,  7, 10,  8,  8, 10,  9, -1, -1, -1, -1, -1, -1, -1 ],
	[   6,  8,  4, 11,  8,  6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   3,  6, 11,  3,  0,  6,  0,  4,  6, -1, -1, -1, -1, -1, -1, -1 ],
	[   8,  6, 11,  8,  4,  6,  9,  0,  1, -1, -1, -1, -1, -1, -1, -1 ],
	[   9,  4,  6,  9,  6,  3,  9,  3,  1, 11,  3,  6, -1, -1, -1, -1 ],
	[   6,  8,  4,  6, 11,  8,  2, 10,  1, -1, -1, -1, -1, -1, -1, -1 ],
	[   1,  2, 10,  3,  0, 11,  0,  6, 11,  0,  4,  6, -1, -1, -1, -1 ],
	[   4, 11,  8,  4,  6, 11,  0,  2,  9,  2, 10,  9, -1, -1, -1, -1 ],
	[  10,  9,  3, 10,  3,  2,  9,  4,  3, 11,  3,  6,  4,  6,  3, -1 ],
	[   8,  2,  3,  8,  4,  2,  4,  6,  2, -1, -1, -1, -1, -1, -1, -1 ],
	[   0,  4,  2,  4,  6,  2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   1,  9,  0,  2,  3,  4,  2,  4,  6,  4,  3,  8, -1, -1, -1, -1 ],
	[   1,  9,  4,  1,  4,  2,  2,  4,  6, -1, -1, -1, -1, -1, -1, -1 ],
	[   8,  1,  3,  8,  6,  1,  8,  4,  6,  6, 10,  1, -1, -1, -1, -1 ],
	[  10,  1,  0, 10,  0,  6,  6,  0,  4, -1, -1, -1, -1, -1, -1, -1 ],
	[   4,  6,  3,  4,  3,  8,  6, 10,  3,  0,  3,  9, 10,  9,  3, -1 ],
	[  10,  9,  4,  6, 10,  4, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   4,  9,  5,  7,  6, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   0,  8,  3,  4,  9,  5, 11,  7,  6, -1, -1, -1, -1, -1, -1, -1 ],
	[   5,  0,  1,  5,  4,  0,  7,  6, 11, -1, -1, -1, -1, -1, -1, -1 ],
	[  11,  7,  6,  8,  3,  4,  3,  5,  4,  3,  1,  5, -1, -1, -1, -1 ],
	[   9,  5,  4, 10,  1,  2,  7,  6, 11, -1, -1, -1, -1, -1, -1, -1 ],
	[   6, 11,  7,  1,  2, 10,  0,  8,  3,  4,  9,  5, -1, -1, -1, -1 ],
	[   7,  6, 11,  5,  4, 10,  4,  2, 10,  4,  0,  2, -1, -1, -1, -1 ],
	[   3,  4,  8,  3,  5,  4,  3,  2,  5, 10,  5,  2, 11,  7,  6, -1 ],
	[   7,  2,  3,  7,  6,  2,  5,  4,  9, -1, -1, -1, -1, -1, -1, -1 ],
	[   9,  5,  4,  0,  8,  6,  0,  6,  2,  6,  8,  7, -1, -1, -1, -1 ],
	[   3,  6,  2,  3,  7,  6,  1,  5,  0,  5,  4,  0, -1, -1, -1, -1 ],
	[   6,  2,  8,  6,  8,  7,  2,  1,  8,  4,  8,  5,  1,  5,  8, -1 ],
	[   9,  5,  4, 10,  1,  6,  1,  7,  6,  1,  3,  7, -1, -1, -1, -1 ],
	[   1,  6, 10,  1,  7,  6,  1,  0,  7,  8,  7,  0,  9,  5,  4, -1 ],
	[   4,  0, 10,  4, 10,  5,  0,  3, 10,  6, 10,  7,  3,  7, 10, -1 ],
	[   7,  6, 10,  7, 10,  8,  5,  4, 10,  4,  8, 10, -1, -1, -1, -1 ],
	[   6,  9,  5,  6, 11,  9, 11,  8,  9, -1, -1, -1, -1, -1, -1, -1 ],
	[   3,  6, 11,  0,  6,  3,  0,  5,  6,  0,  9,  5, -1, -1, -1, -1 ],
	[   0, 11,  8,  0,  5, 11,  0,  1,  5,  5,  6, 11, -1, -1, -1, -1 ],
	[   6, 11,  3,  6,  3,  5,  5,  3,  1, -1, -1, -1, -1, -1, -1, -1 ],
	[   1,  2, 10,  9,  5, 11,  9, 11,  8, 11,  5,  6, -1, -1, -1, -1 ],
	[   0, 11,  3,  0,  6, 11,  0,  9,  6,  5,  6,  9,  1,  2, 10, -1 ],
	[  11,  8,  5, 11,  5,  6,  8,  0,  5, 10,  5,  2,  0,  2,  5, -1 ],
	[   6, 11,  3,  6,  3,  5,  2, 10,  3, 10,  5,  3, -1, -1, -1, -1 ],
	[   5,  8,  9,  5,  2,  8,  5,  6,  2,  3,  8,  2, -1, -1, -1, -1 ],
	[   9,  5,  6,  9,  6,  0,  0,  6,  2, -1, -1, -1, -1, -1, -1, -1 ],
	[   1,  5,  8,  1,  8,  0,  5,  6,  8,  3,  8,  2,  6,  2,  8, -1 ],
	[   1,  5,  6,  2,  1,  6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   1,  3,  6,  1,  6, 10,  3,  8,  6,  5,  6,  9,  8,  9,  6, -1 ],
	[  10,  1,  0, 10,  0,  6,  9,  5,  0,  5,  6,  0, -1, -1, -1, -1 ],
	[   0,  3,  8,  5,  6, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[  10,  5,  6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[  11,  5, 10,  7,  5, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[  11,  5, 10, 11,  7,  5,  8,  3,  0, -1, -1, -1, -1, -1, -1, -1 ],
	[   5, 11,  7,  5, 10, 11,  1,  9,  0, -1, -1, -1, -1, -1, -1, -1 ],
	[  10,  7,  5, 10, 11,  7,  9,  8,  1,  8,  3,  1, -1, -1, -1, -1 ],
	[  11,  1,  2, 11,  7,  1,  7,  5,  1, -1, -1, -1, -1, -1, -1, -1 ],
	[   0,  8,  3,  1,  2,  7,  1,  7,  5,  7,  2, 11, -1, -1, -1, -1 ],
	[   9,  7,  5,  9,  2,  7,  9,  0,  2,  2, 11,  7, -1, -1, -1, -1 ],
	[   7,  5,  2,  7,  2, 11,  5,  9,  2,  3,  2,  8,  9,  8,  2, -1 ],
	[   2,  5, 10,  2,  3,  5,  3,  7,  5, -1, -1, -1, -1, -1, -1, -1 ],
	[   8,  2,  0,  8,  5,  2,  8,  7,  5, 10,  2,  5, -1, -1, -1, -1 ],
	[   9,  0,  1,  5, 10,  3,  5,  3,  7,  3, 10,  2, -1, -1, -1, -1 ],
	[   9,  8,  2,  9,  2,  1,  8,  7,  2, 10,  2,  5,  7,  5,  2, -1 ],
	[   1,  3,  5,  3,  7,  5, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   0,  8,  7,  0,  7,  1,  1,  7,  5, -1, -1, -1, -1, -1, -1, -1 ],
	[   9,  0,  3,  9,  3,  5,  5,  3,  7, -1, -1, -1, -1, -1, -1, -1 ],
	[   9,  8,  7,  5,  9,  7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   5,  8,  4,  5, 10,  8, 10, 11,  8, -1, -1, -1, -1, -1, -1, -1 ],
	[   5,  0,  4,  5, 11,  0,  5, 10, 11, 11,  3,  0, -1, -1, -1, -1 ],
	[   0,  1,  9,  8,  4, 10,  8, 10, 11, 10,  4,  5, -1, -1, -1, -1 ],
	[  10, 11,  4, 10,  4,  5, 11,  3,  4,  9,  4,  1,  3,  1,  4, -1 ],
	[   2,  5,  1,  2,  8,  5,  2, 11,  8,  4,  5,  8, -1, -1, -1, -1 ],
	[   0,  4, 11,  0, 11,  3,  4,  5, 11,  2, 11,  1,  5,  1, 11, -1 ],
	[   0,  2,  5,  0,  5,  9,  2, 11,  5,  4,  5,  8, 11,  8,  5, -1 ],
	[   9,  4,  5,  2, 11,  3, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   2,  5, 10,  3,  5,  2,  3,  4,  5,  3,  8,  4, -1, -1, -1, -1 ],
	[   5, 10,  2,  5,  2,  4,  4,  2,  0, -1, -1, -1, -1, -1, -1, -1 ],
	[   3, 10,  2,  3,  5, 10,  3,  8,  5,  4,  5,  8,  0,  1,  9, -1 ],
	[   5, 10,  2,  5,  2,  4,  1,  9,  2,  9,  4,  2, -1, -1, -1, -1 ],
	[   8,  4,  5,  8,  5,  3,  3,  5,  1, -1, -1, -1, -1, -1, -1, -1 ],
	[   0,  4,  5,  1,  0,  5, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   8,  4,  5,  8,  5,  3,  9,  0,  5,  0,  3,  5, -1, -1, -1, -1 ],
	[   9,  4,  5, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   4, 11,  7,  4,  9, 11,  9, 10, 11, -1, -1, -1, -1, -1, -1, -1 ],
	[   0,  8,  3,  4,  9,  7,  9, 11,  7,  9, 10, 11, -1, -1, -1, -1 ],
	[   1, 10, 11,  1, 11,  4,  1,  4,  0,  7,  4, 11, -1, -1, -1, -1 ],
	[   3,  1,  4,  3,  4,  8,  1, 10,  4,  7,  4, 11, 10, 11,  4, -1 ],
	[   4, 11,  7,  9, 11,  4,  9,  2, 11,  9,  1,  2, -1, -1, -1, -1 ],
	[   9,  7,  4,  9, 11,  7,  9,  1, 11,  2, 11,  1,  0,  8,  3, -1 ],
	[  11,  7,  4, 11,  4,  2,  2,  4,  0, -1, -1, -1, -1, -1, -1, -1 ],
	[  11,  7,  4, 11,  4,  2,  8,  3,  4,  3,  2,  4, -1, -1, -1, -1 ],
	[   2,  9, 10,  2,  7,  9,  2,  3,  7,  7,  4,  9, -1, -1, -1, -1 ],
	[   9, 10,  7,  9,  7,  4, 10,  2,  7,  8,  7,  0,  2,  0,  7, -1 ],
	[   3,  7, 10,  3, 10,  2,  7,  4, 10,  1, 10,  0,  4,  0, 10, -1 ],
	[   1, 10,  2,  8,  7,  4, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   4,  9,  1,  4,  1,  7,  7,  1,  3, -1, -1, -1, -1, -1, -1, -1 ],
	[   4,  9,  1,  4,  1,  7,  0,  8,  1,  8,  7,  1, -1, -1, -1, -1 ],
	[   4,  0,  3,  7,  4,  3, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   4,  8,  7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   9, 10,  8, 10, 11,  8, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   3,  0,  9,  3,  9, 11, 11,  9, 10, -1, -1, -1, -1, -1, -1, -1 ],
	[   0,  1, 10,  0, 10,  8,  8, 10, 11, -1, -1, -1, -1, -1, -1, -1 ],
	[   3,  1, 10, 11,  3, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   1,  2, 11,  1, 11,  9,  9, 11,  8, -1, -1, -1, -1, -1, -1, -1 ],
	[   3,  0,  9,  3,  9, 11,  1,  2,  9,  2, 11,  9, -1, -1, -1, -1 ],
	[   0,  2, 11,  8,  0, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   3,  2, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   2,  3,  8,  2,  8, 10, 10,  8,  9, -1, -1, -1, -1, -1, -1, -1 ],
	[   9, 10,  2,  0,  9,  2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   2,  3,  8,  2,  8, 10,  0,  1,  8,  1, 10,  8, -1, -1, -1, -1 ],
	[   1, 10,  2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   1,  3,  8,  9,  1,  8, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   0,  9,  1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[   0,  3,  8, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ],
	[  -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ]]

'  static const float s_cube[8][3] =
Global s_cube:Float[][] = [
	[ 0.0, 1.0, 1.0 ], ' 0
	[ 1.0, 1.0, 1.0 ], ' 1
	[ 1.0, 1.0, 0.0 ], ' 2
	[ 0.0, 1.0, 0.0 ], ' 3
	[ 0.0, 0.0, 1.0 ], ' 4
	[ 1.0, 0.0, 1.0 ], ' 5
	[ 1.0, 0.0, 0.0 ], ' 6
	[ 0.0, 0.0, 0.0 ]] ' 7

Function VertLerp:Float(_result:Float[], _iso:Float, _idx0:Int, _v0:Float, _idx1:Int, _v1:Float)

	Local edge0:Float[] = s_cube[_idx0]
	Local edge1:Float[] = s_cube[_idx1]

	If Abs(_iso - _v1) < 0.00001 Then
		_result[0] = edge1[0]
		_result[1] = edge1[1]
		_result[2] = edge1[2]
		Return 1.0
	Endif

	If Abs(_iso - _v0) < 0.00001 Or Abs(_v0 - _v1) < 0.00001 Then
		_result[0] = edge0[0]
		_result[1] = edge0[1]
		_result[2] = edge0[2]
		Return 0.0
	Endif

	Local lerp:Float = (_iso - _v0) / (_v1 - _v0)
	_result[0] = edge0[0] + lerp * (edge1[0] - edge0[0])
	_result[1] = edge0[1] + lerp * (edge1[1] - edge0[1])
	_result[2] = edge0[2] + lerp * (edge1[2] - edge0[2])

	Return lerp
End

Global _verts:Float[12][]
Global _idx1:Int[] = [ 1, 2, 3, 0, 5, 6, 7, 4, 4, 5, 6, 7 ]

Function Triangulate:Int(_result:BgfxTransientVertexBuffer, _vertexIndex:Int, _stride:Int, _rgb:Float[], _xyz:Float[], _val:Grid[], _iso:Float)

	Local cubeindex:Int = 0

	If _val[0].m_val < _iso Then cubeindex |= $01 ' Else cubeindex |= 0
	If _val[1].m_val < _iso Then cubeindex |= $02 ' Else cubeindex |= 0
	If _val[2].m_val < _iso Then cubeindex |= $04 ' Else cubeindex |= 0
	If _val[3].m_val < _iso Then cubeindex |= $08 ' Else cubeindex |= 0
	If _val[4].m_val < _iso Then cubeindex |= $10 ' Else cubeindex |= 0
	If _val[5].m_val < _iso Then cubeindex |= $20 ' Else cubeindex |= 0
	If _val[6].m_val < _iso Then cubeindex |= $40 ' Else cubeindex |= 0
	If _val[7].m_val < _iso Then cubeindex |= $80 ' Else cubeindex |= 0

	If 0 = s_edges[cubeindex] Then
		Return 0
	Endif

'  	Local verts:Float[12][]
	Local flags:Int = s_edges[cubeindex]

	For Local ii:Int = 0 Until 12

		If flags & (1 Shl ii) Then

			Local idx0:Int = ii & 7
			Local idx1:Int = _idx1[ii]
			Local vertex:Float[] = _verts[ii]
			Local lerp:Float = VertLerp(vertex, _iso, idx0, _val[idx0].m_val, idx1, _val[idx1].m_val)

			Local na:Float[] = _val[idx0].m_normal
			Local nb:Float[] = _val[idx1].m_normal
			vertex[3] = na[0] + lerp * (nb[0] - na[0])
			vertex[4] = na[1] + lerp * (nb[1] - na[1])
			vertex[5] = na[2] + lerp * (nb[2] - na[2])
		Endif
	Next

	Local dr:Float = _rgb[3] - _rgb[0]
	Local dg:Float = _rgb[4] - _rgb[1]
	Local db:Float = _rgb[5] - _rgb[2]

	Local num:Int = 0
	Local indices:Int[] = s_indices[cubeindex]
	Local address:Int = _vertexIndex * _stride

	While indices[num] <> -1

		Local vertex:Float[] = _verts[ indices[num] ]

		_result.PokeFloat(address +  0, _xyz[0] + vertex[0])
		_result.PokeFloat(address +  4, _xyz[1] + vertex[1])
		_result.PokeFloat(address +  8, _xyz[2] + vertex[2])

		_result.PokeFloat(address + 12, vertex[3])
		_result.PokeFloat(address + 16, vertex[4])
		_result.PokeFloat(address + 20, vertex[5])

		Local rr:Int = (_rgb[0] + vertex[0] * dr) * 255.0
		Local gg:Int = (_rgb[1] + vertex[1] * dg) * 255.0
		Local bb:Int = (_rgb[2] + vertex[2] * db) * 255.0

		_result.PokeInt(address + 24, $ff000000 | bb Shl 16 | gg Shl 8 | rr)

		address += _stride

		num += 1
	Wend

	Return num
End

Class MojoGame Extends App

	Const DIMS:Int = 32
	Field m_grid:Grid[]
	Field m_timeOffset:Int

	Field m_width:Int = 640
	Field m_height:Int = 480

	Field debug:Int = BGFX_DEBUG_NONE
'  	Field debug:Int = BGFX_DEBUG_TEXT

	Field m_program:BgfxProgramHandle

	Field state:Int[2]

	Method OnCreate:Int()

		SetUpdateRate(60)

		' Enable debug text.
		bgfxSetDebug(debug)

		' Set view 0 clear state.
		bgfxSetViewClear(0, BGFX_CLEAR_COLOR|BGFX_CLEAR_DEPTH, $303030ff, 1.0, 0)

		' Create vertex stream declaration.
		PosNormalColorVertex.Init()

		' not using embedded shader
'  		Local type:Int = bgfxGetRendererType()
'  		bgfx::ShaderHandle vsh = bgfx::createEmbeddedShader(s_embeddedShaders, type, "vs_metaballs");
'  		bgfx::ShaderHandle fsh = bgfx::createEmbeddedShader(s_embeddedShaders, type, "fs_metaballs");
'  		' Create program from shaders.
'  		m_program = bgfx::createProgram(vsh, fsh, true /* destroy shaders when program is destroyed */);

		' Create program from shaders.
		m_program = bgfxUtilsLoadProgram("vs_metaballs", "fs_metaballs")

		m_grid = New Grid[DIMS*DIMS*DIMS]
		m_timeOffset = Millisecs()

		'-------------------------------------------------------------------------

		For Local ii:Int = 0 Until m_grid.Length()
			m_grid[ii] = New Grid()
		Next

		For Local ii:Int = 0 Until numSpheres
			sphere[ii] = New Float[4]
		Next

		For Local ii:Int = 0 Until _verts.Length()
			_verts[ii] = New Float[6]
		Next

		Print "maxVertices=" + maxVertices
		Print "stride=" + PosNormalColorVertex.ms_decl.GetStride()

		Return 0
	End

	Method PrintMatrix:Void(m:Float[])
		For Local i:Int = 0 Until 16 Step 4
			Print m[i + 0] + ", " + m[i + 1] + ", " + m[i + 2] + ", " + m[i + 3] + ", "
		Next
	End

	Method OnUpdate:Int()
'  		time += 0.1
		Return 0
	End

	Const ypitch:Int = DIMS
	Const zpitch:Int = DIMS * DIMS
	Const invdim:Float = 1.0 / Float(DIMS - 1)

	Field last:Int 

	Field at:Float[]  = [ 0.0, 0.0,   0.0 ]
	Field eye:Float[] = [ 0.0, 0.0, -50.0 ]

	Field bgfxCaps:BgfxCaps = New BgfxCaps()

	Field view:Float[16]
	Field proj:Float[16]
	Field mtx:Float[16]

	Const maxVertices:Int = (32 Shl 10)

	Const numSpheres:Int = 16
	Field sphere:Float[numSpheres][]

	Field normal:Float[3]
	Field rgb:Float[6]
	Field pos:Float[3]
	Field val:Grid[8]

	Field tvb:BgfxTransientVertexBuffer = New BgfxTransientVertexBuffer()

	Method OnRender:Int()

		' Set view 0 default viewport.
		bgfxSetViewRect(0, 0, 0, m_width, m_height)

		' This dummy draw call is here to make sure that view 0 is cleared
		' if no other draw calls are submitted to view 0.
		bgfxTouch(0)

		Local now:Int = Millisecs()
		Local frameTime:Int = now - last; last = now
		Local time:Float = Float(now - m_timeOffset) / 1000.0

		' Set view and projection matrix for view 0.
		bxMtxLookAt(view, eye, at)

		bgfxGetCaps( bgfxCaps )
		bxMtxProj(proj, 60.0, float(m_width) / float(m_height), 0.1, 100.0, bgfxCaps.GetHomogeneousDepth())
		bgfxSetViewTransform(0, view, proj)

		' Set view 0 default viewport.
		bgfxSetViewRect(0, 0, 0, m_width, m_height)

		' Stats.
		Local numVertices:Int = 0
		Local profUpdate:Int = 0
		Local profNormal:Int = 0
		Local profTriangulate:Int = 0

		' Allocate 32K vertices in transient vertex buffer.
		bgfxAllocTransientVertexBuffer(tvb, maxVertices, PosNormalColorVertex.ms_decl)

		For Local ii:Int = 0 Until numSpheres
			sphere[ii][0] = Sinr(time * (ii * 0.21) + ii * 0.37) * (DIMS * 0.5 - 8.0)
			sphere[ii][1] = Sinr(time * (ii * 0.37) + ii * 0.67) * (DIMS * 0.5 - 8.0)
			sphere[ii][2] = Cosr(time * (ii * 0.11) + ii * 0.13) * (DIMS * 0.5 - 8.0)
			sphere[ii][3] = 1.0 / (2.0 + (Sin(time * (ii * 0.13) ) * 0.5 + 0.5) * 2.0)
		Next

		profUpdate = Millisecs()

		For Local zz:Int = 0 Until DIMS

			For Local yy:Int = 0 Until DIMS
				Local offset:Int = (zz * DIMS + yy) * DIMS

				For Local xx:Int = 0 Until DIMS
					Local xoffset:Int = offset + xx

					Local dist:Float = 0.0
					Local prod:Float = 1.0

					For Local ii:Int = 0 Until numSpheres

						Local pos:Float[] = sphere[ii]
						Local dx:Float = pos[0] - (-DIMS * 0.5 + Float(xx) )
						Local dy:Float = pos[1] - (-DIMS * 0.5 + Float(yy) )
						Local dz:Float = pos[2] - (-DIMS * 0.5 + Float(zz) )
						Local invr:Float = pos[3]
						Local dot:Float = dx * dx + dy * dy + dz * dz
						dot *= invr * invr

						dist *= dot
						dist += prod
						prod *= dot
					Next

					m_grid[xoffset].m_val = dist / prod - 1.0
				Next
			Next
		Next

		profUpdate = Millisecs() - profUpdate

		profNormal = Millisecs()

		For Local zz:Int = 1 Until DIMS-1

			For Local yy:Int = 1 Until DIMS-1
				Local offset:Int = (zz * DIMS + yy) * DIMS

				For Local xx:Int = 1 Until DIMS-1
					Local xoffset:Int = offset + xx

					Local grid:Grid[] = m_grid
					normal[0] = grid[xoffset - 1     ].m_val - grid[xoffset + 1     ].m_val
					normal[1] = grid[xoffset - ypitch].m_val - grid[xoffset + ypitch].m_val
					normal[2] = grid[xoffset - zpitch].m_val - grid[xoffset + zpitch].m_val

					bxVec3Norm(grid[xoffset].m_normal, normal)
				Next
			Next
		Next

		profNormal = Millisecs() - profNormal

		profTriangulate = Millisecs()

'  		PosNormalColorVertex* vertex = (PosNormalColorVertex*)tvb.data;
		Local vertexIndex:Int = 0

		Local zz:Int = 0
		While zz < DIMS - 1 And numVertices + 12 < maxVertices

			rgb[2] = zz * invdim
			rgb[5] = (zz + 1) * invdim;

			Local yy:Int = 0
			While yy < DIMS - 1 And numVertices + 12 < maxVertices

				Local offset:Int = (zz * DIMS + yy) * DIMS

				rgb[1] = yy * invdim
				rgb[4] = (yy + 1) * invdim

				Local xx:Int = 0
				While xx < DIMS - 1 And numVertices + 12 < maxVertices

					Local xoffset:Int = offset + xx

					rgb[0] = xx * invdim;
					rgb[3] = (xx + 1) * invdim;

					pos[0] = -DIMS * 0.5 + Float(xx)
					pos[1] = -DIMS * 0.5 + Float(yy)
					pos[2] = -DIMS * 0.5 + Float(zz)

					Local grid:Grid[] = m_grid
					val[0] = grid[ xoffset + zpitch + ypitch     ]
					val[1] = grid[ xoffset + zpitch + ypitch + 1 ]
					val[2] = grid[ xoffset + ypitch + 1          ]
					val[3] = grid[ xoffset + ypitch              ]
					val[4] = grid[ xoffset + zpitch              ]
					val[5] = grid[ xoffset + zpitch + 1          ]
					val[6] = grid[ xoffset + 1                   ]
					val[7] = grid[ xoffset                       ]

					Local num:Int = Triangulate(tvb, vertexIndex, PosNormalColorVertex.ms_decl.GetStride(), rgb, pos, val, 0.5)
					vertexIndex += num
					numVertices += num

					xx += 1
				Wend

				yy += 1
			Wend

			zz += 1
		Wend

		profTriangulate = Millisecs() - profTriangulate

		bxMtxRotateXY(mtx, time * 0.67, time)

		' Set model matrix for rendering.
		bgfxSetTransform(mtx)

		' Set vertex and index buffer.
		bgfxSetTransientVertexBuffer(0, tvb, 0, numVertices)

		' Set render states.
		bgfxSetState(BGFX_STATE_DEFAULT)

		' Submit primitive for rendering to view 0.
		bgfxSubmit(0, m_program)

		' it is possible to draw 3d and use mojo1bgfx for 2d, like gui
		DrawText("Num vertices: " + numVertices + " (" + Float(numVertices) / maxVertices * 100 + "%)", 8, 14 * 1)
		DrawText("Update: " + Float(profUpdate) + "[ms]", 8, 14 * 2)
		DrawText("Calc normals: " + Float(profNormal) + "[ms]", 8, 14 * 3)
		DrawText("Triangulate: " + Float(profTriangulate) + "[ms]", 8, 14 * 4)
		DrawText("Frame: " + Float(frameTime) + "[ms]", 8, 14 * 5)

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
	New MojoGame()
	Return 0
End
