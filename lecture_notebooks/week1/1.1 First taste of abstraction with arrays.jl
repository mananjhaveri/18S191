### A Pluto.jl notebook ###
# v0.12.4

using Markdown
using InteractiveUtils

# ╔═╡ 66a48c20-12c1-11eb-325f-659ab9ad06a1
md"# First taste of abstraction with arrays"

# ╔═╡ 25f43990-12c2-11eb-3701-c305acad7412
md"### Import libraries"

# ╔═╡ 30a89790-12c3-11eb-13b9-155e158aa603
import Pkg

# ╔═╡ e651ca00-12c1-11eb-158a-cf7c8138fd63
begin
	Pkg.add("ImageMagick")
	using Images
end

# ╔═╡ 2fbd69ae-12c2-11eb-0d60-bb362214c171
md"### Arrays"

# ╔═╡ db36d010-12c2-11eb-372b-2fc29589aefa
element = [1 3
	2 4]

# ╔═╡ e57493f0-12c2-11eb-3a6a-cd6614923d7d
fill(element, 5, 7)

# ╔═╡ f1f19970-12c2-11eb-0235-1db2a4a360fa
typeof(element)

# ╔═╡ 1790cb60-12c3-11eb-1ab2-4b21d829fff5
one_plus = load(download("https://upload.wikimedia.org/wikipedia/commons/thumb/7/75/Oneplus_Bullets_Wireless_Earphones.jpg/330px-Oneplus_Bullets_Wireless_Earphones.jpg"))

# ╔═╡ fc6cb470-12c2-11eb-2063-1d47284ae076
keeptrack = [typeof(1) typeof(1.0) typeof("one") typeof(1 // 1) typeof([1 3; 2 4]) typeof(one_plus)]

# ╔═╡ Cell order:
# ╟─66a48c20-12c1-11eb-325f-659ab9ad06a1
# ╟─25f43990-12c2-11eb-3701-c305acad7412
# ╠═30a89790-12c3-11eb-13b9-155e158aa603
# ╠═e651ca00-12c1-11eb-158a-cf7c8138fd63
# ╟─2fbd69ae-12c2-11eb-0d60-bb362214c171
# ╠═db36d010-12c2-11eb-372b-2fc29589aefa
# ╠═e57493f0-12c2-11eb-3a6a-cd6614923d7d
# ╠═f1f19970-12c2-11eb-0235-1db2a4a360fa
# ╠═fc6cb470-12c2-11eb-2063-1d47284ae076
# ╠═1790cb60-12c3-11eb-1ab2-4b21d829fff5
