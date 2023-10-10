Shader "Custom/RGBDShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "blue" {}
    }
    SubShader
    {
        Cull Back ZWrite On ZTest LEqual

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;

            fixed4 frag (v2f i) : SV_Target
            {
                // Use this for saving images in a file
                if(i.uv.y <= 0.5)
				{
                    // Perspective
                    //float depth = Linear01Depth(tex2D(_CameraDepthTexture, float2(i.uv.x, (i.uv.y * 2))).r);
                    // Orthographic
                    float depth = tex2D(_CameraDepthTexture, float2(i.uv.x, (i.uv.y * 2))).r;
                    return fixed4(depth,depth,depth,1);
                }
                else
                {
                    fixed4 col = tex2D(_MainTex, float2(i.uv.x, (i.uv.y - 0.5)*2));
                    return fixed4(col.rgb, 1); 
                }

                // Use this part for streaming 
                /*if(i.uv.y < 0.5)
				{
                    fixed4 col = tex2D(_MainTex, float2(i.uv.x, 1 -(i.uv.y * 2)));
                    return fixed4(col.rgb, 1);
                }
                else
                {
                    float depth = Linear01Depth(tex2D(_CameraDepthTexture, float2(i.uv.x, 1- (i.uv.y - 0.5)*2)).r);
                    return fixed4(depth,depth,depth,1);
                }*/
                //return fixed4(i.uv, 0, 1);
            }
            ENDCG
        }
    }
}