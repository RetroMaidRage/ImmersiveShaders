
float normpdf(in float x, in float sigma)
{
 return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
}

vec4 GaussBlur(sampler2D color, vec2 Resolution){


const int mSize = 11;
const int kSize = (mSize-1)/2;
float kernel[mSize];
vec3 BlurGaussianQuallity = vec3(0.0);

float sigma = 7.0;
float Z = 0.0;
for (int j = 0; j <= kSize; ++j)
{
  kernel[kSize+j] = kernel[kSize-j] = normpdf(float(j), sigma);
}


for (int j = 0; j < mSize; ++j)
{
  Z += kernel[j];
}

for (int i=-kSize; i <= kSize; ++i)
{
  for (int j=-kSize; j <= kSize; ++j)
  {

    BlurGaussianQuallity += kernel[kSize+j]*kernel[kSize+i]*texture(color, (gl_FragCoord.xy+vec2(float(i),float(j))) / Resolution).rgb;
return vec4(BlurGaussianQuallity, 1.0);
  }
  }
   }
