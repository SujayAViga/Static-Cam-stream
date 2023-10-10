// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Parasol/ShadeStructure_shader"
{
	Properties
	{
		_Color0("Color 0", Color) = (1,1,1,0)
		_Roughness("Roughness", 2D) = "white" {}
		_Smoothness("Roughness Intensity", Range( 0 , 1)) = 0
		_MovementSpeed("Movement Speed", Range( 0 , 5)) = 1
		_MaxDistance("Max Distance", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Off
		Stencil
		{
			Ref 1
			CompFront NotEqual
			CompBack NotEqual
		}
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
			float eyeDepth;
			float3 worldPos;
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

		uniform float _MovementSpeed;
		uniform float _MaxDistance;
		uniform float sg_ColorLut;
		uniform sampler2D StandardLUT;
		uniform float sg_ToonFog;
		uniform float4 _Color0;
		uniform sampler2D _Roughness;
		SamplerState sampler_Roughness;
		uniform float4 _Roughness_ST;
		uniform float _Smoothness;
		uniform sampler2D fog_texture;
		uniform float fog_start;
		uniform float fog_end;
		uniform float fog_spread;
		uniform float fog_height;
		uniform float FogHeightDensity;
		uniform sampler2D SecondLUT;
		uniform float EmissiveGradient;


		float MyCustomExpression8_g19( float fogStart, float fogEnd, float SurfaceDepth )
		{
			return saturate((SurfaceDepth-fogStart)/(fogEnd-fogStart));
		}


		float MyCustomExpression232_g19( float fogStart, float fogEnd, float SurfaceDepth )
		{
			return saturate((SurfaceDepth-fogStart)/(fogEnd-fogStart));
		}


		float MyCustomExpression233_g19( float fogStart, float fogEnd, float SurfaceDepth )
		{
			return saturate((SurfaceDepth-fogStart)/(fogEnd-fogStart));
		}


		inline float4 FeatureSwitch( float TestVal, float4 FeatureOn, float4 FeatureOff )
		{
			return TestVal>0?FeatureOn:FeatureOff;;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float mulTime224 = _Time.y * ( _MovementSpeed * ( v.color.g - 0.5 ) );
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( ( sin( mulTime224 ) + 0.5 ) * v.color.r * ase_vertexNormal * _MaxDistance );
			v.vertex.w = 1;
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float TestVal103_g157 = sg_ColorLut;
			float TestVal194_g19 = sg_ToonFog;
			SurfaceOutputStandard s9_g18 = (SurfaceOutputStandard ) 0;
			s9_g18.Albedo = _Color0.rgb;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			s9_g18.Normal = WorldNormalVector( i , float4( ase_vertexNormal , 0.0 ).rgb );
			s9_g18.Emission = float4( 0,0,0,0 ).rgb;
			s9_g18.Metallic = 0.0;
			float2 uv_Roughness = i.uv_texcoord * _Roughness_ST.xy + _Roughness_ST.zw;
			float lerpResult304 = lerp( 0.0 , tex2D( _Roughness, uv_Roughness ).r , _Smoothness);
			s9_g18.Smoothness = ( 1.0 - lerpResult304 );
			s9_g18.Occlusion = 1.0;

			data.light = gi.light;

			UnityGI gi9_g18 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g9_g18 = UnityGlossyEnvironmentSetup( s9_g18.Smoothness, data.worldViewDir, s9_g18.Normal, float3(0,0,0));
			gi9_g18 = UnityGlobalIllumination( data, s9_g18.Occlusion, s9_g18.Normal, g9_g18 );
			#endif

			float3 surfResult9_g18 = LightingStandard ( s9_g18, viewDir, gi9_g18 ).rgb;
			surfResult9_g18 += s9_g18.Emission;

			#ifdef UNITY_PASS_FORWARDADD//9_g18
			surfResult9_g18 -= s9_g18.Emission;
			#endif//9_g18
			float4 temp_output_19_0_g19 = float4( surfResult9_g18 , 0.0 );
			float fogStart8_g19 = fog_start;
			float fogEnd8_g19 = fog_end;
			float SurfaceDepth8_g19 = i.eyeDepth;
			float localMyCustomExpression8_g19 = MyCustomExpression8_g19( fogStart8_g19 , fogEnd8_g19 , SurfaceDepth8_g19 );
			float fogStart232_g19 = 0.0;
			float fogEnd232_g19 = fog_spread;
			float3 ase_worldPos = i.worldPos;
			float SurfaceDepth232_g19 = ase_worldPos.y;
			float localMyCustomExpression232_g19 = MyCustomExpression232_g19( fogStart232_g19 , fogEnd232_g19 , SurfaceDepth232_g19 );
			float2 appendResult89_g19 = (float2(localMyCustomExpression8_g19 , localMyCustomExpression232_g19));
			float4 fogInputs224_g19 = tex2D( fog_texture, appendResult89_g19 );
			float4 temp_output_111_0_g19 = fogInputs224_g19;
			float4 clampResult165_g19 = clamp( ( temp_output_19_0_g19 + temp_output_111_0_g19 ) , float4( 0,0,0,0 ) , temp_output_111_0_g19 );
			float fogStart233_g19 = fog_spread;
			float fogEnd233_g19 = fog_height;
			float SurfaceDepth233_g19 = ase_worldPos.y;
			float localMyCustomExpression233_g19 = MyCustomExpression233_g19( fogStart233_g19 , fogEnd233_g19 , SurfaceDepth233_g19 );
			float distanceGradiant226_g19 = saturate( ( localMyCustomExpression8_g19 * (localMyCustomExpression233_g19*FogHeightDensity + 0.0) ) );
			float4 lerpResult195_g19 = lerp( temp_output_19_0_g19 , clampResult165_g19 , distanceGradiant226_g19);
			float4 FeatureOn194_g19 = lerpResult195_g19;
			float4 FeatureOff194_g19 = temp_output_19_0_g19;
			float4 localFeatureSwitch194_g19 = FeatureSwitch( TestVal194_g19 , FeatureOn194_g19 , FeatureOff194_g19 );
			float3 inputColor100_g157 = localFeatureSwitch194_g19.xyz;
			float3 appendResult178_g157 = (float3(0.015 , 0.015 , 0.015));
			float3 appendResult180_g157 = (float3(0.98 , 0.98 , 0.98));
			float3 clampResult170_g157 = clamp( inputColor100_g157 , appendResult178_g157 , appendResult180_g157 );
			float3 break2_g157 = clampResult170_g157;
			float2 _Vector1 = float2(1024,32);
			float lutDim14_g157 = _Vector1.y;
			float Red_U81_g157 = ( break2_g157.x / lutDim14_g157 );
			float temp_output_3_0_g157 = ( break2_g157.z * lutDim14_g157 );
			float Green_V75_g157 = break2_g157.y;
			float2 appendResult53_g157 = (float2(( Red_U81_g157 + ( floor( temp_output_3_0_g157 ) / lutDim14_g157 ) ) , Green_V75_g157));
			float2 appendResult7_g157 = (float2(( Red_U81_g157 + ( ceil( temp_output_3_0_g157 ) / lutDim14_g157 ) ) , Green_V75_g157));
			float HalfPixelHeightPad138_g157 = ( 0.5 / lutDim14_g157 );
			float2 temp_cast_8 = (HalfPixelHeightPad138_g157).xx;
			float2 temp_cast_9 = (( 1.0 - HalfPixelHeightPad138_g157 )).xx;
			float2 clampResult153_g157 = clamp( appendResult7_g157 , temp_cast_8 , temp_cast_9 );
			float4 tex2DNode9_g157 = tex2D( StandardLUT, clampResult153_g157 );
			float temp_output_65_0_g157 = ( temp_output_3_0_g157 - floor( temp_output_3_0_g157 ) );
			float4 lerpResult57_g157 = lerp( tex2D( StandardLUT, appendResult53_g157 ) , tex2DNode9_g157 , temp_output_65_0_g157);
			float4 tex2DNode88_g157 = tex2D( SecondLUT, clampResult153_g157 );
			float4 lerpResult90_g157 = lerp( tex2D( SecondLUT, appendResult53_g157 ) , tex2DNode88_g157 , temp_output_65_0_g157);
			float4 lerpResult94_g157 = lerp( lerpResult57_g157 , lerpResult90_g157 , EmissiveGradient);
			float4 FeatureOn103_g157 = lerpResult94_g157;
			float4 FeatureOff103_g157 = float4( inputColor100_g157 , 0.0 );
			float4 localFeatureSwitch103_g157 = FeatureSwitch( TestVal103_g157 , FeatureOn103_g157 , FeatureOff103_g157 );
			c.rgb = localFeatureSwitch103_g157.xyz;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows nolightmap  nodynlightmap nodirlightmap noforwardadd vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.6
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.customPack1.z = customInputData.eyeDepth;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				surfIN.eyeDepth = IN.customPack1.z;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
2772;334;1758;854;-2254.688;1350.889;1.740722;True;False
Node;AmplifyShaderEditor.CommentaryNode;218;4044.829,286.0613;Inherit;False;1125.2;493.1741;Vertex Offset;12;230;229;228;227;226;225;224;223;222;221;220;219;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;219;4267.92,642.0704;Inherit;False;Constant;_Float1;Float 1;23;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;220;4100.75,484.7453;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;221;4094.83,377.6453;Inherit;False;Property;_MovementSpeed;Movement Speed;8;0;Create;True;0;0;False;0;False;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;222;4291.085,459.7552;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;299;3675.817,-502.2452;Inherit;True;Property;_Roughness;Roughness;6;0;Create;True;0;0;False;0;False;-1;None;25dd2a9a2560389418cf5e8c35395303;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;301;3620.667,-240.8865;Inherit;False;Property;_Smoothness;Roughness Intensity;7;0;Create;False;0;0;False;0;False;0;0.256;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;223;4389.14,339.9323;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;224;4531.243,336.0613;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;284;4155.448,-421.6831;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;304;4169.88,-267.0206;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;273;4119.054,-599.538;Inherit;False;Property;_Color0;Color 0;5;0;Create;True;0;0;False;0;False;1,1,1,0;0.5566038,0.5566038,0.5566038,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;242;4502.198,-337.3918;Inherit;False;ParasolCustomLighting;-1;;18;dd582d5258e33374fbbbd0bc1271698d;1,136,0;6;10;COLOR;1,0,0.8704052,0;False;11;COLOR;0,0,0.5,1;False;12;FLOAT;1;False;15;FLOAT;0;False;16;COLOR;0,0,0,0;False;17;FLOAT;1;False;2;FLOAT3;135;COLOR;112
Node;AmplifyShaderEditor.SinOpNode;225;4705.151,339.3743;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;226;4677.457,410.9128;Inherit;False;Constant;_Float2;Float 2;22;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;227;4751.354,519.4918;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;228;4682.577,664.2353;Inherit;False;Property;_MaxDistance;Max Distance;9;0;Create;True;0;0;False;0;False;1;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;229;4853.268,377.3049;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;283;4884.578,-269.9826;Inherit;False;Toon_DistanceFog;3;;19;87a2c17086d6be546a10c470a8adefc0;0;2;19;COLOR;0,0,0,0;False;111;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CustomExpressionNode;268;3040.385,221.6492;Inherit;False;UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, In0);4;False;1;True;In0;FLOAT3;0,0,0;In;;Inherit;False;upside down reflection;True;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.VertexColorNode;272;3020.56,389.915;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;269;2857.834,276.3382;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;270;2638.506,188.6408;Inherit;False;Constant;_Vector6;Vector 6;11;0;Create;True;0;0;False;0;False;1,-1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;230;4998.03,405.3958;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;271;5371.622,-237.0897;Inherit;False;ParasolGlobalLut_;0;;157;415cf2c404453934193ab734c391e132;0;1;15;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldReflectionVector;254;2642.527,366.3752;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;281;3294.072,161.8388;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;5604.787,-447.4933;Float;False;True;-1;6;ASEMaterialInspector;0;0;CustomLighting;Parasol/ShadeStructure_shader;False;False;False;False;False;False;True;True;True;False;False;True;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;True;1;False;-1;255;False;-1;255;False;-1;6;False;-1;0;False;-1;0;False;-1;0;False;-1;6;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;222;0;220;2
WireConnection;222;1;219;0
WireConnection;223;0;221;0
WireConnection;223;1;222;0
WireConnection;224;0;223;0
WireConnection;304;1;299;1
WireConnection;304;2;301;0
WireConnection;242;10;273;0
WireConnection;242;11;284;0
WireConnection;242;12;304;0
WireConnection;225;0;224;0
WireConnection;229;0;225;0
WireConnection;229;1;226;0
WireConnection;283;19;242;135
WireConnection;268;0;269;0
WireConnection;269;0;270;0
WireConnection;269;1;254;0
WireConnection;230;0;229;0
WireConnection;230;1;220;1
WireConnection;230;2;227;0
WireConnection;230;3;228;0
WireConnection;271;15;283;0
WireConnection;281;0;268;0
WireConnection;281;1;272;1
WireConnection;0;13;271;0
WireConnection;0;11;230;0
ASEEND*/
//CHKSM=F3233827961A2D62CB5A193170EFD831BB27C272