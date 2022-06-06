//
//  PaperFilterOffsetScale.fsh
//  RevengeOfTheSamurai iOS
//
//  Created by x414e54 on 03/03/2021.
//

void main()
{
	float2 offsetAndScaledTexCoord = v_tex_coord;
	offsetAndScaledTexCoord *= 2.0;
	offsetAndScaledTexCoord -= 1.0;
	offsetAndScaledTexCoord *= u_scale;
	offsetAndScaledTexCoord.x += u_offset_x;
	offsetAndScaledTexCoord.y += u_offset_y;
	offsetAndScaledTexCoord += 1.0;
	offsetAndScaledTexCoord /= 2.0;
	if (u_flip) {
		offsetAndScaledTexCoord.y = 1.0 - offsetAndScaledTexCoord.y;
	}
	float4 outputColor = texture2D(u_texture, offsetAndScaledTexCoord);
	float alpha = texture2D(u_maskTexture, v_tex_coord).a;
	if (alpha < outputColor.a) {
		outputColor.rgb /= outputColor.a;
		outputColor.rgb *= alpha;
		outputColor.a = alpha;
	}
	gl_FragColor = outputColor;
}
