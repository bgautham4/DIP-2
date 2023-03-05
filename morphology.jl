### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 55d3af3e-b40e-11ed-3576-113bbb77199b
let
	using Pkg
	Pkg.activate(".")
end

# ╔═╡ 27f17e4b-5ba5-46df-964e-d95676c8c6bc
using Images,TestImages,ImageMorphology

# ╔═╡ 2ec0752a-1511-4260-87de-ccdb3785b371
camera = testimage("cameraman")

# ╔═╡ e6802925-4936-4214-abe1-b850806268e4


# ╔═╡ fade63e4-8e6a-4937-b86f-a04499030c3c
lena = testimage("lena_512")

# ╔═╡ 8274aae1-37b4-4fea-88fc-a3ffdb724b47
begin
	offset_se = let
		a = zeros(Bool,5,5)
		a[1:3,1:3] .= 1
		a|> centered
	end
	box_se = strel_box((5,5))
	diamond_se = strel_diamond((5,5))
	Gray.(offset_se),Gray.(box_se),Gray.(diamond_se)
end

# ╔═╡ fe5eb3da-2492-4639-acd2-01cb3dd94061
[dilate(lena,offset_se) dilate(lena,diamond_se) dilate(lena,box_se)]

# ╔═╡ 93755c9a-eaff-4f94-9af7-59a9f2a3fe03
[dilate(camera,offset_se) dilate(camera,diamond_se) dilate(camera,box_se)]

# ╔═╡ f437ba05-6954-41be-84b7-c546fcbd50bb
[erode(lena,offset_se) erode(lena,diamond_se) erode(lena,box_se)]

# ╔═╡ 9218a4a5-2a76-4387-a394-b7cb6a7cbaad
[erode(camera,offset_se) erode(camera,diamond_se) erode(camera,box_se)]

# ╔═╡ 3033ade9-9716-4a4f-a491-54e0b2c1c269
[opening(lena,offset_se) opening(lena,diamond_se) opening(lena,box_se)]

# ╔═╡ 13bb1ed8-7b1d-476e-95cd-a59b08813273
[opening(camera,offset_se) opening(camera,diamond_se) opening(camera,box_se)]

# ╔═╡ 94e53532-d16e-4fb8-98d4-a2ce0c121bef
[closing(lena,offset_se) closing(lena,diamond_se) closing(lena,box_se)]

# ╔═╡ ac3af268-942d-49d9-aa77-a1dce5cb3c80
[closing(camera,offset_se) closing(camera,diamond_se) closing(camera,box_se)]

# ╔═╡ Cell order:
# ╠═55d3af3e-b40e-11ed-3576-113bbb77199b
# ╠═27f17e4b-5ba5-46df-964e-d95676c8c6bc
# ╠═2ec0752a-1511-4260-87de-ccdb3785b371
# ╠═e6802925-4936-4214-abe1-b850806268e4
# ╠═fade63e4-8e6a-4937-b86f-a04499030c3c
# ╠═8274aae1-37b4-4fea-88fc-a3ffdb724b47
# ╠═fe5eb3da-2492-4639-acd2-01cb3dd94061
# ╠═93755c9a-eaff-4f94-9af7-59a9f2a3fe03
# ╠═f437ba05-6954-41be-84b7-c546fcbd50bb
# ╠═9218a4a5-2a76-4387-a394-b7cb6a7cbaad
# ╠═3033ade9-9716-4a4f-a491-54e0b2c1c269
# ╠═13bb1ed8-7b1d-476e-95cd-a59b08813273
# ╠═94e53532-d16e-4fb8-98d4-a2ce0c121bef
# ╠═ac3af268-942d-49d9-aa77-a1dce5cb3c80
