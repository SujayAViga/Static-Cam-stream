// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Parasol/SimpleStandard(AlphaTest)_shader"
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
		[NoScaleOffset][Header(Metallic)]_MetallicMask("Metallic Mask", 2D) = "black" {}
		_IncreaseMetalness("Increase Metalness", Range( 0 , 1)) = 0
		[NoScaleOffset][Header(Alpha)]_Alpha("Alpha", 2D) = "white" {}
		[NoScaleOffset][Header(Normal)]_Normal("Normal", 2D) = "bump" {}
		_NormalScale("Normal Scale", Range( 0 , 1)) = 1
		[Enum(Off,0,On,1)]_AlphaToCoverage("Alpha To Coverage", Int) = 0
		[NoScaleOffset][Header(Roughness)]_RMAO("Roughness", 2D) = "white" {}
		_RoughnessCeiling("Roughness Ceiling", Range( 0 , 1)) = 1
		_RoughnessFloor("Roughness Floor", Range( 0 , 1)) = 0
		_RoughnessContrast("Roughness Contrast", Range( 0 , 10)) = 1
		[Header( Micro Tile Alpha Normal Roughness )]_TextureTilingU("Texture Tiling U", Float) = 1
		_TextureTilingV("Texture Tiling V", Float) = 1
		_TextureOffsetU("Texture Offset U", Float) = 0
		_TextureOffsetV("Texture Offset V", Float) = 0
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
		[Enum(None,0,Front,1,Back,2)]_CullingMode("Culling Mode", Int) = 0
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		[HideInInspector] _texcoord4( "", 2D ) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" "IsEmissive" = "true"  "LightMode"="Meta" }
		Cull [_CullingMode]
		Stencil
		{
			Ref 1
			CompFront NotEqual
			CompBack NotEqual
		}
		AlphaToMask [_AlphaToCoverage]
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

		uniform int _AlphaToCoverage;
		uniform int _CullingMode;
		uniform sampler2D _BaseColor;
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
		uniform float _TextureTilingU;
		uniform float _TextureTilingV;
		uniform float _TextureOffsetU;
		uniform float _TextureOffsetV;
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
		uniform sampler2D _Alpha;
		SamplerState sampler_Alpha;
		uniform float sg_ToonFog;
		uniform float sg_ColorLut;
		uniform sampler2D StandardLUT;
		uniform float _RoughnessContrast;
		uniform sampler2D _RMAO;
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
		uniform float _Cutoff = 0.5;


		float2 MyCustomExpression59_g199( int UVChannel, float2 UV1, float2 UV4 )
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


		float4 MyCustomExpression2_g200( int ScenarioIndex, float4 RuntimeLighting, float4 LightBakeDay, float4 LightBakeNight )
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


		float4 MyCustomExpression28_g201( float4 Uplight, float4 Emissive, int Type )
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


		float4 MyCustomExpression8_g203( int Mode, float4 Straight, float4 Overlay, float4 Hardlight, float4 Screen, float4 Add, float4 Multiply )
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


		float MyCustomExpression8_g204( float fogStart, float fogEnd, float SurfaceDepth )
		{
			return saturate((SurfaceDepth-fogStart)/(fogEnd-fogStart));
		}


		float MyCustomExpression232_g204( float fogStart, float fogEnd, float SurfaceDepth )
		{
			return saturate((SurfaceDepth-fogStart)/(fogEnd-fogStart));
		}


		float MyCustomExpression233_g204( float fogStart, float fogEnd, float SurfaceDepth )
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
			float2 appendResult174 = (float2(_TextureTilingU , _TextureTilingV));
			float2 appendResult219 = (float2(_TextureOffsetU , _TextureOffsetV));
			float2 uv_TexCoord175 = i.uv_texcoord * appendResult174 + appendResult219;
			float TestVal194_g204 = sg_ToonFog;
			float TestVal103_g202 = sg_ColorLut;
			SurfaceOutputStandard s9_g189 = (SurfaceOutputStandard ) 0;
			float4 lerpResult3_g165 = lerp( float4(1,1,1,0) , tex2D( _BaseColor, i.uv_texcoord ) , _DiffuseIntensity);
			float4 lerpResult15_g165 = lerp( _ColorTint , i.vertexColor , (float)_UseVertexColorforTint);
			float2 uv_TintMask13_g165 = i.uv_texcoord;
			float4 lerpResult29_g165 = lerp( lerpResult3_g165 , ( lerpResult3_g165 * lerpResult15_g165 ) , tex2D( _TintMask, uv_TintMask13_g165 ).r);
			float4 temp_output_6_0_g187 = lerpResult29_g165;
			float4 clampResult8_g187 = clamp( temp_output_6_0_g187 , float4( 0.1568628,0.1568628,0.1568628,0 ) , float4( 0.9411765,0.9411765,0.9411765,0.003921569 ) );
			float grayscale13_g187 = Luminance(temp_output_6_0_g187.rgb);
			float4 color16_g187 = IsGammaSpace() ? float4(1,1,1,1) : float4(1,1,1,1);
			float temp_output_179_0 = (_IncreaseMetalness + (tex2D( _MetallicMask, i.uv_texcoord ).r - 0.0) * (1.0 - _IncreaseMetalness) / (1.0 - 0.0));
			float4 lerpResult5_g187 = lerp( clampResult8_g187 ,  ( grayscale13_g187 - 0.0 > 160.0 ? color16_g187 : grayscale13_g187 - 0.0 <= 160.0 && grayscale13_g187 + 0.0 >= 160.0 ? temp_output_6_0_g187 : temp_output_6_0_g187 )  , temp_output_179_0);
			float4 lerpResult17_g187 = lerp( temp_output_6_0_g187 , lerpResult5_g187 , _PBRSafeFilter);
			float4 temp_output_242_0 = lerpResult17_g187;
			s9_g189.Albedo = temp_output_242_0.rgb;
			float3 temp_output_183_0 = UnpackScaleNormal( tex2D( _Normal, uv_TexCoord175 ), _NormalScale );
			float4 temp_output_11_0_g189 = float4( temp_output_183_0 , 0.0 );
			s9_g189.Normal = WorldNormalVector( i , temp_output_11_0_g189.rgb );
			s9_g189.Emission = float4( 0,0,0,0 ).rgb;
			s9_g189.Metallic = temp_output_179_0;
			s9_g189.Smoothness = ( 1.0 - (_RoughnessFloor + (saturate( (CalculateContrast(_RoughnessContrast,tex2D( _RMAO, uv_TexCoord175 ))).r ) - 0.0) * (_RoughnessCeiling - _RoughnessFloor) / (1.0 - 0.0)) );
			float lerpResult24_g165 = lerp( i.vertexColor.a , 1.0 , _VertexAOMinimumValue);
			s9_g189.Occlusion = lerpResult24_g165;

			data.light = gi.light;

			UnityGI gi9_g189 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g9_g189 = UnityGlossyEnvironmentSetup( s9_g189.Smoothness, data.worldViewDir, s9_g189.Normal, float3(0,0,0));
			gi9_g189 = UnityGlobalIllumination( data, s9_g189.Occlusion, s9_g189.Normal, g9_g189 );
			#endif

			float3 surfResult9_g189 = LightingStandard ( s9_g189, viewDir, gi9_g189 ).rgb;
			surfResult9_g189 += s9_g189.Emission;

			#ifdef UNITY_PASS_FORWARDADD//9_g189
			surfResult9_g189 -= s9_g189.Emission;
			#endif//9_g189
			float3 inputColor100_g202 = surfResult9_g189;
			float ifLocalVar202_g202 = 0;
			if( LUTSize <= 2 )
				ifLocalVar202_g202 = (float)32;
			else
				ifLocalVar202_g202 = (float)LUTSize;
			float lutDim14_g202 = ifLocalVar202_g202;
			float temp_output_196_0_g202 = ( 1.0 / lutDim14_g202 );
			float3 temp_cast_33 = (temp_output_196_0_g202).xxx;
			float3 temp_cast_34 = (( 1.0 - temp_output_196_0_g202 )).xxx;
			float3 clampResult170_g202 = clamp( inputColor100_g202 , temp_cast_33 , temp_cast_34 );
			float3 break2_g202 = clampResult170_g202;
			float Red_U81_g202 = ( break2_g202.x / lutDim14_g202 );
			float temp_output_3_0_g202 = ( break2_g202.z * lutDim14_g202 );
			float Green_V75_g202 = break2_g202.y;
			float2 appendResult7_g202 = (float2(( Red_U81_g202 + ( ceil( temp_output_3_0_g202 ) / lutDim14_g202 ) ) , Green_V75_g202));
			float2 temp_output_183_0_g202 = saturate( appendResult7_g202 );
			float4 tex2DNode9_g202 = tex2Dlod( StandardLUT, float4( temp_output_183_0_g202, 0, 0.0) );
			float4 tex2DNode88_g202 = tex2Dlod( SecondLUT, float4( temp_output_183_0_g202, 0, 0.0) );
			float temp_output_182_0_g202 = saturate( EmissiveGradient );
			float4 lerpResult95_g202 = lerp( tex2DNode9_g202 , tex2DNode88_g202 , temp_output_182_0_g202);
			float4 FeatureOn103_g202 = lerpResult95_g202;
			float4 FeatureOff103_g202 = float4( inputColor100_g202 , 0.0 );
			float4 localFeatureSwitch103_g202 = FeatureSwitch( TestVal103_g202 , FeatureOn103_g202 , FeatureOff103_g202 );
			float4 temp_output_19_0_g204 = localFeatureSwitch103_g202;
			float fogStart8_g204 = fog_start;
			float fogEnd8_g204 = fog_end;
			float SurfaceDepth8_g204 = i.eyeDepth;
			float localMyCustomExpression8_g204 = MyCustomExpression8_g204( fogStart8_g204 , fogEnd8_g204 , SurfaceDepth8_g204 );
			float fogStart232_g204 = 0.0;
			float fogEnd232_g204 = fog_spread;
			float3 ase_worldPos = i.worldPos;
			float SurfaceDepth232_g204 = ase_worldPos.y;
			float localMyCustomExpression232_g204 = MyCustomExpression232_g204( fogStart232_g204 , fogEnd232_g204 , SurfaceDepth232_g204 );
			float2 appendResult89_g204 = (float2(localMyCustomExpression8_g204 , localMyCustomExpression232_g204));
			float4 fogInputs224_g204 = tex2D( fog_texture, appendResult89_g204 );
			float4 temp_output_111_0_g204 = fogInputs224_g204;
			float4 clampResult165_g204 = clamp( ( temp_output_19_0_g204 + temp_output_111_0_g204 ) , float4( 0,0,0,0 ) , temp_output_111_0_g204 );
			float fogStart233_g204 = fog_spread;
			float fogEnd233_g204 = fog_height;
			float SurfaceDepth233_g204 = ase_worldPos.y;
			float localMyCustomExpression233_g204 = MyCustomExpression233_g204( fogStart233_g204 , fogEnd233_g204 , SurfaceDepth233_g204 );
			float distanceGradiant226_g204 = saturate( ( localMyCustomExpression8_g204 * (localMyCustomExpression233_g204*FogHeightDensity + 0.0) ) );
			float4 lerpResult195_g204 = lerp( temp_output_19_0_g204 , clampResult165_g204 , ( distanceGradiant226_g204 * _PerPixelFogAmount ));
			float4 FeatureOn194_g204 = lerpResult195_g204;
			float4 FeatureOff194_g204 = temp_output_19_0_g204;
			float4 localFeatureSwitch194_g204 = FeatureSwitch( TestVal194_g204 , FeatureOn194_g204 , FeatureOff194_g204 );
			c.rgb = localFeatureSwitch194_g204.xyz;
			c.a = 1;
			clip( tex2D( _Alpha, uv_TexCoord175 ).r - _Cutoff );
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
			float4 lerpResult3_g165 = lerp( float4(1,1,1,0) , tex2D( _BaseColor, i.uv_texcoord ) , _DiffuseIntensity);
			float4 lerpResult15_g165 = lerp( _ColorTint , i.vertexColor , (float)_UseVertexColorforTint);
			float2 uv_TintMask13_g165 = i.uv_texcoord;
			float4 lerpResult29_g165 = lerp( lerpResult3_g165 , ( lerpResult3_g165 * lerpResult15_g165 ) , tex2D( _TintMask, uv_TintMask13_g165 ).r);
			float4 temp_output_6_0_g187 = lerpResult29_g165;
			float4 clampResult8_g187 = clamp( temp_output_6_0_g187 , float4( 0.1568628,0.1568628,0.1568628,0 ) , float4( 0.9411765,0.9411765,0.9411765,0.003921569 ) );
			float grayscale13_g187 = Luminance(temp_output_6_0_g187.rgb);
			float4 color16_g187 = IsGammaSpace() ? float4(1,1,1,1) : float4(1,1,1,1);
			float temp_output_179_0 = (_IncreaseMetalness + (tex2D( _MetallicMask, i.uv_texcoord ).r - 0.0) * (1.0 - _IncreaseMetalness) / (1.0 - 0.0));
			float4 lerpResult5_g187 = lerp( clampResult8_g187 ,  ( grayscale13_g187 - 0.0 > 160.0 ? color16_g187 : grayscale13_g187 - 0.0 <= 160.0 && grayscale13_g187 + 0.0 >= 160.0 ? temp_output_6_0_g187 : temp_output_6_0_g187 )  , temp_output_179_0);
			float4 lerpResult17_g187 = lerp( temp_output_6_0_g187 , lerpResult5_g187 , _PBRSafeFilter);
			float4 temp_output_242_0 = lerpResult17_g187;
			o.Albedo = temp_output_242_0.rgb;
			int Mode8_g203 = _Mode;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float temp_output_18_0_g201 = ( saturate( ( ( _TopLightHeight - ase_vertex3Pos.y ) / ( _TopLightHeight - _TopLightFalloff ) ) ) * saturate( ( ( ase_vertex3Pos.y - _BotLightHeight ) / ( _BotLightHeight + _BotFalloff ) ) ) );
			#ifdef _FLIPLIGHTDIRECTION_ON
				float staticSwitch41_g201 = ( 1.0 - temp_output_18_0_g201 );
			#else
				float staticSwitch41_g201 = temp_output_18_0_g201;
			#endif
			float2 appendResult174 = (float2(_TextureTilingU , _TextureTilingV));
			float2 appendResult219 = (float2(_TextureOffsetU , _TextureOffsetV));
			float2 uv_TexCoord175 = i.uv_texcoord * appendResult174 + appendResult219;
			float3 temp_output_183_0 = UnpackScaleNormal( tex2D( _Normal, uv_TexCoord175 ), _NormalScale );
			float3 newWorldNormal16_g201 = (WorldNormalVector( i , temp_output_183_0 ));
			float lerpResult22_g201 = lerp( newWorldNormal16_g201.y , ( 1.0 - newWorldNormal16_g201.y ) , _FlipYNormal);
			float4 Uplight28_g201 = ( _UplightLightColor * ( saturate( staticSwitch41_g201 ) * _TreeLightOn * lerpResult22_g201 ) * EmissiveGradient );
			int UVChannel59_g199 = _UVChannel;
			float2 appendResult67_g199 = (float2(_EmissionTilingX , _EmissionTilingY));
			float2 appendResult23_g199 = (float2(_EmissionOffsetX , _EmissionOffsetY));
			float2 uv_TexCoord6_g199 = i.uv_texcoord * appendResult67_g199 + appendResult23_g199;
			float2 UV159_g199 = uv_TexCoord6_g199;
			float2 uv4_TexCoord25_g199 = i.uv4_texcoord4 * appendResult67_g199 + appendResult23_g199;
			float2 UV459_g199 = uv4_TexCoord25_g199;
			float2 localMyCustomExpression59_g199 = MyCustomExpression59_g199( UVChannel59_g199 , UV159_g199 , UV459_g199 );
			float4 tex2DNode2_g199 = tex2D( _EmissionTexture, localMyCustomExpression59_g199 );
			int ScenarioIndex2_g200 = LightBakeScenario;
			float smoothstepResult73_g199 = smoothstep( _HueMin , _HueMax , tex2DNode2_g199.r);
			float4 lerpResult70_g199 = lerp( _EmissionColor , ( _EmissionColor * _EmissionCompliment ) , saturate( smoothstepResult73_g199 ));
			float4 InputColor15_g200 = lerpResult70_g199;
			float4 RuntimeLighting2_g200 = InputColor15_g200;
			#ifdef _OVERRIDEDAYCOLOR_ON
				float4 staticSwitch13_g200 = _BakedEmissionColorDay;
			#else
				float4 staticSwitch13_g200 = InputColor15_g200;
			#endif
			float lerpResult24_g199 = lerp( _DaytimeEmissiveValue , 1.0 , EmissiveGradient);
			#ifdef _OVERRIDEDAYCOLOR_ON
				float staticSwitch20_g200 = _BakedEmissiveIntensityDay;
			#else
				float staticSwitch20_g200 = lerpResult24_g199;
			#endif
			float4 LightBakeDay2_g200 = ( staticSwitch13_g200 * staticSwitch20_g200 );
			#ifdef _OVERRIDENIGHTCOLOR_ON
				float4 staticSwitch14_g200 = _BakedEmissionColorNight;
			#else
				float4 staticSwitch14_g200 = InputColor15_g200;
			#endif
			float4 LightBakeNight2_g200 = ( staticSwitch14_g200 * _BakedEmissiveIntensityNight );
			float4 localMyCustomExpression2_g200 = MyCustomExpression2_g200( ScenarioIndex2_g200 , RuntimeLighting2_g200 , LightBakeDay2_g200 , LightBakeNight2_g200 );
			float4 Emissive28_g201 = ( tex2DNode2_g199 * localMyCustomExpression2_g200 * lerpResult24_g199 );
			int Type28_g201 = _EmissiveType;
			float4 localMyCustomExpression28_g201 = MyCustomExpression28_g201( Uplight28_g201 , Emissive28_g201 , Type28_g201 );
			float4 Top9_g203 = localMyCustomExpression28_g201;
			float4 Straight8_g203 = Top9_g203;
			float4 Bottom10_g203 = temp_output_242_0;
			float temp_output_22_0_g203 = 0.5;
			float4 temp_cast_9 = (temp_output_22_0_g203).xxxx;
			float4 temp_output_19_0_g203 = ( 1.0 - ( ( 1.0 - Bottom10_g203 ) * ( 1.0 - Top9_g203 ) * 2 ) );
			float4 Overlay8_g203 =  ( Bottom10_g203 - 0.0 > temp_cast_9 ? temp_output_19_0_g203 : Bottom10_g203 - 0.0 <= temp_cast_9 && Bottom10_g203 + 0.0 >= temp_cast_9 ? temp_output_19_0_g203 : ( Top9_g203 * Bottom10_g203 * 2 ) ) ;
			float4 temp_cast_14 = (temp_output_22_0_g203).xxxx;
			float4 temp_output_30_0_g203 = ( Top9_g203 * Bottom10_g203 * 2 );
			float4 Hardlight8_g203 =  ( Bottom10_g203 - 0.0 > temp_cast_14 ? temp_output_30_0_g203 : Bottom10_g203 - 0.0 <= temp_cast_14 && Bottom10_g203 + 0.0 >= temp_cast_14 ? temp_output_30_0_g203 : ( 1.0 - ( ( 1.0 - Bottom10_g203 ) * ( 1.0 - Top9_g203 ) * 2 ) ) ) ;
			float4 Screen8_g203 = ( 1.0 - ( ( 1.0 - Bottom10_g203 ) * ( 1.0 - Top9_g203 ) ) );
			float4 Add8_g203 = ( Top9_g203 + Bottom10_g203 );
			float4 Multiply8_g203 = ( Top9_g203 * Bottom10_g203 );
			float4 localMyCustomExpression8_g203 = MyCustomExpression8_g203( Mode8_g203 , Straight8_g203 , Overlay8_g203 , Hardlight8_g203 , Screen8_g203 , Add8_g203 , Multiply8_g203 );
			o.Emission = saturate( localMyCustomExpression8_g203 ).xyz;
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
			AlphaToMask Off
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
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
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
2569.333;36;2472;1304;4012.6;-762.5315;1.798887;True;False
Node;AmplifyShaderEditor.CommentaryNode;171;-2409.603,2215.83;Inherit;False;584.2449;404.0854;;7;221;220;219;175;174;173;172;Micro Tiling Controller;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;220;-2382.831,2434.933;Inherit;False;Property;_TextureOffsetU;Texture Offset U;31;0;Create;True;0;0;False;1;;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;173;-2384.721,2262.616;Inherit;False;Property;_TextureTilingU;Texture Tiling U;29;0;Create;True;0;0;False;1;Header( Micro Tile Alpha Normal Roughness );False;1;150;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;172;-2382.693,2353.186;Inherit;False;Property;_TextureTilingV;Texture Tiling V;30;0;Create;True;0;0;False;0;False;1;100;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;221;-2380.109,2520.425;Inherit;False;Property;_TextureOffsetV;Texture Offset V;32;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;188;-1626.501,2031.82;Inherit;False;260.7063;138.1449;;1;179;Metallic;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;174;-2169.915,2307.963;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;219;-2168.018,2410.085;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;175;-2031.112,2330.684;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;176;-1627.029,1821.328;Inherit;False;679.6389;208.7382;;1;242;Base Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;179;-1613.073,2083.403;Inherit;False;Parasol_Metallic_SF;16;;164;ea0886127b2db2e4d86d4f18d4d302b3;0;1;4;FLOAT2;1,1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;259;-1601.862,1887.043;Inherit;False;Parasol_BaseColor_SF;9;;165;449e373bc45bd994189f3f52b3d88f45;0;1;5;FLOAT2;0,0;False;2;COLOR;0;FLOAT;17
Node;AmplifyShaderEditor.CommentaryNode;178;-1614.2,2186.065;Inherit;False;220.0001;139;;1;183;Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;177;-1616.817,2364.229;Inherit;False;329;161;;1;208;Roughness;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;208;-1596.198,2425.022;Inherit;False;Parasol_Roughness_SF;24;;188;bf68fe7a0dbe8c14686bde4c8c387417;0;1;8;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;183;-1608.357,2228.073;Inherit;False;Parasol_Normal_SF;20;;186;c1afb3f5e736a1b44ba607c69344914d;0;1;3;FLOAT2;1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;242;-1285.378,1886.718;Inherit;False;PbrSafeColor;4;;187;fddc034c003e76d4ba732677cc318d42;0;3;19;FLOAT;0;False;6;COLOR;0.7333333,0.7333333,0.7333333,0.003921569;False;7;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;225;-637.3301,2150.094;Inherit;False;ParasolCustomLighting;0;;189;dd582d5258e33374fbbbd0bc1271698d;1,136,0;6;10;COLOR;0.5019608,0.5019608,0.5019608,0;False;11;COLOR;0.5019608,0.5019608,1,1;False;12;FLOAT;1;False;15;FLOAT;0;False;16;COLOR;0,0,0,0;False;17;FLOAT;1;False;3;FLOAT3;147;FLOAT3;135;COLOR;112
Node;AmplifyShaderEditor.FunctionNode;268;-1590.422,1637.9;Inherit;False;Parasol_Emission_SF;33;;199;98a5bb71709445248bf940bbe0a18586;0;1;1;FLOAT2;1,1;False;2;FLOAT;7;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;264;-999.5477,1639.279;Inherit;False;Simple_Uplight_SF;52;;201;99f37951fd0088745980292981a2025b;0;3;34;FLOAT3;0,0,0;False;31;COLOR;0,0,0,0;False;30;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;75;-1606.999,2541.118;Inherit;True;Property;_Alpha;Alpha;19;1;[NoScaleOffset];Create;True;0;0;False;1;Header(Alpha);False;-1;None;ee43087f65fde2f41bf7f0246c6a4f35;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;260;-334.5924,2198.598;Inherit;False;ParasolGlobalLut_;6;;202;415cf2c404453934193ab734c391e132;0;1;15;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;265;-409.8535,1759.941;Inherit;False;PhotoshopStyleBlendModes_SF;62;;203;355eea3733479f34187920a3d7ed4e48;0;3;1;FLOAT4;1,0.7098039,0.4352942,0;False;2;COLOR;0.2196079,0.2196079,0.2196079,0;False;22;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.IntNode;261;-1599.345,2821.399;Inherit;False;Property;_AlphaToCoverage;Alpha To Coverage;23;1;[Enum];Create;True;2;Off;0;On;1;0;True;0;False;0;0;0;1;INT;0
Node;AmplifyShaderEditor.IntNode;255;-1601.057,2740.32;Inherit;False;Property;_CullingMode;Culling Mode;67;1;[Enum];Create;True;3;None;0;Front;1;Back;2;0;True;0;False;0;0;0;1;INT;0
Node;AmplifyShaderEditor.WireNode;190;-511.2368,2532.325;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;233;-122.6094,2201.42;Inherit;False;Toon_DistanceFog;64;;204;87a2c17086d6be546a10c470a8adefc0;0;2;19;COLOR;0,0,0,0;False;111;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;444.3517,1827.711;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Parasol/SimpleStandard(AlphaTest)_shader;False;False;False;False;False;False;False;True;True;False;False;False;False;False;False;False;True;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;TransparentCutout;;Geometry;ForwardOnly;4;d3d11;glcore;gles3;metal;True;True;True;True;0;False;-1;True;1;False;-1;255;False;-1;255;False;-1;6;False;-1;0;False;-1;0;False;-1;0;False;-1;6;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;68;-1;-1;-1;1;LightMode=Meta;False;0;0;True;255;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;True;261;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;181;-1621.113,1588.66;Inherit;False;398.3566;170.0804;;0;Emission;1,1,1,1;0;0
WireConnection;174;0;173;0
WireConnection;174;1;172;0
WireConnection;219;0;220;0
WireConnection;219;1;221;0
WireConnection;175;0;174;0
WireConnection;175;1;219;0
WireConnection;208;8;175;0
WireConnection;183;3;175;0
WireConnection;242;6;259;0
WireConnection;242;7;179;0
WireConnection;225;10;242;0
WireConnection;225;11;183;0
WireConnection;225;12;208;0
WireConnection;225;15;179;0
WireConnection;225;17;259;17
WireConnection;264;34;183;0
WireConnection;264;31;268;0
WireConnection;264;30;268;7
WireConnection;75;1;175;0
WireConnection;260;15;225;135
WireConnection;265;1;264;0
WireConnection;265;2;242;0
WireConnection;190;0;75;1
WireConnection;233;19;260;0
WireConnection;0;0;242;0
WireConnection;0;2;265;0
WireConnection;0;10;190;0
WireConnection;0;13;233;0
ASEEND*/
//CHKSM=1D26F5B03ADFBFFA5C2EF1AEDAFF3BCC0508EE35