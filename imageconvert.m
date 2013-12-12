/* Copyright (c) 2011 Scott Lembcke and Howling Moon Software
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#import <unistd.h>

#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[])
{
	if(argc != 4){
		printf("usage: imageconvert <scale> <infile> <outfile>\n");
		abort();
	}
	
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init]; {
		NSString* in_path = [NSString stringWithCString:argv[2] encoding:NSUTF8StringEncoding];
		CFURLRef in_url = (CFURLRef)[NSURL fileURLWithPath:in_path];
		
		CGImageSourceRef image_source = CGImageSourceCreateWithURL(in_url, NULL);
		CGImageRef image = CGImageSourceCreateImageAtIndex(image_source, 0, NULL);
		
		NSString* out_path = [NSString stringWithCString:argv[3] encoding:NSUTF8StringEncoding];
		CFURLRef out_url = (CFURLRef)[NSURL fileURLWithPath:out_path];
		CFStringRef out_extension = (CFStringRef)[out_path pathExtension];
		CFStringRef out_type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, out_extension, NULL);
		
		CGImageRef out_image = image;
		
		double scale = 1.0;
		sscanf(argv[1], "%lf", &scale);
		
		if(scale != 1.0){
			size_t width = CGImageGetWidth(image)*scale;
			size_t height = CGImageGetHeight(image)*scale;
			size_t bpc = 8;
			size_t bpp = 32;
			size_t stride = width*((bpp + 7)/8);
			CGColorSpaceRef colorspace = CGImageGetColorSpace(image);
			CGBitmapInfo bitmap_info = CGImageGetBitmapInfo(image)&kCGBitmapAlphaInfoMask;
			
			if(bitmap_info == kCGImageAlphaNone) bitmap_info = kCGImageAlphaNoneSkipLast;
			
			void *buffer = calloc(height, stride);
			CGContextRef context = CGBitmapContextCreate(buffer, width, height, bpc, stride, colorspace, bitmap_info);
			
			CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
			CGContextDrawImage(context, CGRectMake(0.0, 0.0, width, height), image);
			
			CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, buffer, stride*height, NULL);
			out_image = CGImageCreate(width, height, bpc, bpp, stride, colorspace, bitmap_info, dataProvider, NULL, false, kCGRenderingIntentDefault);
		}
		
		CGImageDestinationRef image_destination = CGImageDestinationCreateWithURL(out_url, out_type, 1, NULL);
		CGImageDestinationAddImage(image_destination, out_image, NULL);
		CGImageDestinationFinalize(image_destination);
	}[pool release];
	
	return EXIT_SUCCESS;
}
