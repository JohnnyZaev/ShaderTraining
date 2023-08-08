Shader "Unlit/Shader1"
{
    Properties // InputData
    {
        _ColorA ("Color A", Color) = (1, 1, 1, 1)
        _ColorB ("Color B", Color) = (1, 1, 1, 1)
        _ColorStart ("Color Start", Range(0, 1)) = 0
        _ColorEnd ("Color End", Range(0, 1)) = 1
        _WaveAmp ("Wave Amplitude", Range(0, 0.2)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent"
               "Queue"="Transparent"
        }

        Pass
        {
            // pass tags
            Cull Off
            ZWrite Off // now it will stop using depth buffer
            ZTest LEqual
            Blend One One // additive
            // Blend DstColor Zero // multiply
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define TAU 6.28318530718

            #include "UnityCG.cginc"

            fixed4 _ColorA;
            fixed4 _ColorB;
            float _ColorStart;
            float _ColorEnd;
            float _WaveAmp;

            struct MeshData // Per vertex mesh data
            {
                float4 vertex : POSITION; //vertex position
                float3 normals : NORMAL;
                // float4 tangent : TANGENT;
                // float4 color : COLOR;
                float2 uv0 : TEXCOORD0; // uv coordinates
                // float2 uv1 : TEXCOORD1; // uv coordinates
            };

            struct v2f // Interpolators
            {
                float4 vertex : SV_POSITION; // clip space position
                float3 normal : TEXTCOORD0;
                float2 uv0 : TEXCOORD1;
                // float2 uv : TEXCOORD0;
            };

            v2f vert (MeshData v)
            {
                v2f o; // o for output

                // float wave = cos((v.uv0.y - _Time.y * 0.1) * TAU * 5);
                // float wave2 = cos((v.uv0.x - _Time.y * 0.1) * TAU * 5);
                // v.vertex.y = wave * wave2 * _WaveAmp;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normals);
                o.uv0 = v.uv0; //(v.uv0 + _Offset) * _Scale;
                return o;
            }

            // float (32 bit float)
            // half (16 bit float)
            // fixed (lower precision)

            float InverseLerp(float a, float b, float v)
            {
                return (v - a) / (b - a);
            }

            float4 frag (v2f i) : SV_Target
            {

                // little animation in shader
                float xOffset = cos(i.uv0.y * TAU * 8) * 0.01;
                
                float t = cos((i.uv0.y + xOffset - _Time.y * 0.1) * TAU * 8) * 0.5 + 0.5;
                t *= 1 - i.uv0.y;

                float topBottomRemover = (abs(i.normal.y) < 0.999);
                float waves = t * topBottomRemover;

                float4 gradient = lerp(_ColorA, _ColorB, i.uv0.y);
                
                return gradient * waves;

                
                // TriangleWave
                // float t = abs(frac(i.uv0.x * 5) * 2 - 1);
                //
                // return t;

                
                // easy gradient shader
                // // frac = value - floor(value)
                // float t = saturate(InverseLerp(_ColorStart, _ColorEnd, i.uv0.x));
                // // t = frac(t); good way to test values < 0 && value > 1
                // fixed4 outColor = lerp(_ColorA, _ColorB, t);
                //
                // return outColor; 
            }
            ENDCG
        }
    }
}
