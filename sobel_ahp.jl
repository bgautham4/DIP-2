### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ f42a8cae-bbff-11ed-1e2a-a7a0cfe4900e
let
	using Pkg
	Pkg.activate(".")
end

# ╔═╡ ceaf923a-7b74-448c-85c6-f9fcef234a95
using Images,TestImages

# ╔═╡ c8f41da7-330f-4b8c-bca1-229d1572c3c4
using PlutoUI

# ╔═╡ 3915acc3-a850-4aee-ad42-bde0fdefc627
md"""
# Gautham B
## PES1UG20EC044
"""

# ╔═╡ 74612fef-292a-409d-8768-cec547c88d3a
md"## 1)Sobel operator"

# ╔═╡ bfeba819-4387-4f36-a9cb-46a960c4e9e0
camera = testimage("cameraman")

# ╔═╡ cffb13bc-1e8e-4aca-ba5a-d22ef0dd6890
dy,dx = 16 .* (Kernel.sobel())

# ╔═╡ dba28093-2dc2-4e17-8b06-cd65411ac112
@bind threshold Slider(0:0.01:3, show_value = true)

# ╔═╡ 536357b6-9822-4de3-bcd0-45a2f0437a34
sobel = let
	δx = imfilter(camera,dx)
	δy = imfilter(camera,dy)
	Grad = .√(δx .^ 2  .+ δy .^ 2)
	map(Grad) do x
		x > threshold ? Gray(1) : Gray(0)
	end
end

# ╔═╡ 25455754-7101-48cf-8cf4-b19f0828ab3b
md"## 2)Robert's operator"

# ╔═╡ 6c048588-2de4-414d-8eb4-d313aa3a86cc
Gx,Gy = [1 0;0 -1], [0 1;-1 0]

# ╔═╡ dd5986b2-aa02-4ef0-aadb-907eebe5f854
coins = Gray.(load("coins.png"))

# ╔═╡ 5d3285b0-8740-4540-9530-9c33f6e8b621
roberts_coins = let
	δx = imfilter(coins,Gx)
	δy = imfilter(coins,Gy)
	Grad = .√(δx .^ 2  .+ δy .^ 2)
end

# ╔═╡ be4085a2-1c1a-4013-b56e-a5452252b97b
reoberts_camera = let
	δx = imfilter(camera,Gx)
	δy = imfilter(camera,Gy)
	Grad = .√(δx .^ 2  .+ δy .^ 2)
end

# ╔═╡ 7e3ada8a-0dc7-429f-a5d2-4341c787b333
md"""## Inference: 
	The Robert's operator is computationally simpler due its kernel size of 2x2. The sobel Kernel is a more complex operator and hence is less sensitive to noise. """

# ╔═╡ Cell order:
# ╟─3915acc3-a850-4aee-ad42-bde0fdefc627
# ╠═f42a8cae-bbff-11ed-1e2a-a7a0cfe4900e
# ╠═ceaf923a-7b74-448c-85c6-f9fcef234a95
# ╟─74612fef-292a-409d-8768-cec547c88d3a
# ╠═bfeba819-4387-4f36-a9cb-46a960c4e9e0
# ╠═cffb13bc-1e8e-4aca-ba5a-d22ef0dd6890
# ╠═c8f41da7-330f-4b8c-bca1-229d1572c3c4
# ╟─dba28093-2dc2-4e17-8b06-cd65411ac112
# ╠═536357b6-9822-4de3-bcd0-45a2f0437a34
# ╟─25455754-7101-48cf-8cf4-b19f0828ab3b
# ╠═6c048588-2de4-414d-8eb4-d313aa3a86cc
# ╠═dd5986b2-aa02-4ef0-aadb-907eebe5f854
# ╠═5d3285b0-8740-4540-9530-9c33f6e8b621
# ╠═be4085a2-1c1a-4013-b56e-a5452252b97b
# ╟─7e3ada8a-0dc7-429f-a5d2-4341c787b333
