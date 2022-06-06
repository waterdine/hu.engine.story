//
//  PaperFilter.fsh
//  RevengeOfTheSamurai iOS
//
//  Created by x414e54 on 03/03/2021.
//

void main()
{
	float2 texCoord = v_tex_coord;
	texCoord.y = texCoord.y * abs(0.9 + sin((u_time) + texCoord.x) / 10.0);
	float4 outputColor = texture2D(u_texture, texCoord);
	gl_FragColor = outputColor;
}
