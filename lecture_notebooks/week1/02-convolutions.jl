### A Pluto.jl notebook ###
# v0.12.4

using Markdown
using InteractiveUtils

# ╔═╡ 7c479f80-1367-11eb-227c-db5b6272834d
begin
	using Statistics
	using Images
	using FFTW
	using Plots
	using DSP
	using ImageFiltering
	using PlutoUI
end

# ╔═╡ 42ed52ba-ed34-11ea-26b5-05379824cbc0
md"""
# Convolutions with various kernels
"""

# ╔═╡ 4c13d558-ee15-11ea-2ed9-c5fb90d93881
kernel = Kernel.gaussian((2, 2))

# ╔═╡ 673f7ac0-ee16-11ea-35d0-cf3da430b843
sum(kernel)

# ╔═╡ f569dbbe-137c-11eb-2ba7-2d99bbe3e571
kernel_sharp = centered([
		-0.5 -1.0 -0.5
		-1.0  7.0 -1.0
		-0.5 -1.0 -0.5])

# ╔═╡ 2d17f050-137f-11eb-1148-5b9b00746406
sum(kernel_sharp)

# ╔═╡ 877075f0-1383-11eb-0cbe-636f4b1523c2
md"### Sobel"

# ╔═╡ 992367d0-1383-11eb-24c3-0be4b9cd6e40
kernel_sobel = Kernel.sobel()[2]

# ╔═╡ fdbda5c0-1383-11eb-2346-8b321f2a3740
sum(kernel_sobel)

# ╔═╡ fe541b92-1392-11eb-043e-1921dab4c223
md"""
# Zebra
"""

# ╔═╡ 69a11420-138e-11eb-08fb-157dee168c87
zebra_kernel = Kernel.gaussian((2, 2))

# ╔═╡ 9c90feb8-ec79-11ea-2870-31be5cedff43
md"""
# Function definitions
"""

# ╔═╡ 84e6a57c-edfc-11ea-01a0-157f1df77518
function show_colored_kernel(kernel)
	to_rgb(x) = RGB(max(-x, 0), max(x, 0), 0)
	to_rgb.(kernel) / maximum(abs.(kernel))
end

# ╔═╡ 9424b46a-ee16-11ea-1819-f17ce53e9997
show_colored_kernel(kernel)

# ╔═╡ acbe2c7e-1383-11eb-3bc3-5514c6398aee
show_colored_kernel(kernel_sobel)

# ╔═╡ 68f2afec-eca2-11ea-0758-2f22c7afdd94
function decimate(arr, ratio=5)
	return arr[1:ratio:end, 1:ratio:end]
end

# ╔═╡ aa3b9bd6-ed35-11ea-1bdc-33861bdbd29a
function shrink_image(image, ratio=5)
	(height, width) = size(image)
	new_height = height ÷ ratio - 1
	new_width = width ÷ ratio - 1
	list = [
		mean(image[
			ratio * i:ratio * (i + 1),
			ratio * j:ratio * (j + 1),
		])
		for j in 1:new_width
		for i in 1:new_height
	]
	reshape(list, new_height, new_width)
end

# ╔═╡ 6d39fea8-ed3c-11ea-3d7c-3f62ca91ce23
begin
	large_image = load("philip.jpg")
	image = shrink_image(large_image, 7)
end

# ╔═╡ cc9c8440-1390-11eb-3a81-2f31e4f069d1
size(large_image)

# ╔═╡ 2f446dcc-ee15-11ea-0e78-931ff507b5e5
size(image)

# ╔═╡ 14d5b144-ee18-11ea-0080-c187f068c168
image

# ╔═╡ 8cb52e60-138e-11eb-2085-2bf18281333d
begin
	big_zebra = load("zebra.jpg")
	zebra = shrink_image(big_zebra, 7)
end

# ╔═╡ 160eb236-eca1-11ea-1dbe-47ad61cc9397
function rgb_to_float(color)
    return mean([color.r, color.g, color.b])
end

# ╔═╡ fa3c5074-eca0-11ea-2d2d-bb6bcdeb834c
function fourier_spectrum_magnitudes(img)
    grey_values = rgb_to_float.(img)
    spectrum = fftshift(fft(grey_values))
	return abs.(spectrum)
end

# ╔═╡ e40d807e-ed3a-11ea-2340-7f98bd5d04a2
function plot_1d_fourier_spectrum(img, dims=1)
	spectrum = fourier_spectrum_magnitudes(img)
	plot(centered(mean(spectrum, dims=1)[1:end]))
end

# ╔═╡ 698798b0-138e-11eb-2f47-e3fabcffa3ce
plot_1d_fourier_spectrum(zebra)

# ╔═╡ beb6b4b0-eca1-11ea-1ece-e3c9931c9c13
function heatmap_2d_fourier_spectrum(img)
	heatmap(log.(fourier_spectrum_magnitudes(img)))
end

# ╔═╡ 18045956-ee18-11ea-3e34-612133e2e39c
heatmap_2d_fourier_spectrum(image)

# ╔═╡ 03a93aa0-1391-11eb-3298-5975ea66c040
heatmap_2d_fourier_spectrum(zebra)

# ╔═╡ 58f4754e-ed31-11ea-0464-5bfccf397966
function clamp_at_boundary(M, i, j)
	return M[
		clamp(i, 1, size(M, 1)),
		clamp(j, 1, size(M, 2)),	
	]
end

# ╔═╡ f28af11e-ed31-11ea-2b46-7dff147ccb48
function rolloff_boundary(M, i, j)
	if (1 ≤ i ≤ size(M, 1)) && (1 ≤ j ≤ size(M, 2))
		return M[i, j]
	else
		return 0 * M[1, 1]
	end
end

# ╔═╡ 572cf620-ecb2-11ea-0019-21666a30d9d2
function convolve(M, kernel, M_index_func=clamp_at_boundary)
    height = size(kernel, 1)
    width = size(kernel, 2)
    
    half_height = height ÷ 2
    half_width = width ÷ 2
    
    new_image = similar(M)
	
    # (i, j) loop over the original image
    @inbounds for i in 1:size(M, 1)
        for j in 1:size(M, 2)
            # (k, l) loop over the neighbouring pixels
			new_image[i, j] = sum([
				kernel[k, l] * M_index_func(M, i - k, j - l)
				for k in -half_height:-half_height + height - 1
				for l in -half_width:-half_width + width - 1
			])
        end
    end
    
    return new_image
end

# ╔═╡ 43ea9960-137d-11eb-283d-19836f9ff446
sharp_image = convolve(image, kernel_sharp)

# ╔═╡ fe131590-137f-11eb-295b-9fefa2f766a3
heatmap_2d_fourier_spectrum(sharp_image)

# ╔═╡ 5afed4ea-ee18-11ea-1aa4-abca154b3793
conv_image = convolve(image, kernel)

# ╔═╡ 6340c0f8-ee18-11ea-1765-45f4bc140670
heatmap_2d_fourier_spectrum(conv_image)

# ╔═╡ 840a9930-1384-11eb-20da-996d28cfa739
3 * Gray.(abs.(convolve(image, kernel_sobel)))

# ╔═╡ 03503010-138f-11eb-26c7-6385e31728f3
conv_zebra = convolve(zebra, zebra_kernel)

# ╔═╡ 7f742020-138f-11eb-1e63-77c26e4a0966
plot_1d_fourier_spectrum(conv_zebra)

# ╔═╡ 11b36fd0-1391-11eb-25ba-b9b29a508657
heatmap_2d_fourier_spectrum(conv_zebra)

# ╔═╡ 587092e4-ecb2-11ea-18fc-ad5e9778fb30
box_blur(n) = centered(ones(n, n) ./ (n^2))

# ╔═╡ 991cb9b8-ecb8-11ea-3f80-5d95b2200259
function gauss_blur(n, sigma=0.25)
	kern = gaussian((n, n), sigma)
	return kern / sum(kern)
end

# ╔═╡ Cell order:
# ╟─42ed52ba-ed34-11ea-26b5-05379824cbc0
# ╠═6d39fea8-ed3c-11ea-3d7c-3f62ca91ce23
# ╠═cc9c8440-1390-11eb-3a81-2f31e4f069d1
# ╠═2f446dcc-ee15-11ea-0e78-931ff507b5e5
# ╠═4c13d558-ee15-11ea-2ed9-c5fb90d93881
# ╠═9424b46a-ee16-11ea-1819-f17ce53e9997
# ╠═673f7ac0-ee16-11ea-35d0-cf3da430b843
# ╠═f569dbbe-137c-11eb-2ba7-2d99bbe3e571
# ╠═43ea9960-137d-11eb-283d-19836f9ff446
# ╠═2d17f050-137f-11eb-1148-5b9b00746406
# ╠═fe131590-137f-11eb-295b-9fefa2f766a3
# ╠═14d5b144-ee18-11ea-0080-c187f068c168
# ╠═18045956-ee18-11ea-3e34-612133e2e39c
# ╠═5afed4ea-ee18-11ea-1aa4-abca154b3793
# ╠═6340c0f8-ee18-11ea-1765-45f4bc140670
# ╟─877075f0-1383-11eb-0cbe-636f4b1523c2
# ╠═992367d0-1383-11eb-24c3-0be4b9cd6e40
# ╠═acbe2c7e-1383-11eb-3bc3-5514c6398aee
# ╠═fdbda5c0-1383-11eb-2346-8b321f2a3740
# ╠═840a9930-1384-11eb-20da-996d28cfa739
# ╟─fe541b92-1392-11eb-043e-1921dab4c223
# ╠═8cb52e60-138e-11eb-2085-2bf18281333d
# ╠═698798b0-138e-11eb-2f47-e3fabcffa3ce
# ╠═03a93aa0-1391-11eb-3298-5975ea66c040
# ╠═69a11420-138e-11eb-08fb-157dee168c87
# ╠═03503010-138f-11eb-26c7-6385e31728f3
# ╠═7f742020-138f-11eb-1e63-77c26e4a0966
# ╠═11b36fd0-1391-11eb-25ba-b9b29a508657
# ╟─9c90feb8-ec79-11ea-2870-31be5cedff43
# ╠═7c479f80-1367-11eb-227c-db5b6272834d
# ╠═84e6a57c-edfc-11ea-01a0-157f1df77518
# ╠═68f2afec-eca2-11ea-0758-2f22c7afdd94
# ╠═aa3b9bd6-ed35-11ea-1bdc-33861bdbd29a
# ╠═160eb236-eca1-11ea-1dbe-47ad61cc9397
# ╠═fa3c5074-eca0-11ea-2d2d-bb6bcdeb834c
# ╠═e40d807e-ed3a-11ea-2340-7f98bd5d04a2
# ╠═beb6b4b0-eca1-11ea-1ece-e3c9931c9c13
# ╠═58f4754e-ed31-11ea-0464-5bfccf397966
# ╠═f28af11e-ed31-11ea-2b46-7dff147ccb48
# ╠═572cf620-ecb2-11ea-0019-21666a30d9d2
# ╠═587092e4-ecb2-11ea-18fc-ad5e9778fb30
# ╠═991cb9b8-ecb8-11ea-3f80-5d95b2200259
