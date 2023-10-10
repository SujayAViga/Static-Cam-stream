// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Parasol/SimpleStandard_Diffuse_shader"
{
	Properties
	{
		[Gamma][NoScaleOffset][Header(Base Color)]_BaseColor("Base Color", 2D) = "white" {}
		_DiffuseIntensity("Diffuse Intensity", Range( 0 , 1)) = 1
		[Gamma][NoScaleOffset]_TintMask("Tint Mask", 2D) = "white" {}
		[Gamma]_ColorTint("Base Color Tint", Color) = (1,1,1,0)
		[Enum(Material,0,Vertex,1)]_UseVertexColorforTint("Tint Color Source", Int) = 0
		[Header(Vertex AO)]_VertexAOMinimumValue("Vertex AO Minimum Value", Range( 0 , 1)) = 1
		_TextureTilingU("Texture Tiling U", Float) = 1
		_TextureTilingV("Texture Tiling V", Float) = 1
		[Header(Tiling)]_TextureOffsetU("Texture Offset U", Float) = 1
		_TextureOffsetV("Texture Offset V", Float) = 1
		[Enum(Off,0,On,1)]_PBRSafeFilter("PBR Safe Filter", Float) = 1
		_Roughness("Roughness", Range( 0 , 1)) = 0
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
		[Header(Per Pixel Fog Controls)]_PerPixelFogAmount("Per Pixel Fog Amount", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		Stencil
		{
			Ref 1
			Comp NotEqual
		}
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
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
			float3 worldNormal;
			INTERNAL_DATA
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
		uniform float _PBRSafeFilter;
		uniform sampler2D _EmissionTexture;
		uniform int LightBakeScenario;
		uniform float4 _EmissionColor;
		uniform float4 _EmissionCompliment;
		uniform float _HueMin;
		uniform float _HueMax;
		SamplerState sampler_EmissionTexture;
		uniform float4 _BakedEmissionColorDay;
		uniform float _DaytimeEmissiveValue;
		uniform float EmissiveGradient;
		uniform float _BakedEmissiveIntensityDay;
		uniform float4 _BakedEmissionColorNight;
		uniform float _BakedEmissiveIntensityNight;
		uniform float sg_ToonFog;
		uniform float sg_ColorLut;
		uniform sampler2D StandardLUT;
		uniform float _Roughness;
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


		float4 MyCustomExpression2_g309( int ScenarioIndex, float4 RuntimeLighting, float4 LightBakeDay, float4 LightBakeNight )
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


		inline float4 FeatureSwitch( float TestVal, float4 FeatureOn, float4 FeatureOff )
		{
			return TestVal>0?FeatureOn:FeatureOff;;
		}


		float MyCustomExpression8_g313( float fogStart, float fogEnd, float SurfaceDepth )
		{
			return saturate((SurfaceDepth-fogStart)/(fogEnd-fogStart));
		}


		float MyCustomExpression232_g313( float fogStart, float fogEnd, float SurfaceDepth )
		{
			return saturate((SurfaceDepth-fogStart)/(fogEnd-fogStart));
		}


		float MyCustomExpression233_g313( float fogStart, float fogEnd, float SurfaceDepth )
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
			float TestVal194_g313 = sg_ToonFog;
			float TestVal103_g312 = sg_ColorLut;
			SurfaceOutputStandard s9_g311 = (SurfaceOutputStandard ) 0;
			float2 appendResult82 = (float2(_TextureTilingU , _TextureTilingV));
			float2 appendResult336 = (float2(_TextureOffsetU , _TextureOffsetV));
			float2 uv_TexCoord80 = i.uv_texcoord * appendResult82 + appendResult336;
			float4 lerpResult3_g2 = lerp( float4(1,1,1,0) , tex2D( _BaseColor, uv_TexCoord80 ) , _DiffuseIntensity);
			float4 lerpResult15_g2 = lerp( _ColorTint , i.vertexColor , (float)_UseVertexColorforTint);
			float2 uv_TintMask13_g2 = i.uv_texcoord;
			float4 lerpResult29_g2 = lerp( lerpResult3_g2 , ( lerpResult3_g2 * lerpResult15_g2 ) , tex2D( _TintMask, uv_TintMask13_g2 ).r);
			float4 temp_output_6_0_g310 = lerpResult29_g2;
			float4 clampResult8_g310 = clamp( temp_output_6_0_g310 , float4( 0.1568628,0.1568628,0.1568628,0 ) , float4( 0.9411765,0.9411765,0.9411765,0.003921569 ) );
			float grayscale13_g310 = Luminance(temp_output_6_0_g310.rgb);
			float4 color16_g310 = IsGammaSpace() ? float4(1,1,1,1) : float4(1,1,1,1);
			float4 lerpResult5_g310 = lerp( clampResult8_g310 ,  ( grayscale13_g310 - 0.0 > 160.0 ? color16_g310 : grayscale13_g310 - 0.0 <= 160.0 && grayscale13_g310 + 0.0 >= 160.0 ? temp_output_6_0_g310 : temp_output_6_0_g310 )  , 0.0);
			float4 lerpResult17_g310 = lerp( temp_output_6_0_g310 , lerpResult5_g310 , _PBRSafeFilter);
			float4 temp_output_339_0 = lerpResult17_g310;
			s9_g311.Albedo = temp_output_339_0.rgb;
			float4 temp_output_11_0_g311 = float4( float3(0,0,1) , 0.0 );
			s9_g311.Normal = WorldNormalVector( i , temp_output_11_0_g311.rgb );
			float4 tex2DNode2_g308 = tex2D( _EmissionTexture, uv_TexCoord80 );
			int ScenarioIndex2_g309 = LightBakeScenario;
			float smoothstepResult73_g308 = smoothstep( _HueMin , _HueMax , tex2DNode2_g308.r);
			float4 lerpResult70_g308 = lerp( _EmissionColor , ( _EmissionColor * _EmissionCompliment ) , saturate( smoothstepResult73_g308 ));
			float4 InputColor15_g309 = lerpResult70_g308;
			float4 RuntimeLighting2_g309 = InputColor15_g309;
			#ifdef _OVERRIDEDAYCOLOR_ON
				float4 staticSwitch13_g309 = _BakedEmissionColorDay;
			#else
				float4 staticSwitch13_g309 = InputColor15_g309;
			#endif
			float lerpResult24_g308 = lerp( _DaytimeEmissiveValue , 1.0 , EmissiveGradient);
			#ifdef _OVERRIDEDAYCOLOR_ON
				float staticSwitch20_g309 = _BakedEmissiveIntensityDay;
			#else
				float staticSwitch20_g309 = lerpResult24_g308;
			#endif
			float4 LightBakeDay2_g309 = ( staticSwitch13_g309 * staticSwitch20_g309 );
			#ifdef _OVERRIDENIGHTCOLOR_ON
				float4 staticSwitch14_g309 = _BakedEmissionColorNight;
			#else
				float4 staticSwitch14_g309 = InputColor15_g309;
			#endif
			float4 LightBakeNight2_g309 = ( staticSwitch14_g309 * _BakedEmissiveIntensityNight );
			float4 localMyCustomExpression2_g309 = MyCustomExpression2_g309( ScenarioIndex2_g309 , RuntimeLighting2_g309 , LightBakeDay2_g309 , LightBakeNight2_g309 );
			float4 temp_output_386_0 = ( tex2DNode2_g308 * localMyCustomExpression2_g309 * lerpResult24_g308 );
			s9_g311.Emission = temp_output_386_0.rgb;
			s9_g311.Metallic = 0.0;
			s9_g311.Smoothness = ( 1.0 - _Roughness );
			float lerpResult24_g2 = lerp( i.vertexColor.a , 1.0 , _VertexAOMinimumValue);
			s9_g311.Occlusion = lerpResult24_g2;

			data.light = gi.light;

			UnityGI gi9_g311 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g9_g311 = UnityGlossyEnvironmentSetup( s9_g311.Smoothness, data.worldViewDir, s9_g311.Normal, float3(0,0,0));
			gi9_g311 = UnityGlobalIllumination( data, s9_g311.Occlusion, s9_g311.Normal, g9_g311 );
			#endif

			float3 surfResult9_g311 = LightingStandard ( s9_g311, viewDir, gi9_g311 ).rgb;
			surfResult9_g311 += s9_g311.Emission;

			#ifdef UNITY_PASS_FORWARDADD//9_g311
			surfResult9_g311 -= s9_g311.Emission;
			#endif//9_g311
			float3 inputColor100_g312 = surfResult9_g311;
			float ifLocalVar202_g312 = 0;
			if( LUTSize <= 2 )
				ifLocalVar202_g312 = (float)32;
			else
				ifLocalVar202_g312 = (float)LUTSize;
			float lutDim14_g312 = ifLocalVar202_g312;
			float temp_output_196_0_g312 = ( 1.0 / lutDim14_g312 );
			float3 temp_cast_21 = (temp_output_196_0_g312).xxx;
			float3 temp_cast_22 = (( 1.0 - temp_output_196_0_g312 )).xxx;
			float3 clampResult170_g312 = clamp( inputColor100_g312 , temp_cast_21 , temp_cast_22 );
			float3 break2_g312 = clampResult170_g312;
			float Red_U81_g312 = ( break2_g312.x / lutDim14_g312 );
			float temp_output_3_0_g312 = ( break2_g312.z * lutDim14_g312 );
			float Green_V75_g312 = break2_g312.y;
			float2 appendResult7_g312 = (float2(( Red_U81_g312 + ( ceil( temp_output_3_0_g312 ) / lutDim14_g312 ) ) , Green_V75_g312));
			float2 temp_output_183_0_g312 = saturate( appendResult7_g312 );
			float4 tex2DNode9_g312 = tex2Dlod( StandardLUT, float4( temp_output_183_0_g312, 0, 0.0) );
			float4 tex2DNode88_g312 = tex2Dlod( SecondLUT, float4( temp_output_183_0_g312, 0, 0.0) );
			float temp_output_182_0_g312 = saturate( EmissiveGradient );
			float4 lerpResult95_g312 = lerp( tex2DNode9_g312 , tex2DNode88_g312 , temp_output_182_0_g312);
			float4 FeatureOn103_g312 = lerpResult95_g312;
			float4 FeatureOff103_g312 = float4( inputColor100_g312 , 0.0 );
			float4 localFeatureSwitch103_g312 = FeatureSwitch( TestVal103_g312 , FeatureOn103_g312 , FeatureOff103_g312 );
			float4 temp_output_19_0_g313 = localFeatureSwitch103_g312;
			float fogStart8_g313 = fog_start;
			float fogEnd8_g313 = fog_end;
			float SurfaceDepth8_g313 = i.eyeDepth;
			float localMyCustomExpression8_g313 = MyCustomExpression8_g313( fogStart8_g313 , fogEnd8_g313 , SurfaceDepth8_g313 );
			float fogStart232_g313 = 0.0;
			float fogEnd232_g313 = fog_spread;
			float3 ase_worldPos = i.worldPos;
			float SurfaceDepth232_g313 = ase_worldPos.y;
			float localMyCustomExpression232_g313 = MyCustomExpression232_g313( fogStart232_g313 , fogEnd232_g313 , SurfaceDepth232_g313 );
			float2 appendResult89_g313 = (float2(localMyCustomExpression8_g313 , localMyCustomExpression232_g313));
			float4 fogInputs224_g313 = tex2D( fog_texture, appendResult89_g313 );
			float4 temp_output_111_0_g313 = fogInputs224_g313;
			float4 clampResult165_g313 = clamp( ( temp_output_19_0_g313 + temp_output_111_0_g313 ) , float4( 0,0,0,0 ) , temp_output_111_0_g313 );
			float fogStart233_g313 = fog_spread;
			float fogEnd233_g313 = fog_height;
			float SurfaceDepth233_g313 = ase_worldPos.y;
			float localMyCustomExpression233_g313 = MyCustomExpression233_g313( fogStart233_g313 , fogEnd233_g313 , SurfaceDepth233_g313 );
			float distanceGradiant226_g313 = saturate( ( localMyCustomExpression8_g313 * (localMyCustomExpression233_g313*FogHeightDensity + 0.0) ) );
			float4 lerpResult195_g313 = lerp( temp_output_19_0_g313 , clampResult165_g313 , ( distanceGradiant226_g313 * _PerPixelFogAmount ));
			float4 FeatureOn194_g313 = lerpResult195_g313;
			float4 FeatureOff194_g313 = temp_output_19_0_g313;
			float4 localFeatureSwitch194_g313 = FeatureSwitch( TestVal194_g313 , FeatureOn194_g313 , FeatureOff194_g313 );
			c.rgb = localFeatureSwitch194_g313.xyz;
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
			float2 appendResult336 = (float2(_TextureOffsetU , _TextureOffsetV));
			float2 uv_TexCoord80 = i.uv_texcoord * appendResult82 + appendResult336;
			float4 lerpResult3_g2 = lerp( float4(1,1,1,0) , tex2D( _BaseColor, uv_TexCoord80 ) , _DiffuseIntensity);
			float4 lerpResult15_g2 = lerp( _ColorTint , i.vertexColor , (float)_UseVertexColorforTint);
			float2 uv_TintMask13_g2 = i.uv_texcoord;
			float4 lerpResult29_g2 = lerp( lerpResult3_g2 , ( lerpResult3_g2 * lerpResult15_g2 ) , tex2D( _TintMask, uv_TintMask13_g2 ).r);
			float4 temp_output_6_0_g310 = lerpResult29_g2;
			float4 clampResult8_g310 = clamp( temp_output_6_0_g310 , float4( 0.1568628,0.1568628,0.1568628,0 ) , float4( 0.9411765,0.9411765,0.9411765,0.003921569 ) );
			float grayscale13_g310 = Luminance(temp_output_6_0_g310.rgb);
			float4 color16_g310 = IsGammaSpace() ? float4(1,1,1,1) : float4(1,1,1,1);
			float4 lerpResult5_g310 = lerp( clampResult8_g310 ,  ( grayscale13_g310 - 0.0 > 160.0 ? color16_g310 : grayscale13_g310 - 0.0 <= 160.0 && grayscale13_g310 + 0.0 >= 160.0 ? temp_output_6_0_g310 : temp_output_6_0_g310 )  , 0.0);
			float4 lerpResult17_g310 = lerp( temp_output_6_0_g310 , lerpResult5_g310 , _PBRSafeFilter);
			float4 temp_output_339_0 = lerpResult17_g310;
			o.Albedo = temp_output_339_0.rgb;
			float4 tex2DNode2_g308 = tex2D( _EmissionTexture, uv_TexCoord80 );
			int ScenarioIndex2_g309 = LightBakeScenario;
			float smoothstepResult73_g308 = smoothstep( _HueMin , _HueMax , tex2DNode2_g308.r);
			float4 lerpResult70_g308 = lerp( _EmissionColor , ( _EmissionColor * _EmissionCompliment ) , saturate( smoothstepResult73_g308 ));
			float4 InputColor15_g309 = lerpResult70_g308;
			float4 RuntimeLighting2_g309 = InputColor15_g309;
			#ifdef _OVERRIDEDAYCOLOR_ON
				float4 staticSwitch13_g309 = _BakedEmissionColorDay;
			#else
				float4 staticSwitch13_g309 = InputColor15_g309;
			#endif
			float lerpResult24_g308 = lerp( _DaytimeEmissiveValue , 1.0 , EmissiveGradient);
			#ifdef _OVERRIDEDAYCOLOR_ON
				float staticSwitch20_g309 = _BakedEmissiveIntensityDay;
			#else
				float staticSwitch20_g309 = lerpResult24_g308;
			#endif
			float4 LightBakeDay2_g309 = ( staticSwitch13_g309 * staticSwitch20_g309 );
			#ifdef _OVERRIDENIGHTCOLOR_ON
				float4 staticSwitch14_g309 = _BakedEmissionColorNight;
			#else
				float4 staticSwitch14_g309 = InputColor15_g309;
			#endif
			float4 LightBakeNight2_g309 = ( staticSwitch14_g309 * _BakedEmissiveIntensityNight );
			float4 localMyCustomExpression2_g309 = MyCustomExpression2_g309( ScenarioIndex2_g309 , RuntimeLighting2_g309 , LightBakeDay2_g309 , LightBakeNight2_g309 );
			float4 temp_output_386_0 = ( tex2DNode2_g308 * localMyCustomExpression2_g309 * lerpResult24_g308 );
			o.Emission = temp_output_386_0.rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma only_renderers d3d11 glcore gles3 metal 
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows nodynlightmap nodirlightmap vertex:vertexDataFunc 

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
2569.333;36;2472;1304;1651.129;743.2771;1.41225;True;False
Node;AmplifyShaderEditor.RangedFloatNode;83;-1155.835,62.57047;Inherit;False;Property;_TextureTilingU;Texture Tiling U;11;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;141;-1156.237,154.3074;Inherit;False;Property;_TextureTilingV;Texture Tiling V;12;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;337;-1148.749,262.1119;Inherit;False;Property;_TextureOffsetU;Texture Offset U;13;0;Create;True;0;0;False;1;Header(Tiling);False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;338;-1148.848,345.1536;Inherit;False;Property;_TextureOffsetV;Texture Offset V;14;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;336;-937.7985,243.1327;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;82;-951.1783,98.65798;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;80;-800.7899,66.93471;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;383;-553.2218,3.43919;Inherit;False;Parasol_BaseColor_SF;4;;2;449e373bc45bd994189f3f52b3d88f45;0;1;5;FLOAT2;0,0;False;2;COLOR;0;FLOAT;17
Node;AmplifyShaderEditor.WireNode;365;-301.7803,80.00735;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;386;-563.0649,166.9819;Inherit;False;Parasol_Emission_SF;18;;308;98a5bb71709445248bf940bbe0a18586;0;1;1;FLOAT2;1,1;False;2;FLOAT;7;COLOR;0
Node;AmplifyShaderEditor.WireNode;362;-244.4334,382.6175;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;380;-0.6531887,360.3771;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector3Node;361;51.65005,129.3751;Inherit;False;Constant;_Vector0;Vector 0;10;0;Create;True;0;0;False;0;False;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;144;-80.22674,249.3439;Inherit;False;Property;_Roughness;Roughness;17;0;Create;True;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;364;-83.32272,445.728;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;339;-213.1629,-66.06424;Inherit;False;PbrSafeColor;15;;310;fddc034c003e76d4ba732677cc318d42;0;3;19;FLOAT;0;False;6;COLOR;0.7333333,0.7333333,0.7333333,0.003921569;False;7;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;330;326.8919,154.7348;Inherit;False;ParasolCustomLighting;0;;311;dd582d5258e33374fbbbd0bc1271698d;1,136,0;6;10;COLOR;0.5019608,0.5019608,0.5019608,0;False;11;COLOR;0.5019608,0.5019608,1,1;False;12;FLOAT;1;False;15;FLOAT;0;False;16;COLOR;0,0,0,0;False;17;FLOAT;1;False;3;FLOAT3;147;FLOAT3;135;COLOR;112
Node;AmplifyShaderEditor.FunctionNode;382;654.7408,172.7433;Inherit;False;ParasolGlobalLut_;40;;312;415cf2c404453934193ab734c391e132;0;1;15;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;381;258.7811,35.82876;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;373;889.6685,168.7601;Inherit;False;Toon_DistanceFog;37;;313;87a2c17086d6be546a10c470a8adefc0;0;2;19;COLOR;0,0,0,0;False;111;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1344.893,-58.25603;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Parasol/SimpleStandard_Diffuse_shader;False;False;False;False;False;False;False;True;True;False;False;False;False;False;False;False;True;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;4;d3d11;glcore;gles3;metal;True;True;True;True;0;False;-1;True;1;False;-1;255;False;-1;255;False;-1;6;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;336;0;337;0
WireConnection;336;1;338;0
WireConnection;82;0;83;0
WireConnection;82;1;141;0
WireConnection;80;0;82;0
WireConnection;80;1;336;0
WireConnection;383;5;80;0
WireConnection;365;0;383;17
WireConnection;386;1;80;0
WireConnection;362;0;365;0
WireConnection;380;0;386;0
WireConnection;364;0;362;0
WireConnection;339;6;383;0
WireConnection;330;10;339;0
WireConnection;330;11;361;0
WireConnection;330;12;144;0
WireConnection;330;16;380;0
WireConnection;330;17;364;0
WireConnection;382;15;330;135
WireConnection;381;0;386;0
WireConnection;373;19;382;0
WireConnection;0;0;339;0
WireConnection;0;2;381;0
WireConnection;0;13;373;0
ASEEND*/
//CHKSM=952287A84C6FB58DED2ADC9717E06E0AF4A77BFF