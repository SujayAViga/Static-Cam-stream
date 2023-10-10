// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Parasol/SimpleStandard(AlphaBlend)_shader"
{
	Properties
	{
		[Header(Per Pixel Fog Controls)]_PerPixelFogAmount("Per Pixel Fog Amount", Range( 0 , 1)) = 1
		[Gamma][NoScaleOffset][Header(Base Color)]_BaseColor("Base Color", 2D) = "white" {}
		_DiffuseIntensity("Diffuse Intensity", Range( 0 , 1)) = 1
		[Gamma][NoScaleOffset]_TintMask("Tint Mask", 2D) = "white" {}
		[Gamma]_ColorTint("Base Color Tint", Color) = (1,1,1,0)
		[Enum(Material,0,Vertex,1)]_UseVertexColorforTint("Tint Color Source", Int) = 0
		[Header(Vertex AO)]_VertexAOMinimumValue("Vertex AO Minimum Value", Range( 0 , 1)) = 1
		[Enum(Off,0,On,1)]_PBRSafeFilter("PBR Safe Filter", Float) = 1
		_TextureTilingU("Texture Tiling U", Float) = 1
		_TextureTilingV("Texture Tiling V", Float) = 1
		_TextureOffsetU("Texture Offset  U", Float) = 0
		_TextureOffsetV("Texture Offset V", Float) = 0
		[NoScaleOffset][Header(Normal)]_Normal("Normal", 2D) = "bump" {}
		_NormalScale("Normal Scale", Range( 0 , 1)) = 1
		[NoScaleOffset][Header(Roughness)]_RMAO("Roughness", 2D) = "white" {}
		_RoughnessCeiling("Roughness Ceiling", Range( 0 , 1)) = 1
		_RoughnessFloor("Roughness Floor", Range( 0 , 1)) = 0
		_RoughnessContrast("Roughness Contrast", Range( 0 , 10)) = 1
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
		[NoScaleOffset]_OpacityTexture("Opacity Texture", 2D) = "white" {}
		[Header(Opacity)]_Opacity("Opacity", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] _texcoord4( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#pragma shader_feature_local _OVERRIDEDAYCOLOR_ON
		#pragma shader_feature_local _OVERRIDENIGHTCOLOR_ON
		#pragma only_renderers d3d11 glcore gles3 metal 
		#pragma surface surf StandardCustomLighting alpha:fade keepalpha noshadow exclude_path:deferred nodynlightmap nodirlightmap vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
			float2 uv4_texcoord4;
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
		uniform sampler2D _MetallicMask;
		SamplerState sampler_MetallicMask;
		uniform float _IncreaseMetalness;
		uniform float _PBRSafeFilter;
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
		uniform float EmissiveGradient;
		uniform float _BakedEmissiveIntensityDay;
		uniform float4 _BakedEmissionColorNight;
		uniform float _BakedEmissiveIntensityNight;
		uniform float _Opacity;
		uniform sampler2D _OpacityTexture;
		SamplerState sampler_OpacityTexture;
		uniform float sg_ToonFog;
		uniform float sg_ColorLut;
		uniform sampler2D StandardLUT;
		uniform sampler2D _Normal;
		uniform float _NormalScale;
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


		float2 MyCustomExpression59_g184( int UVChannel, float2 UV1, float2 UV4 )
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


		float4 MyCustomExpression2_g185( int ScenarioIndex, float4 RuntimeLighting, float4 LightBakeDay, float4 LightBakeNight )
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


		float4 CalculateContrast( float contrastValue, float4 colorTarget )
		{
			float t = 0.5 * ( 1.0 - contrastValue );
			return mul( float4x4( contrastValue,0,0,t, 0,contrastValue,0,t, 0,0,contrastValue,t, 0,0,0,1 ), colorTarget );
		}

		inline float4 FeatureSwitch( float TestVal, float4 FeatureOn, float4 FeatureOff )
		{
			return TestVal>0?FeatureOn:FeatureOff;;
		}


		float MyCustomExpression8_g183( float fogStart, float fogEnd, float SurfaceDepth )
		{
			return saturate((SurfaceDepth-fogStart)/(fogEnd-fogStart));
		}


		float MyCustomExpression232_g183( float fogStart, float fogEnd, float SurfaceDepth )
		{
			return saturate((SurfaceDepth-fogStart)/(fogEnd-fogStart));
		}


		float MyCustomExpression233_g183( float fogStart, float fogEnd, float SurfaceDepth )
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
			float2 uv_OpacityTexture108 = i.uv_texcoord;
			float TestVal194_g183 = sg_ToonFog;
			float TestVal103_g182 = sg_ColorLut;
			SurfaceOutputStandard s9_g181 = (SurfaceOutputStandard ) 0;
			float2 appendResult104 = (float2(_TextureTilingU , _TextureTilingV));
			float2 appendResult165 = (float2(_TextureOffsetU , _TextureOffsetV));
			float2 uv_TexCoord102 = i.uv_texcoord * appendResult104 + appendResult165;
			float4 lerpResult3_g146 = lerp( float4(1,1,1,0) , tex2D( _BaseColor, uv_TexCoord102 ) , _DiffuseIntensity);
			float4 lerpResult15_g146 = lerp( _ColorTint , i.vertexColor , (float)_UseVertexColorforTint);
			float2 uv_TintMask13_g146 = i.uv_texcoord;
			float4 lerpResult29_g146 = lerp( lerpResult3_g146 , ( lerpResult3_g146 * lerpResult15_g146 ) , tex2D( _TintMask, uv_TintMask13_g146 ).r);
			float4 temp_output_6_0_g180 = lerpResult29_g146;
			float4 clampResult8_g180 = clamp( temp_output_6_0_g180 , float4( 0.1568628,0.1568628,0.1568628,0 ) , float4( 0.9411765,0.9411765,0.9411765,0.003921569 ) );
			float grayscale13_g180 = Luminance(temp_output_6_0_g180.rgb);
			float4 color16_g180 = IsGammaSpace() ? float4(1,1,1,1) : float4(1,1,1,1);
			float temp_output_150_0 = (_IncreaseMetalness + (tex2D( _MetallicMask, uv_TexCoord102 ).r - 0.0) * (1.0 - _IncreaseMetalness) / (1.0 - 0.0));
			float4 lerpResult5_g180 = lerp( clampResult8_g180 ,  ( grayscale13_g180 - 0.0 > 160.0 ? color16_g180 : grayscale13_g180 - 0.0 <= 160.0 && grayscale13_g180 + 0.0 >= 160.0 ? temp_output_6_0_g180 : temp_output_6_0_g180 )  , temp_output_150_0);
			float4 lerpResult17_g180 = lerp( temp_output_6_0_g180 , lerpResult5_g180 , _PBRSafeFilter);
			float4 temp_output_162_0 = lerpResult17_g180;
			s9_g181.Albedo = temp_output_162_0.rgb;
			float4 temp_output_11_0_g181 = float4( UnpackScaleNormal( tex2D( _Normal, uv_TexCoord102 ), _NormalScale ) , 0.0 );
			s9_g181.Normal = WorldNormalVector( i , temp_output_11_0_g181.rgb );
			s9_g181.Emission = float4( 0,0,0,0 ).rgb;
			s9_g181.Metallic = temp_output_150_0;
			s9_g181.Smoothness = ( 1.0 - (_RoughnessFloor + (saturate( (CalculateContrast(_RoughnessContrast,tex2D( _RMAO, uv_TexCoord102 ))).r ) - 0.0) * (_RoughnessCeiling - _RoughnessFloor) / (1.0 - 0.0)) );
			float lerpResult24_g146 = lerp( i.vertexColor.a , 1.0 , _VertexAOMinimumValue);
			s9_g181.Occlusion = lerpResult24_g146;

			data.light = gi.light;

			UnityGI gi9_g181 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g9_g181 = UnityGlossyEnvironmentSetup( s9_g181.Smoothness, data.worldViewDir, s9_g181.Normal, float3(0,0,0));
			gi9_g181 = UnityGlobalIllumination( data, s9_g181.Occlusion, s9_g181.Normal, g9_g181 );
			#endif

			float3 surfResult9_g181 = LightingStandard ( s9_g181, viewDir, gi9_g181 ).rgb;
			surfResult9_g181 += s9_g181.Emission;

			#ifdef UNITY_PASS_FORWARDADD//9_g181
			surfResult9_g181 -= s9_g181.Emission;
			#endif//9_g181
			float3 inputColor100_g182 = surfResult9_g181;
			float ifLocalVar202_g182 = 0;
			if( LUTSize <= 2 )
				ifLocalVar202_g182 = (float)32;
			else
				ifLocalVar202_g182 = (float)LUTSize;
			float lutDim14_g182 = ifLocalVar202_g182;
			float temp_output_196_0_g182 = ( 1.0 / lutDim14_g182 );
			float3 temp_cast_17 = (temp_output_196_0_g182).xxx;
			float3 temp_cast_18 = (( 1.0 - temp_output_196_0_g182 )).xxx;
			float3 clampResult170_g182 = clamp( inputColor100_g182 , temp_cast_17 , temp_cast_18 );
			float3 break2_g182 = clampResult170_g182;
			float Red_U81_g182 = ( break2_g182.x / lutDim14_g182 );
			float temp_output_3_0_g182 = ( break2_g182.z * lutDim14_g182 );
			float Green_V75_g182 = break2_g182.y;
			float2 appendResult7_g182 = (float2(( Red_U81_g182 + ( ceil( temp_output_3_0_g182 ) / lutDim14_g182 ) ) , Green_V75_g182));
			float2 temp_output_183_0_g182 = saturate( appendResult7_g182 );
			float4 tex2DNode9_g182 = tex2Dlod( StandardLUT, float4( temp_output_183_0_g182, 0, 0.0) );
			float4 tex2DNode88_g182 = tex2Dlod( SecondLUT, float4( temp_output_183_0_g182, 0, 0.0) );
			float temp_output_182_0_g182 = saturate( EmissiveGradient );
			float4 lerpResult95_g182 = lerp( tex2DNode9_g182 , tex2DNode88_g182 , temp_output_182_0_g182);
			float4 FeatureOn103_g182 = lerpResult95_g182;
			float4 FeatureOff103_g182 = float4( inputColor100_g182 , 0.0 );
			float4 localFeatureSwitch103_g182 = FeatureSwitch( TestVal103_g182 , FeatureOn103_g182 , FeatureOff103_g182 );
			float4 temp_output_19_0_g183 = localFeatureSwitch103_g182;
			float fogStart8_g183 = fog_start;
			float fogEnd8_g183 = fog_end;
			float SurfaceDepth8_g183 = i.eyeDepth;
			float localMyCustomExpression8_g183 = MyCustomExpression8_g183( fogStart8_g183 , fogEnd8_g183 , SurfaceDepth8_g183 );
			float fogStart232_g183 = 0.0;
			float fogEnd232_g183 = fog_spread;
			float3 ase_worldPos = i.worldPos;
			float SurfaceDepth232_g183 = ase_worldPos.y;
			float localMyCustomExpression232_g183 = MyCustomExpression232_g183( fogStart232_g183 , fogEnd232_g183 , SurfaceDepth232_g183 );
			float2 appendResult89_g183 = (float2(localMyCustomExpression8_g183 , localMyCustomExpression232_g183));
			float4 fogInputs224_g183 = tex2D( fog_texture, appendResult89_g183 );
			float4 temp_output_111_0_g183 = fogInputs224_g183;
			float4 clampResult165_g183 = clamp( ( temp_output_19_0_g183 + temp_output_111_0_g183 ) , float4( 0,0,0,0 ) , temp_output_111_0_g183 );
			float fogStart233_g183 = fog_spread;
			float fogEnd233_g183 = fog_height;
			float SurfaceDepth233_g183 = ase_worldPos.y;
			float localMyCustomExpression233_g183 = MyCustomExpression233_g183( fogStart233_g183 , fogEnd233_g183 , SurfaceDepth233_g183 );
			float distanceGradiant226_g183 = saturate( ( localMyCustomExpression8_g183 * (localMyCustomExpression233_g183*FogHeightDensity + 0.0) ) );
			float4 lerpResult195_g183 = lerp( temp_output_19_0_g183 , clampResult165_g183 , ( distanceGradiant226_g183 * _PerPixelFogAmount ));
			float4 FeatureOn194_g183 = lerpResult195_g183;
			float4 FeatureOff194_g183 = temp_output_19_0_g183;
			float4 localFeatureSwitch194_g183 = FeatureSwitch( TestVal194_g183 , FeatureOn194_g183 , FeatureOff194_g183 );
			c.rgb = localFeatureSwitch194_g183.xyz;
			c.a = ( _Opacity * tex2D( _OpacityTexture, uv_OpacityTexture108 ).r );
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
			float2 appendResult104 = (float2(_TextureTilingU , _TextureTilingV));
			float2 appendResult165 = (float2(_TextureOffsetU , _TextureOffsetV));
			float2 uv_TexCoord102 = i.uv_texcoord * appendResult104 + appendResult165;
			float4 lerpResult3_g146 = lerp( float4(1,1,1,0) , tex2D( _BaseColor, uv_TexCoord102 ) , _DiffuseIntensity);
			float4 lerpResult15_g146 = lerp( _ColorTint , i.vertexColor , (float)_UseVertexColorforTint);
			float2 uv_TintMask13_g146 = i.uv_texcoord;
			float4 lerpResult29_g146 = lerp( lerpResult3_g146 , ( lerpResult3_g146 * lerpResult15_g146 ) , tex2D( _TintMask, uv_TintMask13_g146 ).r);
			float4 temp_output_6_0_g180 = lerpResult29_g146;
			float4 clampResult8_g180 = clamp( temp_output_6_0_g180 , float4( 0.1568628,0.1568628,0.1568628,0 ) , float4( 0.9411765,0.9411765,0.9411765,0.003921569 ) );
			float grayscale13_g180 = Luminance(temp_output_6_0_g180.rgb);
			float4 color16_g180 = IsGammaSpace() ? float4(1,1,1,1) : float4(1,1,1,1);
			float temp_output_150_0 = (_IncreaseMetalness + (tex2D( _MetallicMask, uv_TexCoord102 ).r - 0.0) * (1.0 - _IncreaseMetalness) / (1.0 - 0.0));
			float4 lerpResult5_g180 = lerp( clampResult8_g180 ,  ( grayscale13_g180 - 0.0 > 160.0 ? color16_g180 : grayscale13_g180 - 0.0 <= 160.0 && grayscale13_g180 + 0.0 >= 160.0 ? temp_output_6_0_g180 : temp_output_6_0_g180 )  , temp_output_150_0);
			float4 lerpResult17_g180 = lerp( temp_output_6_0_g180 , lerpResult5_g180 , _PBRSafeFilter);
			float4 temp_output_162_0 = lerpResult17_g180;
			o.Albedo = temp_output_162_0.rgb;
			int UVChannel59_g184 = _UVChannel;
			float2 appendResult67_g184 = (float2(_EmissionTilingX , _EmissionTilingY));
			float2 appendResult23_g184 = (float2(_EmissionOffsetX , _EmissionOffsetY));
			float2 uv_TexCoord6_g184 = i.uv_texcoord * appendResult67_g184 + appendResult23_g184;
			float2 UV159_g184 = uv_TexCoord6_g184;
			float2 uv4_TexCoord25_g184 = i.uv4_texcoord4 * appendResult67_g184 + appendResult23_g184;
			float2 UV459_g184 = uv4_TexCoord25_g184;
			float2 localMyCustomExpression59_g184 = MyCustomExpression59_g184( UVChannel59_g184 , UV159_g184 , UV459_g184 );
			float4 tex2DNode2_g184 = tex2D( _EmissionTexture, localMyCustomExpression59_g184 );
			int ScenarioIndex2_g185 = LightBakeScenario;
			float smoothstepResult73_g184 = smoothstep( _HueMin , _HueMax , tex2DNode2_g184.r);
			float4 lerpResult70_g184 = lerp( _EmissionColor , ( _EmissionColor * _EmissionCompliment ) , saturate( smoothstepResult73_g184 ));
			float4 InputColor15_g185 = lerpResult70_g184;
			float4 RuntimeLighting2_g185 = InputColor15_g185;
			#ifdef _OVERRIDEDAYCOLOR_ON
				float4 staticSwitch13_g185 = _BakedEmissionColorDay;
			#else
				float4 staticSwitch13_g185 = InputColor15_g185;
			#endif
			float lerpResult24_g184 = lerp( _DaytimeEmissiveValue , 1.0 , EmissiveGradient);
			#ifdef _OVERRIDEDAYCOLOR_ON
				float staticSwitch20_g185 = _BakedEmissiveIntensityDay;
			#else
				float staticSwitch20_g185 = lerpResult24_g184;
			#endif
			float4 LightBakeDay2_g185 = ( staticSwitch13_g185 * staticSwitch20_g185 );
			#ifdef _OVERRIDENIGHTCOLOR_ON
				float4 staticSwitch14_g185 = _BakedEmissionColorNight;
			#else
				float4 staticSwitch14_g185 = InputColor15_g185;
			#endif
			float4 LightBakeNight2_g185 = ( staticSwitch14_g185 * _BakedEmissiveIntensityNight );
			float4 localMyCustomExpression2_g185 = MyCustomExpression2_g185( ScenarioIndex2_g185 , RuntimeLighting2_g185 , LightBakeDay2_g185 , LightBakeNight2_g185 );
			o.Emission = ( tex2DNode2_g184 * localMyCustomExpression2_g185 * lerpResult24_g184 ).rgb;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
2569.333;36;2472;1304;2125.34;1365.136;1.963872;True;False
Node;AmplifyShaderEditor.CommentaryNode;116;-1354.379,138.6463;Inherit;False;574.5488;410.1509;;7;165;164;163;102;104;103;148;Tiling Controller;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;164;-1307.355,349.0148;Inherit;False;Property;_TextureOffsetU;Texture Offset  U;21;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;163;-1306.355,436.0149;Inherit;False;Property;_TextureOffsetV;Texture Offset V;22;0;Create;True;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;148;-1301.192,256.9804;Inherit;False;Property;_TextureTilingV;Texture Tiling V;20;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;103;-1302.551,181.4145;Inherit;False;Property;_TextureTilingU;Texture Tiling U;19;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;104;-1126.051,210.8198;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;165;-1104.379,376.0005;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;102;-997.5966,186.6463;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;113;-726.5137,-117.0301;Inherit;False;634.4745;208.7382;;2;162;187;Base Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;115;-713.6849,241.8813;Inherit;False;220.0001;139;;1;141;Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;150;-690.1742,146.8201;Inherit;False;Parasol_Metallic_SF;31;;145;ea0886127b2db2e4d86d4f18d4d302b3;0;1;4;FLOAT2;1,1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;187;-701.3464,-57.14062;Inherit;False;Parasol_BaseColor_SF;10;;146;449e373bc45bd994189f3f52b3d88f45;0;1;5;FLOAT2;0,0;False;2;COLOR;0;FLOAT;17
Node;AmplifyShaderEditor.CommentaryNode;145;-712.3814,386.8894;Inherit;False;329;161;;1;156;Roughness;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;162;-432.4004,-50.57752;Inherit;False;PbrSafeColor;17;;180;fddc034c003e76d4ba732677cc318d42;0;3;19;FLOAT;0;False;6;COLOR;0.7333333,0.7333333,0.7333333,0.003921569;False;7;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;156;-662.3814,435.0903;Inherit;False;Parasol_Roughness_SF;26;;178;bf68fe7a0dbe8c14686bde4c8c387417;0;1;8;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;141;-707.8415,283.8897;Inherit;False;Parasol_Normal_SF;23;;179;c1afb3f5e736a1b44ba607c69344914d;0;1;3;FLOAT2;1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;158;-41.01932,42.71076;Inherit;False;ParasolCustomLighting;0;;181;dd582d5258e33374fbbbd0bc1271698d;1,136,0;6;10;COLOR;1,0,0.8704052,0;False;11;COLOR;0,0,0.5,1;False;12;FLOAT;1;False;15;FLOAT;0;False;16;COLOR;0,0,0,0;False;17;FLOAT;1;False;3;FLOAT3;147;FLOAT3;135;COLOR;112
Node;AmplifyShaderEditor.CommentaryNode;111;33.26731,-333.5764;Inherit;False;564.1832;318.4095;;3;109;76;108;Opacity;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;186;330.0702,143.6454;Inherit;False;ParasolGlobalLut_;7;;182;415cf2c404453934193ab734c391e132;0;1;15;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;76;85.31384,-283.5764;Inherit;False;Property;_Opacity;Opacity;54;0;Create;True;0;0;False;1;Header(Opacity);False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;169;-22.78674,-380.1387;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;108;47.07613,-208.9754;Inherit;True;Property;_OpacityTexture;Opacity Texture;53;1;[NoScaleOffset];Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;170;491.2336,-525.2857;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;109;372.8085,-255.3825;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;174;623.2582,79.93234;Inherit;False;Toon_DistanceFog;4;;183;87a2c17086d6be546a10c470a8adefc0;0;2;19;COLOR;0,0,0,0;False;111;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;188;675.7978,-331.6941;Inherit;False;Parasol_Emission_SF;34;;184;98a5bb71709445248bf940bbe0a18586;0;1;1;FLOAT2;0,0;False;2;FLOAT;7;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1284.494,-321.5318;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Parasol/SimpleStandard(AlphaBlend)_shader;False;False;False;False;False;False;False;True;True;False;False;False;False;False;True;False;True;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;ForwardOnly;4;d3d11;glcore;gles3;metal;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;114;-717.248,96.37463;Inherit;False;260.7063;138.1449;;0;Metallic;1,1,1,1;0;0
WireConnection;104;0;103;0
WireConnection;104;1;148;0
WireConnection;165;0;164;0
WireConnection;165;1;163;0
WireConnection;102;0;104;0
WireConnection;102;1;165;0
WireConnection;150;4;102;0
WireConnection;187;5;102;0
WireConnection;162;6;187;0
WireConnection;162;7;150;0
WireConnection;156;8;102;0
WireConnection;141;3;102;0
WireConnection;158;10;162;0
WireConnection;158;11;141;0
WireConnection;158;12;156;0
WireConnection;158;15;150;0
WireConnection;158;17;187;17
WireConnection;186;15;158;135
WireConnection;169;0;162;0
WireConnection;170;0;169;0
WireConnection;109;0;76;0
WireConnection;109;1;108;1
WireConnection;174;19;186;0
WireConnection;0;0;170;0
WireConnection;0;2;188;0
WireConnection;0;9;109;0
WireConnection;0;13;174;0
ASEEND*/
//CHKSM=27AF5E6B9BAE634DB642111C548FADFEED007DC1