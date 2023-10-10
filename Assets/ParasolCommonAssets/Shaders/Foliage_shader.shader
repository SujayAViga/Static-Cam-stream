// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Parasol/Foliage_shader"
{
	Properties
	{
		[Enum(Off,0,On,1)]_PBRSafeOverride("PBR Safe Filter", Int) = 0
		[NoScaleOffset]_BaseColor("Base Color", 2D) = "white" {}
		[NoScaleOffset]_TintMask("Tint Mask", 2D) = "white" {}
		[Header(Base Color)]_ColorTint("Color Tint", Color) = (1,1,1,0)
		_LeafColorVariation("Leaf Color Variation", Range( 0 , 1)) = 0.2
		[NoScaleOffset][Header(Alpha Mask)]_Alpha("Alpha", 2D) = "white" {}
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		[NoScaleOffset][Header(Normal)]_Normal("Normal", 2D) = "bump" {}
		_NormalScale("Normal Scale", Range( 0 , 1)) = 1
		[NoScaleOffset][Header(Roughness)]_RMAO("Roughness", 2D) = "white" {}
		_RoughnessCeiling("Roughness Ceiling", Range( 0 , 1)) = 1
		_RoughnessFloor("Roughness Floor", Range( 0 , 1)) = 0
		_RoughnessContrast("Roughness Contrast", Range( 0 , 10)) = 1
		[Header(UV Tiling)]_TextureTilingU("Texture Tiling U", Float) = 1
		_TextureTilingV("Texture Tiling V", Float) = 1
		[Header(UV Offset)]_TextureOffsetU("Texture Offset U", Float) = 0
		_TextureOffsetV("Texture Offset V", Float) = 0
		[Header(Backlight)]_TranslucentColor("Translucent Color", Color) = (0.5660378,0.5660378,0.5660378,0)
		_Transmittance("Transmittance", Range( 0 , 1)) = 0.25
		_Thickness("Thickness", Range( 0 , 1)) = 0.1
		[Enum(Red,0,Alpha,1,Both,2)]_TransmissiveMaskVertexColorChannel("Transmissive Mask Vertex Color Channel", Int) = 2
		[Header(AO)]_AOMin("AOMin", Range( 0 , 1)) = 0
		[Header(Tree Lights)]_TreeLightColor("Tree Light Color", Color) = (1,0.9923881,0.5566038,0)
		_TreeLightOn("Tree Light Intensity", Range( 0 , 1)) = 1
		[IntRange]_FlipYNormal("Flip Y Normal", Range( 0 , 1)) = 1
		_TopHeight("Top Height", Range( -10 , 10)) = 4
		_TopLightFalloff("Top Light Fall off", Range( 0 , 1)) = 0.25
		_BotLightHeight("Bot Light Height", Range( -10 , 10)) = 0
		_BotFalloff("Bot Fall off", Range( 0 , 10)) = 1
		[Enum(Single Sided,0, Double Sided,1)]_TransmissiveLightingType("Transmissive Lighting Type", Int) = 0
		[NoScaleOffset][Header(Fabric Emissive)][_FABRIC_ON  HideInInspector]_FabricEmissiveMask("Fabric Emissive Mask", 2D) = "white" {}
		_FabricMaskTilingX("Fabric Mask Tiling X", Float) = 1
		_FabricMaskTilingY("Fabric Mask Tiling Y", Float) = 1
		_FabricMaskOffsetU("Fabric Mask Offset U", Float) = 0
		_FabricMaskOffsetV("Fabric Mask Offset V", Float) = 0
		_FabricEmissionColor("Fabric Emission Color", Color) = (1,1,1,0)
		[Enum(Tree Uplight,0,Projector,1)]_EmissiveType("Emissive Type", Int) = 0
		_NightDiffuseBrightness("Night Diffuse Dimming", Range( 0 , 1)) = 0
		[NoScaleOffset][Header(Wind)]_Noise("Noise", 2D) = "white" {}
		_ParasolWindIntensity("Parasol Wind Intensity", Float) = 0.05
		_WindHeightMask("Wind Height Mask", Range( 0 , 0.51)) = 0.075
		_HeightWindMask("Height Wind Mask", Range( 0 , 1)) = 0
		[Header(Per Pixel Fog Controls)]_PerPixelFogAmount("Per Pixel Fog Amount", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord4( "", 2D ) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
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
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
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
			float4 vertexColor : COLOR;
			float2 uv_texcoord;
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

		uniform sampler2D _Noise;
		SamplerState sampler_Noise;
		uniform float _ParasolWindIntensity;
		uniform float _WindHeightMask;
		uniform float _HeightWindMask;
		uniform float _LeafColorVariation;
		uniform sampler2D _BaseColor;
		uniform float _TextureTilingU;
		uniform float _TextureTilingV;
		uniform float _TextureOffsetU;
		uniform float _TextureOffsetV;
		uniform float4 _ColorTint;
		uniform sampler2D _TintMask;
		SamplerState sampler_TintMask;
		uniform int _PBRSafeOverride;
		uniform float _TreeLightOn;
		uniform float _TopHeight;
		uniform float _TopLightFalloff;
		uniform float _BotLightHeight;
		uniform float _BotFalloff;
		uniform sampler2D _Normal;
		uniform float _NormalScale;
		uniform float _FlipYNormal;
		uniform float4 _TreeLightColor;
		uniform float EmissiveGradient;
		uniform sampler2D _FabricEmissiveMask;
		uniform float _FabricMaskTilingX;
		uniform float _FabricMaskTilingY;
		uniform float _FabricMaskOffsetU;
		uniform float _FabricMaskOffsetV;
		uniform float4 _FabricEmissionColor;
		uniform int _EmissiveType;
		uniform sampler2D _Alpha;
		SamplerState sampler_Alpha;
		uniform float sg_ToonFog;
		uniform float sg_ColorLut;
		uniform sampler2D StandardLUT;
		uniform float4 _TranslucentColor;
		uniform int _TransmissiveMaskVertexColorChannel;
		uniform float _Transmittance;
		uniform float _Thickness;
		uniform int _TransmissiveLightingType;
		uniform float _RoughnessContrast;
		uniform sampler2D _RMAO;
		uniform float _RoughnessFloor;
		uniform float _RoughnessCeiling;
		uniform float _AOMin;
		uniform int LUTSize;
		uniform sampler2D SecondLUT;
		uniform float _NightDiffuseBrightness;
		uniform sampler2D fog_texture;
		uniform float fog_start;
		uniform float fog_end;
		uniform float fog_spread;
		uniform float fog_height;
		uniform float FogHeightDensity;
		uniform float _PerPixelFogAmount;
		uniform float _Cutoff = 0.5;


		float3 HSVToRGB( float3 c )
		{
			float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
			float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
			return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
		}


		float3 RGBToHSV(float3 c)
		{
			float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
			float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
			float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
			float d = q.x - min( q.w, q.y );
			float e = 1.0e-10;
			return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
		}

		float4 FabricProjectionsUV3590( float4 Standard, float4 Projection, int Type )
		{
			switch(Type)
			{
				case 0:
					return Standard;
					break;
				case 1:
					return Projection;
					break;
				default:
					return Standard;
			}
		}


		float TrasmissiveChannel532( float cRed, float cAlpha, int ChannelSelect )
		{
			switch(ChannelSelect)
			{
			    case 0:
			        return cRed;
			    case 1:
			        return cAlpha;
			    case 2:
			        return (cRed * cAlpha);
			    default:
			        return cAlpha;
			}
		}


		float4 TransmissiveColorRenderType592( float4 SingleSidedLighting, float4 DoubleSidedLighting, int TransmissiveType )
		{
			switch(TransmissiveType)
			{
				case 0:
					return SingleSidedLighting;
					break;
				case 1:
					return DoubleSidedLighting;
					break;
				default:
					return SingleSidedLighting;
					break;
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


		float MyCustomExpression8_g178( float fogStart, float fogEnd, float SurfaceDepth )
		{
			return saturate((SurfaceDepth-fogStart)/(fogEnd-fogStart));
		}


		float MyCustomExpression232_g178( float fogStart, float fogEnd, float SurfaceDepth )
		{
			return saturate((SurfaceDepth-fogStart)/(fogEnd-fogStart));
		}


		float MyCustomExpression233_g178( float fogStart, float fogEnd, float SurfaceDepth )
		{
			return saturate((SurfaceDepth-fogStart)/(fogEnd-fogStart));
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float mulTime5_g177 = _Time.y * 0.25;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float2 appendResult4_g177 = (float2(ase_worldPos.x , ase_worldPos.z));
			float lerpResult22_g177 = lerp( 1.0 , saturate( ( ase_worldPos.y * _WindHeightMask ) ) , _HeightWindMask);
			v.vertex.xyz += ( ( v.color.r * ( ( ( tex2Dlod( _Noise, float4( ( mulTime5_g177 + ( appendResult4_g177 * 0.1 ) ), 0, 0.0) ).g * 2.0 ) + -1.0 ) * _ParasolWindIntensity * lerpResult22_g177 ) ) * float3(0.25,1,0.25) );
			v.vertex.w = 1;
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
			float2 appendResult361 = (float2(_TextureTilingU , _TextureTilingV));
			float2 appendResult363 = (float2(_TextureOffsetU , _TextureOffsetV));
			float2 uv_TexCoord231 = i.uv_texcoord * appendResult361 + appendResult363;
			float2 TexCordReg232 = uv_TexCoord231;
			float AlphaReg152 = tex2D( _Alpha, TexCordReg232 ).r;
			float TestVal194_g178 = sg_ToonFog;
			float TestVal103_g167 = sg_ColorLut;
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 objToWorld417 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float2 appendResult492 = (float2(objToWorld417.x , objToWorld417.y));
			float dotResult4_g2 = dot( appendResult492 , float2( 12.9898,78.233 ) );
			float lerpResult10_g2 = lerp( ( -1.0 * _LeafColorVariation ) , _LeafColorVariation , frac( ( sin( dotResult4_g2 ) * 43758.55 ) ));
			float RandomColorOut482 = ( lerpResult10_g2 * i.vertexColor.r );
			float4 tex2DNode356 = tex2D( _BaseColor, TexCordReg232 );
			float2 uv_TintMask390 = i.uv_texcoord;
			float4 lerpResult598 = lerp( tex2DNode356 , ( tex2DNode356 * _ColorTint ) , tex2D( _TintMask, uv_TintMask390 ).r);
			float3 hsvTorgb497 = RGBToHSV( lerpResult598.rgb );
			float3 hsvTorgb496 = HSVToRGB( float3(( RandomColorOut482 + hsvTorgb497.x ),hsvTorgb497.y,saturate( ( hsvTorgb497.z - abs( RandomColorOut482 ) ) )) );
			float3 Bcolor143 = hsvTorgb496;
			float cRed532 = i.vertexColor.r;
			float cAlpha532 = i.vertexColor.a;
			int ChannelSelect532 = _TransmissiveMaskVertexColorChannel;
			float localTrasmissiveChannel532 = TrasmissiveChannel532( cRed532 , cAlpha532 , ChannelSelect532 );
			float lerpResult341 = lerp( ase_lightAtten , 1.0 , _Transmittance);
			float temp_output_176_0 = ( localTrasmissiveChannel532 * lerpResult341 * ( 1.0 - _Thickness ) );
			float4 temp_output_516_0 = saturate( ( ( ase_lightColor * float4( Bcolor143 , 0.0 ) * _TranslucentColor ) * temp_output_176_0 ) );
			float4 SingleSidedLighting592 = temp_output_516_0;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult566 = normalize( ase_worldlightDir );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			float3 normalizeResult565 = normalize( ( ase_vertexNormal * float3( -1,-1,-1 ) ) );
			float dotResult536 = dot( normalizeResult566 , normalizeResult565 );
			float4 DoubleSidedLighting592 = ( temp_output_516_0 * saturate( dotResult536 ) );
			int TransmissiveType592 = _TransmissiveLightingType;
			float4 localTransmissiveColorRenderType592 = TransmissiveColorRenderType592( SingleSidedLighting592 , DoubleSidedLighting592 , TransmissiveType592 );
			float4 backlightOut197 = localTransmissiveColorRenderType592;
			SurfaceOutputStandard s9_g166 = (SurfaceOutputStandard ) 0;
			float4 temp_output_6_0_g163 = float4( Bcolor143 , 0.0 );
			float4 clampResult8_g163 = clamp( temp_output_6_0_g163 , float4( 0.1568628,0.1568628,0.1568628,0 ) , float4( 0.9411765,0.9411765,0.9411765,0.003921569 ) );
			float grayscale13_g163 = Luminance(temp_output_6_0_g163.rgb);
			float4 color16_g163 = IsGammaSpace() ? float4(1,1,1,1) : float4(1,1,1,1);
			float4 lerpResult5_g163 = lerp( clampResult8_g163 ,  ( grayscale13_g163 - 0.0 > 160.0 ? color16_g163 : grayscale13_g163 - 0.0 <= 160.0 && grayscale13_g163 + 0.0 >= 160.0 ? temp_output_6_0_g163 : temp_output_6_0_g163 )  , 0.0);
			float4 lerpResult17_g163 = lerp( temp_output_6_0_g163 , lerpResult5_g163 , (float)_PBRSafeOverride);
			float4 temp_output_586_0 = lerpResult17_g163;
			s9_g166.Albedo = temp_output_586_0.rgb;
			float3 NormalReg147 = UnpackScaleNormal( tex2D( _Normal, TexCordReg232 ), _NormalScale );
			float4 temp_output_11_0_g166 = float4( NormalReg147 , 0.0 );
			s9_g166.Normal = WorldNormalVector( i , temp_output_11_0_g166.rgb );
			s9_g166.Emission = float4( 0,0,0,0 ).rgb;
			s9_g166.Metallic = 0.0;
			float Rough150 = (_RoughnessFloor + (saturate( (CalculateContrast(_RoughnessContrast,tex2D( _RMAO, TexCordReg232 ))).r ) - 0.0) * (_RoughnessCeiling - _RoughnessFloor) / (1.0 - 0.0));
			s9_g166.Smoothness = ( 1.0 - Rough150 );
			float VertexAlpha571 = i.vertexColor.a;
			float lerpResult396 = lerp( _AOMin , 1.0 , VertexAlpha571);
			float _VertexAoResult511 = lerpResult396;
			s9_g166.Occlusion = _VertexAoResult511;

			data.light = gi.light;

			UnityGI gi9_g166 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g9_g166 = UnityGlossyEnvironmentSetup( s9_g166.Smoothness, data.worldViewDir, s9_g166.Normal, float3(0,0,0));
			gi9_g166 = UnityGlobalIllumination( data, s9_g166.Occlusion, s9_g166.Normal, g9_g166 );
			#endif

			float3 surfResult9_g166 = LightingStandard ( s9_g166, viewDir, gi9_g166 ).rgb;
			surfResult9_g166 += s9_g166.Emission;

			#ifdef UNITY_PASS_FORWARDADD//9_g166
			surfResult9_g166 -= s9_g166.Emission;
			#endif//9_g166
			float3 inputColor100_g167 = ( backlightOut197 + float4( surfResult9_g166 , 0.0 ) ).xyz;
			float ifLocalVar202_g167 = 0;
			if( LUTSize <= 2 )
				ifLocalVar202_g167 = (float)32;
			else
				ifLocalVar202_g167 = (float)LUTSize;
			float lutDim14_g167 = ifLocalVar202_g167;
			float temp_output_196_0_g167 = ( 1.0 / lutDim14_g167 );
			float3 temp_cast_25 = (temp_output_196_0_g167).xxx;
			float3 temp_cast_26 = (( 1.0 - temp_output_196_0_g167 )).xxx;
			float3 clampResult170_g167 = clamp( inputColor100_g167 , temp_cast_25 , temp_cast_26 );
			float3 break2_g167 = clampResult170_g167;
			float Red_U81_g167 = ( break2_g167.x / lutDim14_g167 );
			float temp_output_3_0_g167 = ( break2_g167.z * lutDim14_g167 );
			float Green_V75_g167 = break2_g167.y;
			float2 appendResult7_g167 = (float2(( Red_U81_g167 + ( ceil( temp_output_3_0_g167 ) / lutDim14_g167 ) ) , Green_V75_g167));
			float2 temp_output_183_0_g167 = saturate( appendResult7_g167 );
			float4 tex2DNode9_g167 = tex2Dlod( StandardLUT, float4( temp_output_183_0_g167, 0, 0.0) );
			float4 tex2DNode88_g167 = tex2Dlod( SecondLUT, float4( temp_output_183_0_g167, 0, 0.0) );
			float temp_output_182_0_g167 = saturate( EmissiveGradient );
			float4 lerpResult95_g167 = lerp( tex2DNode9_g167 , tex2DNode88_g167 , temp_output_182_0_g167);
			float4 FeatureOn103_g167 = lerpResult95_g167;
			float4 FeatureOff103_g167 = float4( inputColor100_g167 , 0.0 );
			float4 localFeatureSwitch103_g167 = FeatureSwitch( TestVal103_g167 , FeatureOn103_g167 , FeatureOff103_g167 );
			float _EmissiveGradiantValue507 = EmissiveGradient;
			float lerpResult609 = lerp( 1.0 , ( 1.0 - _NightDiffuseBrightness ) , saturate( _EmissiveGradiantValue507 ));
			float4 temp_output_19_0_g178 = ( localFeatureSwitch103_g167 * lerpResult609 );
			float fogStart8_g178 = fog_start;
			float fogEnd8_g178 = fog_end;
			float SurfaceDepth8_g178 = i.eyeDepth;
			float localMyCustomExpression8_g178 = MyCustomExpression8_g178( fogStart8_g178 , fogEnd8_g178 , SurfaceDepth8_g178 );
			float fogStart232_g178 = 0.0;
			float fogEnd232_g178 = fog_spread;
			float SurfaceDepth232_g178 = ase_worldPos.y;
			float localMyCustomExpression232_g178 = MyCustomExpression232_g178( fogStart232_g178 , fogEnd232_g178 , SurfaceDepth232_g178 );
			float2 appendResult89_g178 = (float2(localMyCustomExpression8_g178 , localMyCustomExpression232_g178));
			float4 fogInputs224_g178 = tex2D( fog_texture, appendResult89_g178 );
			float4 temp_output_111_0_g178 = fogInputs224_g178;
			float4 clampResult165_g178 = clamp( ( temp_output_19_0_g178 + temp_output_111_0_g178 ) , float4( 0,0,0,0 ) , temp_output_111_0_g178 );
			float fogStart233_g178 = fog_spread;
			float fogEnd233_g178 = fog_height;
			float SurfaceDepth233_g178 = ase_worldPos.y;
			float localMyCustomExpression233_g178 = MyCustomExpression233_g178( fogStart233_g178 , fogEnd233_g178 , SurfaceDepth233_g178 );
			float distanceGradiant226_g178 = saturate( ( localMyCustomExpression8_g178 * (localMyCustomExpression233_g178*FogHeightDensity + 0.0) ) );
			float4 lerpResult195_g178 = lerp( temp_output_19_0_g178 , clampResult165_g178 , ( distanceGradiant226_g178 * _PerPixelFogAmount ));
			float4 FeatureOn194_g178 = lerpResult195_g178;
			float4 FeatureOff194_g178 = temp_output_19_0_g178;
			float4 localFeatureSwitch194_g178 = FeatureSwitch( TestVal194_g178 , FeatureOn194_g178 , FeatureOff194_g178 );
			c.rgb = localFeatureSwitch194_g178.xyz;
			c.a = 1;
			clip( AlphaReg152 - _Cutoff );
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
			float3 objToWorld417 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float2 appendResult492 = (float2(objToWorld417.x , objToWorld417.y));
			float dotResult4_g2 = dot( appendResult492 , float2( 12.9898,78.233 ) );
			float lerpResult10_g2 = lerp( ( -1.0 * _LeafColorVariation ) , _LeafColorVariation , frac( ( sin( dotResult4_g2 ) * 43758.55 ) ));
			float RandomColorOut482 = ( lerpResult10_g2 * i.vertexColor.r );
			float2 appendResult361 = (float2(_TextureTilingU , _TextureTilingV));
			float2 appendResult363 = (float2(_TextureOffsetU , _TextureOffsetV));
			float2 uv_TexCoord231 = i.uv_texcoord * appendResult361 + appendResult363;
			float2 TexCordReg232 = uv_TexCoord231;
			float4 tex2DNode356 = tex2D( _BaseColor, TexCordReg232 );
			float2 uv_TintMask390 = i.uv_texcoord;
			float4 lerpResult598 = lerp( tex2DNode356 , ( tex2DNode356 * _ColorTint ) , tex2D( _TintMask, uv_TintMask390 ).r);
			float3 hsvTorgb497 = RGBToHSV( lerpResult598.rgb );
			float3 hsvTorgb496 = HSVToRGB( float3(( RandomColorOut482 + hsvTorgb497.x ),hsvTorgb497.y,saturate( ( hsvTorgb497.z - abs( RandomColorOut482 ) ) )) );
			float3 Bcolor143 = hsvTorgb496;
			float4 temp_output_6_0_g163 = float4( Bcolor143 , 0.0 );
			float4 clampResult8_g163 = clamp( temp_output_6_0_g163 , float4( 0.1568628,0.1568628,0.1568628,0 ) , float4( 0.9411765,0.9411765,0.9411765,0.003921569 ) );
			float grayscale13_g163 = Luminance(temp_output_6_0_g163.rgb);
			float4 color16_g163 = IsGammaSpace() ? float4(1,1,1,1) : float4(1,1,1,1);
			float4 lerpResult5_g163 = lerp( clampResult8_g163 ,  ( grayscale13_g163 - 0.0 > 160.0 ? color16_g163 : grayscale13_g163 - 0.0 <= 160.0 && grayscale13_g163 + 0.0 >= 160.0 ? temp_output_6_0_g163 : temp_output_6_0_g163 )  , 0.0);
			float4 lerpResult17_g163 = lerp( temp_output_6_0_g163 , lerpResult5_g163 , (float)_PBRSafeOverride);
			float4 temp_output_586_0 = lerpResult17_g163;
			o.Albedo = temp_output_586_0.rgb;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 NormalReg147 = UnpackScaleNormal( tex2D( _Normal, TexCordReg232 ), _NormalScale );
			float3 newWorldNormal130 = (WorldNormalVector( i , NormalReg147 ));
			float lerpResult377 = lerp( newWorldNormal130.y , ( 1.0 - newWorldNormal130.y ) , _FlipYNormal);
			float4 Standard590 = ( float4( Bcolor143 , 0.0 ) * ( _TreeLightOn * saturate( ( ( ( ( ( _TopHeight - 1.0 ) + ( ase_vertex3Pos.y * -1.0 ) ) * _TopLightFalloff ) + 1.0 ) * ( ( ( ase_vertex3Pos.y + ( ase_vertex3Pos.y + _BotLightHeight ) ) * _BotFalloff ) + 1.0 ) ) ) * lerpResult377 ) * _TreeLightColor * EmissiveGradient );
			float2 appendResult401 = (float2(_FabricMaskTilingX , _FabricMaskTilingY));
			float2 appendResult481 = (float2(_FabricMaskOffsetU , _FabricMaskOffsetV));
			float2 uv4_TexCoord402 = i.uv4_texcoord4 * appendResult401 + appendResult481;
			float _EmissiveGradiantValue507 = EmissiveGradient;
			float4 Projection590 = ( tex2D( _FabricEmissiveMask, uv4_TexCoord402 ) * _FabricEmissionColor * _EmissiveGradiantValue507 );
			int Type590 = _EmissiveType;
			float4 localFabricProjectionsUV3590 = FabricProjectionsUV3590( Standard590 , Projection590 , Type590 );
			o.Emission = localFabricProjectionsUV3590.xyz;
		}

		ENDCG
		CGPROGRAM
		#pragma only_renderers d3d11 glcore gles3 metal 
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows exclude_path:deferred nodynlightmap nodirlightmap dithercrossfade vertex:vertexDataFunc 

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
3017.333;100;1972;1170;-758.9246;-1060.449;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;562;-2700.789,-1845.329;Inherit;False;1460.511;444.8457;;8;365;364;360;362;363;361;231;232;UV Controlls;0.2354931,0.8147411,0.9245283,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;362;-2660.268,-1785.766;Inherit;False;Property;_TextureTilingU;Texture Tiling U;19;0;Create;True;0;0;False;1;Header(UV Tiling);False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;360;-2658.367,-1709.724;Inherit;False;Property;_TextureTilingV;Texture Tiling V;20;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;364;-2657.737,-1636.589;Inherit;False;Property;_TextureOffsetU;Texture Offset U;21;0;Create;True;0;0;False;1;Header(UV Offset);False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;365;-2657.836,-1553.547;Inherit;False;Property;_TextureOffsetV;Texture Offset V;22;0;Create;True;0;0;False;1;;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;430;-2706.711,-1321.343;Inherit;False;1460.511;444.8457;Randomize color based on position;9;482;408;407;417;491;492;500;423;502;Color Variation;0.6483558,1,0.2830189,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;361;-2430.883,-1762.372;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;363;-2434.667,-1655.569;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;423;-2616.04,-1032.858;Inherit;False;Property;_LeafColorVariation;Leaf Color Variation;8;0;Create;True;0;0;False;0;False;0.2;0.02;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;231;-2236.134,-1736.634;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformPositionNode;417;-2616.223,-1274.313;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WireNode;502;-2146.063,-1000.668;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;232;-2011.378,-1743.461;Inherit;False;TexCordReg;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;155;-299.0042,-2346.043;Inherit;False;2153.513;831.4051;Comment;16;391;505;520;497;483;498;522;504;143;496;79;356;390;384;355;598;Base Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;500;-2259.17,-1106.198;Inherit;False;2;2;0;FLOAT;-1;False;1;FLOAT;360;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;492;-2292.523,-1214.132;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;355;-258.3563,-2275.066;Inherit;True;Property;_BaseColor;Base Color;5;1;[NoScaleOffset];Create;True;0;0;False;0;False;None;19b59d86b7a8f6d46bbfabc21a2582dd;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.FunctionNode;491;-1994.884,-1196.738;Inherit;False;Random Range;-1;;2;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;-360;False;3;FLOAT;360;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;407;-1986.804,-1052.381;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;384;-175.8044,-2061.583;Inherit;False;232;TexCordReg;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;408;-1679.377,-1108.183;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;79;-195.9784,-1759.301;Inherit;False;Property;_ColorTint;Color Tint;7;0;Create;True;0;0;False;1;Header(Base Color);False;1,1,1,0;1,1,1,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;356;99.3127,-2174.925;Inherit;True;Property;_TextureSample2;Texture Sample 2;20;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;391;283.1295,-1958.84;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;390;-271.029,-1966.16;Inherit;True;Property;_TintMask;Tint Mask;6;1;[NoScaleOffset];Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;482;-1495.143,-1096.208;Inherit;False;RandomColorOut;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;598;450.3052,-1973.487;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;505;370.1931,-1744.844;Inherit;False;482;RandomColorOut;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;520;696.1236,-1756.327;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RGBToHSVNode;497;594.7739,-1974.231;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;483;627.4698,-2124.814;Inherit;False;482;RandomColorOut;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;522;929.6039,-1792.022;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;504;1146.146,-1844.059;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;498;941.8656,-2069.474;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;196;-2772.559,275.6697;Inherit;False;2351.699;1044.194;Disconnected because it breaks tree uplight;29;549;536;534;551;516;205;176;341;533;193;164;339;326;330;532;181;527;197;564;565;566;567;558;569;571;573;592;593;599;TransmissiveColor;0.8773585,0.4408527,0.1572624,1;0;0
Node;AmplifyShaderEditor.HSVToRGBNode;496;1395.799,-1980.496;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.VertexColorNode;181;-2720.055,631.1017;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.IntNode;527;-2738.997,856.559;Inherit;False;Property;_TransmissiveMaskVertexColorChannel;Transmissive Mask Vertex Color Channel;26;1;[Enum];Create;True;3;Red;0;Alpha;1;Both;2;0;False;0;False;2;2;0;1;INT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;549;-2003.236,1160.856;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;193;-2706.062,1187.03;Inherit;False;Property;_Thickness;Thickness;25;0;Create;True;0;0;False;0;False;0.1;0.452;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;339;-2679.959,1098.85;Inherit;False;Property;_Transmittance;Transmittance;24;0;Create;True;0;0;False;0;False;0.25;0.892;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;330;-2627.859,949.1317;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;599;-2577.209,1023.419;Inherit;False;Constant;_Float2;Float 2;38;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;143;1655.211,-1963.927;Inherit;False;Bcolor;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;158;-250.6236,-384.1886;Inherit;False;2061.901;670.1982;;28;108;575;368;142;298;243;377;507;165;376;301;375;130;373;295;280;148;294;281;282;289;293;248;369;300;249;292;247;Emmission;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;534;-1880.471,1011.687;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;164;-2468.726,545.1907;Inherit;False;Property;_TranslucentColor;Translucent Color;23;0;Create;True;0;0;True;1;Header(Backlight);False;0.5660378,0.5660378,0.5660378,0;0.4138235,0.525,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightColorNode;326;-2421.716,339.355;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.LerpOp;341;-2277.081,991.1984;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;532;-2359.898,761.3888;Inherit;False;switch(ChannelSelect)${$    case 0:$        return cRed@$    case 1:$        return cAlpha@$    case 2:$        return (cRed * cAlpha)@$    default:$        return cAlpha@$};1;False;3;True;cRed;FLOAT;0;In;;Inherit;False;True;cAlpha;FLOAT;0;In;;Inherit;False;True;ChannelSelect;INT;0;In;;Inherit;False;TrasmissiveChannel;True;False;0;3;0;FLOAT;0;False;1;FLOAT;0;False;2;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;564;-1762.533,1170.561;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;-1,-1,-1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;533;-2433.719,465.555;Inherit;False;143;Bcolor;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;205;-2269.547,1127.091;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;247;-161.0855,-224.6835;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalizeNode;565;-1588.211,1121.48;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;156;-279.8767,-953.7973;Inherit;False;403.2654;134.2168;Comment;2;147;229;Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;249;-202.8899,-8.243881;Inherit;False;Property;_BotLightHeight;Bot Light Height;33;0;Create;True;0;0;False;0;False;0;-4.46;-10;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;233;-628.1133,-947.3125;Inherit;False;232;TexCordReg;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;292;-161.9221,-309.3163;Inherit;False;Property;_TopHeight;Top Height;31;0;Create;True;0;0;False;0;False;4;6.85;-10;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;573;-2021.595,484.1218;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;176;-1955.765,791.1072;Inherit;False;3;3;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;566;-1618.087,1007.54;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;571;-2348.114,887.7184;Inherit;False;VertexAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;569;-1634.583,697.988;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;536;-1430.626,1021.432;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;248;82.83411,-43.23705;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;369;105.3955,-305.8678;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;229;-265.6267,-907.2364;Inherit;False;Parasol_Normal_SF;11;;144;c1afb3f5e736a1b44ba607c69344914d;0;1;3;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;300;114.0984,-214.7638;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;561;-2635.076,-661.0146;Inherit;False;830.0466;454.7483;Modify Vertex AO;5;511;396;395;394;570;AO;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;282;208.122,-104.4988;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;289;266.7366,-204.0663;Inherit;False;Property;_TopLightFalloff;Top Light Fall off;32;0;Create;True;0;0;False;0;False;0.25;0.191;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;147;-58.6115,-912.7974;Inherit;False;NormalReg;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;567;-1277.276,983.158;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;570;-2503.653,-314.2602;Inherit;False;571;VertexAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;293;247.5663,-304.6916;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;281;83.31849,57.84647;Inherit;False;Property;_BotFalloff;Bot Fall off;34;0;Create;True;0;0;False;0;False;1;0.22;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;394;-2600.513,-580.0768;Inherit;False;Property;_AOMin;AOMin;27;0;Create;True;0;0;False;1;Header(AO);False;0;0.641;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;516;-1282.194,799.1663;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;148;408.1974,17.58033;Inherit;False;147;NormalReg;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;558;-1098.498,898.0703;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;585;-246.6508,-640.1686;Inherit;False;Parasol_Roughness_SF;14;;161;bf68fe7a0dbe8c14686bde4c8c387417;0;1;8;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;593;-1312.992,1137.771;Inherit;False;Property;_TransmissiveLightingType;Transmissive Lighting Type;35;1;[Enum];Create;True;2;Single Sided;0; Double Sided;1;0;False;0;False;0;0;0;1;INT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;280;344.4603,-97.30956;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;154;-273.676,-695.5776;Inherit;False;760.7224;153.0703;;1;150;Roughness;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;294;548.5507,-305.7314;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;396;-2269.125,-426.3346;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;399;-108.3724,501.448;Inherit;False;Property;_FabricMaskTilingX;Fabric Mask Tiling X;37;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;295;672.0043,-306.394;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;400;-102.1245,577.6705;Inherit;False;Property;_FabricMaskTilingY;Fabric Mask Tiling Y;38;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;511;-2109.538,-313.0664;Inherit;False;_VertexAoResult;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;480;-110.88,753.1412;Inherit;False;Property;_FabricMaskOffsetV;Fabric Mask Offset V;40;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;479;-116.0799,662.1414;Inherit;False;Property;_FabricMaskOffsetU;Fabric Mask Offset U;39;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;165;1008.723,163.7225;Inherit;False;Global;EmissiveGradient;EmissiveGradient;17;0;Create;True;0;0;False;0;False;0;1.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;592;-816.5342,778.324;Inherit;False;switch(TransmissiveType)${$	case 0:$		return SingleSidedLighting@$		break@$	case 1:$		return DoubleSidedLighting@$		break@$	default:$		return SingleSidedLighting@$		break@$}$;4;False;3;True;SingleSidedLighting;FLOAT4;0,0,0,0;In;;Inherit;False;True;DoubleSidedLighting;FLOAT4;0,0,0,0;In;;Inherit;False;True;TransmissiveType;INT;0;In;;Inherit;False;Transmissive Color Render Type;True;False;0;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;INT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;150;125.4939,-640.6951;Inherit;False;Rough;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;342;5.362996,1151.145;Inherit;False;143;Bcolor;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.IntNode;587;771.4207,995.7128;Inherit;False;Property;_PBRSafeOverride;PBR Safe Filter;4;1;[Enum];Create;False;2;Off;0;On;1;0;False;0;False;0;1;0;1;INT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;373;480.3123,-100.4568;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;130;604.0897,-38.59715;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;481;296.0203,689.4412;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;401;284.1846,507.5444;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;151;1077.516,1384.956;Inherit;False;150;Rough;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;149;1077.237,1261.261;Inherit;False;147;NormalReg;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;301;851.4207,-131.8733;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;376;815.5441,63.56937;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;510;1064.782,1496.764;Inherit;False;511;_VertexAoResult;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;197;-474.8452,835.7616;Inherit;False;backlightOut;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;375;721.9508,129.5003;Inherit;False;Property;_FlipYNormal;Flip Y Normal;30;1;[IntRange];Create;True;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;507;1274.619,209.8504;Inherit;False;_EmissiveGradiantValue;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;586;1010.929,1107.208;Inherit;False;PbrSafeColor;55;;163;fddc034c003e76d4ba732677cc318d42;0;3;19;FLOAT;0;False;6;COLOR;0.7333333,0.7333333,0.7333333,0.003921569;False;7;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;402;475.8635,550.5104;Inherit;False;3;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;298;984.8891,-132.4158;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;243;847.2657,-212.9337;Inherit;False;Property;_TreeLightOn;Tree Light Intensity;29;0;Create;False;0;0;False;0;False;1;0.807;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;610;1414.608,1641.016;Inherit;False;Property;_NightDiffuseBrightness;Night Diffuse Dimming;43;0;Create;False;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;603;1409.613,1825.717;Inherit;False;507;_EmissiveGradiantValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;377;983.2712,9.571053;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;234;1749.997,1175.991;Inherit;False;ParasolCustomLighting;0;;166;dd582d5258e33374fbbbd0bc1271698d;1,136,0;6;10;COLOR;1,0,0.8704052,0;False;11;COLOR;0,0,0.5,1;False;12;FLOAT;1;False;15;FLOAT;0;False;16;COLOR;0,0,0,0;False;17;FLOAT;1;False;3;FLOAT3;147;FLOAT3;135;COLOR;112
Node;AmplifyShaderEditor.GetLocalVarNode;601;1794.729,792.7822;Inherit;False;197;backlightOut;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;215;-281.2653,-1331.758;Inherit;False;488.8531;259.6206;;2;152;358;Alpha;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;142;1181.425,-36.83836;Inherit;False;Property;_TreeLightColor;Tree Light Color;28;0;Create;True;0;0;False;1;Header(Tree Lights);False;1,0.9923881,0.5566038,0;1,1,0.61,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;368;1171.988,-157.9716;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;600;2085.092,841.1062;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;387;817.098,666.3096;Inherit;False;Property;_FabricEmissionColor;Fabric Emission Color;41;0;Create;True;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;607;1774.703,1689.53;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;386;773.556,466.458;Inherit;True;Property;_FabricEmissiveMask;Fabric Emissive Mask;36;1;[NoScaleOffset];Create;True;0;0;False;2;Header(Fabric Emissive);_FABRIC_ON  HideInInspector;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;575;1454.613,-145.14;Inherit;False;143;Bcolor;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;608;1777.715,1776.829;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;508;1091.653,805.7691;Inherit;False;507;_EmissiveGradiantValue;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;404;1524.24,484.2798;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;108;1651.938,-75.29729;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;597;2236.042,565.8569;Inherit;False;ParasolGlobalLut_;49;;167;415cf2c404453934193ab734c391e132;0;1;15;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;609;1968.975,1696.482;Inherit;False;3;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;591;1871.42,541.027;Inherit;False;Property;_EmissiveType;Emissive Type;42;1;[Enum];Create;True;2;Tree Uplight;0;Projector;1;0;False;0;False;0;0;0;1;INT;0
Node;AmplifyShaderEditor.SamplerNode;358;-269.9674,-1281.361;Inherit;True;Property;_Alpha;Alpha;9;1;[NoScaleOffset];Create;True;0;0;False;1;Header(Alpha Mask);False;-1;None;d6594e52875ffa94fa45fa96044b89a1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;595;2154.979,73.24883;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;152;16.19451,-1262.559;Inherit;False;AlphaReg;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;602;2534.255,580.9796;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CustomExpressionNode;590;2318.942,186.6641;Inherit;False;switch(Type)${$	case 0:$		return Standard@$		break@$	case 1:$		return Projection@$		break@$	default:$		return Standard@$};4;False;3;True;Standard;FLOAT4;0,0,0,0;In;;Inherit;False;True;Projection;FLOAT4;0,0,0,0;In;;Inherit;False;True;Type;INT;0;In;;Inherit;False;Fabric Projections UV3;True;False;0;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;INT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;440;2746.091,458.3641;Inherit;False;Toon_DistanceFog;52;;178;87a2c17086d6be546a10c470a8adefc0;0;2;19;COLOR;0,0,0,0;False;111;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RelayNode;594;2641.131,135.7454;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;550;3393.39,618.256;Inherit;False;551;Debug;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;438;3226.219,507.0854;Inherit;False;ParasolWind;44;;177;dc1d460373bb8514abd1aa3568da6b99;0;1;26;SAMPLER2D;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;395;-2626.364,-424.6681;Inherit;False;Constant;_AOMax;AOMax;29;0;Create;True;0;0;False;1;Tooltip(Usually set this to 1);False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;596;2923.259,91.98731;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;551;-1667.497,848.1392;Inherit;False;Debug;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;153;3290.762,257.7068;Inherit;False;152;AlphaReg;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3609.816,95.14919;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Parasol/Foliage_shader;False;False;False;False;False;False;False;True;True;False;False;False;True;False;False;False;True;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Masked;0.5;True;True;0;False;TransparentCutout;;AlphaTest;ForwardOnly;4;d3d11;glcore;gles3;metal;True;True;True;True;0;False;-1;True;1;False;-1;255;False;-1;255;False;-1;6;False;-1;0;False;-1;0;False;-1;0;False;-1;6;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;10;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;361;0;362;0
WireConnection;361;1;360;0
WireConnection;363;0;364;0
WireConnection;363;1;365;0
WireConnection;231;0;361;0
WireConnection;231;1;363;0
WireConnection;502;0;423;0
WireConnection;232;0;231;0
WireConnection;500;1;423;0
WireConnection;492;0;417;1
WireConnection;492;1;417;2
WireConnection;491;1;492;0
WireConnection;491;2;500;0
WireConnection;491;3;502;0
WireConnection;408;0;491;0
WireConnection;408;1;407;1
WireConnection;356;0;355;0
WireConnection;356;1;384;0
WireConnection;391;0;356;0
WireConnection;391;1;79;0
WireConnection;482;0;408;0
WireConnection;598;0;356;0
WireConnection;598;1;391;0
WireConnection;598;2;390;1
WireConnection;520;0;505;0
WireConnection;497;0;598;0
WireConnection;522;0;497;3
WireConnection;522;1;520;0
WireConnection;504;0;522;0
WireConnection;498;0;483;0
WireConnection;498;1;497;1
WireConnection;496;0;498;0
WireConnection;496;1;497;2
WireConnection;496;2;504;0
WireConnection;143;0;496;0
WireConnection;341;0;330;0
WireConnection;341;1;599;0
WireConnection;341;2;339;0
WireConnection;532;0;181;1
WireConnection;532;1;181;4
WireConnection;532;2;527;0
WireConnection;564;0;549;0
WireConnection;205;0;193;0
WireConnection;565;0;564;0
WireConnection;573;0;326;0
WireConnection;573;1;533;0
WireConnection;573;2;164;0
WireConnection;176;0;532;0
WireConnection;176;1;341;0
WireConnection;176;2;205;0
WireConnection;566;0;534;0
WireConnection;571;0;181;4
WireConnection;569;0;573;0
WireConnection;569;1;176;0
WireConnection;536;0;566;0
WireConnection;536;1;565;0
WireConnection;248;0;247;2
WireConnection;248;1;249;0
WireConnection;369;0;292;0
WireConnection;229;3;233;0
WireConnection;300;0;247;2
WireConnection;282;0;247;2
WireConnection;282;1;248;0
WireConnection;147;0;229;0
WireConnection;567;0;536;0
WireConnection;293;0;369;0
WireConnection;293;1;300;0
WireConnection;516;0;569;0
WireConnection;558;0;516;0
WireConnection;558;1;567;0
WireConnection;585;8;233;0
WireConnection;280;0;282;0
WireConnection;280;1;281;0
WireConnection;294;0;293;0
WireConnection;294;1;289;0
WireConnection;396;0;394;0
WireConnection;396;2;570;0
WireConnection;295;0;294;0
WireConnection;511;0;396;0
WireConnection;592;0;516;0
WireConnection;592;1;558;0
WireConnection;592;2;593;0
WireConnection;150;0;585;0
WireConnection;373;0;280;0
WireConnection;130;0;148;0
WireConnection;481;0;479;0
WireConnection;481;1;480;0
WireConnection;401;0;399;0
WireConnection;401;1;400;0
WireConnection;301;0;295;0
WireConnection;301;1;373;0
WireConnection;376;0;130;2
WireConnection;197;0;592;0
WireConnection;507;0;165;0
WireConnection;586;19;587;0
WireConnection;586;6;342;0
WireConnection;402;0;401;0
WireConnection;402;1;481;0
WireConnection;298;0;301;0
WireConnection;377;0;130;2
WireConnection;377;1;376;0
WireConnection;377;2;375;0
WireConnection;234;10;586;0
WireConnection;234;11;149;0
WireConnection;234;12;151;0
WireConnection;234;17;510;0
WireConnection;368;0;243;0
WireConnection;368;1;298;0
WireConnection;368;2;377;0
WireConnection;600;0;601;0
WireConnection;600;1;234;135
WireConnection;607;0;610;0
WireConnection;386;1;402;0
WireConnection;608;0;603;0
WireConnection;404;0;386;0
WireConnection;404;1;387;0
WireConnection;404;2;508;0
WireConnection;108;0;575;0
WireConnection;108;1;368;0
WireConnection;108;2;142;0
WireConnection;108;3;165;0
WireConnection;597;15;600;0
WireConnection;609;1;607;0
WireConnection;609;2;608;0
WireConnection;358;1;233;0
WireConnection;595;0;586;0
WireConnection;152;0;358;1
WireConnection;602;0;597;0
WireConnection;602;1;609;0
WireConnection;590;0;108;0
WireConnection;590;1;404;0
WireConnection;590;2;591;0
WireConnection;440;19;602;0
WireConnection;594;0;590;0
WireConnection;596;0;595;0
WireConnection;551;0;176;0
WireConnection;0;0;596;0
WireConnection;0;2;594;0
WireConnection;0;10;153;0
WireConnection;0;13;440;0
WireConnection;0;11;438;0
ASEEND*/
//CHKSM=F1CF77643EE84EE2075B209F22D71098E4E28F2D