### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ ad95b8e0-bc2f-11ed-080f-09dd16f257f8
let
	using Pkg
	Pkg.activate(".")
end

# ╔═╡ 93de013d-699b-405d-a7d9-7388d13c3a88
using Images,TestImages

# ╔═╡ 186a845c-089a-412c-9e72-05f65bc4e4d9
md"""
# Gautham B
## PES1UG20EC044
"""

# ╔═╡ b780fd19-88f7-4cce-978d-0d7b8f04f274
md"## Definitions for custom functions: Convolution,Gaussian kernel and padding"

# ╔═╡ ef2c2a7c-c835-4b37-b894-6ce7cdfc80ad
function pad_img(img::Matrix{T},i,j) where T
	M,N = size(img)
	i>=1 && j>=1 ? i<=M && j<=N ? img[i,j] : zero(T) : zero(T)
end

# ╔═╡ 5ae8e7fb-0ad2-46ac-8a9f-780bc01ffc3b
function my_convolve(img::Matrix{T},kernel::Matrix) where T<:AbstractGray
	m,n = size(kernel)
	kernel = rot180(kernel)
	k,l = (m-1)÷2, (n-1)÷2
	M,N = size(img)
	convolved_img = zeros(T,(M,N))
	for (x,y) in Iterators.product(1:M,1:N)
		S = [pad_img(img,p,q) for (p,q) in Iterators.product(x-k:x+k,y-l:y+l)]
		S .= S .* kernel
		convolved_img[x,y] = sum(S)
	end
	convolved_img
end	

# ╔═╡ 4e3cc62d-c55b-4452-96bd-36eec813789b
function generate_gaussian_kernel(N::Int, var::Float64)
    kernel = zeros(Float64, N, N)
    center = (N+1)÷2
    for i = 1:N
        for j = 1:N
            x = i - center
            y = j - center
            kernel[i,j] = exp(-(x^2+y^2)/(2*var))
        end
    end

    # Normalize kernel to sum to 1
    kernel ./= sum(kernel)

    return kernel
end

# ╔═╡ 24464a30-44a4-4123-bbe0-d134425a0630
camera = convert.(Gray{Float64},testimage("camera"))

# ╔═╡ 61c60a96-8b1d-4233-8b4c-fd5d28b2219a
md"## Prewitt's operator"

# ╔═╡ bb6645e5-7200-4f51-957c-0faf348be2bf
δx,δy = [1 0 -1;1 0 -1;1 0 -1],[1 1 1;0 0 0;-1 -1 -1]

# ╔═╡ de17cb9e-79aa-4456-ae16-3e80bd2b1742
result_prew = let
	Gx = my_convolve(camera,δx)
	Gy = my_convolve(camera,δy)
	G = .√(Gx .^ 2 + Gy .^ 2)
end

# ╔═╡ 1199a9e8-9dc3-43cf-ab9d-5a7f89614436
md"## Canny's operator"

# ╔═╡ 5fae8321-fbd3-41a5-8383-343c6e855a92
md"""The Canny operator involves 5 steps(step 5 is not performed here)
1)Gaussian filter to smoothen and remove noise.

2)Finding the intensity gradient of the image.(Can use sobel,prewitt's etc)

3)Gradient magnitude thresholding or lower bound cut-off suppression.

4)Double threshold.

5)Edge tracking by hysteresis. *
"""

# ╔═╡ 87096ac1-d79f-4dc1-9efc-210cf8e710ac
md"## Step 1"

# ╔═╡ eb58e64e-0500-4607-9766-8342c05c5ef6
begin
	Gaussian  = generate_gaussian_kernel(5,1.4)
	step1 = my_convolve(camera,Gaussian)
end

# ╔═╡ 5d9bf9cf-be14-459d-827e-04669732efdc
md"## Step 2"

# ╔═╡ 413a6385-895f-4287-a105-a324bebba63a
edge_detect, angles = let
	δx,δy = [1 0 -1;2 0 -2;1 0 -1],[1 2 1;0 0 0;-1 -2 -1]
	Gx = my_convolve(step1,δx)
	Gy = my_convolve(step1,δy)
	G = .√(Gx .^2 .+ Gy .^2)
	angles = [atan(gy,gx) for (gx,gy) in zip(Gx,Gy)]
	angles .= map(angles) do x
		x<45*π/180 ? 0 : x<90*π/180 ? 45 : x<135*π/180 ? 90 : 135
	end
	G,angles
end

# ╔═╡ 56317cab-05aa-425c-8730-1c90e033041d
edge_detect

# ╔═╡ f91f69e8-9ad1-4fbf-8bbf-01296a3125ce
md"## Step 3"

# ╔═╡ f5a1f765-0837-40ff-a95e-e1b482a43aa6
begin
	M,N = size(camera)
	step3 = zeros(Gray{Float64},(M,N))
	for (x,y) in Iterators.product(1:M,1:N)
		neighbourhood = [pad_img(edge_detect,p,q) for (p,q) in Iterators.product(x-1:x+1,y-1:y+1)]
		if angles[x,y] == 0
			 _,k = findmax([neighbourhood[2,1],neighbourhood[2,2],neighbourhood[2,3]])
			k==2 ? step3[x,y] = neighbourhood[2,2] : step3[x,y] = zero(Gray{Float64})
			
		elseif angles[x,y]==45
 			_,k = findmax([neighbourhood[3,1],neighbourhood[2,2],neighbourhood[1,3]])
			k==2 ? step3[x,y] = neighbourhood[2,2] : step3[x,y] = zero(Gray{Float64})
			
		elseif angles[x,y]==90
			 _,k = findmax([neighbourhood[1,2],neighbourhood[2,2],neighbourhood[3,2]])
			k==2 ? step3[x,y] = neighbourhood[2,2] : step3[x,y] = zero(Gray{Float64})
			
		else
			 _,k = findmax([neighbourhood[1,1],neighbourhood[2,2],neighbourhood[3,3]])
			k==2 ? step3[x,y] = neighbourhood[2,2] : step3[x,y] = zero(Gray{Float64})
			
		end
	end
step3
end		

# ╔═╡ cada127d-d4e0-4d1c-a0bd-ea9e6459808a
md"## Step 4"

# ╔═╡ 40a412ed-9aad-4c9c-b6b6-bf9afa9e4d39
begin
	th1 = 0.5
	th2 = 1.5
	step4 = map(step3) do x
		x >th1 ? x : zero(Gray{Float64})
	end
step4
end

# ╔═╡ c460c19c-9ee2-476e-8065-e1d65b869f62
md"## Conclusions"

# ╔═╡ 0914991c-56d9-495c-bacb-d656a08545e8
[result_prew step4]

# ╔═╡ 040b992c-0423-4055-a64a-2f6fee15c243
md"""
Canny operator is a more complex process and is hence able to filter out uneccessary/weak edges caused due to noise. Hence we can conclude that Canny operator is superior.
"""

# ╔═╡ Cell order:
# ╟─186a845c-089a-412c-9e72-05f65bc4e4d9
# ╟─ad95b8e0-bc2f-11ed-080f-09dd16f257f8
# ╠═93de013d-699b-405d-a7d9-7388d13c3a88
# ╟─b780fd19-88f7-4cce-978d-0d7b8f04f274
# ╠═ef2c2a7c-c835-4b37-b894-6ce7cdfc80ad
# ╠═5ae8e7fb-0ad2-46ac-8a9f-780bc01ffc3b
# ╠═4e3cc62d-c55b-4452-96bd-36eec813789b
# ╠═24464a30-44a4-4123-bbe0-d134425a0630
# ╟─61c60a96-8b1d-4233-8b4c-fd5d28b2219a
# ╠═bb6645e5-7200-4f51-957c-0faf348be2bf
# ╠═de17cb9e-79aa-4456-ae16-3e80bd2b1742
# ╟─1199a9e8-9dc3-43cf-ab9d-5a7f89614436
# ╟─5fae8321-fbd3-41a5-8383-343c6e855a92
# ╟─87096ac1-d79f-4dc1-9efc-210cf8e710ac
# ╠═eb58e64e-0500-4607-9766-8342c05c5ef6
# ╟─5d9bf9cf-be14-459d-827e-04669732efdc
# ╠═413a6385-895f-4287-a105-a324bebba63a
# ╠═56317cab-05aa-425c-8730-1c90e033041d
# ╟─f91f69e8-9ad1-4fbf-8bbf-01296a3125ce
# ╠═f5a1f765-0837-40ff-a95e-e1b482a43aa6
# ╟─cada127d-d4e0-4d1c-a0bd-ea9e6459808a
# ╠═40a412ed-9aad-4c9c-b6b6-bf9afa9e4d39
# ╟─c460c19c-9ee2-476e-8065-e1d65b869f62
# ╟─0914991c-56d9-495c-bacb-d656a08545e8
# ╟─040b992c-0423-4055-a64a-2f6fee15c243
