### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 2092f1ce-f7fb-450c-bfdb-f17a9e87c428
let
	using Pkg
	Pkg.activate(".")
end

# ╔═╡ a5b64895-24d6-4bfb-8a41-f6b4ef2e3d9f
using Images,TestImages

# ╔═╡ 01e74b64-b9d3-41aa-9b69-6a191cfdd376
using Plots

# ╔═╡ 3177871f-382d-4da3-94e2-60d7450acb4b
include("huffman.jl")

# ╔═╡ 5af4f3e1-248f-4e11-9953-74d28a788152
md"# Gautham B
## PES1UG20EC044"

# ╔═╡ 381130eb-0b54-4a6f-82a2-f5397513d749
md"# Loading the image"

# ╔═╡ b99ff27d-a7b1-4cdd-9dcd-20fc5ed79f27
lena = let
	lena = testimage("lena_512")
	lena_resize = imresize(lena,(128,128))
end

# ╔═╡ 8a2ce1ea-d527-4a90-bdf1-cba6bed06c37
typeof(lena)

# ╔═╡ 574f5191-5312-4645-9c6e-90514683dc1d
md"# Converting the image to a matrix of integers"

# ╔═╡ 04fa5fac-0c13-465c-9661-005a55360ac1
lena_ints = convert.(Int64,rawview(convert.(N0f8,lena)))

# ╔═╡ c5cb56c4-6419-4592-ac0b-3e90bf592e03
md"# Finding the probability of occurance of each intensity level in the image"

# ╔═╡ f5417e20-e997-4626-adbe-fe2229939cc7
function pixel_probs(img::Union{Matrix{S},Matrix{Gray{T}}}) where T<:FixedPoint where S<:Integer
	N = prod(size(img))
	probs = Dict()
	for pix in img
		haskey(probs,pix) ? probs[pix] += 1/N : probs[pix] = 1/N
	end
	probs
end	

# ╔═╡ 66d9d013-b2f1-45d6-8327-04a8439d5e56
probs = pixel_probs(lena_ints)

# ╔═╡ 1116f49d-bd3f-483d-bd79-514b32c8612a
bar(probs)

# ╔═╡ 5038fd95-7932-40c7-ac15-8e34ef1c11eb
symbols = [(symbol,prob) for (symbol,prob) in probs]

# ╔═╡ dd3c8284-90ec-4604-98d1-d25f4d14dd8f
md"# Performing the Huffman encoding, given the symbol probabilities"

# ╔═╡ 2b12586a-ee26-4cd6-87df-1cb8acc6155e
begin
	codes_enc,codes_dec = huffman_encoding(symbols)
	display(codes_enc)
end

# ╔═╡ 2254ae4a-33d5-418e-a68f-aa5d70df1782
begin
	L_avg = 0
	H = 0
	for (symbol,prob) in symbols
		L_avg += prob * length(codes_enc[symbol])
		H += -log(2,prob) * prob
	end
end

# ╔═╡ d66bea50-739b-44e0-80d7-0d4924c627c6
begin
	println("The Entropy(Expected information) is $(H) bits/pixel")
	println("The L_average of the encoding is $(L_avg) bits/pixel")
end

# ╔═╡ 18fc2f85-9921-49da-aab6-c627f7a74843
md"## Performing encoding for transmission"

# ╔═╡ da928d51-6347-4b0c-bc63-6f18766b81af
begin
	encoded_seq = encode_sequence(codes_enc,vec(lena_ints))
	display(encoded_seq)
end

# ╔═╡ b7c2445e-3138-4cad-be93-8210551189d8
md"## Decoding the sequence at the receiver"

# ╔═╡ 978cb925-7e6b-4e6d-b698-4f22098d629d
decoded_seq = decode_sequence(codes_dec,encoded_seq)

# ╔═╡ f79d4c77-a816-48c3-b509-d083069ad638
md"## Reconstructing the image after decoding"

# ╔═╡ f8b1e1ea-1e64-4127-a059-2f259d48702f
Gray.(reshape(decoded_seq,(128,128)) ./ 255)

# ╔═╡ Cell order:
# ╟─5af4f3e1-248f-4e11-9953-74d28a788152
# ╠═2092f1ce-f7fb-450c-bfdb-f17a9e87c428
# ╠═a5b64895-24d6-4bfb-8a41-f6b4ef2e3d9f
# ╠═01e74b64-b9d3-41aa-9b69-6a191cfdd376
# ╟─381130eb-0b54-4a6f-82a2-f5397513d749
# ╠═b99ff27d-a7b1-4cdd-9dcd-20fc5ed79f27
# ╠═8a2ce1ea-d527-4a90-bdf1-cba6bed06c37
# ╟─574f5191-5312-4645-9c6e-90514683dc1d
# ╠═04fa5fac-0c13-465c-9661-005a55360ac1
# ╟─c5cb56c4-6419-4592-ac0b-3e90bf592e03
# ╠═f5417e20-e997-4626-adbe-fe2229939cc7
# ╠═66d9d013-b2f1-45d6-8327-04a8439d5e56
# ╠═1116f49d-bd3f-483d-bd79-514b32c8612a
# ╠═5038fd95-7932-40c7-ac15-8e34ef1c11eb
# ╟─dd3c8284-90ec-4604-98d1-d25f4d14dd8f
# ╠═3177871f-382d-4da3-94e2-60d7450acb4b
# ╠═2b12586a-ee26-4cd6-87df-1cb8acc6155e
# ╠═2254ae4a-33d5-418e-a68f-aa5d70df1782
# ╟─d66bea50-739b-44e0-80d7-0d4924c627c6
# ╟─18fc2f85-9921-49da-aab6-c627f7a74843
# ╠═da928d51-6347-4b0c-bc63-6f18766b81af
# ╟─b7c2445e-3138-4cad-be93-8210551189d8
# ╠═978cb925-7e6b-4e6d-b698-4f22098d629d
# ╟─f79d4c77-a816-48c3-b509-d083069ad638
# ╠═f8b1e1ea-1e64-4127-a059-2f259d48702f
