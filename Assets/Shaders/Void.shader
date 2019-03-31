Shader "Unlit/Void"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			#define mod(x, y) (x-y*floor(x/y))
			#define T _Time.y * .1

			// toggle for psychedelic madness
			#define ENABLE_COLOR_CYCLE 0

			// FabriceNeyret2 
			#define hue(v)  (.5 + cos(6.3 * (v) + float4(0, 23, 21, 0)))

			static int id = -1;

			float2x2 rotate(float a) {
				float c = cos(a),
					s = sin(a);
				return float2x2(c, s, -s, c);
			}

			float random(in float2 st) {
				return frac(sin(dot(st.xy, float2(12.9898, 78.233))) * 43758.1);
			}

			float noise(float2 p) {
				float2 i = ceil(p);
				float2 f = frac(p);
				//float2 u = f * f * (3. - 2. * f); //Low Fps - High graphics
				float2 u = float2(1.0, 1.0); //Super high Fps - Muddy low graphics
				float a = random(i);
				float b = random(i + float2(1., 0.));
				float c = random(i + float2(0., 1.));
				float d = random(i + float2(1., 1.));
				return lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y);
			}

			float fbm(in float2 p) {
				float s = .0;
				float m = .0;
				float a = .5;
				for (int i = 0; i < 8; i++) {
					s += a * noise(p);
					m += a;
					a *= .5;
					p *= 2.;
				}
				return s / m;
			}

			float3 renderfracal(float2 uv) {

				float3 color = float3(0.0, 0.0, 0.0);
				float2 p = uv;

				// per channel iters
				float t = T;
				for (int c = 0; c < 3; c++) {

					t += .1; // time offset per channel
					float l = 0.;
					float s = 1.;
					for (int i = 0; i < 8; i++) {
						// from Kali's fracal iteration
						p = abs(p) / dot(p, p);
						p -= s;
						p = mul(p, rotate(t * .5));
						s *= .8;
						l += (s  * .08) / length(p);
					}
					switch (c)
					{
					case 0:
						color.x += l;
						break;
					case 1:
						color.y += l;
						break;
					case 2:
						color.z += l;
						break;
					}
				}
				return color;
			}

			float map(float3 p) {

				float m = 1000.;
				float3 q = p;
				float k = fbm(q.xz + fbm(q.xz + T * 0.25)); //waveiness

				q.y += .1;
				float d = dot(q, float3(0., 1.25, 0.)) + k * 1.0; //pos + peak height
				d = min(8. - d, d); //sky gap
				if (d < m) {
					m = d;
					id = 1;
				}
				return m;
			}

			float3 render(float3 ro, float3 rd) {

				float3 col = float3(0.0, 0.0, 0.0);
				float3 p;

				float t = 0.;
				for (int i = 0; i < 128; i++) {
					p = ro + rd * t;
					float d = map(p);
					if (d < .001 || t > 50.) break;
					t += .5 * d;
					#if ENABLE_COLOR_CYCLE 
					col += .02 * hue(d * .5 + cos(T) * .4).rgb;
					#else
					col += .02 * hue(d).rgb;
					#endif
				}
				col /= 1.5;
				/*
				float3 tex = renderfracal(frac(.1 * p.xz) - .5);
				if (id == 1) col += tex / (1. + t * t * .5);
				if (id == 2) col += abs(.1 / sin(10. * p.y + T)) * float3(0., 1., 1.); *///Spacey stuff

				return col;

			}

			fixed4 frag(v2f i) : SV_Target {
				float2 uv = i.uv;
				float3 ro = float3(2., 1., T * 2.);
				float3 rd = float3(uv, 0.5); //depth
				float3 pc = render(ro, rd); //ray origin, ray direction
				return float4(pc, 1.);
			}
			ENDCG
		}
	}
}
