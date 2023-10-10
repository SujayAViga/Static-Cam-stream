// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Parasol/FoliageXCardLOD_Shader"
{
	Properties
	{
		[Header(Per Pixel Fog Controls)]_PerPixelFogAmount("Per Pixel Fog Amount", Range( 0 , 1)) = 1
		[Gamma][NoScaleOffset]_BaseColor("Base Color", 2D) = "white" {}
		[NoScaleOffset]_WorldSpaceNormal("World Space Normal", 2D) = "white" {}
		[Enum(Normal,0,RBG,1,RB iG,2,iRGB,3,iRnBiG,4)]_SwizzleMode("Swizzle Mode", Int) = 4
		[NoScaleOffset]_Alpha("Alpha", 2D) = "white" {}
		_DitherStart("Dither Start", Range( 0 , 1)) = 0.5
		_DitherCutoff("Dither Cutoff", Range( 0 , 1)) = 0.6
		_ColorContrast("Color Contrast", Range( 0 , 2)) = 1.5
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_LODTreeLightColor("LOD Tree Light Color", Color) = (1,0.9923881,0.5566038,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+100" "ForceNoShadowCasting" = "True" "IsEmissive" = "true"  }
		Cull Off
		Stencil
		{
			Ref 1
			CompFront NotEqual
			CompBack NotEqual
		}
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#pragma only_renderers d3d11 glcore gles3 metal 
		#pragma surface surf StandardCustomLighting keepalpha noshadow exclude_path:deferred nolightmap  nodynlightmap nodirlightmap nometa noforwardadd vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
			float4 screenPosition;
			float3 worldPos;
			float3 worldNormal;
			float eyeDepth;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform sampler2D _BaseColor;
		uniform float EmissiveGradient;
		uniform float4 _LODTreeLightColor;
		uniform sampler2D _Alpha;
		SamplerState sampler_Alpha;
		uniform float _DitherStart;
		uniform float _DitherCutoff;
		uniform float sg_ToonFog;
		uniform float sg_ColorLut;
		uniform sampler2D StandardLUT;
		uniform float _ColorContrast;
		uniform sampler2D _WorldSpaceNormal;
		uniform int _SwizzleMode;
		uniform int LUTSize;
		uniform sampler2D SecondLUT;
		uniform sampler2D fog_texture;
		uniform float fog_start;
		uniform float fog_end;
		uniform float fog_spread;
		uniform float fog_height;
		uniform float FogHeightDensity;
		uniform float _PerPixelFogAmount;
		uniform float _Cutoff = 0.5;


		inline float Dither4x4Bayer( int x, int y )
		{
			const float dither[ 16 ] = {
				 1,  9,  3, 11,
				13,  5, 15,  7,
				 4, 12,  2, 10,
				16,  8, 14,  6 };
			int r = y * 4 + x;
			return dither[r] / 16; // same # of instructions as pre-dividing due to compiler magic
		}


		float4 CalculateContrast( float contrastValue, float4 colorTarget )
		{
			float t = 0.5 * ( 1.0 - contrastValue );
			return mul( float4x4( contrastValue,0,0,t, 0,contrastValue,0,t, 0,0,contrastValue,t, 0,0,0,1 ), colorTarget );
		}

		float3 MyCustomExpression251( float R, float G, float B, float Mode )
		{
			switch(Mode)
			{
				case 0:
					return(float3(R, G, B));
					break;
				case 1:
					return(float3(R, B, G));
					break;
				case 2:
					return(float3(R, B , 1-G));
					break;
				case 3:
					return(float3(1-R, 1-B , 1-G));
					break;
				case 4:
					return(float3(1-R, B , 1-G));
					break;
				default:
					return(float3(1-R, B , 1-G));
					break;
			}
		}


		inline float4 FeatureSwitch( float TestVal, float4 FeatureOn, float4 FeatureOff )
		{
			return TestVal>0?FeatureOn:FeatureOff;;
		}


		float MyCustomExpression8_g10( float fogStart, float fogEnd, float SurfaceDepth )
		{
			return saturate((SurfaceDepth-fogStart)/(fogEnd-fogStart));
		}


		float MyCustomExpression232_g10( float fogStart, float fogEnd, float SurfaceDepth )
		{
			return saturate((SurfaceDepth-fogStart)/(fogEnd-fogStart));
		}


		float MyCustomExpression233_g10( float fogStart, float fogEnd, float SurfaceDepth )
		{
			return saturate((SurfaceDepth-fogStart)/(fogEnd-fogStart));
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float4 ase_screenPos = ComputeScreenPos( UnityObjectToClipPos( v.vertex ) );
			o.screenPosition = ase_screenPos;
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float2 uv_Alpha2 = i.uv_texcoord;
			float4 ase_screenPos = i.screenPosition;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 clipScreen60 = ase_screenPosNorm.xy * _ScreenParams.xy;
			float dither60 = Dither4x4Bayer( fmod(clipScreen60.x, 4), fmod(clipScreen60.y, 4) );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float dotResult11 = dot( ase_worldViewDir , ase_worldNormal );
			float smoothstepResult61 = smoothstep( _DitherStart , _DitherCutoff , abs( dotResult11 ));
			dither60 = step( dither60, smoothstepResult61 );
			float TestVal194_g10 = sg_ToonFog;
			float TestVal103_g7 = sg_ColorLut;
			SurfaceOutputStandard s189 = (SurfaceOutputStandard ) 0;
			float2 uv_BaseColor1 = i.uv_texcoord;
			float4 baseColor154 = tex2D( _BaseColor, uv_BaseColor1 );
			float4 SampledBaseColor244 = CalculateContrast(_ColorContrast,baseColor154);
			s189.Albedo = SampledBaseColor244.rgb;
			float2 uv_WorldSpaceNormal28 = i.uv_texcoord;
			float4 break215 = tex2D( _WorldSpaceNormal, uv_WorldSpaceNormal28 );
			float R251 = break215.r;
			float G251 = break215.g;
			float B251 = break215.b;
			float Mode251 = (float)_SwizzleMode;
			float3 localMyCustomExpression251 = MyCustomExpression251( R251 , G251 , B251 , Mode251 );
			s189.Normal = localMyCustomExpression251;
			s189.Emission = float3( 0,0,0 );
			s189.Metallic = 0.0;
			s189.Smoothness = 0.0;
			s189.Occlusion = 1.0;

			data.light = gi.light;

			UnityGI gi189 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g189 = UnityGlossyEnvironmentSetup( s189.Smoothness, data.worldViewDir, s189.Normal, float3(0,0,0));
			gi189 = UnityGlobalIllumination( data, s189.Occlusion, s189.Normal, g189 );
			#endif

			float3 surfResult189 = LightingStandard ( s189, viewDir, gi189 ).rgb;
			surfResult189 += s189.Emission;

			#ifdef UNITY_PASS_FORWARDADD//189
			surfResult189 -= s189.Emission;
			#endif//189
			float3 inputColor100_g7 = surfResult189;
			float ifLocalVar202_g7 = 0;
			if( LUTSize <= 2 )
				ifLocalVar202_g7 = (float)32;
			else
				ifLocalVar202_g7 = (float)LUTSize;
			float lutDim14_g7 = ifLocalVar202_g7;
			float temp_output_196_0_g7 = ( 1.0 / lutDim14_g7 );
			float3 temp_cast_7 = (temp_output_196_0_g7).xxx;
			float3 temp_cast_8 = (( 1.0 - temp_output_196_0_g7 )).xxx;
			float3 clampResult170_g7 = clamp( inputColor100_g7 , temp_cast_7 , temp_cast_8 );
			float3 break2_g7 = clampResult170_g7;
			float Red_U81_g7 = ( break2_g7.x / lutDim14_g7 );
			float temp_output_3_0_g7 = ( break2_g7.z * lutDim14_g7 );
			float Green_V75_g7 = break2_g7.y;
			float2 appendResult7_g7 = (float2(( Red_U81_g7 + ( ceil( temp_output_3_0_g7 ) / lutDim14_g7 ) ) , Green_V75_g7));
			float2 temp_output_183_0_g7 = saturate( appendResult7_g7 );
			float4 tex2DNode9_g7 = tex2Dlod( StandardLUT, float4( temp_output_183_0_g7, 0, 0.0) );
			float4 tex2DNode88_g7 = tex2Dlod( SecondLUT, float4( temp_output_183_0_g7, 0, 0.0) );
			float temp_output_182_0_g7 = saturate( EmissiveGradient );
			float4 lerpResult95_g7 = lerp( tex2DNode9_g7 , tex2DNode88_g7 , temp_output_182_0_g7);
			float4 FeatureOn103_g7 = lerpResult95_g7;
			float4 FeatureOff103_g7 = float4( inputColor100_g7 , 0.0 );
			float4 localFeatureSwitch103_g7 = FeatureSwitch( TestVal103_g7 , FeatureOn103_g7 , FeatureOff103_g7 );
			float4 temp_output_19_0_g10 = localFeatureSwitch103_g7;
			float fogStart8_g10 = fog_start;
			float fogEnd8_g10 = fog_end;
			float SurfaceDepth8_g10 = i.eyeDepth;
			float localMyCustomExpression8_g10 = MyCustomExpression8_g10( fogStart8_g10 , fogEnd8_g10 , SurfaceDepth8_g10 );
			float fogStart232_g10 = 0.0;
			float fogEnd232_g10 = fog_spread;
			float SurfaceDepth232_g10 = ase_worldPos.y;
			float localMyCustomExpression232_g10 = MyCustomExpression232_g10( fogStart232_g10 , fogEnd232_g10 , SurfaceDepth232_g10 );
			float2 appendResult89_g10 = (float2(localMyCustomExpression8_g10 , localMyCustomExpression232_g10));
			float4 fogInputs224_g10 = tex2D( fog_texture, appendResult89_g10 );
			float4 temp_output_111_0_g10 = fogInputs224_g10;
			float4 clampResult165_g10 = clamp( ( temp_output_19_0_g10 + temp_output_111_0_g10 ) , float4( 0,0,0,0 ) , temp_output_111_0_g10 );
			float fogStart233_g10 = fog_spread;
			float fogEnd233_g10 = fog_height;
			float SurfaceDepth233_g10 = ase_worldPos.y;
			float localMyCustomExpression233_g10 = MyCustomExpression233_g10( fogStart233_g10 , fogEnd233_g10 , SurfaceDepth233_g10 );
			float distanceGradiant226_g10 = saturate( ( localMyCustomExpression8_g10 * (localMyCustomExpression233_g10*FogHeightDensity + 0.0) ) );
			float4 lerpResult195_g10 = lerp( temp_output_19_0_g10 , clampResult165_g10 , ( distanceGradiant226_g10 * _PerPixelFogAmount ));
			float4 FeatureOn194_g10 = lerpResult195_g10;
			float4 FeatureOff194_g10 = temp_output_19_0_g10;
			float4 localFeatureSwitch194_g10 = FeatureSwitch( TestVal194_g10 , FeatureOn194_g10 , FeatureOff194_g10 );
			c.rgb = localFeatureSwitch194_g10.xyz;
			c.a = 1;
			clip( ( tex2D( _Alpha, uv_Alpha2 ).r * dither60 ) - _Cutoff );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			float2 uv_BaseColor1 = i.uv_texcoord;
			float4 baseColor154 = tex2D( _BaseColor, uv_BaseColor1 );
			o.Albedo = baseColor154.rgb;
			float2 uv_TexCoord192 = i.uv_texcoord * float2( 2,2 );
			float4 TreeUplight203 = ( EmissiveGradient * _LODTreeLightColor * ( 1.0 - fmod( uv_TexCoord192.y , 1.0 ) ) * baseColor154 );
			o.Emission = TreeUplight203.rgb;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
3688.667;230;1918;1051;4532.816;2253.243;3.773896;True;False
Node;AmplifyShaderEditor.CommentaryNode;164;-950.9773,-548.368;Inherit;False;1204.414;537.9608;;10;2;60;61;17;59;62;11;10;63;25;Alpha Dither;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;1;-2167.555,32.10727;Inherit;True;Property;_BaseColor;Base Color;6;2;[Gamma];[NoScaleOffset];Create;True;0;0;False;0;False;-1;None;8bb8394a5ab175f46a58a756ad6430bd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;28;-1798.372,452.7818;Inherit;True;Property;_WorldSpaceNormal;World Space Normal;7;1;[NoScaleOffset];Create;True;0;0;False;0;False;-1;758e4cb23f956f9449fa6b35230bb1a5;65ff326eec441894e920d7a34b5cfbe7;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;0.5;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;154;-1615.886,170.3466;Inherit;False;baseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;10;-890.099,-357.0894;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;204;-710.9131,-1228.053;Inherit;False;1204.414;537.9608;;8;194;193;192;202;153;152;151;203;Tree Uplight;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;225;-1421.522,298.7513;Inherit;False;Property;_ColorContrast;Color Contrast;13;0;Create;True;0;0;False;0;False;1.5;1.5;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;63;-899.0292,-193.4075;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.IntNode;253;-1347.915,701.3622;Inherit;False;Property;_SwizzleMode;Swizzle Mode;8;1;[Enum];Create;True;5;Normal;0;RBG;1;RB iG;2;iRGB;3;iRnBiG;4;0;False;0;False;4;4;0;1;INT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;215;-1405.453,448.4344;Inherit;True;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleContrastOpNode;224;-1086.741,213.8652;Inherit;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;2;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;11;-671.054,-324.0889;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;192;-662.49,-833.8456;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;2,2;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;62;-563.4882,-254.5618;Inherit;False;Property;_DitherStart;Dither Start;10;0;Create;True;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;191;-701.4871,589.2139;Inherit;False;Constant;_Float1;Float 1;11;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;190;-705.9431,503.3072;Inherit;False;Constant;_Zero;Zero;11;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FmodOpNode;193;-399.2595,-865.0587;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;251;-1072.062,404.0347;Inherit;False;switch(Mode)${$	case 0:$		return(float3(R, G, B))@$		break@$	case 1:$		return(float3(R, B, G))@$		break@$	case 2:$		return(float3(R, B , 1-G))@$		break@$	case 3:$		return(float3(1-R, 1-B , 1-G))@$		break@$	case 4:$		return(float3(1-R, B , 1-G))@$		break@$	default:$		return(float3(1-R, B , 1-G))@$		break@$};3;False;4;True;R;FLOAT;0;In;;Inherit;False;True;G;FLOAT;0;In;;Inherit;False;True;B;FLOAT;0;In;;Inherit;False;True;Mode;FLOAT;0;In;;Inherit;False;My Custom Expression;True;False;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;244;-730.9039,234.0064;Inherit;False;SampledBaseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.AbsOpNode;17;-416.2615,-323.743;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-563.3523,-180.2847;Inherit;False;Property;_DitherCutoff;Dither Cutoff;12;0;Create;True;0;0;False;0;False;0.6;0.6;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;202;-256.4506,-789.5134;Inherit;False;154;baseColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;194;-225.0159,-873.0543;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;152;-262.3491,-1121.343;Inherit;False;Global;EmissiveGradient;EmissiveGradient;17;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomStandardSurface;189;-271.2059,326.0535;Inherit;False;Metallic;World;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;153;-624.7697,-1098.168;Inherit;False;Property;_LODTreeLightColor;LOD Tree Light Color;15;0;Create;True;0;0;False;0;False;1,0.9923881,0.5566038,0;0.6320754,0.5977883,0.494927,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;61;-268.6278,-296.4241;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-219.2517,-498.368;Inherit;True;Property;_Alpha;Alpha;9;1;[NoScaleOffset];Create;True;0;0;False;0;False;-1;None;1734f19b04cf4044c8606c0ced086d01;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DitheringNode;60;-108.2467,-298.7425;Inherit;False;0;False;3;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;226;-1965.104,902.6082;Inherit;False;1460.511;444.8457;Randomize color based on position;9;235;234;233;232;231;230;229;228;227;Color Variation;0.6483558,1,0.2830189,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;151;19.34658,-929.0267;Inherit;False;4;4;0;FLOAT;0;False;1;COLOR;1,0,0,0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;207;88.7923,263.0733;Inherit;False;ParasolGlobalLut_;3;;7;415cf2c404453934193ab734c391e132;0;1;15;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.AbsOpNode;236;-1510.015,1827.192;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;208;742.9903,-679.3534;Inherit;False;154;baseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;235;-753.5374,1127.743;Inherit;False;RandomColorOut;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;233;-1245.198,1171.57;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RGBToHSVNode;237;-1611.364,1609.288;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;243;-1835.945,1838.675;Inherit;False;235;RandomColorOut;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;203;198.167,-853.0336;Inherit;False;TreeUplight;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;234;-937.7717,1115.768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;246;-2037.623,1617.599;Inherit;False;244;SampledBaseColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.TransformPositionNode;227;-1874.616,949.6382;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;245;-480.4819,1687.322;Inherit;False;ModifiedColor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;232;-1253.279,1027.213;Inherit;False;Random Range;-1;;9;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;-360;False;3;FLOAT;360;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;91.43637,-386.5983;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;238;-1578.668,1458.705;Inherit;False;235;RandomColorOut;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;242;-810.3387,1603.023;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;200;433.1073,85.32201;Inherit;False;Toon_DistanceFog;0;;10;87a2c17086d6be546a10c470a8adefc0;0;2;19;COLOR;0,0,0,0;False;111;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;231;-1404.457,1223.283;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;230;-1550.917,1009.819;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;241;-1264.272,1514.045;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;228;-1874.433,1191.093;Inherit;False;Property;_LeafColorVariation;Leaf Color Variation;11;0;Create;True;0;0;False;0;False;0.2;0.108;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;229;-1517.564,1117.753;Inherit;False;2;2;0;FLOAT;-1;False;1;FLOAT;360;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;239;-1276.534,1791.497;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;240;-1059.991,1739.46;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;992.0303,-480.7358;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Parasol/FoliageXCardLOD_Shader;False;False;False;False;False;False;True;True;True;False;True;True;False;False;False;True;True;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;100;True;TransparentCutout;;Geometry;ForwardOnly;4;d3d11;glcore;gles3;metal;True;True;True;True;0;False;-1;True;1;False;-1;255;False;-1;255;False;-1;6;False;-1;0;False;-1;0;False;-1;0;False;-1;6;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;14;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;154;0;1;0
WireConnection;215;0;28;0
WireConnection;224;1;154;0
WireConnection;224;0;225;0
WireConnection;11;0;10;0
WireConnection;11;1;63;0
WireConnection;193;0;192;2
WireConnection;251;0;215;0
WireConnection;251;1;215;1
WireConnection;251;2;215;2
WireConnection;251;3;253;0
WireConnection;244;0;224;0
WireConnection;17;0;11;0
WireConnection;194;0;193;0
WireConnection;189;0;244;0
WireConnection;189;1;251;0
WireConnection;189;3;190;0
WireConnection;189;4;190;0
WireConnection;189;5;191;0
WireConnection;61;0;17;0
WireConnection;61;1;62;0
WireConnection;61;2;59;0
WireConnection;60;0;61;0
WireConnection;151;0;152;0
WireConnection;151;1;153;0
WireConnection;151;2;194;0
WireConnection;151;3;202;0
WireConnection;207;15;189;0
WireConnection;236;0;243;0
WireConnection;235;0;234;0
WireConnection;237;0;246;0
WireConnection;203;0;151;0
WireConnection;234;0;232;0
WireConnection;234;1;233;1
WireConnection;245;0;242;0
WireConnection;232;1;230;0
WireConnection;232;2;229;0
WireConnection;232;3;231;0
WireConnection;25;0;2;1
WireConnection;25;1;60;0
WireConnection;242;0;241;0
WireConnection;242;1;237;2
WireConnection;242;2;240;0
WireConnection;200;19;207;0
WireConnection;231;0;228;0
WireConnection;230;0;227;1
WireConnection;230;1;227;2
WireConnection;241;0;238;0
WireConnection;241;1;237;1
WireConnection;229;1;228;0
WireConnection;239;0;237;3
WireConnection;239;1;236;0
WireConnection;240;0;239;0
WireConnection;0;0;208;0
WireConnection;0;2;203;0
WireConnection;0;10;25;0
WireConnection;0;13;200;0
ASEEND*/
//CHKSM=945014E89C02D101BCD24707FB7E934A42F1C16A