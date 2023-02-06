mutable struct ENode
	symbol::String
	p_node::Real
	encoded_val::String
	prev_node1::Union{ENode,Nothing}
	prev_node2::Union{ENode,Nothing}
end

function ENode(symbol::String,prob::Real, prev_node1::Union{ENode,Nothing}, prev_node2::Union{ENode,Nothing})
	ENode(symbol,prob,"0",prev_node1,prev_node2)
end

function Base.show(io::IO, x::ENode)
	print(io,"ENode(symbol = $(x.symbol),pnode = $(x.p_node),encoding = $(x.encoded_val))")
end

#Initialize the nodes
function init_nodes(symbol_probs::Vector)
	sorted_symbol_probs = sort(symbol_probs, by = x->x[2], rev=true)
	ENode_arr = Vector{ENode}()
	for (symbol,prob) in sorted_symbol_probs
		push!(ENode_arr,ENode(symbol,prob,nothing,nothing))
	end
	return ENode_arr
end

#Form the encoding tree
function encoding_tree(nodes::Vector{ENode})
	if length(nodes) == 2
		nodes = sort(nodes,by = x->x.p_node,rev=true)
		nodes[1].encoded_val = "0"
		nodes[2].encoded_val = "1"
		return nodes
	else
		new_nodes = Vector{ENode}()
		for node_indx in 1:length(nodes) - 2
			node = nodes[node_indx]
			push!(new_nodes,ENode(node.symbol,node.p_node,node,nothing))
		end
		last_node = nodes[end]
		last_2_node = nodes[end-1]
		p_new_node = round(last_node.p_node + last_2_node.p_node,digits = 5)
		symbol_new_node = last_node.symbol * last_2_node.symbol
		push!(new_nodes,ENode(symbol_new_node,p_new_node,last_2_node,last_node))
		sort(new_nodes, by = x->x.p_node, rev = true) |> encoding_tree
	end
end

#Use the encoding tree to assign the encoded values to the nodes until you reach the base(init) nodes.
function assign_encoding(nodes::Vector{ENode})
	nodes_upd = copy(nodes)
	while length(nodes_upd) != 0
		nodes = copy(nodes_upd)
		for node in nodes
			prev_node1 = node.prev_node1
			prev_node2 = node.prev_node2
			if (~isequal(prev_node1,nothing) && isequal(prev_node2,nothing))
				prev_node1.encoded_val = node.encoded_val
				push!(nodes_upd,prev_node1)
			end

			if (~isequal(prev_node1,nothing) && ~isequal(prev_node2,nothing))
				prev_node1.encoded_val = (node.encoded_val * "0")
				push!(nodes_upd,prev_node1)
				prev_node2.encoded_val = (node.encoded_val * "1")
				push!(nodes_upd,prev_node2)
			end
			
			nodes_upd = filter(x -> ~isequal(node,x),nodes_upd)
		end
	end
end

#Huffman encoding of the symbols given their probabilities
function huffman_encoding(symbol_probs::Vector)
	nodes = init_nodes(symbol_probs)
	nodes |> encoding_tree |> assign_encoding
	println("The encodings are $(nodes)")
end

#test case
symbol_probs = [("a1",0.1),("a2",0.4),("a3",0.06),("a4",0.1),("a5",0.04),("a6",0.3)]
huffman_encoding(symbol_probs)
