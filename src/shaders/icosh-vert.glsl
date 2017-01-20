uniform float time;
varying vec2 vUv;
varying vec3 col;
uniform int data[1024];

float Noise(in int x, in int y, in int z)
{
    float a;
	//int b;
    //b = x + y*13 + z*53 + 104543;
   // b = (b<<13) ^ b;
    //a = 1.0 - ((b*(b*b*15731+789221)+1376312589) & 0x7fffffff) / 1073741824.0;
    //a=(a+1)/2;
	
	a=fract(sin(dot(vec3(x,y,z),vec3(12.9898,78.233,138.531))) * 43758.5453);
    return a;
}

float smoothnoise(int x2, int y2, int z2)
{	
	float noise;
	float div;
	for(float i=-1.0;i<2.0;i++)
	{
		for(float j=-1.0;j<2.0;j++)
		{
			for(float k=-1.0;k<2.0;k++)
			{
				if(abs(i)+abs(j)+abs(k)==3.0)
					div=32.0;
				else if(abs(i)+abs(j)+abs(k)==2.0)
					div=16.0;
				else if(abs(i)+abs(j)+abs(k)==1.0)
					div=12.0;
				else
					div=4.0;
					
				noise += Noise(x2+int(i),y2+int(j),z2+int(k)) / div;
			}
		}
	}
	return noise;
}

float interp(float a, float b, float f)
{
    float f1 = f * 3.1415927;
    f1 = (1.0 - cos(f1)) * 0.5;
    return a*(1.0-f1) + b*f1;
}

float intnoise(float x1, float y1, float z1)
{
    int ix = int(x1);
    int iy = int(y1);
	int iz = int(z1);
    float fx = x1-float(ix);
    float fy = y1-float(iy);
	float fz = z1-float(iz);

    float v1 = smoothnoise(ix,iy,iz);
    float v2 = smoothnoise(ix,iy+1,iz);
	float v3 = smoothnoise(ix,iy,iz+1);
	float v4 = smoothnoise(ix,iy+1,iz+1);
	float v5 = smoothnoise(ix+1,iy,iz);
    float v6 = smoothnoise(ix+1,iy+1,iz);
	float v7 = smoothnoise(ix+1,iy,iz+1);
    float v8 = smoothnoise(ix+1,iy+1,iz+1);

    float i1 = interp(v1, v2, fy);
    float i2 = interp(v3, v4, fy);
	float i3 = interp(v5, v6, fy);
    float i4 = interp(v7, v8, fy);
	
    float i5=interp(i1, i2, fz);
	float i6=interp(i3, i4, fz);
	
	float i7=interp(i5, i6, fx);

    return i7;
}

float noise3D(float x, float y, float z)
{
    float total = 0.0;
    for(float i=0.0; i<8.0; i++) // octaves = 4
    {
        float freq = pow(2.0,i);
        float amp = pow(0.5,i); // persistence = 0.25
        total += intnoise(x * freq*4.0, y* freq*4.0, z * freq*4.0) * amp;
    }
//	float minval=0.0, maxval=0.99;
//	if(total<minval)
//		total = minval;
//	if(total>maxval)
//		total = maxval;
//	total=(total-minval)/(maxval-minval);
    return total;
}


void main() {
    vUv = uv;
	
	//col=abs(normal);
	
	float tx,ty,tz;
	//tx=fract(sin(time)); //1D noise based on time..
	//ty=fract(sin(time*13.0+789221.0)); //1D noise based on time..
	//tz=fract(sin(time*29.0+15731.0)); //1D noise based on time..
	
	tx=time; ty=time; tz=time;
	float n = noise3D((tx+position.x),(ty+position.y),(tz+position.z));
	
	int ind = int(n*1024.0/75.0);
	float d = float(data[ind])/255.0;
	
	vec3 pos = (n)*normal;
	
	//col=abs(normalize(vec3(pos)));
	//col=abs(vec3(n,1-n,1-n));
	//pos += vec3(d,d,d);
	
	col=abs(mix(vec3(1,1,1),vec3(1.0-d,0,0.0),n));
    gl_Position= projectionMatrix * modelViewMatrix * vec4( pos, 1.0 );
}



































