// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Parasol/SimpleStandardStylizedReflection_shader"
{
	Properties
	{
		[Header(Stylized Reflection)][Toggle(_STYLIZEDREFLECTION_ON)] _StylizedReflection("Stylized Reflection", Float) = 1
		_Reflectivity("Stylized Reflectivity", Range( 0 , 4)) = 1
		_ReflectionAngleScaler("Reflection Angle Scaler", Range( -10 , 10)) = 1
		_MixWithRealReflections("Blend Real Reflections", Range( 0 , 1)) = 0
		_FalloffMin("Falloff Min", Range( 0 , 1)) = 0
		_FalloffMax("Falloff Max", Range( 0 , 1)) = 1
		_StylizedShadowIntensity("Stylized Shadow Intensity", Range( 0 , 1)) = 0.2
		[Header(Tiling)]_TextureTilingU("Texture Tiling U", Float) = 1
		_TextureTilingV("Texture Tiling V", Float) = 1
		[Gamma][NoScaleOffset][Header(Base Color)]_BaseColor("Base Color", 2D) = "white" {}
		_DiffuseIntensity("Diffuse Intensity", Range( 0 , 1)) = 1
		[Gamma][NoScaleOffset]_TintMask("Tint Mask", 2D) = "white" {}
		[Gamma]_ColorTint("Base Color Tint", Color) = (1,1,1,0)
		[Enum(Material,0,Vertex,1)]_UseVertexColorforTint("Tint Color Source", Int) = 0
		[Header(Vertex AO)]_VertexAOMinimumValue("Vertex AO Minimum Value", Range( 0 , 1)) = 1
		_ToggleDiffuse("Blend Diffuse", Range( 0 , 1)) = 0
		_ToggleDiffuse1("SkyColorTop_Intensity", Range( 0 , 5)) = 1
		_ToggleDiffuse2("SkyColorBottom_Intensity", Range( 0 , 5)) = 1
		[NoScaleOffset][Header(Normal)]_Normal("Normal", 2D) = "bump" {}
		_NormalScale("Normal Scale", Range( 0 , 1)) = 1
		[NoScaleOffset][Header(Metallic)]_MetallicMask("Metallic Mask", 2D) = "black" {}
		_IncreaseMetalness("Increase Metalness", Range( 0 , 1)) = 0
		[NoScaleOffset][Header(Roughness)]_RMAO("Roughness", 2D) = "white" {}
		_RoughnessCeiling("Roughness Ceiling", Range( 0 , 1)) = 1
		_RoughnessFloor("Roughness Floor", Range( 0 , 1)) = 0
		_RoughnessContrast("Roughness Contrast", Range( 0 , 10)) = 1
		[HDR][Header(Emission)]_EmissionColor("Emission Color", Color) = (0.8867924,0.8867924,0.8867924,0)
		[HDR][Header(Emission)]_EmissionCompliment("Emission Compliment", Color) = (1,1,1,0)
		_HueMin("Hue Min", Range( -5 , 5)) = 0
		_HueMax("Hue Max", Range( -5 , 5)) = 1
		[NoScaleOffset]_EmissionTexture("Emission Texture", 2D) = "white" {}
		_DaytimeEmissiveValue("Daytime Emissive Value", Range( 0 , 1)) = 0
		[Header(Light Baking Emissive Overrrides)][Toggle(_OVERRIDEDAYCOLOR_ON)] _OverrideDayColor("OverrideDayColor", Float) = 0
		[HDR]_BakedEmissionColorDay("Baked Emission Color Day", Color) = (0.4622642,0.4622642,0.4622642,0)
		_BakedEmissiveIntensityDay("Baked Emissive Intensity Day", Range( 0 , 2)) = 1
		[Toggle(_OVERRIDENIGHTCOLOR_ON)] _OverrideNightColor("OverrideNightColor", Float) = 0
		[HDR]_BakedEmissionColorNight("Baked Emission Color Night", Color) = (1,0.8169013,0,0)
		_BakedEmissiveIntensityNight("Baked Emissive Intensity Night", Range( 0 , 2)) = 1
		[HDR][Header(Uplight Effect)]_UplightLightColor("Uplight Light Color", Color) = (1,0.9923881,0.5566038,0)
		_TreeLightOn("Uplight Light Brightness", Range( 0 , 1)) = 1
		[Enum(Emissive,0,Uplight,1,Add,2,Max,3)]_EmissiveType("Emissive Blend Type", Int) = 0
		_TopLightHeight("Uplight End Height", Range( -10 , 100)) = 4
		_TopLightFalloff("Uplight End Falloff", Range( -10 , 10)) = 0.6897392
		_BotLightHeight("Uplight Start Height", Range( -10 , 100)) = 0
		_BotFalloff("Uplight Start Falloff", Range( -10 , 10)) = 1
		[Enum(Normal,0,Inverted,1)]_FlipYNormal("Y Normal Direction", Range( 0 , 1)) = 1
		[Toggle(_FLIPLIGHTDIRECTION_ON)] _FlipLightDirection("Flip Light Direction", Float) = 0
		[Header(Per Pixel Fog Controls)]_PerPixelFogAmount("Per Pixel Fog Amount", Range( 0 , 1)) = 1
		[Enum(Straight,0,Screen,1,Add,2,Multiply,3,Overlay,4,Hard Light,5)][Header(Photoshop Blend Modes)]_Mode("Mode", Int) = 0
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
		#pragma shader_feature_local _STYLIZEDREFLECTION_ON
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
			float3 worldPos;
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldRefl;
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

		uniform float4 g_SkyColorTop;
		uniform float _ToggleDiffuse1;
		uniform float4 g_SkyColorBottom;
		uniform float _ToggleDiffuse2;
		uniform sampler2D _BaseColor;
		uniform float _TextureTilingU;
		uniform float _TextureTilingV;
		uniform float _DiffuseIntensity;
		uniform float4 _ColorTint;
		uniform int _UseVertexColorforTint;
		uniform sampler2D _TintMask;
		SamplerState sampler_TintMask;
		uniform float _ToggleDiffuse;
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
		uniform sampler2D _MetallicMask;
		SamplerState sampler_MetallicMask;
		uniform float _IncreaseMetalness;
		uniform float _RoughnessContrast;
		uniform sampler2D _RMAO;
		uniform float _RoughnessFloor;
		uniform float _RoughnessCeiling;
		uniform float _VertexAOMinimumValue;
		uniform float _ReflectionAngleScaler;
		uniform float _FalloffMin;
		uniform float _FalloffMax;
		uniform float _Reflectivity;
		uniform float _MixWithRealReflections;
		uniform float _StylizedShadowIntensity;
		uniform int LUTSize;
		uniform sampler2D SecondLUT;
		uniform sampler2D fog_texture;
		uniform float fog_start;
		uniform float fog_end;
		uniform float fog_spread;
		uniform float fog_height;
		uniform float FogHeightDensity;
		uniform float _PerPixelFogAmount;


		float4 MyCustomExpression2_g392( int ScenarioIndex, float4 RuntimeLighting, float4 LightBakeDay, float4 LightBakeNight )
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


		float4 MyCustomExpression28_g1184( float4 Uplight, float4 Emissive, int Type )
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


		float4 MyCustomExpression8_g1189( int Mode, float4 Straight, float4 Overlay, float4 Hardlight, float4 Screen, float4 Add, float4 Multiply )
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

		inline float4 UnityActiveReflectionProbewithRoughness108_g1185( float3 ReflectionVector, float Roughness )
		{
			return UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, ReflectionVector, Roughness * UNITY_SPECCUBE_LOD_STEPS);
		}


		inline float4 FeatureSwitch( float TestVal, float4 FeatureOn, float4 FeatureOff )
		{
			return TestVal>0?FeatureOn:FeatureOff;;
		}


		float MyCustomExpression8_g1187( float fogStart, float fogEnd, float SurfaceDepth )
		{
			return saturate((SurfaceDepth-fogStart)/(fogEnd-fogStart));
		}


		float MyCustomExpression232_g1187( float fogStart, float fogEnd, float SurfaceDepth )
		{
			return saturate((SurfaceDepth-fogStart)/(fogEnd-fogStart));
		}


		float MyCustomExpression233_g1187( float fogStart, float fogEnd, float SurfaceDepth )
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
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float TestVal194_g1187 = sg_ToonFog;
			float TestVal103_g1186 = sg_ColorLut;
			SurfaceOutputStandard s9_g396 = (SurfaceOutputStandard ) 0;
			float3 ase_worldPos = i.worldPos;
			float4 lerpResult178 = lerp( ( g_SkyColorTop * _ToggleDiffuse1 ) , ( g_SkyColorBottom * _ToggleDiffuse2 ) , saturate( (0.0 + (ase_worldPos.y - 0.0) * (1.0 - 0.0) / (200.0 - 0.0)) ));
			float2 appendResult363 = (float2(_TextureTilingU , _TextureTilingV));
			float2 uv_TexCoord364 = i.uv_texcoord * appendResult363;
			float4 lerpResult3_g393 = lerp( float4(1,1,1,0) , tex2D( _BaseColor, uv_TexCoord364 ) , _DiffuseIntensity);
			float4 lerpResult15_g393 = lerp( _ColorTint , i.vertexColor , (float)_UseVertexColorforTint);
			float2 uv_TintMask13_g393 = i.uv_texcoord;
			float4 lerpResult29_g393 = lerp( lerpResult3_g393 , ( lerpResult3_g393 * lerpResult15_g393 ) , tex2D( _TintMask, uv_TintMask13_g393 ).r);
			float4 lerpResult371 = lerp( lerpResult178 , lerpResult29_g393 , _ToggleDiffuse);
			s9_g396.Albedo = lerpResult371.rgb;
			float3 temp_output_282_0 = UnpackScaleNormal( tex2D( _Normal, uv_TexCoord364 ), _NormalScale );
			float3 SurfaceNormal286 = temp_output_282_0;
			float4 temp_output_11_0_g396 = float4( SurfaceNormal286 , 0.0 );
			s9_g396.Normal = WorldNormalVector( i , temp_output_11_0_g396.rgb );
			s9_g396.Emission = float4( 0,0,0,0 ).rgb;
			float SurfaceMetalic304 = (_IncreaseMetalness + (tex2D( _MetallicMask, uv_TexCoord364 ).r - 0.0) * (1.0 - _IncreaseMetalness) / (1.0 - 0.0));
			s9_g396.Metallic = SurfaceMetalic304;
			float SurfaceRoughness288 = (_RoughnessFloor + (saturate( (CalculateContrast(_RoughnessContrast,tex2D( _RMAO, uv_TexCoord364 ))).r ) - 0.0) * (_RoughnessCeiling - _RoughnessFloor) / (1.0 - 0.0));
			s9_g396.Smoothness = ( 1.0 - SurfaceRoughness288 );
			float lerpResult24_g393 = lerp( i.vertexColor.a , 1.0 , _VertexAOMinimumValue);
			s9_g396.Occlusion = lerpResult24_g393;

			data.light = gi.light;

			UnityGI gi9_g396 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g9_g396 = UnityGlossyEnvironmentSetup( s9_g396.Smoothness, data.worldViewDir, s9_g396.Normal, float3(0,0,0));
			gi9_g396 = UnityGlobalIllumination( data, s9_g396.Occlusion, s9_g396.Normal, g9_g396 );
			#endif

			float3 surfResult9_g396 = LightingStandard ( s9_g396, viewDir, gi9_g396 ).rgb;
			surfResult9_g396 += s9_g396.Emission;

			#ifdef UNITY_PASS_FORWARDADD//9_g396
			surfResult9_g396 -= s9_g396.Emission;
			#endif//9_g396
			float4 temp_output_67_0_g1185 = float4( surfResult9_g396 , 0.0 );
			float4 temp_output_57_0_g1185 = lerpResult371;
			float3 temp_output_56_0_g1185 = SurfaceNormal286;
			float3 newWorldReflection30_g1185 = normalize( WorldReflectionVector( i , temp_output_56_0_g1185 ) );
			float3 appendResult35_g1185 = (float3(( newWorldReflection30_g1185.x * _ReflectionAngleScaler ) , sqrt( ( pow( newWorldReflection30_g1185.x , 2.0 ) + pow( newWorldReflection30_g1185.z , 2.0 ) ) ) , ( newWorldReflection30_g1185.z * _ReflectionAngleScaler )));
			float3 DistortedUVs90_g1185 = appendResult35_g1185;
			float3 ReflectionVector108_g1185 = DistortedUVs90_g1185;
			float Roughness108_g1185 = SurfaceRoughness288;
			float4 localUnityActiveReflectionProbewithRoughness108_g1185 = UnityActiveReflectionProbewithRoughness108_g1185( ReflectionVector108_g1185 , Roughness108_g1185 );
			float WorldReflectionY93_g1185 = newWorldReflection30_g1185.y;
			float smoothstepResult104_g1185 = smoothstep( _FalloffMin , _FalloffMax , abs( WorldReflectionY93_g1185 ));
			float4 lerpResult50_g1185 = lerp( temp_output_57_0_g1185 , localUnityActiveReflectionProbewithRoughness108_g1185 , smoothstepResult104_g1185);
			float4 tex2DNode2_g391 = tex2D( _EmissionTexture, uv_TexCoord364 );
			int ScenarioIndex2_g392 = LightBakeScenario;
			float smoothstepResult73_g391 = smoothstep( _HueMin , _HueMax , tex2DNode2_g391.r);
			float4 lerpResult70_g391 = lerp( _EmissionColor , ( _EmissionColor * _EmissionCompliment ) , saturate( smoothstepResult73_g391 ));
			float4 InputColor15_g392 = lerpResult70_g391;
			float4 RuntimeLighting2_g392 = InputColor15_g392;
			#ifdef _OVERRIDEDAYCOLOR_ON
				float4 staticSwitch13_g392 = _BakedEmissionColorDay;
			#else
				float4 staticSwitch13_g392 = InputColor15_g392;
			#endif
			float lerpResult24_g391 = lerp( _DaytimeEmissiveValue , 1.0 , EmissiveGradient);
			#ifdef _OVERRIDEDAYCOLOR_ON
				float staticSwitch20_g392 = _BakedEmissiveIntensityDay;
			#else
				float staticSwitch20_g392 = lerpResult24_g391;
			#endif
			float4 LightBakeDay2_g392 = ( staticSwitch13_g392 * staticSwitch20_g392 );
			#ifdef _OVERRIDENIGHTCOLOR_ON
				float4 staticSwitch14_g392 = _BakedEmissionColorNight;
			#else
				float4 staticSwitch14_g392 = InputColor15_g392;
			#endif
			float4 LightBakeNight2_g392 = ( staticSwitch14_g392 * _BakedEmissiveIntensityNight );
			float4 localMyCustomExpression2_g392 = MyCustomExpression2_g392( ScenarioIndex2_g392 , RuntimeLighting2_g392 , LightBakeDay2_g392 , LightBakeNight2_g392 );
			float4 SurfaceEmissive294 = ( tex2DNode2_g391 * localMyCustomExpression2_g392 * lerpResult24_g391 );
			float grayscale51_g1185 = Luminance(SurfaceEmissive294.xyz);
			float4 lerpResult52_g1185 = lerp( lerpResult50_g1185 , float4( 0,0,0,0 ) , grayscale51_g1185);
			float4 lerpResult84_g1185 = lerp( temp_output_57_0_g1185 , lerpResult52_g1185 , _Reflectivity);
			float lerpResult122_g1185 = lerp( _MixWithRealReflections , 0.0 , EmissiveGradient);
			float4 lerpResult98_g1185 = lerp( lerpResult84_g1185 , saturate( ( temp_output_67_0_g1185 + lerpResult84_g1185 ) ) , lerpResult122_g1185);
			float lerpResult119_g1185 = lerp( _StylizedShadowIntensity , 0.0 , EmissiveGradient);
			float lerpResult114_g1185 = lerp( 1.0 , ase_lightAtten , lerpResult119_g1185);
			#ifdef _STYLIZEDREFLECTION_ON
				float4 staticSwitch66_g1185 = ( lerpResult98_g1185 * lerpResult114_g1185 );
			#else
				float4 staticSwitch66_g1185 = temp_output_67_0_g1185;
			#endif
			float3 inputColor100_g1186 = staticSwitch66_g1185.xyz;
			float ifLocalVar202_g1186 = 0;
			if( LUTSize <= 2 )
				ifLocalVar202_g1186 = (float)32;
			else
				ifLocalVar202_g1186 = (float)LUTSize;
			float lutDim14_g1186 = ifLocalVar202_g1186;
			float temp_output_196_0_g1186 = ( 1.0 / lutDim14_g1186 );
			float3 temp_cast_40 = (temp_output_196_0_g1186).xxx;
			float3 temp_cast_41 = (( 1.0 - temp_output_196_0_g1186 )).xxx;
			float3 clampResult170_g1186 = clamp( inputColor100_g1186 , temp_cast_40 , temp_cast_41 );
			float3 break2_g1186 = clampResult170_g1186;
			float Red_U81_g1186 = ( break2_g1186.x / lutDim14_g1186 );
			float temp_output_3_0_g1186 = ( break2_g1186.z * lutDim14_g1186 );
			float Green_V75_g1186 = break2_g1186.y;
			float2 appendResult7_g1186 = (float2(( Red_U81_g1186 + ( ceil( temp_output_3_0_g1186 ) / lutDim14_g1186 ) ) , Green_V75_g1186));
			float2 temp_output_183_0_g1186 = saturate( appendResult7_g1186 );
			float4 tex2DNode9_g1186 = tex2Dlod( StandardLUT, float4( temp_output_183_0_g1186, 0, 0.0) );
			float4 tex2DNode88_g1186 = tex2Dlod( SecondLUT, float4( temp_output_183_0_g1186, 0, 0.0) );
			float temp_output_182_0_g1186 = saturate( EmissiveGradient );
			float4 lerpResult95_g1186 = lerp( tex2DNode9_g1186 , tex2DNode88_g1186 , temp_output_182_0_g1186);
			float4 FeatureOn103_g1186 = lerpResult95_g1186;
			float4 FeatureOff103_g1186 = float4( inputColor100_g1186 , 0.0 );
			float4 localFeatureSwitch103_g1186 = FeatureSwitch( TestVal103_g1186 , FeatureOn103_g1186 , FeatureOff103_g1186 );
			float4 temp_output_19_0_g1187 = localFeatureSwitch103_g1186;
			float fogStart8_g1187 = fog_start;
			float fogEnd8_g1187 = fog_end;
			float SurfaceDepth8_g1187 = i.eyeDepth;
			float localMyCustomExpression8_g1187 = MyCustomExpression8_g1187( fogStart8_g1187 , fogEnd8_g1187 , SurfaceDepth8_g1187 );
			float fogStart232_g1187 = 0.0;
			float fogEnd232_g1187 = fog_spread;
			float SurfaceDepth232_g1187 = ase_worldPos.y;
			float localMyCustomExpression232_g1187 = MyCustomExpression232_g1187( fogStart232_g1187 , fogEnd232_g1187 , SurfaceDepth232_g1187 );
			float2 appendResult89_g1187 = (float2(localMyCustomExpression8_g1187 , localMyCustomExpression232_g1187));
			float4 fogInputs224_g1187 = tex2D( fog_texture, appendResult89_g1187 );
			float4 temp_output_111_0_g1187 = fogInputs224_g1187;
			float4 clampResult165_g1187 = clamp( ( temp_output_19_0_g1187 + temp_output_111_0_g1187 ) , float4( 0,0,0,0 ) , temp_output_111_0_g1187 );
			float fogStart233_g1187 = fog_spread;
			float fogEnd233_g1187 = fog_height;
			float SurfaceDepth233_g1187 = ase_worldPos.y;
			float localMyCustomExpression233_g1187 = MyCustomExpression233_g1187( fogStart233_g1187 , fogEnd233_g1187 , SurfaceDepth233_g1187 );
			float distanceGradiant226_g1187 = saturate( ( localMyCustomExpression8_g1187 * (localMyCustomExpression233_g1187*FogHeightDensity + 0.0) ) );
			float4 lerpResult195_g1187 = lerp( temp_output_19_0_g1187 , clampResult165_g1187 , ( distanceGradiant226_g1187 * _PerPixelFogAmount ));
			float4 FeatureOn194_g1187 = lerpResult195_g1187;
			float4 FeatureOff194_g1187 = temp_output_19_0_g1187;
			float4 localFeatureSwitch194_g1187 = FeatureSwitch( TestVal194_g1187 , FeatureOn194_g1187 , FeatureOff194_g1187 );
			c.rgb = localFeatureSwitch194_g1187.xyz;
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
			float3 ase_worldPos = i.worldPos;
			float4 lerpResult178 = lerp( ( g_SkyColorTop * _ToggleDiffuse1 ) , ( g_SkyColorBottom * _ToggleDiffuse2 ) , saturate( (0.0 + (ase_worldPos.y - 0.0) * (1.0 - 0.0) / (200.0 - 0.0)) ));
			float2 appendResult363 = (float2(_TextureTilingU , _TextureTilingV));
			float2 uv_TexCoord364 = i.uv_texcoord * appendResult363;
			float4 lerpResult3_g393 = lerp( float4(1,1,1,0) , tex2D( _BaseColor, uv_TexCoord364 ) , _DiffuseIntensity);
			float4 lerpResult15_g393 = lerp( _ColorTint , i.vertexColor , (float)_UseVertexColorforTint);
			float2 uv_TintMask13_g393 = i.uv_texcoord;
			float4 lerpResult29_g393 = lerp( lerpResult3_g393 , ( lerpResult3_g393 * lerpResult15_g393 ) , tex2D( _TintMask, uv_TintMask13_g393 ).r);
			float4 lerpResult371 = lerp( lerpResult178 , lerpResult29_g393 , _ToggleDiffuse);
			float4 temp_output_508_0 = lerpResult371;
			o.Albedo = temp_output_508_0.rgb;
			int Mode8_g1189 = _Mode;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float temp_output_18_0_g1184 = ( saturate( ( ( _TopLightHeight - ase_vertex3Pos.y ) / ( _TopLightHeight - _TopLightFalloff ) ) ) * saturate( ( ( ase_vertex3Pos.y - _BotLightHeight ) / ( _BotLightHeight + _BotFalloff ) ) ) );
			#ifdef _FLIPLIGHTDIRECTION_ON
				float staticSwitch41_g1184 = ( 1.0 - temp_output_18_0_g1184 );
			#else
				float staticSwitch41_g1184 = temp_output_18_0_g1184;
			#endif
			float3 temp_output_282_0 = UnpackScaleNormal( tex2D( _Normal, uv_TexCoord364 ), _NormalScale );
			float3 normalVector565 = temp_output_282_0;
			float3 newWorldNormal16_g1184 = (WorldNormalVector( i , normalVector565 ));
			float lerpResult22_g1184 = lerp( newWorldNormal16_g1184.y , ( 1.0 - newWorldNormal16_g1184.y ) , _FlipYNormal);
			float temp_output_563_7 = EmissiveGradient;
			float4 Uplight28_g1184 = ( _UplightLightColor * ( saturate( staticSwitch41_g1184 ) * _TreeLightOn * lerpResult22_g1184 ) * temp_output_563_7 );
			float4 tex2DNode2_g391 = tex2D( _EmissionTexture, uv_TexCoord364 );
			int ScenarioIndex2_g392 = LightBakeScenario;
			float smoothstepResult73_g391 = smoothstep( _HueMin , _HueMax , tex2DNode2_g391.r);
			float4 lerpResult70_g391 = lerp( _EmissionColor , ( _EmissionColor * _EmissionCompliment ) , saturate( smoothstepResult73_g391 ));
			float4 InputColor15_g392 = lerpResult70_g391;
			float4 RuntimeLighting2_g392 = InputColor15_g392;
			#ifdef _OVERRIDEDAYCOLOR_ON
				float4 staticSwitch13_g392 = _BakedEmissionColorDay;
			#else
				float4 staticSwitch13_g392 = InputColor15_g392;
			#endif
			float lerpResult24_g391 = lerp( _DaytimeEmissiveValue , 1.0 , EmissiveGradient);
			#ifdef _OVERRIDEDAYCOLOR_ON
				float staticSwitch20_g392 = _BakedEmissiveIntensityDay;
			#else
				float staticSwitch20_g392 = lerpResult24_g391;
			#endif
			float4 LightBakeDay2_g392 = ( staticSwitch13_g392 * staticSwitch20_g392 );
			#ifdef _OVERRIDENIGHTCOLOR_ON
				float4 staticSwitch14_g392 = _BakedEmissionColorNight;
			#else
				float4 staticSwitch14_g392 = InputColor15_g392;
			#endif
			float4 LightBakeNight2_g392 = ( staticSwitch14_g392 * _BakedEmissiveIntensityNight );
			float4 localMyCustomExpression2_g392 = MyCustomExpression2_g392( ScenarioIndex2_g392 , RuntimeLighting2_g392 , LightBakeDay2_g392 , LightBakeNight2_g392 );
			float4 SurfaceEmissive294 = ( tex2DNode2_g391 * localMyCustomExpression2_g392 * lerpResult24_g391 );
			float4 Emissive28_g1184 = SurfaceEmissive294;
			int Type28_g1184 = _EmissiveType;
			float4 localMyCustomExpression28_g1184 = MyCustomExpression28_g1184( Uplight28_g1184 , Emissive28_g1184 , Type28_g1184 );
			float4 UplitEmissiveColor567 = localMyCustomExpression28_g1184;
			float4 Top9_g1189 = UplitEmissiveColor567;
			float4 Straight8_g1189 = Top9_g1189;
			float4 Bottom10_g1189 = SurfaceEmissive294;
			float temp_output_22_0_g1189 = 0.5;
			float4 temp_cast_8 = (temp_output_22_0_g1189).xxxx;
			float4 temp_output_19_0_g1189 = ( 1.0 - ( ( 1.0 - Bottom10_g1189 ) * ( 1.0 - Top9_g1189 ) * 2 ) );
			float4 Overlay8_g1189 =  ( Bottom10_g1189 - 0.0 > temp_cast_8 ? temp_output_19_0_g1189 : Bottom10_g1189 - 0.0 <= temp_cast_8 && Bottom10_g1189 + 0.0 >= temp_cast_8 ? temp_output_19_0_g1189 : ( Top9_g1189 * Bottom10_g1189 * 2 ) ) ;
			float4 temp_cast_13 = (temp_output_22_0_g1189).xxxx;
			float4 temp_output_30_0_g1189 = ( Top9_g1189 * Bottom10_g1189 * 2 );
			float4 Hardlight8_g1189 =  ( Bottom10_g1189 - 0.0 > temp_cast_13 ? temp_output_30_0_g1189 : Bottom10_g1189 - 0.0 <= temp_cast_13 && Bottom10_g1189 + 0.0 >= temp_cast_13 ? temp_output_30_0_g1189 : ( 1.0 - ( ( 1.0 - Bottom10_g1189 ) * ( 1.0 - Top9_g1189 ) * 2 ) ) ) ;
			float4 Screen8_g1189 = ( 1.0 - ( ( 1.0 - Bottom10_g1189 ) * ( 1.0 - Top9_g1189 ) ) );
			float4 Add8_g1189 = ( Top9_g1189 + Bottom10_g1189 );
			float4 Multiply8_g1189 = ( Top9_g1189 * Bottom10_g1189 );
			float4 localMyCustomExpression8_g1189 = MyCustomExpression8_g1189( Mode8_g1189 , Straight8_g1189 , Overlay8_g1189 , Hardlight8_g1189 , Screen8_g1189 , Add8_g1189 , Multiply8_g1189 );
			o.Emission = saturate( localMyCustomExpression8_g1189 ).xyz;
		}

		ENDCG
		CGPROGRAM
		#pragma only_renderers d3d11 glcore gles3 metal 
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows exclude_path:deferred nodynlightmap nodirlightmap noforwardadd vertex:vertexDataFunc 

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
				float3 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
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
				o.customPack1.z = customInputData.eyeDepth;
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
				surfIN.eyeDepth = IN.customPack1.z;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.worldRefl = -worldViewDir;
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
2569.333;36;2472;1304;623.9415;1038.725;1.770706;True;False
Node;AmplifyShaderEditor.CommentaryNode;360;40.87161,330.2019;Inherit;False;508.6409;218.6585;;4;364;363;362;361;Tiling Controller;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;548;193.233,-558.6321;Inherit;False;476;247;New;2;545;543;;0,0.5200343,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;547;-34.65971,-263.4418;Inherit;False;603.2332;223.8498;New;2;546;544;;0,0.5200343,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;362;51.70557,386.4022;Inherit;False;Property;_TextureTilingU;Texture Tiling U;15;0;Create;True;0;0;False;1;Header(Tiling);False;1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;361;53.60657,462.4438;Inherit;False;Property;_TextureTilingV;Texture Tiling V;16;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;189;-47.37991,48.4166;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;546;12.02127,-132.3589;Inherit;False;Property;_ToggleDiffuse2;SkyColorBottom_Intensity;26;0;Create;False;0;0;False;0;False;1;3.28;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;451;240.799,94.76628;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;200;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;363;226.8426,409.3695;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;545;243.233,-427.6321;Inherit;False;Property;_ToggleDiffuse1;SkyColorTop_Intensity;25;0;Create;False;0;0;False;0;False;1;2.43;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;174;-302.4948,-506.7494;Inherit;False;Global;g_SkyColorTop;g_SkyColorTop;35;0;Create;True;0;0;False;0;False;0.3027768,0.764151,0.6652851,0;0.259434,0.5542889,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;179;-299.6986,-225.9195;Inherit;False;Global;g_SkyColorBottom;g_SkyColorBottom;29;0;Create;True;0;0;False;0;False;0.49288,0.735849,0.6534659,0;0.8308345,0.8766645,0.9691483,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;364;349.2497,387.4396;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;544;386.6593,-218.4204;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;450;480.6375,-29.16776;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;543;507.233,-508.6321;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;282;784.5981,245.4034;Inherit;False;Parasol_Normal_SF;28;;339;c1afb3f5e736a1b44ba607c69344914d;0;1;3;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;488;529.4171,149.8632;Inherit;False;Property;_ToggleDiffuse;Blend Diffuse;24;0;Create;False;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;563;881.6819,645.3204;Inherit;False;Parasol_Emission_SF;39;;391;98a5bb71709445248bf940bbe0a18586;0;1;1;FLOAT2;0,0;False;2;FLOAT;7;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;534;619.1666,23.06411;Inherit;False;Parasol_BaseColor_SF;17;;393;449e373bc45bd994189f3f52b3d88f45;0;1;5;FLOAT2;0,0;False;2;COLOR;0;FLOAT;17
Node;AmplifyShaderEditor.LerpOp;178;782.0042,-241.6113;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;571;1442.092,-318.7487;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;348;821.968,461.2672;Inherit;False;Parasol_Metallic_SF;31;;395;ea0886127b2db2e4d86d4f18d4d302b3;0;1;4;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;294;1454.805,715.2514;Inherit;False;SurfaceEmissive;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;371;1004.318,44.74986;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;532;827.1951,350.0139;Inherit;False;Parasol_Roughness_SF;34;;394;bf68fe7a0dbe8c14686bde4c8c387417;0;1;8;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;530;985.4388,189.645;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;565;1845.597,-440.4998;Inherit;False;normalVector;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwitchNode;432;1367.217,-11.6785;Inherit;False;1;2;8;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;572;1786.137,-219.494;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;304;1103.637,504.7134;Inherit;False;SurfaceMetalic;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;529;1434.467,154.6558;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;564;1829.165,-627.8751;Inherit;False;294;SurfaceEmissive;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;288;1192.893,375.9481;Inherit;False;SurfaceRoughness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;286;1234.462,204.4421;Inherit;False;SurfaceNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RelayNode;508;2006.512,-14.18486;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;566;2347.998,-431.2186;Inherit;False;Simple_Uplight_SF;58;;1184;99f37951fd0088745980292981a2025b;0;3;34;FLOAT3;0,0,0;False;31;COLOR;0,0,0,0;False;30;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;515;1783.77,408.5229;Inherit;False;288;SurfaceRoughness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;446;1787.885,188.669;Inherit;False;ParasolCustomLighting;0;;396;dd582d5258e33374fbbbd0bc1271698d;1,136,0;6;10;COLOR;0.5019608,0.5019608,0.5019608,0;False;11;COLOR;0.5019608,0.5019608,1,1;False;12;FLOAT;1;False;15;FLOAT;0;False;16;COLOR;0,0,0,0;False;17;FLOAT;1;False;3;FLOAT3;147;FLOAT3;135;COLOR;112
Node;AmplifyShaderEditor.FunctionNode;559;2205.813,182.6382;Inherit;False;StylizedReflection;4;;1185;344f04f6dd8b6604eb2fcb92a11fb89f;0;5;67;FLOAT4;0.5,0.5,0.5,1;False;57;FLOAT4;0.5,0.5,0.5,1;False;56;FLOAT3;0.5,0.5,1;False;55;FLOAT;0;False;59;FLOAT4;0,0,0,0;False;2;FLOAT4;0;FLOAT;103
Node;AmplifyShaderEditor.RegisterLocalVarNode;567;2784.959,-430.9613;Inherit;False;UplitEmissiveColor;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;568;2311.003,-740.6451;Inherit;False;567;UplitEmissiveColor;1;0;OBJECT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;509;2715.164,176.8255;Inherit;False;ParasolGlobalLut_;12;;1186;415cf2c404453934193ab734c391e132;0;1;15;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;141;-3254.908,212.3729;Inherit;False;663.7299;227.9639;;3;83;82;80;Tiling Controller;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;83;-3204.908,302.162;Inherit;False;Property;_TextureTiling;Texture Tiling;27;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;337;1463.286,834.774;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;569;2632.13,-649.4571;Inherit;False;PhotoshopStyleBlendModes_SF;71;;1189;355eea3733479f34187920a3d7ed4e48;0;3;1;FLOAT4;1,0.7098039,0.4352942,0;False;2;COLOR;0.2196079,0.2196079,0.2196079,0;False;22;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;82;-3026.377,307.3368;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;459;3007.742,177.6028;Inherit;False;Toon_DistanceFog;68;;1187;87a2c17086d6be546a10c470a8adefc0;0;2;19;COLOR;0,0,0,0;False;111;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;80;-2854.511,262.3729;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;338;1769.981,742.3832;Inherit;False;InverseEmissiveGradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;320;1826.719,-150.7763;Inherit;False;SurfaceDiffuse;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3429.871,-12.21671;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Parasol/SimpleStandardStylizedReflection_shader;False;False;False;False;False;False;False;True;True;False;False;True;False;False;False;False;True;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;4;d3d11;glcore;gles3;metal;True;True;True;True;0;False;-1;True;1;False;-1;255;False;-1;255;False;-1;6;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;1;LightMode=Meta;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;549;2155.813,132.6382;Inherit;False;499;257;New Functionality Inside Here;0;;0,0.5200343,1,1;0;0
WireConnection;451;0;189;2
WireConnection;363;0;362;0
WireConnection;363;1;361;0
WireConnection;364;0;363;0
WireConnection;544;0;179;0
WireConnection;544;1;546;0
WireConnection;450;0;451;0
WireConnection;543;0;174;0
WireConnection;543;1;545;0
WireConnection;282;3;364;0
WireConnection;563;1;364;0
WireConnection;534;5;364;0
WireConnection;178;0;543;0
WireConnection;178;1;544;0
WireConnection;178;2;450;0
WireConnection;571;0;282;0
WireConnection;348;4;364;0
WireConnection;294;0;563;0
WireConnection;371;0;178;0
WireConnection;371;1;534;0
WireConnection;371;2;488;0
WireConnection;532;8;364;0
WireConnection;530;0;534;17
WireConnection;565;0;571;0
WireConnection;432;0;178;0
WireConnection;432;1;371;0
WireConnection;572;0;563;7
WireConnection;304;0;348;0
WireConnection;529;0;530;0
WireConnection;288;0;532;0
WireConnection;286;0;282;0
WireConnection;508;0;432;0
WireConnection;566;34;565;0
WireConnection;566;31;564;0
WireConnection;566;30;572;0
WireConnection;446;10;432;0
WireConnection;446;11;286;0
WireConnection;446;12;288;0
WireConnection;446;15;304;0
WireConnection;446;17;529;0
WireConnection;559;67;446;135
WireConnection;559;57;508;0
WireConnection;559;56;286;0
WireConnection;559;55;515;0
WireConnection;559;59;294;0
WireConnection;567;0;566;0
WireConnection;509;15;559;0
WireConnection;337;0;563;7
WireConnection;569;1;568;0
WireConnection;569;2;564;0
WireConnection;82;0;83;0
WireConnection;82;1;83;0
WireConnection;459;19;509;0
WireConnection;80;0;82;0
WireConnection;338;0;337;0
WireConnection;320;0;432;0
WireConnection;0;0;508;0
WireConnection;0;2;569;0
WireConnection;0;13;459;0
ASEEND*/
//CHKSM=44E4BAA9F2F196B409753BE6C96ED42E073E43FF