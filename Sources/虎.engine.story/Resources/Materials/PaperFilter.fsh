//
//  PaperFilter.fsh
//  RevengeOfTheSamurai iOS
//
//  Created by x414e54 on 03/03/2021.
//

void main()
{
	float4 outputColor = SKDefaultShading();
	float alpha = texture2D(u_maskTexture, v_tex_coord).a;
	if (alpha < outputColor.a) {
		outputColor.rgb /= outputColor.a;
		outputColor.rgb *= alpha;
		outputColor.a = alpha;
	}
	gl_FragColor = outputColor;
}
