// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Parasol/SimpleStandard_shader"
{
	Properties
	{
		[Enum(Off,0,On,1)]_PBRSafeFilter("PBR Safe Filter", Float) = 1
		[Gamma][NoScaleOffset][Header(Base Color)]_BaseColor("Base Color", 2D) = "white" {}
		_DiffuseIntensity("Diffuse Intensity", Range( 0 , 1)) = 1
		[Gamma][NoScaleOffset]_TintMask("Tint Mask", 2D) = "white" {}
		[Gamma]_ColorTint("Base Color Tint", Color) = (1,1,1,0)
		[Enum(Material,0,Vertex,1)]_UseVertexColorforTint("Tint Color Source", Int) = 0
		[Header(Vertex AO)]_VertexAOMinimumValue("Vertex AO Minimum Value", Range( 0 , 1)) = 1
		[Header(UV Tiling  Offset)]_TextureTilingU("Texture Tiling U", Float) = 1
		_TextureTilingV("Texture Tiling V", Float) = 1
		_TextureOffsetU("Texture Offset U", Float) = 1
		_TextureOffsetV("Texture Offset V", Float) = 1
		[NoScaleOffset][Header(Normal)]_Normal("Normal", 2D) = "bump" {}
		_NormalScale("Normal Scale", Range( 0 , 1)) = 1
		[NoScaleOffset][Header(Roughness)]_RMAO("Roughness", 2D) = "white" {}
		_RoughnessCeiling("Roughness Ceiling", Range( 0 , 1)) = 1
		_RoughnessFloor("Roughness Floor", Range( 0 , 1)) = 0
		_RoughnessContrast("Roughness Contrast", Range( 0 , 10)) = 1
		_RoughnessTiling("Roughness Tiling", Range( 0.001 , 16)) = 1
		[NoScaleOffset][Header(Metallic)]_MetallicMask("Metallic Mask", 2D) = "black" {}
		_IncreaseMetalness("Increase Metalness", Range( 0 , 1)) = 0
		[HDR][Header(Emission)]_EmissionColor("Emission Color", Color) = (0.8867924,0.8867924,0.8867924,0)
		[HDR][Header(Emission)]_EmissionCompliment("Emission Compliment", Color) = (1,1,1,0)
		_HueMin("Hue Min", Range( -5 , 5)) = 0
		_HueMax("Hue Max", Range( -5 , 5)) = 1
		[NoScaleOffset]_EmissionTexture("Emission Texture", 2D) = "white" {}
		[Enum(UV1,1,UV4,4)]_UVChannel("UV Channel", Int) = 1
		_DaytimeEmissiveValue("Daytime Emissive Value", Range( 0 , 1)) = 0
		[Header(Light Baking Emissive Overrrides)][Toggle(_OVERRIDEDAYCOLOR_ON)] _OverrideDayColor("OverrideDayColor", Float) = 0
		[HDR]_BakedEmissionColorDay("Baked Emission Color Day", Color) = (0.4622642,0.4622642,0.4622642,0)
		_BakedEmissiveIntensityDay("Baked Emissive Intensity Day", Range( 0 , 2)) = 1
		[Toggle(_OVERRIDENIGHTCOLOR_ON)] _OverrideNightColor("OverrideNightColor", Float) = 0
		[HDR]_BakedEmissionColorNight("Baked Emission Color Night", Color) = (1,0.8169013,0,0)
		_BakedEmissiveIntensityNight("Baked Emissive Intensity Night", Range( 0 , 2)) = 1
		_EmissionTilingX("Emission Tiling X", Float) = 1
		_EmissionTilingY("Emission Tiling Y", Float) = 1
		_EmissionOffsetX("Emission Offset X", Float) = 0
		_EmissionOffsetY("Emission Offset Y", Float) = 0
		[HDR][Header(Uplight Effect)]_UplightLightColor("Uplight Light Color", Color) = (1,0.9923881,0.5566038,0)
		_TreeLightOn("Uplight Light Brightness", Range( 0 , 1)) = 1
		[Enum(Emissive,0,Uplight,1,Add,2,Max,3)]_EmissiveType("Emissive Blend Type", Int) = 0
		_TopLightHeight("Uplight End Height", Range( -10 , 100)) = 4
		_TopLightFalloff("Uplight End Falloff", Range( -10 , 10)) = 0.6897392
		_BotLightHeight("Uplight Start Height", Range( -10 , 100)) = 0
		_BotFalloff("Uplight Start Falloff", Range( -10 , 10)) = 1
		[Enum(Normal,0,Inverted,1)]_FlipYNormal("Y Normal Direction", Range( 0 , 1)) = 1
		[Toggle(_FLIPLIGHTDIRECTION_ON)] _FlipLightDirection("Flip Light Direction", Float) = 0
		[Enum(Straight,0,Screen,1,Add,2,Multiply,3,Overlay,4,Hard Light,5)][Header(Photoshop Blend Modes)]_Mode("Mode", Int) = 0
		[Header(Per Pixel Fog Controls)]_PerPixelFogAmount("Per Pixel Fog Amount", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord4( "", 2D ) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  "LightMode"="Meta" }
		Cull Back
		Stencil
		{
			Ref 1
			Comp NotEqual
		}
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#pragma shader_feature_local _FLIPLIGHTDIRECTION_ON
		#pragma shader_feature_local _OVERRIDEDAYCOLOR_ON
		#pragma shader_feature_local _OVERRIDENIGHTCOLOR_ON
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
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv4_texcoord4;
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
		uniform float _TextureTilingU;
		uniform float _TextureTilingV;
		uniform float _TextureOffsetU;
		uniform float _TextureOffsetV;
		uniform float _DiffuseIntensity;
		uniform float4 _ColorTint;
		uniform int _UseVertexColorforTint;
		uniform sampler2D _TintMask;
		SamplerState sampler_TintMask;
		uniform sampler2D _MetallicMask;
		SamplerState sampler_MetallicMask;
		uniform float _IncreaseMetalness;
		uniform float _PBRSafeFilter;
		uniform int _Mode;
		uniform float4 _UplightLightColor;
		uniform float _TopLightHeight;
		uniform float _TopLightFalloff;
		uniform float _BotLightHeight;
		uniform float _BotFalloff;
		uniform float _TreeLightOn;
		uniform sampler2D _Normal;
		uniform float _NormalScale;
		uniform float _FlipYNormal;
		uniform float EmissiveGradient;
		uniform sampler2D _EmissionTexture;
		uniform int _UVChannel;
		uniform float _EmissionTilingX;
		uniform float _EmissionTilingY;
		uniform float _EmissionOffsetX;
		uniform float _EmissionOffsetY;
		uniform int LightBakeScenario;
		uniform float4 _EmissionColor;
		uniform float4 _EmissionCompliment;
		uniform float _HueMin;
		uniform float _HueMax;
		SamplerState sampler_EmissionTexture;
		uniform float4 _BakedEmissionColorDay;
		uniform float _DaytimeEmissiveValue;
		uniform float _BakedEmissiveIntensityDay;
		uniform float4 _BakedEmissionColorNight;
		uniform float _BakedEmissiveIntensityNight;
		uniform int _EmissiveType;
		uniform float sg_ToonFog;
		uniform float sg_ColorLut;
		uniform sampler2D StandardLUT;
		uniform float _RoughnessContrast;
		uniform sampler2D _RMAO;
		uniform float _RoughnessTiling;
		uniform float _RoughnessFloor;
		uniform float _RoughnessCeiling;
		uniform float _VertexAOMinimumValue;
		uniform int LUTSize;
		uniform sampler2D SecondLUT;
		uniform sampler2D fog_texture;
		uniform float fog_start;
		uniform float fog_end;
		uniform float fog_spread;
		uniform float fog_height;
		uniform float FogHeightDensity;
		uniform float _PerPixelFogAmount;


		float2 MyCustomExpression59_g1206( int UVChannel, float2 UV1, float2 UV4 )
		{
			switch (UVChannel)
			{ 
				case 1:
					return UV1;
				case 4:
					return UV4;
				default:
					return UV4;
			}
		}


		float4 MyCustomExpression2_g1207( int ScenarioIndex, float4 RuntimeLighting, float4 LightBakeDay, float4 LightBakeNight )
		{
			switch (ScenarioIndex)
			{ 
				case 1:
					return LightBakeDay;
				case 2:
					return LightBakeNight;
				default:
					return RuntimeLighting;
			}
		}


		float4 MyCustomExpression28_g1210( float4 Uplight, float4 Emissive, int Type )
		{
			switch( Type )
			{
			    case 0:
			        return Emissive;
			        break;
			    case 1:
			        return Uplight;
			        break;
			    case 2:
			        return saturate( Emissive + Uplight );
			        break;
			    case 3:
			        return max( Emissive, Uplight);
			        break;
			    default:
			        return Emissive;
			}
		}


		float4 MyCustomExpression8_g1214( int Mode, float4 Straight, float4 Overlay, float4 Hardlight, float4 Screen, float4 Add, float4 Multiply )
		{
			 switch (Mode)
			{
				case 1:
					return Screen;
					break;
				case 2:
					return Add;
					break;
				case 3:
					return Multiply;
					break;
				case 4: 
					return Overlay;
					break;
				case 5:
					return Hardlight;
					break;
				default:
					return Straight;
			}
		}


		float4 CalculateContrast( float contrastValue, float4 colorTarget )
		{
			float t = 0.5 * ( 1.0 - contrastValue );
			return mul( float4x4( contrastValue,0,0,t, 0,contrastValue,0,t, 0,0,contrastValue,t, 0,0,0,1 ), colorTarget );
		}

		inline float4 FeatureSwitch( float TestVal, float4 FeatureOn, float4 FeatureOff )
		{
			return TestVal>0?FeatureOn:FeatureOff;;
		}


		float MyCustomExpression8_g1213( float fogStart, float fogEnd, float SurfaceDepth )
		{
			return saturate((SurfaceDepth-fogStart)/(fogEnd-fogStart));
		}


		float MyCustomExpression232_g1213( float fogStart, float fogEnd, float SurfaceDepth )
		{
			return saturate((SurfaceDepth-fogStart)/(fogEnd-fogStart));
		}


		float MyCustomExpression233_g1213( float fogStart, float fogEnd, float SurfaceDepth )
		{
			return saturate((SurfaceDepth-fogStart)/(fogEnd-fogStart));
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float TestVal194_g1213 = sg_ToonFog;
			float TestVal103_g1212 = sg_ColorLut;
			SurfaceOutputStandard s9_g1211 = (SurfaceOutputStandard ) 0;
			float2 appendResult82 = (float2(_TextureTilingU , _TextureTilingV));
			float2 appendResult1161 = (float2(_TextureOffsetU , _TextureOffsetV));
			float2 uv_TexCoord80 = i.uv_texcoord * appendResult82 + appendResult1161;
			float4 lerpResult3_g1215 = lerp( float4(1,1,1,0) , tex2D( _BaseColor, uv_TexCoord80 ) , _DiffuseIntensity);
			float4 lerpResult15_g1215 = lerp( _ColorTint , i.vertexColor , (float)_UseVertexColorforTint);
			float2 uv_TintMask13_g1215 = i.uv_texcoord;
			float4 lerpResult29_g1215 = lerp( lerpResult3_g1215 , ( lerpResult3_g1215 * lerpResult15_g1215 ) , tex2D( _TintMask, uv_TintMask13_g1215 ).r);
			float4 temp_output_6_0_g1208 = lerpResult29_g1215;
			float4 clampResult8_g1208 = clamp( temp_output_6_0_g1208 , float4( 0.1568628,0.1568628,0.1568628,0 ) , float4( 0.9411765,0.9411765,0.9411765,0.003921569 ) );
			float grayscale13_g1208 = Luminance(temp_output_6_0_g1208.rgb);
			float4 color16_g1208 = IsGammaSpace() ? float4(1,1,1,1) : float4(1,1,1,1);
			float metallicValue313 = (_IncreaseMetalness + (tex2D( _MetallicMask, uv_TexCoord80 ).r - 0.0) * (1.0 - _IncreaseMetalness) / (1.0 - 0.0));
			float4 lerpResult5_g1208 = lerp( clampResult8_g1208 ,  ( grayscale13_g1208 - 0.0 > 160.0 ? color16_g1208 : grayscale13_g1208 - 0.0 <= 160.0 && grayscale13_g1208 + 0.0 >= 160.0 ? temp_output_6_0_g1208 : temp_output_6_0_g1208 )  , metallicValue313);
			float4 lerpResult17_g1208 = lerp( temp_output_6_0_g1208 , lerpResult5_g1208 , _PBRSafeFilter);
			float4 baseColor211 = lerpResult17_g1208;
			s9_g1211.Albedo = baseColor211.rgb;
			float3 normalVector218 = UnpackScaleNormal( tex2D( _Normal, uv_TexCoord80 ), _NormalScale );
			float4 temp_output_11_0_g1211 = float4( normalVector218 , 0.0 );
			s9_g1211.Normal = WorldNormalVector( i , temp_output_11_0_g1211.rgb );
			s9_g1211.Emission = float4( 0,0,0,0 ).rgb;
			s9_g1211.Metallic = metallicValue313;
			float roughnessValue219 = (_RoughnessFloor + (saturate( (CalculateContrast(_RoughnessContrast,tex2D( _RMAO, ( uv_TexCoord80 * _RoughnessTiling ) ))).r ) - 0.0) * (_RoughnessCeiling - _RoughnessFloor) / (1.0 - 0.0));
			s9_g1211.Smoothness = ( 1.0 - roughnessValue219 );
			float lerpResult24_g1215 = lerp( i.vertexColor.a , 1.0 , _VertexAOMinimumValue);
			float AOColor1153 = lerpResult24_g1215;
			s9_g1211.Occlusion = AOColor1153;

			data.light = gi.light;

			UnityGI gi9_g1211 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g9_g1211 = UnityGlossyEnvironmentSetup( s9_g1211.Smoothness, data.worldViewDir, s9_g1211.Normal, float3(0,0,0));
			gi9_g1211 = UnityGlobalIllumination( data, s9_g1211.Occlusion, s9_g1211.Normal, g9_g1211 );
			#endif

			float3 surfResult9_g1211 = LightingStandard ( s9_g1211, viewDir, gi9_g1211 ).rgb;
			surfResult9_g1211 += s9_g1211.Emission;

			#ifdef UNITY_PASS_FORWARDADD//9_g1211
			surfResult9_g1211 -= s9_g1211.Emission;
			#endif//9_g1211
			float3 inputColor100_g1212 = surfResult9_g1211;
			float ifLocalVar202_g1212 = 0;
			if( LUTSize <= 2 )
				ifLocalVar202_g1212 = (float)32;
			else
				ifLocalVar202_g1212 = (float)LUTSize;
			float lutDim14_g1212 = ifLocalVar202_g1212;
			float temp_output_196_0_g1212 = ( 1.0 / lutDim14_g1212 );
			float3 temp_cast_33 = (temp_output_196_0_g1212).xxx;
			float3 temp_cast_34 = (( 1.0 - temp_output_196_0_g1212 )).xxx;
			float3 clampResult170_g1212 = clamp( inputColor100_g1212 , temp_cast_33 , temp_cast_34 );
			float3 break2_g1212 = clampResult170_g1212;
			float Red_U81_g1212 = ( break2_g1212.x / lutDim14_g1212 );
			float temp_output_3_0_g1212 = ( break2_g1212.z * lutDim14_g1212 );
			float Green_V75_g1212 = break2_g1212.y;
			float2 appendResult7_g1212 = (float2(( Red_U81_g1212 + ( ceil( temp_output_3_0_g1212 ) / lutDim14_g1212 ) ) , Green_V75_g1212));
			float2 temp_output_183_0_g1212 = saturate( appendResult7_g1212 );
			float4 tex2DNode9_g1212 = tex2Dlod( StandardLUT, float4( temp_output_183_0_g1212, 0, 0.0) );
			float4 tex2DNode88_g1212 = tex2Dlod( SecondLUT, float4( temp_output_183_0_g1212, 0, 0.0) );
			float temp_output_182_0_g1212 = saturate( EmissiveGradient );
			float4 lerpResult95_g1212 = lerp( tex2DNode9_g1212 , tex2DNode88_g1212 , temp_output_182_0_g1212);
			float4 FeatureOn103_g1212 = lerpResult95_g1212;
			float4 FeatureOff103_g1212 = float4( inputColor100_g1212 , 0.0 );
			float4 localFeatureSwitch103_g1212 = FeatureSwitch( TestVal103_g1212 , FeatureOn103_g1212 , FeatureOff103_g1212 );
			float4 temp_output_19_0_g1213 = localFeatureSwitch103_g1212;
			float fogStart8_g1213 = fog_start;
			float fogEnd8_g1213 = fog_end;
			float SurfaceDepth8_g1213 = i.eyeDepth;
			float localMyCustomExpression8_g1213 = MyCustomExpression8_g1213( fogStart8_g1213 , fogEnd8_g1213 , SurfaceDepth8_g1213 );
			float fogStart232_g1213 = 0.0;
			float fogEnd232_g1213 = fog_spread;
			float3 ase_worldPos = i.worldPos;
			float SurfaceDepth232_g1213 = ase_worldPos.y;
			float localMyCustomExpression232_g1213 = MyCustomExpression232_g1213( fogStart232_g1213 , fogEnd232_g1213 , SurfaceDepth232_g1213 );
			float2 appendResult89_g1213 = (float2(localMyCustomExpression8_g1213 , localMyCustomExpression232_g1213));
			float4 fogInputs224_g1213 = tex2D( fog_texture, appendResult89_g1213 );
			float4 temp_output_111_0_g1213 = fogInputs224_g1213;
			float4 clampResult165_g1213 = clamp( ( temp_output_19_0_g1213 + temp_output_111_0_g1213 ) , float4( 0,0,0,0 ) , temp_output_111_0_g1213 );
			float fogStart233_g1213 = fog_spread;
			float fogEnd233_g1213 = fog_height;
			float SurfaceDepth233_g1213 = ase_worldPos.y;
			float localMyCustomExpression233_g1213 = MyCustomExpression233_g1213( fogStart233_g1213 , fogEnd233_g1213 , SurfaceDepth233_g1213 );
			float distanceGradiant226_g1213 = saturate( ( localMyCustomExpression8_g1213 * (localMyCustomExpression233_g1213*FogHeightDensity + 0.0) ) );
			float4 lerpResult195_g1213 = lerp( temp_output_19_0_g1213 , clampResult165_g1213 , ( distanceGradiant226_g1213 * _PerPixelFogAmount ));
			float4 FeatureOn194_g1213 = lerpResult195_g1213;
			float4 FeatureOff194_g1213 = temp_output_19_0_g1213;
			float4 localFeatureSwitch194_g1213 = FeatureSwitch( TestVal194_g1213 , FeatureOn194_g1213 , FeatureOff194_g1213 );
			c.rgb = localFeatureSwitch194_g1213.xyz;
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
			float2 appendResult82 = (float2(_TextureTilingU , _TextureTilingV));
			float2 appendResult1161 = (float2(_TextureOffsetU , _TextureOffsetV));
			float2 uv_TexCoord80 = i.uv_texcoord * appendResult82 + appendResult1161;
			float4 lerpResult3_g1215 = lerp( float4(1,1,1,0) , tex2D( _BaseColor, uv_TexCoord80 ) , _DiffuseIntensity);
			float4 lerpResult15_g1215 = lerp( _ColorTint , i.vertexColor , (float)_UseVertexColorforTint);
			float2 uv_TintMask13_g1215 = i.uv_texcoord;
			float4 lerpResult29_g1215 = lerp( lerpResult3_g1215 , ( lerpResult3_g1215 * lerpResult15_g1215 ) , tex2D( _TintMask, uv_TintMask13_g1215 ).r);
			float4 temp_output_6_0_g1208 = lerpResult29_g1215;
			float4 clampResult8_g1208 = clamp( temp_output_6_0_g1208 , float4( 0.1568628,0.1568628,0.1568628,0 ) , float4( 0.9411765,0.9411765,0.9411765,0.003921569 ) );
			float grayscale13_g1208 = Luminance(temp_output_6_0_g1208.rgb);
			float4 color16_g1208 = IsGammaSpace() ? float4(1,1,1,1) : float4(1,1,1,1);
			float metallicValue313 = (_IncreaseMetalness + (tex2D( _MetallicMask, uv_TexCoord80 ).r - 0.0) * (1.0 - _IncreaseMetalness) / (1.0 - 0.0));
			float4 lerpResult5_g1208 = lerp( clampResult8_g1208 ,  ( grayscale13_g1208 - 0.0 > 160.0 ? color16_g1208 : grayscale13_g1208 - 0.0 <= 160.0 && grayscale13_g1208 + 0.0 >= 160.0 ? temp_output_6_0_g1208 : temp_output_6_0_g1208 )  , metallicValue313);
			float4 lerpResult17_g1208 = lerp( temp_output_6_0_g1208 , lerpResult5_g1208 , _PBRSafeFilter);
			float4 baseColor211 = lerpResult17_g1208;
			o.Albedo = baseColor211.rgb;
			int Mode8_g1214 = _Mode;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float temp_output_18_0_g1210 = ( saturate( ( ( _TopLightHeight - ase_vertex3Pos.y ) / ( _TopLightHeight - _TopLightFalloff ) ) ) * saturate( ( ( ase_vertex3Pos.y - _BotLightHeight ) / ( _BotLightHeight + _BotFalloff ) ) ) );
			#ifdef _FLIPLIGHTDIRECTION_ON
				float staticSwitch41_g1210 = ( 1.0 - temp_output_18_0_g1210 );
			#else
				float staticSwitch41_g1210 = temp_output_18_0_g1210;
			#endif
			float3 normalVector218 = UnpackScaleNormal( tex2D( _Normal, uv_TexCoord80 ), _NormalScale );
			float3 newWorldNormal16_g1210 = (WorldNormalVector( i , normalVector218 ));
			float lerpResult22_g1210 = lerp( newWorldNormal16_g1210.y , ( 1.0 - newWorldNormal16_g1210.y ) , _FlipYNormal);
			float4 Uplight28_g1210 = ( _UplightLightColor * ( saturate( staticSwitch41_g1210 ) * _TreeLightOn * lerpResult22_g1210 ) * EmissiveGradient );
			int UVChannel59_g1206 = _UVChannel;
			float2 appendResult67_g1206 = (float2(_EmissionTilingX , _EmissionTilingY));
			float2 appendResult23_g1206 = (float2(_EmissionOffsetX , _EmissionOffsetY));
			float2 uv_TexCoord6_g1206 = i.uv_texcoord * appendResult67_g1206 + appendResult23_g1206;
			float2 UV159_g1206 = uv_TexCoord6_g1206;
			float2 uv4_TexCoord25_g1206 = i.uv4_texcoord4 * appendResult67_g1206 + appendResult23_g1206;
			float2 UV459_g1206 = uv4_TexCoord25_g1206;
			float2 localMyCustomExpression59_g1206 = MyCustomExpression59_g1206( UVChannel59_g1206 , UV159_g1206 , UV459_g1206 );
			float4 tex2DNode2_g1206 = tex2D( _EmissionTexture, localMyCustomExpression59_g1206 );
			int ScenarioIndex2_g1207 = LightBakeScenario;
			float smoothstepResult73_g1206 = smoothstep( _HueMin , _HueMax , tex2DNode2_g1206.r);
			float4 lerpResult70_g1206 = lerp( _EmissionColor , ( _EmissionColor * _EmissionCompliment ) , saturate( smoothstepResult73_g1206 ));
			float4 InputColor15_g1207 = lerpResult70_g1206;
			float4 RuntimeLighting2_g1207 = InputColor15_g1207;
			#ifdef _OVERRIDEDAYCOLOR_ON
				float4 staticSwitch13_g1207 = _BakedEmissionColorDay;
			#else
				float4 staticSwitch13_g1207 = InputColor15_g1207;
			#endif
			float lerpResult24_g1206 = lerp( _DaytimeEmissiveValue , 1.0 , EmissiveGradient);
			#ifdef _OVERRIDEDAYCOLOR_ON
				float staticSwitch20_g1207 = _BakedEmissiveIntensityDay;
			#else
				float staticSwitch20_g1207 = lerpResult24_g1206;
			#endif
			float4 LightBakeDay2_g1207 = ( staticSwitch13_g1207 * staticSwitch20_g1207 );
			#ifdef _OVERRIDENIGHTCOLOR_ON
				float4 staticSwitch14_g1207 = _BakedEmissionColorNight;
			#else
				float4 staticSwitch14_g1207 = InputColor15_g1207;
			#endif
			float4 LightBakeNight2_g1207 = ( staticSwitch14_g1207 * _BakedEmissiveIntensityNight );
			float4 localMyCustomExpression2_g1207 = MyCustomExpression2_g1207( ScenarioIndex2_g1207 , RuntimeLighting2_g1207 , LightBakeDay2_g1207 , LightBakeNight2_g1207 );
			float4 emissiveColor214 = ( tex2DNode2_g1206 * localMyCustomExpression2_g1207 * lerpResult24_g1206 );
			float4 Emissive28_g1210 = emissiveColor214;
			int Type28_g1210 = _EmissiveType;
			float4 localMyCustomExpression28_g1210 = MyCustomExpression28_g1210( Uplight28_g1210 , Emissive28_g1210 , Type28_g1210 );
			float4 UplitEmissiveColor1541 = localMyCustomExpression28_g1210;
			float4 Top9_g1214 = UplitEmissiveColor1541;
			float4 Straight8_g1214 = Top9_g1214;
			float4 Bottom10_g1214 = baseColor211;
			float temp_output_22_0_g1214 = 0.5;
			float4 temp_cast_9 = (temp_output_22_0_g1214).xxxx;
			float4 temp_output_19_0_g1214 = ( 1.0 - ( ( 1.0 - Bottom10_g1214 ) * ( 1.0 - Top9_g1214 ) * 2 ) );
			float4 Overlay8_g1214 =  ( Bottom10_g1214 - 0.0 > temp_cast_9 ? temp_output_19_0_g1214 : Bottom10_g1214 - 0.0 <= temp_cast_9 && Bottom10_g1214 + 0.0 >= temp_cast_9 ? temp_output_19_0_g1214 : ( Top9_g1214 * Bottom10_g1214 * 2 ) ) ;
			float4 temp_cast_14 = (temp_output_22_0_g1214).xxxx;
			float4 temp_output_30_0_g1214 = ( Top9_g1214 * Bottom10_g1214 * 2 );
			float4 Hardlight8_g1214 =  ( Bottom10_g1214 - 0.0 > temp_cast_14 ? temp_output_30_0_g1214 : Bottom10_g1214 - 0.0 <= temp_cast_14 && Bottom10_g1214 + 0.0 >= temp_cast_14 ? temp_output_30_0_g1214 : ( 1.0 - ( ( 1.0 - Bottom10_g1214 ) * ( 1.0 - Top9_g1214 ) * 2 ) ) ) ;
			float4 Screen8_g1214 = ( 1.0 - ( ( 1.0 - Bottom10_g1214 ) * ( 1.0 - Top9_g1214 ) ) );
			float4 Add8_g1214 = ( Top9_g1214 + Bottom10_g1214 );
			float4 Multiply8_g1214 = ( Top9_g1214 * Bottom10_g1214 );
			float4 localMyCustomExpression8_g1214 = MyCustomExpression8_g1214( Mode8_g1214 , Straight8_g1214 , Overlay8_g1214 , Hardlight8_g1214 , Screen8_g1214 , Add8_g1214 , Multiply8_g1214 );
			o.Emission = saturate( localMyCustomExpression8_g1214 ).xyz;
		}

		ENDCG
		CGPROGRAM
		#pragma only_renderers d3d11 glcore gles3 metal 
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows exclude_path:deferred nodynlightmap nodirlightmap vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
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
				float4 customPack1 : TEXCOORD1;
				float1 customPack2 : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				half4 color : COLOR0;
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
				o.customPack1.zw = customInputData.uv4_texcoord4;
				o.customPack1.zw = v.texcoord3;
				o.customPack2.x = customInputData.eyeDepth;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.color = v.color;
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
				surfIN.uv4_texcoord4 = IN.customPack1.zw;
				surfIN.eyeDepth = IN.customPack2.x;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.vertexColor = IN.color;
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
2569.333;36;2472;1304;2190.698;434.1125;1.043356;True;False
Node;AmplifyShaderEditor.CommentaryNode;141;-1756.819,227.2318;Inherit;False;525.6409;435.6585;;7;1160;1159;1161;82;178;83;80;Tiling Controller;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;83;-1745.985,283.4321;Inherit;False;Property;_TextureTilingU;Texture Tiling U;16;0;Create;True;0;0;False;1;Header(UV Tiling  Offset);False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1159;-1743.454,432.6095;Inherit;False;Property;_TextureOffsetU;Texture Offset U;18;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1160;-1743.553,515.6512;Inherit;False;Property;_TextureOffsetV;Texture Offset V;19;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;178;-1744.084,359.4739;Inherit;False;Property;_TextureTilingV;Texture Tiling V;17;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;82;-1575.848,297.3994;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;1161;-1555.503,395.6303;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;80;-1448.441,284.4695;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;129;-1120.957,412.9448;Inherit;False;433.7273;151.8254;;2;313;310;Metallic;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;310;-1104.378,465.905;Inherit;False;Parasol_Metallic_SF;29;;843;ea0886127b2db2e4d86d4f18d4d302b3;0;1;4;FLOAT2;1,1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;132;-1110.342,242.0106;Inherit;False;421.0452;133.9492;;2;218;648;Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;300;-1140.035,-94.28571;Inherit;False;688.4855;282.8704;BAse;4;1153;1564;314;1698;Base Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;1361;-1584.379,726.7966;Inherit;False;Property;_RoughnessTiling;Roughness Tiling;28;0;Create;True;0;0;False;0;False;1;0.47;0.001;16;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;313;-882.757,462.4377;Inherit;False;metallicValue;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;648;-1100.168,285.7011;Inherit;False;Parasol_Normal_SF;20;;1201;c1afb3f5e736a1b44ba607c69344914d;0;1;3;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;1698;-1112.433,-28.62469;Inherit;False;Parasol_BaseColor_SF;9;;1215;449e373bc45bd994189f3f52b3d88f45;0;1;5;FLOAT2;0,0;False;2;COLOR;0;FLOAT;17
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1360;-1290.379,685.7966;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;314;-1074.438,99.18896;Inherit;False;313;metallicValue;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;218;-879.2418,285.0108;Inherit;False;normalVector;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;131;-1124.681,597.5507;Inherit;False;445.9725;145.801;;1;219;Roughness;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;1682;-1068.574,-288.4077;Inherit;False;Parasol_Emission_SF;32;;1206;98a5bb71709445248bf940bbe0a18586;0;1;1;FLOAT2;1,1;False;2;FLOAT;7;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;1564;-802.3833,46.71418;Inherit;False;PbrSafeColor;4;;1208;fddc034c003e76d4ba732677cc318d42;0;3;19;FLOAT;0;False;6;COLOR;0.7333333,0.7333333,0.7333333,0.003921569;False;7;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;130;-1129.039,-336.7513;Inherit;False;586.6033;142.1606;;1;214;Emission;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;1689;-1115.258,653.0394;Inherit;False;Parasol_Roughness_SF;23;;1209;bf68fe7a0dbe8c14686bde4c8c387417;0;1;8;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;214;-651.8337,-243.0843;Inherit;False;emissiveColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;211;-364.4181,45.2775;Inherit;False;baseColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;219;-876.423,646.2477;Inherit;False;roughnessValue;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1561;-519.3349,-350.3852;Inherit;False;218;normalVector;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1153;-809.3943,-45.2214;Inherit;False;AOColor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;222;-459.9104,562.3479;Inherit;False;218;normalVector;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;1678;-250.5863,-325.2422;Inherit;False;Simple_Uplight_SF;51;;1210;99f37951fd0088745980292981a2025b;0;3;34;FLOAT3;0,0,0;False;31;COLOR;0,0,0,0;False;30;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;212;-319.9129,470.0114;Inherit;False;211;baseColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1154;-581.3387,863.0423;Inherit;False;1153;AOColor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;220;-455.028,754.0792;Inherit;False;313;metallicValue;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;221;-506.4862,661.8608;Inherit;False;219;roughnessValue;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1541;179.6526,-313.78;Inherit;False;UplitEmissiveColor;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;1491;-33.65831,600.4671;Inherit;False;ParasolCustomLighting;0;;1211;dd582d5258e33374fbbbd0bc1271698d;1,136,0;6;10;COLOR;0.7333333,0.7333333,0.7333333,0;False;11;COLOR;0.5019608,0.5019608,1,1;False;12;FLOAT;1;False;15;FLOAT;0;False;16;COLOR;0,0,0,0;False;17;FLOAT;1;False;3;FLOAT3;147;FLOAT3;135;COLOR;112
Node;AmplifyShaderEditor.CommentaryNode;1583;727.0366,-496.4033;Inherit;False;691.1353;210.6472;For backwards compatibility only -- should just be uplit color;2;1545;1229;Deprecated Functionality;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;1217;466.0756,432.6939;Inherit;False;211;baseColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;215;457.4761,217.7227;Inherit;False;1541;UplitEmissiveColor;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;1671;313.2481,623.1641;Inherit;False;ParasolGlobalLut_;6;;1212;415cf2c404453934193ab734c391e132;0;1;15;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StaticSwitch;1229;1075.753,-429.143;Inherit;False;Property;_ProjectionEmission;Projection Emission;61;0;Create;False;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;1679;778.603,308.9107;Inherit;False;PhotoshopStyleBlendModes_SF;62;;1214;355eea3733479f34187920a3d7ed4e48;0;3;1;FLOAT4;1,0.7098039,0.4352942,0;False;2;COLOR;0.2196079,0.2196079,0.2196079,0;False;22;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;1582;944.7907,84.63096;Inherit;False;211;baseColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1545;762.0693,-375.9327;Inherit;False;214;emissiveColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1586;766.5957,-461.2993;Inherit;False;1541;UplitEmissiveColor;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;1694;554.1815,599.9851;Inherit;False;Toon_DistanceFog;64;;1213;87a2c17086d6be546a10c470a8adefc0;0;2;19;COLOR;0,0,0,0;False;111;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1235.039,159.1722;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Parasol/SimpleStandard_shader;False;False;False;False;False;False;False;True;True;False;False;False;False;False;False;False;True;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;4;d3d11;glcore;gles3;metal;True;True;True;True;0;False;-1;True;1;False;-1;255;False;-1;255;False;-1;6;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;1;LightMode=Meta;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;82;0;83;0
WireConnection;82;1;178;0
WireConnection;1161;0;1159;0
WireConnection;1161;1;1160;0
WireConnection;80;0;82;0
WireConnection;80;1;1161;0
WireConnection;310;4;80;0
WireConnection;313;0;310;0
WireConnection;648;3;80;0
WireConnection;1698;5;80;0
WireConnection;1360;0;80;0
WireConnection;1360;1;1361;0
WireConnection;218;0;648;0
WireConnection;1564;6;1698;0
WireConnection;1564;7;314;0
WireConnection;1689;8;1360;0
WireConnection;214;0;1682;0
WireConnection;211;0;1564;0
WireConnection;219;0;1689;0
WireConnection;1153;0;1698;17
WireConnection;1678;34;1561;0
WireConnection;1678;31;214;0
WireConnection;1678;30;1682;7
WireConnection;1541;0;1678;0
WireConnection;1491;10;212;0
WireConnection;1491;11;222;0
WireConnection;1491;12;221;0
WireConnection;1491;15;220;0
WireConnection;1491;17;1154;0
WireConnection;1671;15;1491;135
WireConnection;1229;1;1586;0
WireConnection;1229;0;1545;0
WireConnection;1679;1;215;0
WireConnection;1679;2;1217;0
WireConnection;1694;19;1671;0
WireConnection;0;0;1582;0
WireConnection;0;2;1679;0
WireConnection;0;13;1694;0
ASEEND*/
//CHKSM=F03B2591021DF41F1DC88449E47E59CE19B741B6