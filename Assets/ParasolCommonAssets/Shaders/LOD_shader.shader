// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Parasol/LOD_shader"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Background+1499" "ForceNoShadowCasting" = "True" }
		Cull Back
		Stencil
		{
			Ref 1
			Comp NotEqual
		}
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma only_renderers d3d11 glcore gles3 metal 
		#pragma surface surf StandardCustomLighting keepalpha noshadow exclude_path:deferred nolightmap  nodynlightmap nodirlightmap nometa noforwardadd vertex:vertexDataFunc 
		struct Input
		{
			half3 worldNormal;
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

		uniform half sg_ToonFog;
		uniform half sg_ColorLut;
		uniform sampler2D StandardLUT;
		uniform int LUTSize;
		uniform sampler2D SecondLUT;
		uniform half EmissiveGradient;
		uniform sampler2D fog_texture;
		uniform half fog_start;
		uniform half fog_end;
		uniform half fog_spread;
		uniform half fog_height;
		uniform half FogHeightDensity;


		inline half4 FeatureSwitch( half TestVal, half4 FeatureOn, half4 FeatureOff )
		{
			return TestVal>0?FeatureOn:FeatureOff;;
		}


		half MyCustomExpression8_g247( float fogStart, float fogEnd, float SurfaceDepth )
		{
			return saturate((SurfaceDepth-fogStart)/(fogEnd-fogStart));
		}


		half MyCustomExpression232_g247( float fogStart, float fogEnd, float SurfaceDepth )
		{
			return saturate((SurfaceDepth-fogStart)/(fogEnd-fogStart));
		}


		half MyCustomExpression233_g247( float fogStart, float fogEnd, float SurfaceDepth )
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
			half TestVal194_g247 = sg_ToonFog;
			half TestVal103_g1 = sg_ColorLut;
			SurfaceOutputStandard s9_g244 = (SurfaceOutputStandard ) 0;
			s9_g244.Albedo = half4(0.7333333,0.7333333,0.7333333,0).rgb;
			half4 temp_output_11_0_g244 = half4(0.5,0.5,1,1);
			s9_g244.Normal = WorldNormalVector( i , temp_output_11_0_g244.rgb );
			s9_g244.Emission = float4( 0,0,0,0 ).rgb;
			s9_g244.Metallic = 0.0;
			s9_g244.Smoothness = ( 1.0 - ( 1.0 - 0.0 ) );
			s9_g244.Occlusion = 1.0;

			data.light = gi.light;

			UnityGI gi9_g244 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g9_g244 = UnityGlossyEnvironmentSetup( s9_g244.Smoothness, data.worldViewDir, s9_g244.Normal, float3(0,0,0));
			gi9_g244 = UnityGlobalIllumination( data, s9_g244.Occlusion, s9_g244.Normal, g9_g244 );
			#endif

			float3 surfResult9_g244 = LightingStandard ( s9_g244, viewDir, gi9_g244 ).rgb;
			surfResult9_g244 += s9_g244.Emission;

			#ifdef UNITY_PASS_FORWARDADD//9_g244
			surfResult9_g244 -= s9_g244.Emission;
			#endif//9_g244
			half3 inputColor100_g1 = surfResult9_g244;
			int lutDim14_g1 = LUTSize;
			half temp_output_196_0_g1 = ( 1.0 / lutDim14_g1 );
			half3 temp_cast_3 = (temp_output_196_0_g1).xxx;
			half3 temp_cast_4 = (( 1.0 - temp_output_196_0_g1 )).xxx;
			half3 clampResult170_g1 = clamp( inputColor100_g1 , temp_cast_3 , temp_cast_4 );
			half3 break2_g1 = clampResult170_g1;
			half Red_U81_g1 = ( break2_g1.x / lutDim14_g1 );
			half temp_output_3_0_g1 = ( break2_g1.z * lutDim14_g1 );
			half Green_V75_g1 = break2_g1.y;
			half2 appendResult7_g1 = (half2(( Red_U81_g1 + ( ceil( temp_output_3_0_g1 ) / lutDim14_g1 ) ) , Green_V75_g1));
			half2 temp_output_183_0_g1 = saturate( appendResult7_g1 );
			half4 tex2DNode9_g1 = tex2Dlod( StandardLUT, float4( temp_output_183_0_g1, 0, 0.0) );
			half4 tex2DNode88_g1 = tex2Dlod( SecondLUT, float4( temp_output_183_0_g1, 0, 0.0) );
			half temp_output_182_0_g1 = saturate( EmissiveGradient );
			half4 lerpResult95_g1 = lerp( tex2DNode9_g1 , tex2DNode88_g1 , temp_output_182_0_g1);
			half4 FeatureOn103_g1 = lerpResult95_g1;
			half4 FeatureOff103_g1 = half4( inputColor100_g1 , 0.0 );
			half4 localFeatureSwitch103_g1 = FeatureSwitch( TestVal103_g1 , FeatureOn103_g1 , FeatureOff103_g1 );
			half4 temp_output_19_0_g247 = localFeatureSwitch103_g1;
			half fogStart8_g247 = fog_start;
			half fogEnd8_g247 = fog_end;
			half SurfaceDepth8_g247 = i.eyeDepth;
			half localMyCustomExpression8_g247 = MyCustomExpression8_g247( fogStart8_g247 , fogEnd8_g247 , SurfaceDepth8_g247 );
			half fogStart232_g247 = 0.0;
			half fogEnd232_g247 = fog_spread;
			float3 ase_worldPos = i.worldPos;
			half SurfaceDepth232_g247 = ase_worldPos.y;
			half localMyCustomExpression232_g247 = MyCustomExpression232_g247( fogStart232_g247 , fogEnd232_g247 , SurfaceDepth232_g247 );
			half2 appendResult89_g247 = (half2(localMyCustomExpression8_g247 , localMyCustomExpression232_g247));
			half4 fogInputs224_g247 = tex2D( fog_texture, appendResult89_g247 );
			half4 temp_output_111_0_g247 = fogInputs224_g247;
			half4 clampResult165_g247 = clamp( ( temp_output_19_0_g247 + temp_output_111_0_g247 ) , float4( 0,0,0,0 ) , temp_output_111_0_g247 );
			half fogStart233_g247 = fog_spread;
			half fogEnd233_g247 = fog_height;
			half SurfaceDepth233_g247 = ase_worldPos.y;
			half localMyCustomExpression233_g247 = MyCustomExpression233_g247( fogStart233_g247 , fogEnd233_g247 , SurfaceDepth233_g247 );
			half distanceGradiant226_g247 = saturate( ( localMyCustomExpression8_g247 * (localMyCustomExpression233_g247*FogHeightDensity + 0.0) ) );
			half4 lerpResult195_g247 = lerp( temp_output_19_0_g247 , clampResult165_g247 , distanceGradiant226_g247);
			half4 FeatureOn194_g247 = lerpResult195_g247;
			half4 FeatureOff194_g247 = temp_output_19_0_g247;
			half4 localFeatureSwitch194_g247 = FeatureSwitch( TestVal194_g247 , FeatureOn194_g247 , FeatureOff194_g247 );
			c.rgb = localFeatureSwitch194_g247.xyz;
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
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
-2074;479.3333;1722;853;2290.39;280.0113;1.647603;True;False
Node;AmplifyShaderEditor.RangedFloatNode;31;-1275.508,420.3857;Inherit;False;Constant;_BaseValue;BaseValue;2;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;42;-1214.177,189.1163;Inherit;False;Constant;_NormalColor;NormalColor;2;0;Create;True;0;0;False;0;False;0.5,0.5,1,1;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;35;-1058.807,388.5785;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;25;-1101.46,-7.849825;Inherit;False;Constant;_BaseColor;BaseColor;2;0;Create;True;0;0;False;0;False;0.7333333,0.7333333,0.7333333,0;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;36;-629.6365,320.6238;Inherit;False;ParasolCustomLighting;0;;244;dd582d5258e33374fbbbd0bc1271698d;1,136,0;6;10;COLOR;0.5019608,0.5019608,0.5019608,0;False;11;COLOR;0.5019608,0.5019608,1,1;False;12;FLOAT;1;False;15;FLOAT;0;False;16;COLOR;0,0,0,0;False;17;FLOAT;1;False;3;FLOAT3;147;FLOAT3;135;COLOR;112
Node;AmplifyShaderEditor.FunctionNode;49;-271.2516,327.9542;Inherit;False;ParasolGlobalLut_;7;;1;415cf2c404453934193ab734c391e132;0;1;15;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.VertexColorNode;37;-1082.815,487.1976;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;46;-14.03353,270.7571;Inherit;False;Toon_DistanceFog;4;;247;87a2c17086d6be546a10c470a8adefc0;0;2;19;COLOR;0,0,0,0;False;111;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;3;758.051,114.5821;Half;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Parasol/LOD_shader;False;False;False;False;False;False;True;True;True;False;True;True;False;False;False;True;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;1;False;-1;5;False;-1;False;0;Custom;0.5;True;False;1499;True;Opaque;;Background;ForwardOnly;4;d3d11;glcore;gles3;metal;True;True;True;True;0;False;-1;True;1;False;-1;255;False;-1;255;False;-1;6;False;-1;0;False;-1;0;False;-1;0;False;-1;6;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;6;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;35;0;31;0
WireConnection;36;10;25;0
WireConnection;36;11;42;0
WireConnection;36;12;35;0
WireConnection;49;15;36;135
WireConnection;46;19;49;0
WireConnection;3;13;46;0
ASEEND*/
//CHKSM=09AC9A05A7D5EC7A3E31D3FE2ADAE6BC5B4FE67A